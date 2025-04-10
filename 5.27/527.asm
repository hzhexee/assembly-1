section .data
    ; Сообщения для пользовательского интерфейса
    prompt_size db "Введите размер массива (максимум 100): ", 0
    prompt_size_len equ $ - prompt_size
    
    prompt_elem db "Введите элемент ", 0
    prompt_elem_len equ $ - prompt_elem
    
    colon db ": ", 0
    colon_len equ $ - colon
    
    result_msg db "Максимальный элемент: ", 0
    result_msg_len equ $ - result_msg
    
    error_msg db "Ошибка ввода. Пожалуйста, введите целое число.", 10, 0
    error_msg_len equ $ - error_msg
    
    error_size db "Размер должен быть от 1 до 100.", 10, 0
    error_size_len equ $ - error_size
    
    newline db 10, 0
    
section .bss
    array resd 100       ; Массив для хранения до 100 целых чисел
    buffer resb 32       ; Буфер для ввода
    array_size resd 1    ; Размер массива
    max_element resd 1   ; Переменная для хранения максимального элемента
    output_buffer resb 16 ; Буфер для вывода чисел

section .text
global _start

_start:
    ; Запрашиваем размер массива
    mov eax, 4           ; sys_write
    mov ebx, 1           ; stdout
    mov ecx, prompt_size ; сообщение
    mov edx, prompt_size_len
    int 0x80

input_size:
    ; Считываем ввод размера
    mov eax, 3           ; sys_read
    mov ebx, 0           ; stdin
    mov ecx, buffer      ; буфер для ввода
    mov edx, 32          ; максимальная длина
    int 0x80
    
    cmp eax, 1           ; проверка на пустой ввод
    jle input_size
    
    ; Преобразуем строку в число
    mov esi, buffer
    xor ecx, ecx         ; ecx будет хранить число
    xor ebx, ebx         ; флаг отрицательного числа
    
    ; Проверка на минус в начале
    cmp byte [esi], '-'
    jne .process_digits
    inc esi              ; пропускаем минус
    mov ebx, 1           ; устанавливаем флаг отриц. числа
    
.process_digits:
    xor eax, eax
    mov al, [esi]
    
    ; Проверка на конец строки или перевод строки
    cmp al, 0
    je .end_conversion
    cmp al, 10
    je .end_conversion
    
    ; Проверяем, что символ - цифра
    sub al, '0'
    cmp al, 9
    ja .invalid_input
    
    ; Добавляем цифру к числу
    imul ecx, 10
    add ecx, eax
    inc esi
    jmp .process_digits
    
.invalid_input:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_msg_len
    int 0x80
    jmp input_size
    
.end_conversion:
    ; Преобразуем число в отрицательное, если нужно
    test ebx, ebx
    jz .check_size
    neg ecx
    
.check_size:
    ; Проверяем, что размер в допустимых пределах
    cmp ecx, 1
    jl .size_error
    cmp ecx, 100
    jg .size_error
    
    mov [array_size], ecx
    jmp input_elements
    
.size_error:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_size
    mov edx, error_size_len
    int 0x80
    jmp input_size

input_elements:
    ; Вводим элементы массива
    xor esi, esi        ; индекс текущего элемента
    
.input_loop:
    cmp esi, [array_size]
    jge find_max        ; если все элементы введены, находим максимум
    
    ; Выводим приглашение для ввода
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_elem
    mov edx, prompt_elem_len
    int 0x80
    
    ; Выводим номер элемента (esi + 1)
    push esi
    mov ecx, esi
    inc ecx             ; нумерация с 1
    call print_int
    pop esi
    
    ; Выводим двоеточие
    mov eax, 4
    mov ebx, 1
    mov ecx, colon
    mov edx, colon_len
    int 0x80

    ; Считываем ввод элемента
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 32
    int 0x80
    
    ; Проверяем на пустой ввод
    cmp eax, 1
    jle .input_loop
    
    ; Преобразуем строку в число
    mov edi, buffer
    xor ecx, ecx        ; ecx будет хранить число
    xor ebx, ebx        ; флаг отрицательного числа
    
    ; Проверка на минус в начале
    cmp byte [edi], '-'
    jne .process_digits_elem
    inc edi             ; пропускаем минус
    mov ebx, 1          ; устанавливаем флаг отриц. числа
    
