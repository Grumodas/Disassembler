;Parašykite programą, kuri leidžia įvesti eilutę žodžių, atskirtų tarpais ir atspausdina šių žodžių ilgius;
;Pvz.: įvedus asd oprutp paoiujk turi atspausdinti 3 6 7

.model small

; .stack 100h

; .code
; .org 100h
BSeg SEGMENT
;***************************************************************

;*******************Pridėta*************************************
ORG	100h
ASSUME ds:BSeg, cs:BSeg, ss:BSeg

program:

; mov ax, @data
; mov ds, ax

mov ah, 09h
mov dx, offset enterWords
int 21h

mov ah, 0Ah
mov dx, offset buffer
int 21h

call NewLine

mov si, 2
xor dx, dx
xor cx, cx

letterCount:
mov bl, [buffer + si]
cmp bl, 0Dh		;checking if reached carriage return
je endOfString
cmp bl, 20h
je newWord
inc cx
inc si
xor bx, bx
jmp letterCount

newWord:
cmp cx, 9
ja prepareTwoDigits
mov dx, cx
add dx, 30h
mov ah, 02h
int 21h
xor cx, cx
xor dx, dx
inc si

mov ah, 02h
mov dx, 20h
int 21h
jmp letterCount

prepareTwoDigits:
xor di, di
mov bl, 0Ah

TwoDigits:
mov ax, cx
div bl
inc di
xor cx, cx
mov cl, al
xor al, al
xchg al, ah
push ax
cmp cl, 0
je printTwoDigits
jmp TwoDigits

printTwoDigits:
dec di
pop dx
add dx, 30h
mov ah, 02h
int 21h
cmp di, 0
jne printTwoDigits

call Space

cmp [buffer + si], 0Dh
je theEnd
xor cx, cx
inc si
jmp letterCount

endOfString:
cmp cx, 9
ja prepareTwoDigits
mov dx, cx
add dx, 30h
mov ah, 02h
int 21h

theEnd:
mov ah, 4Ch
int 21h
enterWords db "Iveskite eilute zodziu: $"
buffer db 255, ?, 255 dup('$')
lineBreak db 0Ah, 24h
td db "two digits $"
NewLine:
	mov ah, 09h
	mov dx, offset lineBreak
	int 21h
	ret

Space:
	mov ah, 02h
	mov dx, 20h
	int 21h
	ret


BSeg ENDS

END program
