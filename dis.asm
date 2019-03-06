.model small

.stack 100h

.DATA
lineBreak db 0Ah
printErrorFile db 0Ah, "*** FILE ERROR ***$"

currentAddress dw ?
printSomeTabs db "                                   "

inputFile db "task1.com", 0
inputFileHandle dw ?
inputFileContent db 255d dup("$")
inputFileSize dw ?

outputFile db "RESULTS.txt", 0
outputFileHandle dw ?
outputFileContent db 255d dup("$")

whatToPrintByte dw ?
whatToPrintWord dw ?
expand_f db "F"
expand_0 db "0"

printWelcome db ">>Hello. Welcome to disassembler.<<", "$"
printGoodbye db 0Ah, ">>Disassembling has finished successfully. Goodbye!<<$"

farThing db "far "
jumpRange db 0
printOneZero db "0"
wasPrefixFound db ?
shouldPrefixBeChecked db 1h
commaSpace db ",", " "
squareBracketOpen db "["
squareBracketClose db "]"
printColon db ":"
bytePtr db "byte ptr "
wordPtr db "word ptr "

currentSegment db ?, "s"
howManyBytes db ?
howManyBytesInaRow db ?

instr_add db "add "
instr_push db "push "
instr_pop db "pop "
instr_sub db "sub "
instr_cmp db "cmp "
instr_inc db "inc "
instr_dec db "dec "
instr_jo db "jo "
instr_jno db "jno "
instr_jnae db "jnae "
instr_jae db "jae "
instr_je db "je "
instr_jne db "jne "
instr_jbe db "jbe "
instr_ja db "ja "
instr_js db "js "
instr_jns db "jns "
instr_jp db "jp "
instr_jnp db "jnp "
instr_jl db "jl "
instr_jge db "jge "
instr_jle db "jle "
instr_jg db "jg "
instr_mov db "mov "
instr_call db "call "
instr_ret db "ret "
instr_retf db "retf "
instr_int db "int "
instr_loop db "loop "
instr_jcxz db "jcxz "
instr_jmp db "jmp "
instr_mul db "mul "
instr_div db "div "
instr_xor db "xor "

r_w_0 db "al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"
r_w_1 db "ax", "cx", "dx", "bx", "sp", "bp", "si", "di"

r_seg db "es", "cs", "ss", "ds"
r_es db "es"
r_cs db "cs"
r_ss db "ss"
r_ds db "ds"

r_bx_si db "bx + si"
r_bx_di db "bx + di"
r_bp_si db "bp + si"
r_bp_di db "bp + di"
r_bx_si_offset db "bx + si + "
r_bx_di_offset db "bx + di + "
r_bp_si_offset db "bp + si + "
r_bp_di_offset db "bp + di + "
r_si_offset db "si + "
r_di_offset db "di + "
r_bp_offset db "bp + "
r_bx_offset db "bx + "

r_ax db "ax"
r_ah db "ah"
r_al db "al"
r_bx db "bx"
r_bh db "bh"
r_bl db "bl"
r_cx db "cx"
r_ch db "ch"
r_cl db "cl"
r_dx db "dx"
r_dh db "dh"
r_dl db "dl"
r_sp db "sp"
r_bp db "bp"
r_si db "si"
r_di db "di"

info_d db ?
info_w db ?
info_mod db ?
info_reg db ?
info_rm db ?
currentByte db ?

howManyBytesBO db ?
shouldPtrBeUsed db ?
write_byte_ptr db "byte ptr "
write_word_ptr db "word ptr "
whereIsSR db ?

printCommandNotFound db "*Byte not recognised*"
printFound db "Found a command!", 0Ah

.CODE

commandNotFound:
  push ax
  push bx
  push cx
  push dx
	mov howManyBytesInaRow, 1h
	call printBytesInSequence
  mov ah, 40h
  mov bx, outputFileHandle
  mov cx, 21d
  lea dx, printCommandNotFound
  int 21h
  jc fileError
  pop dx
  pop cx
  pop bx
  pop ax
  ret

printToOutput: ;parameters are passed with dx and cl
  push ax
  push bx
	push cx
  xor ch, ch
	xor al, al
  mov bx, outputFileHandle
  ; mov cl, c_mov_length
  ; lea dx, c_mov
  mov ah, 40h
  int 21h
  jc fileError

	pop cx
  pop bx
  pop ax
  ret

fileError:
  mov ah, 09h
  lea dx, printErrorFile
  int 21h
  mov ah, 4Ch
  int 21h

newLine:
  mov ah, 40h
  mov bx, outputFileHandle
  mov cx, 1h
  lea dx, lineBreak
  int 21h
  ret

get_w_info:
  test bl, 1b
  jnz set_w_1
  mov info_w, 00h
  ret
  set_w_1:
  mov info_w, 1b
  ret

get_d_info:
  test bl, 10b
  jnz set_d_1
  mov info_d, 0
  ret
  set_d_1:
  mov info_d, 01h
  ret

get_mod_info:
	push cx
	mov cl, bl
	ror cl, 6
	and cl, 11b
	mov info_mod, cl
	pop cx
	ret

get_reg_info:
	push cx

	mov cl, bl
	ror cl, 3
	and cl, 111b
	mov info_reg, cl

	pop cx
	ret

get_rm_info:
	push cx

	mov cl, bl
	and cl, 111b
	mov info_rm, cl

	pop cx
	ret

shouldPrefixBeUsed:
	push ax
	push cx
	push dx
	cmp wasPrefixFound, 1b
	je prefixWasFound
	jmp ENDshouldPrefixBeUsed
	prefixWasFound:
	xor ah, ah
	mov al, currentSegment
	lea dx, r_seg
	add dx, ax
	mov cl, 2h
	call printToOutput
	mov cl, 1h
	lea dx, printColon
	call printToOutput
	ENDshouldPrefixBeUsed:
	pop dx
	pop cx
	pop ax
	ret