.process_digits_elem:
    xor eax, eax
    mov al, [edi]
    
    ; Проверка на конец строки или перевод строки
    cmp al, 0
    je .end_conversion_elem
    cmp al, 10
    je .end_conversion_elem
    
    ; Проверяем, что символ - цифра
    sub al, '0'
    cmp al, 9
    ja .invalid_elem_input
    
    ; Добавляем цифру к числу
    imul ecx, 10
    add ecx, eax
    inc edi
    jmp .process_digits_elem
    
.invalid_elem_input:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_msg_len
    int 0x80
    jmp .input_loop
    
.end_conversion_elem:
    ; Преобразуем число в отрицательное, если нужно
    test ebx, ebx
    jz .store_element
    neg ecx
    
.store_element:
    ; Сохраняем число в массиве
    mov [array + esi*4], ecx
    inc esi
    jmp .input_loop

find_max:
    ; Находим максимальный элемент
    mov esi, 0          ; индекс текущего элемента
    mov ecx, [array]    ; предполагаем, что первый элемент - максимальный
    
.max_loop:
    cmp esi, [array_size]
    jge .finish_max     ; если просмотрели весь массив, выходим
    
    mov eax, [array + esi*4]  ; получаем текущий элемент
    cmp eax, ecx
    jle .continue       ; если не больше текущего максимума, продолжаем
    mov ecx, eax        ; иначе обновляем максимум
    
.continue:
    inc esi
    jmp .max_loop

.finish_max:
    ; Сохраняем максимальный элемент в переменную
    mov [max_element], ecx
    jmp print_result

print_result:
    ; Выводим сообщение о максимальном элементе
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_msg_len
    int 0x80
    
    ; Выводим максимальный элемент
    mov eax, [max_element]
    call print_int_new
    
    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Завершаем программу
    mov eax, 1       ; sys_exit
    xor ebx, ebx     ; exit code 0
    int 0x80

; Новая функция для вывода целого числа
print_int_new:
    ; eax содержит число для вывода
    
    ; Проверяем на отрицательное число
    test eax, eax
    jns .positive
    
    ; Для отрицательного числа выводим минус
    push eax         ; сохраняем число
    mov eax, 4       ; sys_write
    mov ebx, 1       ; stdout
    push '-'         ; помещаем символ минуса на стек
    mov ecx, esp     ; указатель на символ в стеке
    mov edx, 1       ; длина строки
    int 0x80
    add esp, 4       ; восстанавливаем стек
    pop eax          ; восстанавливаем число
    neg eax          ; делаем положительным
    
.positive:
    ; Подготовка буфера для вывода
    mov edi, output_buffer
    add edi, 15      ; указатель на конец буфера
    mov byte [edi], 0 ; нулевой символ в конец строки
    dec edi
    
    mov ebx, 10      ; делитель (система счисления)
    
.divide_loop:
    xor edx, edx     ; очищаем edx для деления
    div ebx          ; делим eax на 10, результат в eax, остаток в edx
    add dl, '0'      ; конвертируем остаток в символ ASCII
    mov [edi], dl    ; сохраняем символ в буфере
    dec edi          ; двигаемся к началу буфера
    
    test eax, eax    ; проверяем, остались ли цифры
    jnz .divide_loop ; если да, продолжаем цикл
    
    ; Вывод числа
    inc edi          ; корректируем указатель (указывает на первую цифру)
    mov eax, 4       ; sys_write
    mov ebx, 1       ; stdout
    mov ecx, edi     ; буфер с числом
    mov edx, output_buffer
    add edx, 15      ; конец буфера
    sub edx, edi     ; вычисляем длину строки
    int 0x80
    
    ret

; Оставляем старую функцию для совместимости
print_int:
    ; Просто вызываем новую функцию
    mov eax, ecx
    call print_int_new
    ret

clear_input_buffer:
    ; Очищаем буфер ввода
    mov eax, 3         ; sys_read
    mov ebx, 0         ; stdin
    mov ecx, buffer    ; буфер
    mov edx, 1         ; читаем по 1 символу
    int 0x80
    
    cmp eax, 1         ; проверяем, был ли считан символ
    jl .done           ; если ошибка или конец файла, выходим
    
    mov al, [buffer]
    cmp al, 10         ; сравниваем с символом новой строки
    jne clear_input_buffer ; если не новая строка, продолжаем чтение
    
.done:
    ret
