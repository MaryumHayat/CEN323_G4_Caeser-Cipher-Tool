include 'emu8086.inc'
org 100h
      

.code

  ; --- INPUT SECTION ---
  print 'Enter message to encrypt: '
  lea di, buffer      
  mov dx, 20          
  call GET_STRING     
  
  ; --- ENCRYPTION SECTION ---
  lea si, buffer      
encrypt_loop:
  mov al, [si]        
  cmp al, 0           
  je  show_encrypted            
  inc al              ; Shift forward (A -> B)
  mov [si], al        
  inc si              
  jmp encrypt_loop    

show_encrypted:
  printn
  print 'Encrypted message: '
  lea si, buffer
  call PRINT_STRING
  printn
  printn

  ; --- DECRYPTION SECTION ---
  print 'Press any key to decrypt...'
  mov ah, 0           ; Wait for user key press
  int 16h
  printn

  lea si, buffer      ; Point back to the start of the buffer
decrypt_loop:
  mov al, [si]
  cmp al, 0           ; Check for end of string
  je  show_decrypted
  dec al              ; Shift backward (B -> A)
  mov [si], al
  inc si
  jmp decrypt_loop

show_decrypted:
  print 'Decrypted message: '
  lea si, buffer
  call PRINT_STRING

  ret

; Data and procedures  
buffer db 20 dup(?)  

DEFINE_GET_STRING
<<<<<<< HEAD
DEFINE_PRINT_STRING    ;djhfeifghsduihkdasjhkhjdbqashkdbwhduw3udhiwjed

=======
DEFINE_PRINT_STRING  ;yufhibhfirdhidfkvnfgbkvgfo fk
                      ;nfirkenfiehnfdkrndfefod
END