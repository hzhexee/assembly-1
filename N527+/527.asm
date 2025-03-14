extern printf
extern scanf
extern puts
extern getchar

section .data
    prompt_size db 'Введите размер массива: ', 0
    prompt_element db 'Введите элемент: ', 0
    result_msg db 'Максимальный элемент: %d', 10, 0
    format_int db '%d', 0
    error_input db 'Ошибка: введите число!', 10, 0
    error_size db 'Ошибка: размер должен быть от 1 до 100!', 10, 0

section .bss
    array resd 100              ; Array to store up to 100 integers
    array_size resd 1           ; Variable to store the size of the array

section .text
    global main

main:
    push ebp
    mov ebp, esp
    
read_size:
    ; Ask for array size
    push prompt_size
    call printf
    add esp, 4
    
    ; Read array size
    push array_size
    push format_int
    call scanf
    add esp, 8
    
    ; Check if scanf was successful
    cmp eax, 1
    je validate_size
    
    ; Error handling for invalid input
    call clear_input_buffer
    push error_input
    call printf
    add esp, 4
    jmp read_size
    
validate_size:
    ; Check if array_size is within valid range (1-100)
    mov eax, [array_size]
    cmp eax, 1
    jl invalid_size
    cmp eax, 100
    jg invalid_size
    jmp initialize_variables
    
invalid_size:
    push error_size
    call printf
    add esp, 4
    jmp read_size
    
initialize_variables:
    ; Initialize variables
    mov ecx, 0                  ; Loop counter
    
read_array_loop:
    ; Check if we've read all elements
    cmp ecx, [array_size]
    jge find_max                ; If yes, proceed to find max
    
    ; Ask for array element
    push ecx                    ; Save counter
    push prompt_element
    call printf
    add esp, 4
    
    ; Read array element
    lea eax, [array + ecx*4]    ; Calculate address
    push eax                    ; Push address for scanf
    push format_int             ; Push format
    call scanf
    add esp, 8
    
    ; Check if scanf was successful
    cmp eax, 1
    je read_success
    
    ; Error handling for invalid input
    call clear_input_buffer
    push error_input
    call printf
    add esp, 4
    
    ; Retrieve counter but don't increment
    pop ecx
    push ecx
    jmp read_array_loop
    
read_success:
    ; Restore counter
    pop ecx
    
    ; Increment counter
    inc ecx
    jmp read_array_loop
    
find_max:
    ; Initialize max_value with first element
    mov edx, [array]            ; Use EDX for max value
    
    ; Initialize loop counter
    mov ecx, 1
    
max_loop:
    ; Check if we've checked all elements
    cmp ecx, [array_size]
    jge print_result            ; If yes, print the result
    
    ; Get current element
    mov eax, [array + ecx*4]    ; Get value
    
    ; Compare with current max
    cmp eax, edx
    jle not_greater             ; If not greater, skip update
    
    ; Update max_value
    mov edx, eax
    
not_greater:
    ; Increment counter
    inc ecx
    jmp max_loop
    
print_result:
    ; Print result message with the maximum value
    push edx                    ; max value
    push result_msg             ; format string
    call printf
    add esp, 8
    
    ; Return 0 (success)
    mov eax, 0
    
    mov esp, ebp
    pop ebp
    ret

; Function to clear the input buffer after a failed scanf
clear_input_buffer:
    push ebp
    mov ebp, esp
    
clear_loop:
    call getchar
    cmp eax, 10      ; Check for newline character
    je clear_done
    cmp eax, -1      ; Check for EOF
    je clear_done
    jmp clear_loop
    
clear_done:
    mov esp, ebp
    pop ebp
    ret

section .note.GNU-stack noalloc noexec nowrite