printCurrentAddress:
	push si
	push ax
	push cx
	push bx
	push dx
	lea bx, inputFileContent
	sub si, bx
	add si, 100h

	mov currentAddress, si

	mov whatToPrintWord, si
	call printWordRegisterValue

	lea dx, printColon
	mov cl, 1h
	call printToOutput
	lea dx, printSomeTabs
	mov cl, 2h
	call printToOutput
	pop dx
	pop bx
	pop cx
	pop ax
	pop si
	ret

printWordRegisterValue:
	push bx
	push si
	push cx
	push ax
	push dx
	; mov whatToPrintByte, 012h
	cmp whatToPrintWord, 0fffh
	ja dontPrintZero1
	mov cl, 1h
	lea dx, printOneZero
	call printToOutput
	cmp whatToPrintWord, 0ffh
	ja dontPrintZero1
	mov cl, 1h
	lea dx, printOneZero
	call printToOutput
	cmp whatToPrintWord, 0fh
	ja dontPrintZero1
	mov cl, 1h
	lea dx, printOneZero
	call printToOutput
	dontPrintZero1:
	mov ax, whatToPrintWord
	mov bx, 10h
	xor si, si
	xor dx, dx
	TwoDigits2:
		div bx
		inc si
		push dx
		xor dx, dx
		cmp ax, 0
		je printTwoDigits2
		jmp TwoDigits2

	printTwoDigits2:
		dec si
		pop dx
		cmp dx, 09h
		ja its_not_a_number2
		add dx, 30h
		jmp prepForPrinting2
		its_not_a_number2:
		add dx, 37h
		prepForPrinting2:
		mov currentByte, dl
		lea dx, currentByte
		mov cl, 1h
		call printToOutput
		cmp si, 0
		jne printTwoDigits2
		pop dx
		pop ax
		pop cx
		pop si
		pop bx
		ret

printByteRegisterValue:
	push bx
	push si
	push cx
	push ax
	push dx
	; mov whatToPrintByte, 012h
	mov ax, whatToPrintByte
	mov bl, 10h
	xor si, si
	mov cx, ax
	xor bh, bh
	TwoDigits:
		mov ax, cx
		div bl
		inc bh
		xor cx, cx
		mov cl, al
		xor al, al
		xchg al, ah
		push ax
		cmp cl, 0
		je printTwoDigits
		jmp TwoDigits

	printTwoDigits:
		dec bh
		pop dx
		cmp dx, 09h
		ja its_not_a_number
		add dx, 30h
		jmp prepForPrinting
		its_not_a_number:
		add dx, 37h
		prepForPrinting:
		mov currentByte, dl
		lea dx, currentByte
		mov cl, 1h
		call printToOutput
		cmp bh, 0
		jne printTwoDigits
		pop dx
		pop ax
		pop cx
		pop si
		pop bx
		ret

PROGRAM:

mov ax, @data
mov ds, ax

mov ah, 09h
lea dx, printWelcome
int 21h

openInputFile:
  mov ah, 3Dh
  xor al, al
  lea dx, inputFile
  int 21h
  jc fileError2
  mov inputFileHandle, ax

readInputFile:
  mov ah, 3Fh
  mov bx, inputFileHandle
  mov cx, 255d
  lea dx, inputFileContent
  int 21h
  jc fileError2
  dec ax
  mov inputFileSize, ax

closeInputFile:
  mov ah, 3Eh
  mov bx, inputFileHandle
  int 21h
  jc fileError2

createOutputFile:
  mov ah, 3Ch
  xor cx, cx
  lea dx, outputFile
  int 21h
  jc fileError2

jmp OpenOutputFile
fileError2:
  jmp fileError

openOutputFile:
  mov ah, 3Dh
  mov al, 01h
  lea dx, outputFile
  int 21h
  jc fileError2
  mov outputFileHandle, ax
;---------------------------------------------
mov si, offset inputFileContent
mov di, inputFileSize
add di, si

main:

  call getByte
  call analyseAndPrint

  call newLine
	mov shouldPrefixBeChecked, 1h
  jmp main

getByte:
	cmp si, di
	ja closeOutputFile5
	cmp shouldPrefixBeChecked, 0h
	je dontCheckPrefix
	call printCurrentAddress
	call checkPrefix
	dontCheckPrefix:
  mov bl, [si]
  inc si
  ret

printBytesInSequenceMod:
	push si
	push cx
	dec si
	; mov howManyBytesInaRow, 5h
	dec si
	cmp info_mod, 11b
	je modDontInc
	cmp info_mod, 00b
	je check_rm_is_110
	cmp info_mod, 10b
	je needTwoBytes
	inc howManyBytesInaRow
	jmp modDontInc
	check_rm_is_110:
	cmp info_rm, 110b
	jne modDontInc
	add howManyBytesInaRow, 2h
	jmp modDontInc
	needTwoBytes:
	add howManyBytesInaRow, 2h
	modDontInc:
	mov howManyBytes, 1h
	mov ch, howManyBytesInaRow
	mod_while_ch_is_0:
	cmp ch, 0
	je mod_ch_0
	call printNextHowManyBytes
	dec ch
	jmp mod_while_ch_is_0
	mod_ch_0:
	lea dx, printSomeTabs
	mov cl, 10h
	sub cl, howManyBytesInaRow
	sub cl, howManyBytesInaRow
	sub cl, wasPrefixFound
	sub cl, wasPrefixFound
	call printToOutput
	pop cx
	pop si
	ret

closeOutputFile5:
	jmp closeOutputFile4


