include 'emu8086.inc'
org 100h

                        ; Macro to output strings using DOS string functions
PRINT_MSG MACRO msg
    PUSH AX             ; save value of ax on stack
    PUSH DX             ; save value of dx on stack
    MOV AH, 09h
    LEA DX, msg         ; load memory address of msg into dx
    INT 21h
    POP DX              ; restore value of dx from stack
    POP AX              ; restore value of ax from stack
ENDM

                        ; Macro to clear screen and set background color
CLEAR_SCREEN MACRO
    MOV AH, 06h         ; Scroll up window function
    MOV AL, 0           ; Clear entire screen area
    MOV BH, 5Fh         ; Attribute: Pink/Magenta background (5), White text (F)
    MOV CX, 0           ; Upper left corner (0,0)
    MOV DX, 369Fh       ; Lower right corner expanded (Row 54, Column 159)
    INT 10h             ; Video Interrupt Call
     
    MOV AH, 02h         ; Reset cursor position to top-left
    MOV BH, 0           ; BH = page number 0
    MOV DX, 0           ; DH = row 0, DL = column 0 
    INT 10h
ENDM
; =====================================================================================

.data

welcome  db '================================================', 0Dh, 0Ah
         db '      CRYPTOGRAPHY SYSTEM - 8086 PROJECT        ', 0Dh, 0Ah
         db '      ----------------------------------        ', 0Dh, 0Ah
         db '    Developed by: Maryum, Alisha & Madeeha       ', 0Dh, 0Ah
         db '================================================', 0Dh, 0Ah, '$'

menu     db 0Dh, 0Ah   
         db '            MENU             ', 0Dh, 0Ah  
         db '============================', 0Dh, 0Ah
         db ' [ E ] -> Encrypt a Message', 0Dh, 0Ah
         db ' [ D ] -> Decrypt a Message', 0Dh, 0Ah
         db ' [ X ] -> Exit System', 0Dh, 0Ah, 0Dh, 0Ah
         db ' Please select an option (E/D/X): $'

msg_key      db 0Dh, 0Ah, ' Enter encryption key (1-5): $'
encrypt      db ' Enter message to encrypt: $'
decrypt      db ' Enter message to decrypt: $'
cipher       db 0Dh, 0Ah, ' Ciphertext: $'
plain        db 0Dh, 0Ah, ' Plaintext: $'   

msg_again    db 0Dh, 0Ah, ' Do you want to decrypt the same message? (Y/N): $'
msg_return   db 0Dh, 0Ah, ' Press any key to return to menu... $'

err_key      db 0Dh, 0Ah, ' ERROR: Key out of range (1-5)! ', 0Dh, 0Ah, '$'
err_input    db 0Dh, 0Ah, ' ERROR: Only alphabets and spaces allowed!', 0Dh, 0Ah, '$'
err_invalid  db 0Dh, 0Ah, ' Invalid selection! Press any key to try again... $'

exit db '================================================', 0Dh, 0Ah
     db '        THANK YOU FOR USING OUR SYSTEM!          ', 0Dh, 0Ah
     db '================================================', 0Dh, 0Ah
     db ' System shutting down. Goodbye! ', 0Dh, 0Ah
     db ' Press any key to close...$'


array db 50 dup(0)
choice db ?
key    dw 0
   
; ====================================================================================
 
 
.code

START:
                                          
    CLEAR_SCREEN
    PRINT_MSG welcome         
    jmp GOTO_MENU

GOTO_MENU:

    PRINT_MSG menu          ; macro calling to print message
    mov ah, 1               ; DOS input with echo
    int 21h
    mov choice, al          ; store ascii of al into memory
    printn                  ; print a newline character

                            
    cmp choice, 'X'         ; Evaluate main menu options
    je EXIT_SCREEN
    cmp choice, 'x'
    je EXIT_SCREEN
    
    cmp choice, 'E'
    je GET_KEY
    cmp choice, 'e'
    je GET_KEY
    
    cmp choice, 'D'
    je GET_KEY
    cmp choice, 'd'
    je GET_KEY

    
    PRINT_MSG err_invalid   ; Fmessage for invalid options
    mov ah, 0               ; ZF = 1 if keystroke is not available, ZF = 0 if keystroke available.
    int 16h                 ; Wait for keystroke   
    CLEAR_SCREEN            ; clear screen
    jmp GOTO_MENU           ; show menu again

GET_KEY:

    PRINT_MSG msg_key
    mov ah, 1               ; read character from standard input, with echo, result is stored in AL.
    int 21h
    printn                  ; print a newline character
    
   
    cmp al, '1'             ; Key must be between 1 and 5
    jb KEY_ERROR
    cmp al, '5'
    ja KEY_ERROR
    
    sub al, 48              ; Convert ASCII numeric character to integer
    mov ah, 0               ; clear ah
    mov key, ax             ; store value of ax into memory
    
    cmp choice, 'E'
    je ENCRYPTION
    cmp choice, 'e'
    je ENCRYPTION  
    
    jmp DECRYPTION

KEY_ERROR: 

    PRINT_MSG err_key       ; invalid key so,
    jmp GET_KEY             ; get key again

