include 'emu8086.inc'

org 100h

.data
buffer db 50 dup(0)
choice db ?
key    db 0

.code

start_program:
    ; --- FIX: FULL SCREEN COLOR ---
    mov ah, 06h      ; Scroll window function
    mov al, 0        ; Clear entire window
    mov bh, 0fh      ; Blue Background (1), Yellow Text (E)
    mov cx, 0        ; Top-left corner (0,0)
    mov dx, 184Fh    ; Bottom-right corner (Row 24, Col 79) - THIS FILLS THE SCREEN
    int 10h
    

    printn '================================================'
    printn '      CRYPTOGRAPHY SYSTEM - 8086 PROJECT        '
    printn '      ----------------------------------        '
    printn '   Developed by: Maryum, Alisha & Madeeha       '
    printn '================================================'
    printn '           Press any key to start...            '
    mov ah, 0
    int 16h
    jmp selection_prompt

selection_prompt:
   
   
    printn
    printn ' [ E ] -> Encrypt a Message'
    printn ' [ D ] -> Decrypt a Message'
    printn ' [ X ] -> Exit System'
    printn
    print  ' Please select an option (E/D/X): '

    mov ah, 1
    int 21h
    mov choice, al
    printn

    cmp choice, 'X'
    je exit_program
    cmp choice, 'x'
    je exit_program

    cmp choice, 'E'
    je get_key
    cmp choice, 'e'
    je get_key
    cmp choice, 'D'
    je get_key
    cmp choice, 'd'
    je get_key

    printn
    printn 'Invalid selection! Press any key to try again...'
    mov ah, 0
    int 16h
    jmp selection_prompt

get_key:
    printn
    print ' Enter encryption key (1-5): '
    mov ah, 1
    int 21h
    printn
    
    cmp al, '1'
    jb key_error
    cmp al, '5'
    ja key_error
    
    sub al, 48
    mov key, al
    
    cmp choice, 'E'
    je start_encryption
    cmp choice, 'e'
    je start_encryption
    jmp start_decryption

key_error:
    printn ' ERROR: Key out of range (1-5)! '
    jmp get_key

; --- ENCRYPTION (Logic by Maryum & Madeeha) ---
start_encryption:
    print ' Enter message: '
    lea di, buffer
    mov dx, 50
    call GET_STRING
    
    lea si, buffer
encrypt_loop:
    mov al, [si]
    cmp al, 0
    je show_encrypted
    cmp al, ' '
    je next_encrypt

    cmp al, 'A'
    jb invalid_input
    cmp al, 'Z'
    jbe encrypt_upper
    cmp al, 'a'
    jb invalid_input
    cmp al, 'z'
    jbe encrypt_lower
    jmp invalid_input

encrypt_upper: 
    add al, key
    cmp al, 'Z'
    jbe save_char
    sub al, 26
    jmp save_char

encrypt_lower:
    add al, key
    cmp al, 'z'
    jbe save_char
    sub al, 26

save_char:
    mov [si], al
next_encrypt:
    inc si
    jmp encrypt_loop

show_encrypted:
    printn
    print ' Ciphertext: '
    lea si, buffer
    call PRINT_STRING
    printn
    jmp ask_continue

; --- DECRYPTION (Logic by Maryum & Madeeha) ---
start_decryption:
    print ' Enter message: '
    lea di, buffer
    mov dx, 50
    call GET_STRING

    lea si, buffer
decrypt_loop:
    mov al, [si]
    cmp al, 0
    je show_decrypted
    cmp al, ' '
    je next_decrypt

    cmp al, 'A'
    jb next_decrypt
    cmp al, 'Z'
    jbe decrypt_upper
    cmp al, 'a'
    jb next_decrypt
    cmp al, 'z'
    jbe decrypt_lower
    jmp next_decrypt

decrypt_upper: 
    sub al, key
    cmp al, 'A'
    jae save_decrypt
    add al, 26
    jmp save_decrypt

decrypt_lower:
    sub al, key
    cmp al, 'a'
    jae save_decrypt
    add al, 26

save_decrypt:
    mov [si], al
next_decrypt:
    inc si
    jmp decrypt_loop

show_decrypted:
    printn
    print ' Plaintext: '
    lea si, buffer
    call PRINT_STRING
    printn
    jmp ask_continue

; --- CONTINUE & EXIT (Logic by Alisha) ---
ask_continue:
    printn
    print ' Do you want to perform another action? (Y/N): '
    mov ah, 1
    int 21h
    
    cmp al, 'Y'
    je selection_prompt
    cmp al, 'y'
    je selection_prompt
    
    cmp al, 'N'
    je exit_program
    cmp al, 'n'
    je exit_program
    
    printn ' Invalid input.'
    jmp ask_continue

invalid_input:
    printn
    print ' ERROR: Invalid character! '
    jmp ask_continue

exit_program:
    ; --- FIX: ENSURE FULL COLOR ON EXIT ---
    mov ah, 06h
    mov al, 0
    mov bh, 1Eh      ; Keep Blue/Yellow theme
    mov cx, 0
    mov dx, 184Fh    ; Fill full screen again
    int 10h
    
   
    printn '================================================'
    printn '       THANK YOU FOR USING OUR SYSTEM!          '
    printn '================================================'
    printn
    printn ' Developed by: Maryum, Alisha & Madeeha'
    printn
    printn ' System shutting down. Goodbye! '
    printn ' Press any key to close...'
    
    mov ah, 0
    int 16h
    ret

DEFINE_GET_STRING
DEFINE_PRINT_STRING

END