printBytesInSequenceW:
	push si
	push cx
	dec si
	; mov howManyBytesInaRow, 5h
	call get_w_info
	cmp info_w, 0h
	je dontInc
	inc howManyBytesInaRow
	dontInc:
	mov howManyBytes, 1h
	mov ch, howManyBytesInaRow
	while_ch_is_0:
	cmp ch, 0
	je ch_0
	call printNextHowManyBytes
	dec ch
	jmp while_ch_is_0
	ch_0:
	lea dx, printSomeTabs
	mov cl, 10h
	sub cl, howManyBytesInaRow
	sub cl, howManyBytesInaRow
	sub cl, wasPrefixFound
	sub cl, wasPrefixFound
	call printToOutput
	pop cx
	pop si
	ret

printBytesInSequence_w_and_mod:
	push si
	push cx
	dec si
	; mov howManyBytesInaRow, 5h
	dec si
	cmp info_mod, 11b
	je nowCheckWord_wm
	cmp info_mod, 00b
	je check_rm_is_110_wm
	cmp info_mod, 10b
	je needTwoBytes_wm
	inc howManyBytesInaRow
	jmp nowCheckWord_wm
	check_rm_is_110_wm:
	cmp info_rm, 110b
	jne nowCheckWord_wm
	add howManyBytesInaRow, 2h
	jmp dontInc_wm
	needTwoBytes_wm:
	add howManyBytesInaRow, 2h
	nowCheckWord_wm:
	cmp info_w, 0b
	je dontInc_wm
	inc howManyBytesInaRow
	dontInc_wm:
	mov howManyBytes, 1h
	mov ch, howManyBytesInaRow
	wm_while_ch_is_0:
	cmp ch, 0
	je wm_ch_0
	call printNextHowManyBytes
	dec ch
	jmp wm_while_ch_is_0
	wm_ch_0:
	lea dx, printSomeTabs
	mov cl, 10h
	sub cl, howManyBytesInaRow
	sub cl, howManyBytesInaRow
	sub cl, wasPrefixFound
	sub cl, wasPrefixFound
	call printToOutput
	pop cx
	pop si
	ret

printBytesInSequence_w_and_mod_and_s:
	push si
	push cx
	dec si
	; mov howManyBytesInaRow, 5h
	dec si
	cmp info_mod, 11b
	je nowCheckWord_wms
	cmp info_mod, 00b
	je check_rm_is_110_wms
	cmp info_mod, 10b
	je needTwoBytes_wms
	inc howManyBytesInaRow
	jmp nowCheckWord_wms
	check_rm_is_110_wms:
	cmp info_rm, 110b
	jne nowCheckWord_wms
	add howManyBytesInaRow, 2h
	jmp dontInc_wms
	needTwoBytes_wms:
	add howManyBytesInaRow, 2h
	nowCheckWord_wms:
	cmp info_d, 0b
	je justRegularWord
	jmp dontInc_wms
	justRegularWord:
	cmp info_w, 0b
	je dontInc_wms
	inc howManyBytesInaRow
	dontInc_wms:
	mov howManyBytes, 1h
	mov ch, howManyBytesInaRow
	wms_while_ch_is_0:
	cmp ch, 0
	je wms_ch_0
	call printNextHowManyBytes
	dec ch
	jmp wms_while_ch_is_0
	wms_ch_0:
	lea dx, printSomeTabs
	mov cl, 10h
	sub cl, howManyBytesInaRow
	sub cl, howManyBytesInaRow
	sub cl, wasPrefixFound
	sub cl, wasPrefixFound
	call printToOutput
	pop cx
	pop si
	ret

printBytesInSequence:
	push si
	push cx
	dec si
	; mov howManyBytesInaRow, 5h
	mov howManyBytes, 1h
	mov ch, howManyBytesInaRow
	printUntil_ch_is_0:
	cmp ch, 0
	je ch_is_0
	call printNextHowManyBytes
	dec ch
	jmp printUntil_ch_is_0
	ch_is_0:
	lea dx, printSomeTabs
	mov cl, 10h
	sub cl, howManyBytesInaRow
	sub cl, howManyBytesInaRow
	sub cl, wasPrefixFound
	sub cl, wasPrefixFound
	call printToOutput
	pop cx
	pop si
	ret

closeOutputFile4:
	jmp closeOutputFile3


checkPrefix:
	push ax
	push bx
	mov shouldPrefixBeChecked, 0h
	mov bl, [si]
	cmp bl, 26h
	je prefix_is_es
	cmp bl, 2Eh
	je prefix_is_cs
	cmp bl, 36h
	je prefix_is_ss
	cmp bl, 3Eh
	je prefix_is_ds
	mov wasPrefixFound, 0b
	jmp checkPrefixEnd
	prefix_is_es:
	; mov al, r_es
	; mov currentSegment, al
	mov currentSegment, 0h
	jmp foundPrefix
	prefix_is_cs:
	; mov al, r_cs
	; mov currentSegment, al
	mov currentSegment, 2h
	jmp foundPrefix
	prefix_is_ss:
	; mov al, r_ss
	; mov currentSegment, al
	mov currentSegment, 4h
	jmp foundPrefix
	prefix_is_ds:
	; mov al, r_ds
	; mov currentSegment, al
	mov currentSegment, 6h
	foundPrefix:
	mov wasPrefixFound, 1b
	xor bh, bh
	mov whatToPrintByte, bx
	call printByteRegisterValue
	inc si
	checkPrefixEnd:
	pop bx
	pop ax
	ret


closeOutputFile3:
	jmp closeOutputFile2

howFarToJump:
	push bx
	push ax
	push dx
	push cx
	xor ch, ch
	mov cl, howManyBytesInaRow
	mov ax, currentAddress
	add ax, cx
	add al, [si]
	; mov bh, [si]
	; cmp bh, 080h
	; jb jump
	; cmp jumpRange, 1h
	; je jump
	; sub ax, 100h
	; mov jumpRange, 01h
	; jump:
	mov whattoPrintWord, ax
	call printWordRegisterValue
	inc si
	pop cx
	pop dx
	pop ax
	pop bx
	ret

