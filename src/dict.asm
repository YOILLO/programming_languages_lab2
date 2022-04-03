section .text
global find_word

%include 'inc/lib.inc'
 
; rsi: адрес начала словаря
; rdi: указатель на строку

find_word:
.loop:
	push rsi 
	push rdi
	add rsi, 8 
	call string_equals			; Сравним строки
	pop rdi	
	pop rsi
	cmp rax, 0
	jne .found 				; Если равны, закончим
	mov rsi, [rsi] 				; Берем следующий элемент
	cmp rsi, 0
	je .end		 			; Если он 0, то закончим
	jmp .loop
.found:
    mov rax, rsi 
    ret
.end:
    xor rax, rax 
    ret