; =============================================================================

ENCRYPTION: 

    printn                  ; print a newline character
    PRINT_MSG encrypt
    lea di, array
    mov dx, 50
    call GET_STRING
    
    push 1                  ; Flag indicating encryption action
    push key                ; Passing shift key by value
    call CRYPTO_PROCESS
    
    PRINT_MSG cipher
    lea si, array
    call PRINT_STRING
    printn
    
    PRINT_MSG msg_again

DECRYPT_SAME:

    mov ah, 0               ; BIOS keystroke reader
    int 16h
    cmp al, 'Y'
    je AUTO_DECRYPT
    cmp al, 'y'
    je AUTO_DECRYPT 
    
    cmp al, 'N'
    je RESET
    cmp al, 'n'
    je RESET
    
    jmp DECRYPT_SAME

AUTO_DECRYPT:

    push 0                  ; Flag indicating decryption action
    push key
    call CRYPTO_PROCESS
    jmp DECRYPTED

; =============================================================================

DECRYPTION:

    printn
    PRINT_MSG decrypt
    lea di, array
    mov dx, 50
    call GET_STRING

    push 0                  ; Flag indicating decryption action
    push key
    call CRYPTO_PROCESS

DECRYPTED:

    PRINT_MSG plain
    lea si, array
    call PRINT_STRING
    printn
    PRINT_MSG msg_return
    mov ah, 0
    int 16h
    jmp RESET

RESET: 

    CLEAR_SCREEN
    jmp GOTO_MENU

; =============================================================================

CRYPTO_PROCESS PROC
    push bp                 ; Save old base pointer
    mov bp, sp              ; BP points to current stack top
    sub sp, 2               ; Reserve 2 bytes for local variable (shift value)
    
    push ax                 ; save registers
    push si
    push bx

    mov ax, [bp+4]          ; key parameter
    cmp [bp+6], 1           ; check operation flag (1 = Encryption, 0 = Decryption)
             
    je SET_SHIFT
    neg ax                  ; Perform two's complement negation if decrypting (shifts backward)
                            
SET_SHIFT: 

    mov [bp-2], ax          ; Store shift value in local stack variable
    lea si, array           ; SI points to start of message string  
    
CRYPTO_LOOP:

    mov al, [si]            ; read current char from memory offset
    cmp al, 0               ; Check for null-terminator 
    je CRYPTO_END           ; exit procedure
    cmp al, ' '             ; Is it a space?
    je SKIP_CHAR            ; If Yes, leave unchanged
    
    cmp al, 'A'
    jb CHAR_ERR             ; Below 'A' = invalid
    cmp al, 'Z'
    jbe PROC_UPPER          ; If 'A'-'Z', go to uppercase processor
    
    cmp al, 'a'
    jb CHAR_ERR             ; Between 'Z' and 'a' = invalid
    cmp al, 'z'
    jbe PROC_LOWER          ; If 'a'-'z'',go to lowercase processor
    
    jmp CHAR_ERR            ; Any other character = invalid

PROC_UPPER:

    add al, byte ptr [bp-2] ; Add shift value to the ASCII value
    cmp al, 'Z'
    jbe UP_LOW_CHECK        ; If still within 'Z', check lower bound 
    
    sub al, 26              ; Wrap around: past 'Z', subtract 26
    jmp SAVE
    
UP_LOW_CHECK: 

    cmp al, 'A'
    jae SAVE                ; Within 'A'-'Z', keep it
    add al, 26              ; Wrap around: below 'A', add 26
    jmp SAVE

PROC_LOWER: 

    add al, byte ptr [bp-2] ; Add shift value to letter
    cmp al, 'z'
    jbe LOW_LOW_CHECK       ; If still within 'z', check lower bound
    
    sub al, 26              ; Wrap around: past 'z', subtract 26
    jmp SAVE 
    
LOW_LOW_CHECK:  

    cmp al, 'a'
    jae SAVE                ; Within 'a'-'z', keep it
    add al, 26              ; Wrap around: below 'a', add 26

SAVE:
    mov [si], al            ; Write modified character back to string
              
SKIP_CHAR: 

    inc si                  ; Move to next character
    jmp CRYPTO_LOOP         ; Process next character

CHAR_ERR:
    
    pop bx                  ; Restore registers
    pop si
    pop ax
    mov sp, bp              ; Deallocate local variable
    pop bp
    add sp, 4               ; Remove parameters from stack
    

    PRINT_MSG err_input
    mov ah, 0               ; Wait for key press
    int 16h
    jmp RESET               ; Return to main menu

CRYPTO_END:
    
    pop bx
    pop si
    pop ax
    mov sp, bp              ; Clean up local variable space
    pop bp
    ret 4                   ; Return and remove 4 bytes of parameters from stack
CRYPTO_PROCESS ENDP

; =============================================================================

EXIT_SCREEN:   

    CLEAR_SCREEN
    PRINT_MSG exit
    mov ah, 0               ; Wait for key press
    int 16h
    
    mov ah, 4Ch
    int 21h


DEFINE_GET_STRING
DEFINE_PRINT_STRING

END