howFarToJumpWord:
	push bx
	push ax
	mov al, [si]
	inc si
	mov ah, [si]
	add ax, currentAddress
	add al, howManyBytesInaRow
	mov whattoPrintWord, ax
	call printWordRegisterValue
	inc si
	pop ax
	pop bx
	ret

analyseAndPrint:
  cmp bl, 03h
  jbe add1
	cmp bl, 05h
	jbe add2
	cmp bl, 06h
	je push1
	cmp bl, 16h
	je push1
	cmp bl, 0Eh
	je push1
	cmp bl, 1Eh
	je push1
	jmp analyseAndPrint1
  add1:
		call get_instr_category_2_info
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceMod
		call get_reg_info
		lea dx, instr_add
		mov cl, 4
		call printToOutput
		call print_rm_or_reg_in_proper_order
    ret
	add2: ;neįmanoma žinot ar prie ax bus pridedama 2 baitai ar vienas
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceW
		mov cl, 4
		lea dx, instr_add
		call printToOutput
		call print_accumulator_and_bytes
		ret
	push1:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 5
		lea dx, instr_push
		call printToOutput
		mov cl, 2
		mov whereIsSR, 3h
		call findSegment
		lea dx, currentSegment
		call printToOutput
		ret

analyseAndPrint1:
	cmp bl, 07h
	je pop1
	cmp bl, 17h
	je pop1
	cmp bl, 0Fh
	je pop1
	cmp bl, 1Fh
	je pop1
	cmp bl, 28h
	je sub1
	cmp bl, 29h
	je sub1
	cmp bl, 2Ah
	je sub1
	cmp bl, 2Bh
	je sub1 ;pabandyt padaryt intervalą instead
	cmp bl, 2Ch
	je sub2
	cmp bl, 2Dh
	je sub2
	cmp bl, 38h
	je cmp1
	cmp bl, 39h
	je cmp1
	cmp bl, 3Ah
	je cmp1
	cmp bl, 3Bh
	je cmp1
	jmp analyseAndPrint2
jmp commandNotRecognised1
	pop1:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 4
		lea dx, instr_pop
		call printToOutput
		mov cl, 2
		mov whereIsSR, 3h
		call findSegment
		lea dx, currentSegment
		call printToOutput
		ret
	sub1:
		call get_instr_category_2_info
		call get_reg_info
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceMod
		mov cl, 4h
		lea dx, instr_sub
		call printToOutput
		call print_rm_or_reg_in_proper_order
		ret
	sub2:
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceW
		mov cl, 4h
		lea dx, instr_sub
		call printToOutput
		call print_accumulator_and_bytes
		ret
	cmp1:
		call get_instr_category_2_info
		call get_reg_info
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceMod
		mov cl, 4h
		lea dx, instr_cmp
		call printToOutput
		call print_rm_or_reg_in_proper_order
		ret
	xor1:
		call get_instr_category_2_info
		call get_reg_info
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceMod
		lea dx, instr_xor
		mov cl, 4h
		call printToOutput
		call print_rm_or_reg_in_proper_order
		ret


analyseAndPrint2:
		cmp bl, 30h
		je xor1
		cmp bl, 31h
		je xor1
		cmp bl, 32h
		je xor1
		cmp bl, 33h
		je xor1
		cmp bl, 3Ch
		je cmp2
		cmp bl, 3Dh
		je cmp2
		cmp bl, 40h
		jb commandNotRecognised1
		cmp bl, 47h
		jbe inc1
		cmp bl, 48h
		jb commandNotRecognised1
		cmp bl, 4Fh
		jbe dec1
		cmp bl, 50h
		jb commandNotRecognised1
		cmp bl, 57h
		jbe push2
		cmp bl, 58h
		jb commandNotRecognised1
		cmp bl, 5Fh
		jbe pop2
		cmp bl, 70h
	jmp analyseAndPrint3
	cmp2:
		mov howManyBytesInaRow, 2h
		call printBytesInSequenceW
		mov cl, 4h
		lea dx, instr_cmp
		call printToOutput
		call print_accumulator_and_bytes
		ret
	inc1:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_inc
		call printToOutput
		call printWordRegister
		ret
	dec1:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_dec
		call printToOutput
		call printWordRegister
		ret
	push2:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 5d
		lea dx, instr_push
		call printToOutput
		call printWordRegister
		ret
		commandNotRecognised1:
		jmp commandNotRecognised2
	pop2:
		mov howManyBytesInaRow, 1h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_pop
		call printToOutput
		call printWordRegister
		ret


	analyseAndPrint3:
		je jo1
		cmp bl, 71h
		je jno1
		cmp bl, 72h
		je jnae1
		cmp bl, 73h
		je jae1
		cmp bl, 74h
		je je1
	jmp analyseAndPrint4
	jo1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_jo
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		; call printNextHowManyBytes
		ret
	jno1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jno
		call printToOutput
		mov howManyBytes, 2d
		call howFarToJump
		ret
	jnae1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 5d
		lea dx, instr_jnae
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	jae1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jae
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	je1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_je
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	jne1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jne
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret

commandNotRecognised2:
	jmp commandNotRecognised3

analyseAndPrint4:
	cmp bl, 75h
	je jne1
	cmp bl, 76h
	je jbe1
	cmp bl, 77h
	je ja1
	cmp bl, 78h
	je js1
	cmp bl, 79h
	je jns1
	cmp bl, 7ah
	je jp1
	jmp analyseAndPrint5
	jbe1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jbe
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	ja1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_ja
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	js1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_js
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	jns1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jns
		call printToOutput
		mov howManyBytes, 1d
		call howFarToJump
		ret
	jp1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_jp
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	jnp1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jnp
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	jl1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_jl
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	jge1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jge
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret

