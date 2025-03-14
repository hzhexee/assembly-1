section .data
    prompt_a db "Введите a: ", 0
    prompt_b db "Введите b: ", 0
    prompt_c db "Введите c: ", 0
    prompt_d db "Введите d: ", 0
    result_msg db "Результат (a-b)+(c+d) = %d", 10, 0
    format_in db "%d", 0
    error_msg db "Ошибка: введите целое число! Будет использовано значение 0.", 10, 0
    clear_buffer_fmt db "%c", 0

section .bss
    a resd 1
    b resd 1
    c resd 1
    d resd 1
    temp_char resb 1

section .text
    global main
    extern printf, scanf

; Функция для очистки буфера ввода
clear_input_buffer:
    push ebp
    mov ebp, esp
    
.clear_loop:
    ; Считываем один символ
    push temp_char
    push clear_buffer_fmt
    call scanf
    add esp, 8
    
    ; Проверяем результат scanf и символ на новую строку
    cmp eax, 1
    jne .end_clear
    
    mov al, [temp_char]
    cmp al, 10          ; 10 = '\n'
    je .end_clear
    
    jmp .clear_loop
    
.end_clear:
    mov esp, ebp
    pop ebp
    ret

main:
    ; Set up stack frame
    push ebp
    mov ebp, esp
    
    ; Display prompt for a
    push prompt_a
    call printf
    add esp, 4
    
    ; Read a
    push a
    push format_in
    call scanf
    add esp, 8
    
    ; Check for input error for a
    cmp eax, 1
    je .valid_a
    
    ; Handle error for a
    push error_msg
    call printf
    add esp, 4
    
    ; Clear input buffer
    call clear_input_buffer
    
    ; Set default value for a
    mov dword [a], 0
    
.valid_a:
    ; Display prompt for b
    push prompt_b
    call printf
    add esp, 4
    
    ; Read b
    push b
    push format_in
    call scanf
    add esp, 8
    
    ; Check for input error for b
    cmp eax, 1
    je .valid_b
    
    ; Handle error for b
    push error_msg
    call printf
    add esp, 4
    
    ; Clear input buffer
    call clear_input_buffer
    
    ; Set default value for b
    mov dword [b], 0
    
.valid_b:
    ; Display prompt for c
    push prompt_c
    call printf
    add esp, 4
    
    ; Read c
    push c
    push format_in
    call scanf
    add esp, 8
    
    ; Check for input error for c
    cmp eax, 1
    je .valid_c
    
    ; Handle error for c
    push error_msg
    call printf
    add esp, 4
    
    ; Clear input buffer
    call clear_input_buffer
    
    ; Set default value for c
    mov dword [c], 0
    
.valid_c:
    ; Display prompt for d
    push prompt_d
    call printf
    add esp, 4
    
    ; Read d
    push d
    push format_in
    call scanf
    add esp, 8
    
    ; Check for input error for d
    cmp eax, 1
    je .valid_d
    
    ; Handle error for d
    push error_msg
    call printf
    add esp, 4
    
    ; Clear input buffer
    call clear_input_buffer
    
    ; Set default value for d
    mov dword [d], 0
    
.valid_d:
    ; Calculate (a-b)+(c+d)
    mov eax, [a]    ; Load a into eax
    sub eax, [b]    ; eax = a-b
    
    mov ebx, [c]    ; Load c into ebx
    add ebx, [d]    ; ebx = c+d
    
    add eax, ebx    ; eax = (a-b)+(c+d)
    
    ; Display result
    push eax        ; Push the result as the format argument
    push result_msg
    call printf
    add esp, 8
    
    ; Clean up and return
    mov esp, ebp
    pop ebp
    xor eax, eax    ; Return 0
    ret
