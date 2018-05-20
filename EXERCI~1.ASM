;Computer Architecture
;Assignment Riccardo Persiani

DIM		EQU	9	   ;Dimension of the given vector of integer
CR		EQU	0DH
LF		EQU	0AH	   ;Create new line

	.MODEL small
	.STACK
	.DATA

; OF: overflow flag, forced to one if during an operation there is an overflow

VETT1	DB  15,16,17,18,19,20,21,22,23,24
VETT2	DB  DIM  DUP(?)
MATRIX	DW  DIM*DIM DUP(?)

STRING_2 DB 'THE MINIMUM OF VETT2 IS: '
STRING_3 DB 'THE MINIMUM OF VETT1 IS: '
STRING_4 DB 'MAX IN MATRIX: '
STRING_OF DB 'THERE IS AN OVERFLOW'

	.CODE
	.STARTUP

	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI

	MOV CX, DIM		   ;Need to scan every position of VETT2 to fill it
	MOV DI, 0		   ;Counter from 0 to 8
	MOV AH, 2		   ;Loading print function

lab1:	MOV BL, VETT1[DI]	   ;Setting BL for storing the addittion
	ADD BL, VETT1[DI+1]	   ;BL=A[j]+A[j+1]

	JC oflow		   ;Jump if overflow in the addition

	MOV VETT2[DI], BL	   ;B[j]=BL

	MOV DL, VETT2[DI]	   ;Setting the j-element for print it
	INT 21H 		   ;Print the value

	INC DI			   ;Move on the vector position
	DEC CX			   ;CX-1 counter decrease
	CMP CX,0		   ;Continue if the vector is completly filled
	JNZ lab1		   ;If not completed, cicle again

	MOV DI,0		   ;Counter from 0 to 8
	MOV CX, DIM-1		   ;From 0 to 8 for 9 values

	MOV BL, VETT2[DI]	   ;BL contains always the MIN value of VETT2
lab2:	CMP BL, VETT2[DI+1]	   ;Is BL < VETT[DI+1] ?
	JL lab3 		   ;If yes BL is the minimum value of the cmp

	MOV BL, VETT2[DI+1]	   ;If no set VETT2[DI+1] as MIN in BL

lab3:	INC DI
	DEC CX
	CMP CX, 0		   ;Scan every postion of the vector
	JNZ lab2		   ;If no, continue to scan it

	MOV DL,CR
	INT 21H
	MOV DL,LF
	INT 21H

	MOV AH,2		    ;Load print function for MIN VETT2
	MOV CX,25		    ;String length
	LEA SI, STRING_2	    ;Address of the string
s2:	MOV DL, [SI]		    ;Move in dl the content of the address
	INT 21H 		    ;Print single char
	INC SI
	DEC CX
	CMP CX,0
	JNZ s2

	MOV DL, BL		   ;Prepare MIN of VETT2 to be printed
	INT 21H 		   ;Print

	MOV DI,0
	MOV CX, DIM
	MOV BL, VETT1[DI]	   ;Using BL for storing the MIN of VETT1
lab4:	CMP BL, VETT1[DI+1]	   ;Check which is the MIN value
	JL lab5 		   ;Jump if the MIN value is already in BL

	MOV BL, VETT1[DI+1]	   ;Store the new MIN value in BL

lab5:	INC DI
	DEC CX
	CMP CX,0
	JNZ lab4

	MOV DL, CR
	INT 21H
	MOV DL, LF
	INT 21H

	MOV AH,2		    ;Load print function for MIN of VETT1
	MOV CX,25		    ;String length
	LEA SI, STRING_3	    ;Address of the string
s3:	MOV DL, [SI]		    ;Move in DL the content of the address
	INT 21H 		    ;Print the single char
	INC SI
	DEC CX
	CMP CX,0
	JNZ s3

	MOV DL, BL		    ;Prepare MIN of VETT1 for printing
	INT 21H 		    ;Print

	MOV DL, CR
	INT 21H
	MOV DL, LF
	INT 21H

	XOR SI, SI		    ;SI counter for rows
	XOR BX, BX		    ;BX counter for columns
	XOR DI, DI		    ;DI will contain the MAX value
	XOR CX, CX		    ;CX additional register

mult:	MOV AL, VETT1[DI]	    ;Load the first factor(VETT1[i])
	MUL VETT2[BX]		    ;Multiply with the second factor(VETT2[j])

	SHL BX,1		    ;BX*2, 16 bits column index
	SHL SI,1		    ;SI*2, 16 bits row index

	MOV MATRIX[SI][BX], AX	    ;Store the product in MATRIX

	SHR BX,1		    ;Restore counter values dividing by 2
	SHR SI,1

	CMP CX, AX		    ;CX < MATRIX[SI][BX] ?
	JA notf			    ;If CX > MATRIX[SI][BX] jump

	MOV CX, AX		    ;Otherwise store the bigger value in CX

notf:	INC BX			    ;Increas column index and position of VETT2
	CMP BX, DIM		    ;If BX=9 change to the next row
	JNE mult

	ADD SI,9		    ;Go to the next row
	INC DI			    ;Increase values of the VETT1
	XOR BX,BX		    ;Go to the first column

	CMP SI, DIM*DIM
	JNE mult		    ;Go out if all the matrix is completely filled

	PUSH CX 		    ;Save MAX value
	MOV AH,2		    ;Load print function
	MOV CX,15		    ;String length
	LEA SI, STRING_4	    ;Address of the string
s4:	MOV DL, [SI]		    ;Move in DL the content of the address
	INT 21H 		    ;Print single char
	INC SI
	DEC CX
	CMP CX,0
	JNZ s4

	POP CX			    ;Pop MAX value from the stack
	MOV DX, CX		    ;Prepare MAX Value to be printed
	INT 21H 		    ;Print
	jmp esci

oflow:	MOV AH, 2		    ;Overflow detected

	MOV DL,CR		    ;Go down in the layout
	INT 21H
	MOV DL, LF
	INT 21H

	LEA SI, STRING_OF	    ;Pointer to the STRING_OF
	MOV CX, 20		    ;Chars of the string

s_of:	MOV DL, [SI]		    ;Loop for printing the string Overflow
	INT 21H
	DEC CX
	INC SI
	CMP CX, 0
	JNZ s_of

esci:	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
.EXIT
END
