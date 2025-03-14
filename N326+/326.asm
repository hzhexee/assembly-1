section .data
    prompt_msg db 'Введите количество членов ряда (по умолчанию 5): ', 0
    result_msg db 'Сумма первых %d членов ряда A(k) = 3*k^2 - 2*k + 1: %d', 10, 0
    format_in db '%d', 0
    error_msg db 'Ошибка: введите целое число! Будет использовано значение 5.', 10, 0
    clear_buffer_fmt db '%c', 0

section .bss
    n resd 1       ; Количество членов ряда
    sum resd 1     ; Сумма членов ряда
    temp_char resb 1 ; Временная переменная для очистки буфера

section .text
    global main
    extern printf
    extern scanf

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
    ; Выводим приглашение для ввода
    push prompt_msg
    call printf
    add esp, 4

    ; Считываем n от пользователя
    push n
    push format_in
    call scanf
    add esp, 8

    ; Проверяем успешность считывания
    cmp eax, 1
    je .check_value
    
    ; Обработка ошибки ввода
    push error_msg
    call printf
    add esp, 4
    
    ; Очистка буфера ввода
    call clear_input_buffer
    
    ; Устанавливаем значение по умолчанию
    mov dword [n], 5
    jmp calculate_start

.check_value:
    ; Проверяем, ввел ли пользователь корректное значение (>0)
    mov eax, [n]
    cmp eax, 0
    jg calculate_start
    
    ; Если ввел ноль/отрицательное, используем 5
    mov dword [n], 5

calculate_start:
    ; Инициализируем переменные
    mov dword [sum], 0  ; sum = 0
    mov ecx, [n]        ; счетчик цикла
    mov edx, 1          ; k = 1 (первый член)
    
calculate_loop:
    ; Рассчитываем A(k) = 3*k^2 - 2*k + 1
    mov eax, edx        ; eax = k
    imul eax, eax       ; eax = k^2
    imul eax, 3         ; eax = 3*k^2
    
    mov ebx, edx        ; ebx = k
    imul ebx, 2         ; ebx = 2*k
    sub eax, ebx        ; eax = 3*k^2 - 2*k
    add eax, 1          ; eax = 3*k^2 - 2*k + 1
    
    ; Добавляем A(k) к сумме
    add [sum], eax
    
    ; Увеличиваем k
    inc edx
    
    ; Повторяем цикл
    loop calculate_loop
    
    ; Выводим результат
    push dword [sum]
    push dword [n]
    push result_msg
    call printf
    add esp, 12
    
    ; Завершение программы
    mov eax, 0
    ret
