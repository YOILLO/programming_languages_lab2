section .data

%include 'inc/word.inc'
%include 'inc/lib.inc'

extern find_word

%define BUFFER_SIZE 256
%define OFFSET 8

error: db 'Не могу считать слово.', 10, 0
found: db 'Найдено значение: ', 0
not_found: db 'Такого элемента нет(.', 10, 0
enter: db 'Введите ключ: ', 0

section .text
global _start

_start:
	mov rdi, enter
	call print_string
	sub rsp, BUFFER_SIZE
	mov rsi, BUFFER_SIZE
	mov rdi, rsp
	call read_word			;Читаем слово из stdin
	cmp rax, 0
	jz .err	
	mov rsi, current
	mov rdi, rax
	call find_word			;Ищем слово
	cmp rax, 0
	je .not_found
	add rax, OFFSET			;Печатаем найденное слово
	push rax
	mov rsi, rax
	call string_length 
	pop rsi
	add rax, rsi
	inc rax
	push rax
	mov rdi, found
	call print_string
	pop rdi
	call print_string
	call print_newline
	xor rdi, rdi
	jmp .end
.err:					;Если произошла ошибка при выводе
	mov rdi, error
	call print_string_err
	mov rdi, 1
	jmp .end
.not_found:				;Если слово не найдено
	mov rdi, not_found
	call print_string_err
	xor rdi, rdi	
	jmp .end
.end:					;В конце очищаем стек и заканчиваем
	add rsp, BUFFER_SIZE
	call exit

