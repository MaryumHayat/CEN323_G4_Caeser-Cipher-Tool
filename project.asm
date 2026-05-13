include 'emu8086.inc'

org 100h

.data

buffer db 50 dup(0)

.code

; ---------------- INPUT ----------------
print 'Enter message to encrypt: '

lea di, buffer
mov dx, 50
call GET_STRING


; ---------------- VALIDATE + ENCRYPT ----------------
lea si, buffer

encrypt_loop:

    mov al, [si]

    ; End of string
    cmp al, 0
    je show_encrypted

    ; Allow spaces
    cmp al, ' '
    je next_encrypt

    ; Check uppercase A-Z
    cmp al, 'A'
    jb invalid_input

    cmp al, 'Z'
    jbe encrypt_upper

    ; Check lowercase a-z
    cmp al, 'a'
    jb invalid_input

    cmp al, 'z'
    jbe encrypt_lower

    ; Anything else invalid
    jmp invalid_input


; ---------------- ENCRYPT UPPERCASE ----------------
encrypt_upper:

    ; Z -> A
    cmp al, 'Z'
    jne upper_normal

    mov al, 'A'
    jmp save_char

upper_normal:
    inc al
    jmp save_char


; ---------------- ENCRYPT LOWERCASE ----------------
encrypt_lower:

    ; z -> a
    cmp al, 'z'
    jne lower_normal

    mov al, 'a'
    jmp save_char

lower_normal:
    inc al


; ---------------- SAVE CHARACTER ----------------
save_char:

    mov [si], al


next_encrypt:

    inc si
    jmp encrypt_loop


; ---------------- ERROR HANDLING ----------------
invalid_input:

    printn
    print 'ERROR: Only alphabets and spaces allowed!'
    printn

    ret


; ---------------- SHOW ENCRYPTED ----------------
show_encrypted:

    printn
    print 'Encrypted message: '

    lea si, buffer
    call PRINT_STRING

    printn
    printn


; ---------------- WAIT ----------------
print 'Press any key to decrypt...'

mov ah,0
int 16h

printn


; ---------------- DECRYPT ----------------
lea si, buffer

decrypt_loop:

    mov al, [si]

    cmp al, 0
    je show_decrypted

    ; Skip spaces
    cmp al, ' '
    je next_decrypt

    ; Uppercase
    cmp al, 'A'
    jb next_decrypt

    cmp al, 'Z'
    jbe decrypt_upper

    ; Lowercase
    cmp al, 'a'
    jb next_decrypt

    cmp al, 'z'
    jbe decrypt_lower

    jmp next_decrypt


; ---------------- DECRYPT UPPERCASE ----------------
decrypt_upper:

    ; A -> Z
    cmp al, 'A'
    jne upper_dec

    mov al, 'Z'
    jmp save_decrypt

upper_dec:
    dec al
    jmp save_decrypt


; ---------------- DECRYPT LOWERCASE ----------------
decrypt_lower:

    ; a -> z
    cmp al, 'a'
    jne lower_dec

    mov al, 'z'
    jmp save_decrypt

lower_dec:
    dec al


; ---------------- SAVE DECRYPTED ----------------
save_decrypt:

    mov [si], al


next_decrypt:

    inc si
    jmp decrypt_loop


; ---------------- SHOW DECRYPTED ----------------
show_decrypted:

    print 'Decrypted message: '

    lea si, buffer
    call PRINT_STRING

    ret


DEFINE_GET_STRING
DEFINE_PRINT_STRING

END