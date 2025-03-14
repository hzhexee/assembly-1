section .data
    prompt_msg db "Введите 10 натуральных чисел:", 10
    prompt_len equ $ - prompt_msg
    input_msg db "Введите число "
    input_msg_len equ $ - input_msg
    colon_msg db ": "
    colon_len equ $ - colon_msg
    result_msg db "Количество четных целых чисел: "
    result_len equ $ - result_msg
    error_msg db "Ошибка: введите только числа!", 10
    error_len equ $ - error_msg
    empty_error_msg db "Ошибка: пустой ввод!", 10
    empty_error_len equ $ - empty_error_msg
    newline db 10

section .bss
    array resd 10        ; Array to store 10 integers
    buffer resb 12       ; Buffer for input
    num_buffer resb 2    ; Buffer for number display
    
section .text
global _start

_start:
    ; Display prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_msg
    mov edx, prompt_len
    int 0x80
    
    ; Initialize array index
    xor esi, esi        ; array index
    
input_loop:
    ; Display "Enter number X: "
    mov eax, 4
    mov ebx, 1
    mov ecx, input_msg
    mov edx, input_msg_len
    int 0x80
    
    ; Display number (esi + 1)
    mov eax, esi
    inc eax
    add eax, '0'
    mov [num_buffer], al
    
    mov eax, 4
    mov ebx, 1
    mov ecx, num_buffer
    mov edx, 1
    int 0x80
    
    ; Display ": "
    mov eax, 4
    mov ebx, 1
    mov ecx, colon_msg
    mov edx, colon_len
    int 0x80
    
    ; Read input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 12
    int 0x80
    
    ; Check if input is empty (only newline)
    cmp eax, 1
    jg check_input
    
    ; Handle empty input
    mov eax, 4
    mov ebx, 1
    mov ecx, empty_error_msg
    mov edx, empty_error_len
    int 0x80
    jmp input_loop
    
check_input:
    ; Convert ASCII to integer
    xor ecx, ecx        ; Initialize result
    xor edx, edx        ; Initialize index into buffer
    mov edi, 0          ; Set flag: 0 = no digits found yet
    
convert_loop:
    movzx eax, byte [buffer + edx]  ; Get current character
    cmp al, 10          ; Check for newline
    je end_of_input
    cmp al, '0'         ; Check if it's a digit
    jl invalid_char
    cmp al, '9'
    jg invalid_char
    
    ; Valid digit found
    mov edi, 1          ; Set flag: digit found
    
    ; Multiply current result by 10
    imul ecx, 10
    sub al, '0'         ; Convert ASCII to number
    movzx eax, al
    add ecx, eax        ; Add to result
    
    inc edx
    jmp convert_loop
    
invalid_char:
    ; Display error message
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg
    mov edx, error_len
    int 0x80
    jmp input_loop      ; Re-prompt for this number
    
end_of_input:
    ; Check if we found at least one digit
    cmp edi, 0
    je input_loop       ; No digits found, re-prompt
    
    ; Store the number in the array
    mov [array + esi*4], ecx
    inc esi
    
    ; Check if we've read 10 numbers
    cmp esi, 10
    jl input_loop
    
    ; Count even numbers
    xor esi, esi        ; Reset array index
    xor edi, edi        ; Initialize even counter
    
count_loop:
    mov eax, [array + esi*4]
    test eax, 1         ; Test if least significant bit is set
    jnz not_even        ; If LSB is 1, number is odd
    inc edi             ; Increment counter for even numbers
    
not_even:
    inc esi
    cmp esi, 10
    jl count_loop
    
    ; Display result message
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_len
    int 0x80
    
    ; Convert count to ASCII and display
    mov eax, edi
    call int_to_ascii
    
    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Convert integer in EAX to ASCII and display
int_to_ascii:
    push ebx
    push ecx
    push edx
    push esi
    
    mov ecx, 10         ; Divisor
    mov esi, buffer + 10 ; Start from end of buffer
    mov byte [esi], 0   ; Null-terminate
    dec esi
    
    ; Handle zero case
    test eax, eax
    jnz .convert_loop
    mov byte [esi], '0'
    dec esi
    jmp .display
    
.convert_loop:
    xor edx, edx        ; Clear EDX for division
    div ecx             ; Divide EAX by 10, remainder in EDX
    add dl, '0'         ; Convert to ASCII
    mov [esi], dl       ; Store digit
    dec esi             ; Move buffer pointer
    
    test eax, eax       ; Check if quotient is zero
    jnz .convert_loop
    
.display:
    ; Calculate length of the number
    mov edx, buffer + 10
    sub edx, esi        ; EDX = length of digits
    inc esi             ; Point to first digit
    
    ; Print number
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, esi        ; Pointer to digits
    int 0x80
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

section .note.GNU-stack
