section .data
    prompt_a db "Введите коэффициент a: ", 0
    prompt_b db "Введите коэффициент b: ", 0
    prompt_c db "Введите коэффициент c: ", 0
    
    has_roots_msg db "Уравнение ax^2 + bx + c = 0 имеет действительные корни", 10, 0
    no_roots_msg db "Уравнение ax^2 + bx + c = 0 не имеет действительных корней", 10, 0
    
    format_in db "%d", 0

section .bss
    a resd 1  ; Коэффициент a
    b resd 1  ; Коэффициент b
    c resd 1  ; Коэффициент c

section .text
    global main
    extern printf, scanf

main:
    ; Установка стекового фрейма
    push ebp
    mov ebp, esp
    
    ; Запрашиваем коэффициент a
    push prompt_a
    call printf
    add esp, 4
    
    ; Считываем a
    push a
    push format_in
    call scanf
    add esp, 8
    
    ; Запрашиваем коэффициент b
    push prompt_b
    call printf
    add esp, 4
    
    ; Считываем b
    push b
    push format_in
    call scanf
    add esp, 8
    
    ; Запрашиваем коэффициент c
    push prompt_c
    call printf
    add esp, 4
    
    ; Считываем c
    push c
    push format_in
    call scanf
    add esp, 8
    
    ; Вычисляем дискриминант: D = b^2 - 4*a*c
    
    ; Вычисляем b^2
    mov eax, [b]
    imul eax, [b]  ; eax = b^2
    
    ; Вычисляем 4*a
    mov ebx, [a]
    imul ebx, 4    ; ebx = 4*a
    
    ; Вычисляем 4*a*c
    imul ebx, [c]  ; ebx = 4*a*c
    
    ; Вычисляем D = b^2 - 4*a*c
    sub eax, ebx   ; eax = b^2 - 4*a*c
    
    ; Проверяем, имеет ли уравнение действительные корни
    cmp eax, 0
    jl no_roots    ; Если D < 0, уравнение не имеет действительных корней
    
    ; Если D >= 0, уравнение имеет действительные корни
    push has_roots_msg
    call printf
    add esp, 4
    jmp end
    
no_roots:
    ; Уравнение не имеет действительных корней
    push no_roots_msg
    call printf
    add esp, 4
    
end:
    ; Завершение программы
    mov esp, ebp
    pop ebp
    xor eax, eax   ; Возвращаем 0
    ret