commandNotRecognised3:
	jmp commandNotRecognised4

	analyseAndPrint5:
	cmp bl, 7bh
	je jnp1
	cmp bl, 7ch
	je jl1
	cmp bl, 7dh
	je jge1
	cmp bl, 7eh
	je jle1
	cmp bl, 7fh
	je jg1
	cmp bl, 80h
	jb commandNotRecognised3
	cmp bl, 83h
	jbe add3_or_sub3_or_cmp3
	cmp bl, 88h
	jb commandNotRecognised3
	jmp analyseAndPrint6
	jle1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 4d
		lea dx, instr_jle
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	jg1:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		mov cl, 3d
		lea dx, instr_jg
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	add3_or_sub3_or_cmp3: ;here d = s
		call get_instr_category_2_info
		call get_reg_info
		mov howManyBytesInaRow, 3h
		call printBytesInSequence_w_and_mod_and_s
		cmp info_reg, 000b
		je add3
		cmp info_reg, 101b
		je sub3
		cmp3:
			mov cl, 4h
			lea dx, instr_cmp
			call printToOutput
			call print_something_ptr
			call print_rm
			call printCommaSpace
			call printBO
			ret
		add3:
			mov cl, 4h
			lea dx, instr_add
			call printToOutput
			call print_something_ptr
			call print_rm
			call printCommaSpace
			call printBO
			ret
		sub3:
			mov cl, 4h
			lea dx, instr_sub
			call printToOutput
			call print_something_ptr
			call print_rm
			call printCommaSpace
			call printBO
			ret
	mov1:
		call get_instr_category_2_info
		call get_reg_info
		mov howManyBytesInaRow, 2
		call printBytesInSequenceMod
		lea dx, instr_mov
		mov cl, 4h
		call printToOutput
		call print_rm_or_reg_in_proper_order
		ret

	analyseAndPrint6:
		cmp bl, 8bh
		jbe mov1
		cmp bl, 8fh
		je pop3
		cmp bl, 8ch
		je mov2
		cmp bl, 8eh
		je mov2
		cmp bl, 9ah
		je call1
	jmp analyseAndPrint7
	pop3:
		call get_instr_category_2_info
		mov howManyBytesInaRow, 2
		call printBytesInSequenceMod
		lea dx, instr_pop
		mov cl, 4h
		call printToOutput
		call print_something_ptr
		call print_rm
		ret
	mov2:
		call get_instr_category_2_info
		mov howManyBytesInaRow, 2
		call printBytesInSequenceMod
		lea dx, instr_mov
		mov cl, 4h
		call printToOutput
		mov info_w, 1h
		;here reg = sr, w = ???
		cmp info_d, 0h
		je destination_is_rm2
		mov al, currentSegment
		mov whereIsSR, 3h
		call findSegment
		lea dx, currentSegment
		mov cl, 2h
		call printToOutput
		call printCommaSpace
		mov currentSegment, al
		call print_rm
		ret
		destination_is_rm2:
		call print_rm
		call printCommaSpace
		mov whereIsSR, 3h
		call findSegment
		lea dx, currentSegment
		mov cl, 2h
		call printToOutput
		ret
	call1:
		mov howManyBytesInaRow, 5h
		call printBytesInSequence
		lea dx, instr_call
		mov cl, 5h
		call printToOutput
		mov howManyBytes, 2h
		call printNextHowManyBytes
		lea dx, printColon
		mov cl, 1h
		call printToOutput
		call printNextHowManyBytes
		ret

	commandNotRecognised4:
		call commandNotRecognised5
		ret

