section .data
    prompt_a db "Введите a: ", 0
    prompt_b db "Введите b: ", 0
    prompt_c db "Введите c: ", 0
    prompt_d db "Введите d: ", 0
    result_msg db "Результат (a-b)+(c+d) = %d", 10, 0
    format_in db "%d", 0

section .bss
    a resd 1
    b resd 1
    c resd 1
    d resd 1

section .text
    global main
    extern printf, scanf

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
    
    ; Display prompt for b
    push prompt_b
    call printf
    add esp, 4
    
    ; Read b
    push b
    push format_in
    call scanf
    add esp, 8
    
    ; Display prompt for c
    push prompt_c
    call printf
    add esp, 4
    
    ; Read c
    push c
    push format_in
    call scanf
    add esp, 8
    
    ; Display prompt for d
    push prompt_d
    call printf
    add esp, 4
    
    ; Read d
    push d
    push format_in
    call scanf
    add esp, 8
    
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
