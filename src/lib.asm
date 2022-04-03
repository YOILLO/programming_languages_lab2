section .text
 
global exit
global string_length
global print_string
global print_string_err
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy

%define stdout 1
%define stderr 2

; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, 60
    syscall
    ret 

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
    .loop:
    	inc rax
	cmp byte [rdi + rax - 1], 0
	jne .loop
    dec rax
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    mov r8, stdout
    jmp print

; Принимает указатель на нуль-терминированную строку, выводит её в stderr
print_string_err:
    mov r8, stderr
    jmp print

print:
    call string_length
    mov rsi, rdi
    mov rdx, rax
    mov rax, 1
    mov rdi, r8
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push 0
    push rdi
    mov rdi, rsp
    call print_string
    pop r9
    pop r9
    xor r9, r9
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 10
    jmp print_char

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r10, rsp
    push 0
    mov rax, rdi
    mov r8, 10
    add rsp, 7
    .loop:
        xor rdx, rdx
        div r8
        add dl, '0'
        mov dh, byte[rsp]
        add rsp, 1
        push dx
        cmp rax, 0
        jne .loop
    mov rdi, rsp 
    call print_string
    mov rsp, r10 
    ret



; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi
    jns print_uint
    mov r8, rdi
    mov rdi, '-'
    call print_char
    mov rdi, r8
    neg rdi
    jmp print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    mov r8, rdi
    call string_length
    mov rdi, rsi
    mov r9, rax
    call string_length
    cmp rax, r9
    jne .not_equals
    mov rdi, r8
    mov rcx, r9
    .loop: 
        cmp rcx, 0
        jbe .stop
        mov dl, byte[rdi + rcx - 1] 
        cmp dl, byte[rsi + rcx - 1] 
        jne .not_equals
        dec rcx
        jmp .loop
.stop:
    mov rax, 1
    ret
    
.not_equals:
    mov rax, 0
    ret

    
; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    push 0
    mov rsi, rsp
    mov rax, 0
    mov rdi, 0
    mov rdx, 1
    syscall
    pop rax
    ret 

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
    mov r8, rdi
    mov r10, rdi ;save adress to remember the begining of string
    mov r9, rsi
    .loop: 
        call read_char
        cmp rax, 0x20 
        je .loop
        cmp rax, 0x9
        je .loop
        cmp rax, 0xA
        je .loop
    .word_reader:
        cmp rax, 0
        je .end
        cmp rax, 0x20
        je .end
        cmp rax, 0x9
        je .end
        cmp rax, 0xA
        je .end
        dec r9
        cmp r9, 0
        je .overflow
        mov byte[r8], al
        inc r8
        call read_char
        jmp .word_reader
    .overflow:
        xor rax, rax
        ret     
    .end:
        mov byte[r8], 0
	mov rdx, r8
        sub rdx, r10
        mov rax, r10
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rcx, rcx
    xor rax, rax
    xor r8, r8
    mov r10, 10
    .loop:
        mov al, byte[rdi+rcx]
        cmp al, "0"
        jb .fine
        cmp al, "9"
        ja .fine
        sub al, "0"
        push rax
 
        mov rax, r8
        mul r10
        mov r8, rax
        
        pop rax
        add r8, rax
        inc rcx
        jmp .loop
    .fine:
    mov rdx, rcx
    mov rax, r8
    ret





; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    mov al, byte[rdi]
    cmp al, "-"
    jne parse_uint
    inc rdi
    call parse_uint
    cmp rdx, 0
    je .end
    neg rax
    inc rdx
.end:
    ret


; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    call string_length
    inc rax
    cmp rdx, rax
    jb .error
    xor rax, rax
    .loop:
        mov dl, byte[rdi+rax]
        mov byte[rsi+rax], dl
        inc rax
        cmp dl, 0
        jne .loop
    ret
.error:
    xor rax, rax
    ret