analyseAndPrint7:
	cmp bl, 0a0h
	je mov3
	cmp bl, 0a1h
	je mov3
	cmp bl, 0a2h
	je mov4
	cmp bl, 0a3h
	je mov4
	jmp analyseAndPrint8
	mov3:
		call get_w_info
		mov howManyBytesInaRow, 3h
		call printBytesInSequence
		lea dx, instr_mov
		mov cl, 4h
		call printToOutput
		cmp info_w, 1b
		je mov4_w_is_1
		mov4_w_is_0:
		lea dx, r_al
		mov cl, 2h
		call printToOutput
		call printCommaSpace
		call printSquareBracketOpen
		mov howManyBytes, 2h
		call printNextHowManyBytes
		call printSquareBracketClose
		ret
		mov4_w_is_1:
		lea dx, r_ax
		mov cl, 2h
		call printToOutput
		call printCommaSpace
		call printSquareBracketOpen
		mov howManyBytes, 2h
		call printNextHowManyBytes
		call printSquareBracketClose
		ret
	mov4:
		mov howManyBytesInaRow, 3h
		call printBytesInSequence
		lea dx, instr_mov
		mov cl, 4h
		call printToOutput
		call get_w_info
		cmp info_w, 1b
		je mov3_w_is_1
		mov3_w_is_0:
		call printSquareBracketOpen
		mov howManyBytes, 2h
		call printNextHowManyBytes
		call printSquareBracketClose
		call printCommaSpace
		lea dx, r_al
		mov cl, 2h
		call printToOutput
		ret
		mov3_w_is_1:
		call printSquareBracketOpen
		mov howManyBytes, 2h
		call printNextHowManyBytes
		call printSquareBracketClose
		call printCommaSpace
		lea dx, r_ax
		mov cl, 2h
		call printToOutput
		ret

	commandNotRecognised5:
		jmp commandNotRecognised6

	analyseAndPrint8:
		cmp bl, 0b0h
		jb commandNotRecognised5
		cmp bl, 0bfh
		jbe mov5
		cmp bl, 0c2h
		je ret1
		cmp bl, 0c3h
		je ret2
		cmp bl, 0c6h
		je mov6
		cmp bl, 0c7h
		je mov6
	jmp analyseAndPrint9
		mov5:
			mov ch, bl
			and ch, 111b
			mov info_reg, ch
			mov ch, bl
			shr ch, 3
			and ch, 1b
			mov info_w, ch
			cmp info_w, 0b
			je onlyTwoInaRow
			mov howManyBytesInaRow, 3h
			call printBytesInSequence
			jmp printTheThing
			onlyTwoInaRow:
			mov howManyBytesInaRow, 2h
			call printBytesInSequence
			printTheThing:
			lea dx, instr_mov
			mov cl, 4h
			call printToOutput
			call print_reg
			call printCommaSpace
			mov al, info_w
			inc al
			mov howManyBytes, al
			call printNextHowManyBytes
			ret
		ret1:
			mov howManyBytesInaRow, 3h
			call printBytesInSequence
			lea dx, instr_ret
			mov cl, 4h
			call printToOutput
			mov howManyBytes, 2h
			call printNextHowManyBytes
			ret
		ret2:
			mov howManyBytesInaRow, 1h
			call printBytesInSequence
			lea dx, instr_ret
			mov cl, 4h
			call printToOutput
			ret
		mov6:
			call get_instr_category_2_info
			mov howManyBytesInaRow, 3h
			call printBytesInSequence_w_and_mod
			lea dx, instr_mov
			mov cl, 4h
			call printToOutput
			cmp info_mod, 11b
			je dont_print_something_ptr
			call print_something_ptr
			dont_print_something_ptr:
			call print_rm
			call printCommaSpace
			mov al, info_w
			inc al
			mov howManyBytes, al
			call printNextHowManyBytes
			ret
		retf1:
			mov howManyBytesInaRow, 3h
			call printBytesInSequence
			lea dx, instr_retf
			mov cl, 5h
			call printToOutput
			mov howManyBytes, 2h
			call printNextHowManyBytes
			ret

	commandNotRecognised6:
    jmp commandNotRecognised



	analyseAndPrint9:
		cmp bl, 0cah
		je retf1
		cmp bl, 0cbh
		je retf2
		cmp bl, 0cdh
		je int1
		cmp bl, 0e2h
		je loop1
		cmp bl, 0e3h
		je jcxz1
		cmp bl, 0e8h
		je call2
		cmp bl, 0e9h
		je jmp1
	jmp analyseAndPrint10
		retf2:
			mov howManyBytesInaRow, 1h
			call printBytesInSequence
			lea dx, instr_retf
			mov cl, 5h
			call printToOutput
			ret
		int1:
			mov howManyBytesInaRow, 2h
			call printBytesInSequence
			lea dx, instr_int
			mov cl, 4h
			call printToOutput
			mov howManyBytes, 1h
			call printNextHowManyBytes
			ret
		loop1:
			mov howManyBytesInaRow, 2h
			call printBytesInSequence
			lea dx, instr_loop
			mov cl, 5h
			call printToOutput
			mov howManyBytes, 1h
			call howFarToJump
			ret
		jcxz1:
			mov howManyBytesInaRow, 2h
			call printBytesInSequence
			lea dx, instr_jcxz
			mov cl, 5h
			call printToOutput
			mov howManyBytes, 1h
			call howFarToJump
			ret
		call2:
			mov howManyBytesInaRow, 3h
			call printBytesInSequence
			lea dx, instr_call
			mov cl, 5h
			call printToOutput
			mov howManyBytes, 1h
			call howFarToJumpWord
			ret
		jmp1:
			mov howManyBytesInaRow, 3h
			call printBytesInSequence
			lea dx, instr_jmp
			mov cl, 4h
			call printToOutput
			mov howManyBytes, 1h
			call howFarToJumpWord
			ret
		jmp2:
			mov howManyBytesInaRow, 5h
			call printBytesInSequence
			lea dx, instr_jmp
			mov cl, 4h
			call printToOutput
			mov howManyBytes, 2h
			call printNextHowManyBytes
			lea dx, printColon
			mov cl, 1h
			call printToOutput
			call printNextHowManyBytes
			ret

analyseAndPrint10:
	cmp bl, 0eah
	je jmp2
	cmp bl, 0ebh
	je jmp3
	cmp bl, 0f6h
	je mul1_or_div1
	cmp bl, 0f7h
	je mul1_or_div1
	jmp analyseAndPrint11
	jmp3:
		mov howManyBytesInaRow, 2h
		call printBytesInSequence
		lea dx, instr_jmp
		mov cl, 4h
		call printToOutput
		mov howManyBytes, 1h
		call howFarToJump
		ret
	mul1_or_div1:
		call get_instr_category_2_info
		call get_reg_info
		cmp info_reg, 100b
		je mul1
		div1:
			mov howManyBytesInaRow, 2h
			call printBytesInSequenceMod
			lea dx, instr_div
			mov cl, 4h
			call printToOutput
			call print_something_ptr
			call print_rm
			ret
		mul1:
			mov howManyBytesInaRow, 2h
			call printBytesInSequenceMod
			lea dx, instr_mul
			mov cl, 4h
			call printToOutput
			call print_something_ptr
			call print_rm
			ret

  commandNotRecognised7:
    jmp commandNotRecognised

analyseAndprint11:
	cmp bl, 0feh
	je  call_jmp_push_inc_or_dec
	cmp bl, 0ffh
	je call_jmp_push_inc_or_dec
