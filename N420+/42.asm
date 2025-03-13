section .data
    prompt_x db "Введите координату x: ", 0
    prompt_y db "Введите координату y: ", 0
    inside_msg db "Точка M(%d, %d) находится внутри квадрата", 10, 0
    outside_msg db "Точка M(%d, %d) находится вне квадрата", 10, 0
    format_in db "%d", 0

section .bss
    x_coord resd 1
    y_coord resd 1

section .text
    global main
    extern printf, scanf

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
    
    ; Display prompt for y
    push prompt_y
    call printf
    add esp, 4
    
    ; Read y
    push y_coord
    push format_in
    call scanf
    add esp, 8
    
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
