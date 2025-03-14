section .data
    prompt_x db "Введите координату x: ", 0
    prompt_y db "Введите координату y: ", 0
    inside_msg db "Точка M(%d, %d) находится внутри квадрата", 10, 0
    outside_msg db "Точка M(%d, %d) находится вне квадрата", 10, 0
    format_in db "%d", 0
    error_msg db "Ошибка: введите целое число! Будет использовано значение 0.", 10, 0
    clear_buffer_fmt db "%c", 0

section .bss
    x_coord resd 1
    y_coord resd 1
    temp_char resb 1  ; Временная переменная для очистки буфера

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
    
    ; Display prompt for x
    push prompt_x
    call printf
    add esp, 4
    
    ; Read x
    push x_coord
    push format_in
    call scanf
    add esp, 8
    
    ; Проверяем успешность считывания
    cmp eax, 1
    je .valid_x_input
    
    ; Обработка ошибки ввода
    push error_msg
    call printf
    add esp, 4
    
    ; Очистка буфера ввода
    call clear_input_buffer
    
    ; Устанавливаем значение по умолчанию
    mov dword [x_coord], 0

.valid_x_input:
    ; Display prompt for y
    push prompt_y
    call printf
    add esp, 4
    
    ; Read y
    push y_coord
    push format_in
    call scanf
    add esp, 8
    
    ; Проверяем успешность считывания
    cmp eax, 1
    je .valid_y_input
    
    ; Обработка ошибки ввода
    push error_msg
    call printf
    add esp, 4
    
    ; Очистка буфера ввода
    call clear_input_buffer
    
    ; Устанавливаем значение по умолчанию
    mov dword [y_coord], 0

.valid_y_input:
    ; Check if point is inside the square (2 <= x <= 4, 2 <= y <= 4)
    
    ; Check lower bounds
    mov eax, [x_coord]
    cmp eax, 2
    jl outside      ; Jump if x < 2
    
    mov eax, [y_coord]
    cmp eax, 2
    jl outside      ; Jump if y < 2
    
    ; Check upper bounds
    mov eax, [x_coord]
    cmp eax, 4
    jg outside      ; Jump if x > 4
    
    mov eax, [y_coord]
    cmp eax, 4
    jg outside      ; Jump if y > 4
    
    ; If we get here, the point is inside the square
    push dword [y_coord]
    push dword [x_coord]
    push inside_msg
    call printf
    add esp, 12
    jmp end
    
outside:
    ; The point is outside the square
    push dword [y_coord]
    push dword [x_coord]
    push outside_msg
    call printf
    add esp, 12
    
end:
    ; Clean up and return
    mov esp, ebp
    pop ebp
    xor eax, eax    ; Return 0
    ret
