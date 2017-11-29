
	ORIG 8000h
FRASE	STR 'PARA COMECAR CARREGUE IA@'
FIM_STR	EQU '@'


	ORIG 0000h
	MOV R2, FFFFh
	MOV M[FFFCh], R2 ;inicialziar janela de texto

	MOV R3, 0100h
	MOV M[FFFCh],R3
	MOV R5, FRASE

ciclo: 	MOV R4, M[R5] ; uma letra de cada vez
	CMP R4,FIM_STR
	BR.Z tag
	INC R5
	MOV R1, R4   ; ESCREVE uma letra
	MOV M[FFFEh],R1
	INC R3
	MOV M[FFFCh],R3 ; INC CURSOR
	CMP R4,FIM_STR
	BR ciclo

tag: 	NOP
Fim: 	BR Fim




	ORIG 8000h
FRASE	STR 'HIGHSCORE: @'
FIM_STR	EQU '@'


	ORIG 0000h
	MOV R3, 8000h
	MOV M[FFF4h], R3 ;inicialziar janela de LCD
	MOV R4, M[FRASE]
	MOV R5, FRASE

ciclo: 	MOV R4, M[R5] ; uma letra de cada vez
	CMP R4,FIM_STR
	BR.Z tag
	INC R5
	MOV R1, R4   ; ESCREVE uma letra
	MOV M[FFF5h],R1
	INC R3
	MOV M[FFF4h],R3 ; INC CURSOR
	CMP R4,FIM_STR
	BR ciclo

tag: 	NOP
Fim: 	BR Fim
