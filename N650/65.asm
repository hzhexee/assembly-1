extern printf
extern scanf
extern getchar

section .data
    prompt_sentence db 'Введите предложение (завершите символом "!"): ', 0
    prompt_letter db 'Введите букву: ', 0
    result_msg db 'Число слов, начинающихся на "%c": %d', 10, 0
    format_char db ' %c', 0
    scan_format db '%c', 0

section .bss
    sentence resb 1024        ; Buffer for the sentence (1024 bytes)
    letter resb 1             ; Buffer for the letter (single byte is enough)
    count resd 1              ; Counter for words
    in_word resb 1            ; Flag: 1 if we're in a word, 0 otherwise

section .text
    global main

main:
    push ebp
    mov ebp, esp
    
    ; Prompt for sentence
    push prompt_sentence
    call printf
    add esp, 4
    
    ; Read the sentence character by character until '!'
    mov edi, sentence        ; EDI points to where to store characters
    xor ecx, ecx             ; ECX will count characters

read_char:
    call getchar             ; Get a character from stdin
    cmp eax, -1              ; Check if EOF
    je end_input
    cmp eax, '!'             ; Check if it's exclamation mark
    je end_input             ; If yes, end input
    
    ; Store character and move to next position
    mov byte [edi + ecx], al
    inc ecx
    cmp ecx, 1023            ; Check if we're about to overflow buffer
    jge end_input            ; If yes, stop reading
    
    jmp read_char            ; Continue reading

end_input:
    ; Null-terminate the string
    mov byte [edi + ecx], 0
    
    ; Clear input buffer
    call getchar             ; Clear any remaining input (like newline)
    
    ; Prompt for letter
    push prompt_letter
    call printf
    add esp, 4
    
    ; Read the letter using scanf instead of getchar
    push letter
    push scan_format
    call scanf
    add esp, 8
    
    ; Clear input buffer again
    call getchar             ; Clear newline after character input
    
    ; Initialize counters and flags
    mov dword [count], 0     ; Word count = 0
    mov byte [in_word], 0    ; Not in a word initially
    
    ; Process the sentence
    mov esi, sentence        ; ESI points to the current character
    
process_char:
    movzx eax, byte [esi]    ; Load current character
    test eax, eax            ; Check if end of string
    jz print_result          ; If yes, finish processing
    
    ; Check if it's a delimiter (space, punctuation)
    cmp al, ' '
    je is_delimiter
    cmp al, ','
    je is_delimiter
    cmp al, '.'
    je is_delimiter
    cmp al, '!'
    je is_delimiter
    cmp al, '?'
    je is_delimiter
    cmp al, ';'
    je is_delimiter
    cmp al, ':'
    je is_delimiter
    cmp al, 9  ; Tab
    je is_delimiter
    cmp al, 10 ; Line feed
    je is_delimiter
    cmp al, 13 ; Carriage return
    je is_delimiter
    
    ; Not a delimiter, it's part of a word
    cmp byte [in_word], 0
    jne already_in_word
    
    ; We're at the beginning of a new word
    mov byte [in_word], 1
    
    ; Check if the first letter matches
    movzx ecx, byte [letter]
    cmp al, cl
    jne already_in_word
    
    ; Match found, increment counter
    inc dword [count]
    
already_in_word:
    jmp next_char
    
is_delimiter:
    ; Found a delimiter
    mov byte [in_word], 0
    
next_char:
    inc esi                  ; Move to the next character
    jmp process_char
    
print_result:
    ; Print the result
    push dword [count]       ; Count of words
    movzx eax, byte [letter] ; Get letter value
    push eax                 ; Push the letter value
    push result_msg
    call printf
    add esp, 12
    
    ; Return 0 (success)
    mov eax, 0
    
    mov esp, ebp
    pop ebp
    ret

section .note.GNU-stack noalloc noexec nowrite