jmp commandNotRecognised
call_jmp_push_inc_or_dec:
	call get_instr_category_2_info
	call get_reg_info
	mov howManyBytesInaRow, 2h
	call printBytesInSequenceMod
	cmp info_w, 0b
	je inc2_or_dec2
		cmp info_reg, 010b
		je call3
		cmp info_reg, 011b
		je call4
		cmp info_reg, 100b
		je jmp4
		cmp info_reg, 101b
		je jmp5
	push3:
		lea dx, instr_push
		mov cl, 5h
		call printToOutput
		call print_something_ptr
		call print_rm
		ret
	jmp5:
		lea dx, instr_jmp
		mov cl, 4h
		call printToOutput
		lea dx, farThing
		mov cl, 4h
		call printToOutput
		call print_rm
		ret
	jmp4:
		lea dx, instr_jmp
		mov cl, 4h
		call printToOutput
		call print_rm
		ret
	call4:
		lea dx, instr_call
		mov cl, 5h
		call printToOutput
		lea dx, farThing
		mov cl, 4h
		call printToOutput
		call print_rm
		ret
	call3:
		lea dx, instr_call
		mov cl, 5h
		call printToOutput
		call print_rm
		ret
	inc2_or_dec2:
		cmp info_reg, 000b
		je inc2
		dec2:
			lea dx, instr_dec
			mov cl, 4h
			call printToOutput
			call print_something_ptr
			call print_rm
			ret
		inc2:
			lea dx, instr_inc
			mov cl, 4h
			call printToOutput
			call print_something_ptr
			call print_rm
			ret

commandNotRecognised:
  call commandNotFound
  ret


print_something_ptr:
	push dx
	push cx
	cmp info_mod, 11b
	je dontNeedPtr
	cmp info_w, 0b
	je print_byte_ptr
	lea dx, write_word_ptr
	mov cl, 9d
	call printToOutput
	jmp ENDprint_something_ptr
	print_byte_ptr:
	lea dx, write_byte_ptr
	mov cl, 9d
	call printToOutput
	ENDprint_something_ptr:
	pop cx
	pop dx
	ret
	dontNeedPtr:
		pop cx
		pop dx
		ret


printBO:
	push cx
	cmp info_d, 0b
	je s_is_0
	s_is_1:
	BO_is_byte_but_signed:
	mov ch, [si]
	rol ch, 1
	and ch, 1b
	cmp ch, 0h
	je expand_00
	expand_FF:
	mov cl, 1h
	lea dx, expand_f
	call printToOutput
	call printToOutput
	mov howManyBytes, 1d
	call printNextHowManyBytes
	pop cx
	ret
	expand_00:
	mov cl, 1h
	lea dx, expand_0
	call printToOutput
	call printToOutput
	mov howManyBytes, 1d
	call printNextHowManyBytes
	pop cx
	ret
	print_00:
	s_is_0:
	cmp info_w, 0b
	je BO_is_byte
	BO_is_word:
	mov HowManyBytes, 2h
	call printNextHowManyBytes
	pop cx
	ret
	BO_is_byte:
	mov howManyBytes, 1h
	call printNextHowManyBytes
	pop cx
	ret

printWordRegister:
	push bx
	push cx
	; push si
	mov ch, bl
	and ch, 111b
	shl ch, 1
	mov info_reg, ch
	lea bx, r_w_1
	add bl, info_reg
	mov cl, 2h
	mov dx, bx
	call printToOutput
	; pop si
	pop cx
	pop bx
	ret

print_accumulator_and_bytes:
	mov cl, 2
	call get_w_info
	cmp info_w, 0b
	je add2_w_is_0
	lea dx, r_ax
	call printToOutput
	call printCommaSpace
	mov howManyBytes, 2
	call printNextHowManyBytes
	ret
	add2_w_is_0:
	lea dx, r_al
	call printToOutput
	call printCommaSpace
	mov howManyBytes, 1
	call printNextHowManyBytes
	ret

print_rm_or_reg_in_proper_order:
	cmp info_d, 0h
	je destination_is_rm
	call print_reg
	call printCommaSpace
	call print_rm
	ret
	destination_is_rm:
	call print_rm
	call printCommaSpace
	call print_reg
	ret


fileError3:
  jmp fileError2

findSegment:
	push bx
	push ax
	push cx
	mov cl, whereIsSR
	ror bl, cl
	and bl, 03h
	cmp bl, 00b
	je segment_is_es
	cmp bl, 01b
	je segment_is_cs
	cmp bl, 10b
	je segment_is_ss
	segment_is_ds:
	mov al, r_ds
	mov currentSegment, al
	jmp findSegmentEnd
	segment_is_es:
	mov al, r_es
	mov currentSegment, al
	jmp findSegmentEnd
	segment_is_cs:
	mov al, r_cs
	mov currentSegment, al
	jmp findSegmentEnd
	segment_is_ss:
	mov al, r_ss
	mov currentSegment, al
	findSegmentEnd:
	pop cx
	pop ax
	pop bx
	ret

printCommaSpace:
	push cx
	push dx
	mov cl, 2d
	lea dx, commaSpace
	call printToOutput
	pop dx
	pop cx
	ret

get_instr_category_2_info:
	call get_w_info
	call get_d_info
	call getByte
	call get_mod_info
	call get_rm_info
	ret

closeOutputFile2:
	jmp closeOutputFile


print_rm:
	push bx
	push dx
	push cx
	cmp info_mod, 01b
	je mod_is_01_or_10 ;je mod_is_01
	cmp info_mod, 10b
	je mod_is_01_or_10; ;je mod_is_10
	cmp info_mod, 00b
	je mod_is_00reach

	mod_is_11:
	cmp info_w, 0h
	je rm_w_is_0
	rm_w_is_1:
	xor bh, bh
	mov ch, info_rm
	shl ch, 1
	mov bx, offset r_w_1
	add bl, ch
	mov cl, 2d
	mov dx, bx
	call printToOutput
	jmp print_rm_end
	rm_w_is_0:
	xor bh, bh
	mov ch, info_rm
	shl ch, 1
	mov bx, offset r_w_0
	add bl, ch
	mov cl, 2d
	mov dx, bx
	call printToOutput
	jmp print_rm_end

mod_is_00reach:
	jmp mod_is_00

	mod_is_01_or_10:
	call shouldPrefixBeUsed
	cmp info_mod, 10b
	je needToPrintWordOffset
	mov howManyBytes, 1h
	jmp continueWithPrinting
	needToPrintWordOffset:
	mov howManyBytes, 2h
	continueWithPrinting:
	call printSquareBracketOpen
	mov cl, 0ah
	cmp info_rm, 000b
	je rm_is_bx_si_offset
	cmp info_rm, 001b
	je rm_is_bx_di_offset
	cmp info_rm, 010b
	je rm_is_bp_si_offset
	cmp info_rm, 011b
	je rm_is_bp_di_offset
	mov cl, 5d
	cmp info_rm, 100b
	je rm_is_si_offset
	cmp info_rm, 101b
	je rm_is_di_offset
	cmp info_rm, 110b
	je rm_is_bp_offset
	rm_is_bx_offset:
	lea dx, r_bx_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_bx_si_offset:
	lea dx, r_bx_si_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_bx_di_offset:
	lea dx, r_bx_di_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_bp_si_offset:
	lea dx, r_bp_si_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_bp_di_offset:
	lea dx, r_bp_di_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_si_offset:
	lea dx, r_si_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_di_offset:
	lea dx, r_di_offset
	jmp print_rm_offset_and_square_bracket
	rm_is_bp_offset:
	lea dx, r_bp_offset
	jmp print_rm_offset_and_square_bracket

	mod_is_00:
	call shouldPrefixBeUsed
	call printSquareBracketOpen
	cmp info_rm, 110b
	je rm_is_address
	mov cl, 7d
	cmp info_rm, 000b
	je rm_is_bx_si
	cmp info_rm, 001b
	je rm_is_bx_di
	cmp info_rm, 010b
	je rm_is_bp_si
	cmp info_rm, 011b
	je rm_is_bp_di
	mov cl, 2d
	cmp info_rm, 100b
	je rm_is_si
	cmp info_rm, 101b
	je rm_is_di
	rm_is_bx:
	lea dx, r_bx
	jmp print_rm_and_square_bracket
	rm_is_bx_si:
	lea dx, r_bx_si
	jmp print_rm_and_square_bracket
	rm_is_bx_di:
	lea dx, r_bx_di
	jmp print_rm_and_square_bracket
	rm_is_bp_si:
	lea dx, r_bp_si
	jmp print_rm_and_square_bracket
	rm_is_bp_di:
	lea dx, r_bp_di
	jmp print_rm_and_square_bracket
	rm_is_si:
	lea dx, r_si
	jmp print_rm_and_square_bracket
	rm_is_di:
	lea dx, r_di
	jmp print_rm_and_square_bracket
	rm_is_address:
	mov howManyBytes, 2 ; OR 1
	call printNextHowManyBytes
	call printSquareBracketClose
	jmp print_rm_end
	; rm_above_011:

	print_rm_offset_and_square_bracket:
	call printToOutput
	cmp info_mod, 10b
	je needToPrintTwoBytes
	mov howManyBytes, 1
	jmp proceedWithPrinting
	needToPrintTwoBytes:
	mov howManyBytes, 2d
	proceedWithPrinting:
	call printNextHowManyBytes
	call printSquareBracketClose
	jmp print_rm_end
	print_rm_and_square_bracket:
	call printToOutput
	call printSquareBracketClose
	print_rm_end:
	pop cx
	pop dx
	pop bx
	ret

print_reg:
	push bx
	push dx
	push cx
	cmp info_w, 0h
	je reg_w_is_0
	reg_w_is_1:
	xor bh, bh
	mov ch, info_reg
	shl ch, 1
	mov bx, offset r_w_1
	add bl, ch
	mov cl, 2d
	mov dx, bx
	call printToOutput
	jmp print_reg_end
	reg_w_is_0:
	xor bh, bh
	xor cl, cl
	mov ch, info_reg
	shl ch, 1
	xchg ch, cl
	mov bx, offset r_w_0
	add bx, cx
	mov cl, 2d
	mov dx, bx
	call printToOutput
	print_reg_end:
	pop cx
	pop dx
	pop bx
	ret


printNextHowManyBytes:
	push bx
	push ax
	push dx
	push cx
	xor bh, bh
	mov ch, 1
	cmp howManyBytes, 1
	je printOnlyOneByte
	inc si
	printOnlyOneByte:
	call getByte
	xor ah, ah
	mov al, bl

	division:
	mov bl, 10h
	div bl
	mov cl, 1d
	print_the_number:
	cmp bh, 2
	jne changeToAscii
	jmp printSecondByte
	changeToAscii:
	cmp al, 9h
	ja not_a_number
	add al, 30h
	jmp actualPrinting
	not_a_number:
	add al, 37h
	actualPrinting:
	mov currentByte, al
	lea dx, currentByte
	call printToOutput
	inc bh
	mov al, ah
	jmp print_the_number

	printSecondByte:
	xor bh, bh
	cmp ch, howManyBytes
	je endprintNextHowManyBytes
	inc ch
	sub si, 2
	xor ah, ah
	mov al, [si]
	jmp division
	endprintNextHowManyBytes:
	cmp howManyBytes, 1
	je onlyOneByteWasUsed
	add si, 2
	onlyOneByteWasUsed:
	pop cx
	pop dx
	pop ax
	pop bx
	ret

printSquareBracketOpen:
	push cx
	push dx
	mov cl, 1d
	lea dx, squareBracketOpen
	call printToOutput
	pop dx
	pop cx
	ret

printSquareBracketClose:
	push cx
	push dx
	mov cl, 1d
	lea dx, squareBracketClose
	call printToOutput
	pop dx
	pop cx
	ret


fileError4: ;conditional jump out of reach :)
jmp fileError3


closeOutputFile:
  mov ah, 3Eh
  mov bx, outputFileHandle
  int 21h
  jc fileError4

exit:
  mov ah, 09h
  lea dx, printGoodbye
  int 21h

	mov al, info_mod

  mov ah, 4Ch
  int 21h
END PROGRAM
