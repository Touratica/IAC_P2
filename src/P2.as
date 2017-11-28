;Este programa e um jogo de Mastermind, que gera uma chave secreta e que vai aceitando tentativas
;do utilizador em R2 ate este acertar na combinacao. Tem 12 tentativas para acertar e depois de cada
;uma, aparece uma mensagem na janela de texto indicando quantas pecas e que o utilizador pos no
;sitio certo, quantas e que pos no sitio errado e quantas e que nao existem na chave
SP_INICIAL		EQU FDFFh
IO_DISPLAY0		EQU FFF0h
IO_DISPLAY1		EQU FFF1h
IO_DISPLAY2		EQU FFF2h
IO_DISPLAY3		EQU FFF3h
IO_TEMP_CONT	EQU FFF6h
IO_TEMP_INIC	EQU FFF7h
IO_LEDS			EQU FFF8h
INT_MASK_ADDR	EQU FFFAh
INT_MASK		EQU 1000010001111110b
MASCARA			EQU 8016h
FIM_STR			EQU "@"
strFim			WORD "Fim do Jogo@"
strRecomeco		WORD "Carregue em IA para recomecar@"

				ORIG FE01h
INT1			WORD INT1F
INT2			WORD INT2F
INT3			WORD INT3F
INT4			WORD INT4F
INT5			WORD INT5F
INT6			WORD INT6F
vazio1			TAB 3
INT10			WORD INTIA
vazio2			TAB 4
INT15			WORD TEMP

				ORIG 0000h
				JMP inicializa

;INTERRUPCOES
INT1F:			SHL R2, 3
				ADD R2, 1
				RTI
INT2F:			SHL R2, 3
				ADD R2, 2
				RTI
INT3F:			SHL R2, 3
				ADD R2, 3
				RTI
INT4F:			SHL R2, 3
				ADD R2, 4
				RTI
INT5F:			SHL R2, 3
				ADD R2, 5
				RTI
INT6F:			SHL R2, 3
				ADD R2, 6
				RTI
INTIA:			MOV R4, 5
				RTI
TEMP:			SHR R1, 1
				JMP.Z derrota
				MOV M[LEDS], R1
				MOV R6, 5
				MOV M[TEMP_CONT], R6
				MOV R6, 1
				MOV M[TEMP_INIC], R6
				RTI

;CODIGO
muda_linha:		MOV R1, 000Ah			;codigo de mudanca de linha
				MOV M[FFFEh], R1		;muda de linha na janela de texto
				POP R2					;retira ultima entrada do stack
				MOV R2, 0				;poe valor da tentativa a 0
				POP R1					;retira ultima entrada do stack
				MOV R1, M[SP+1]			;poe em R1 o valor da chave
opcao:			CMP R4, 5
				BR.Z reinicio
				MOV R4, 4				;inicializa contador de tracos
				CMP R7, 12				;verifica o numero de tentativas
				JMP.Z derrota			;se numero tentativas > 12, utilizador perde
				CMP R2, 01FFh			;verifica se utilizador já introduzio tentativa
				BR.NP opcao				;loop até utilizador introduizir tentativa


tentativa:		DSI
				INC R7					;incrementa numero de tentativas
				MOV R1, R6
				MOV R6, 0				;inicia contador de pecas
				PUSH R1					;coloca chave mestra no stack (outra vez)
				PUSH R2					;coloca tentativa no stack
tenta_certa:	INC R6					;incrementa contador de pecas
				AND R1, 0E00h			;isola primeira peca da chave
				AND R2, 0E00h			;isola primeira peca da tentativa
				CMP R1, R2				;verifica se sao iguais
				JMP.Z p_certa			;se iguais, salta para p_certa
				POP R2					;restablece tentativa em R2
				POP R1					;restablece chave em R1
				ROL R2, 3				;roda as pecas da tentativa para a esquerda
				ROL R1, 3				;roda as pecas da chave para a esqueda
				PUSH R1					;coloca "nova chave" no stack
				PUSH R2					;coloca "nova tentativa" no stack
verifica:		CMP R6, 4				;verifica se ja testou as 4 pecas
				BR.NZ tenta_certa		;se nao, salta para tenta_certa
				CMP R1, 0				;se a "nova chave" com 0
				JMP.Z vitoria			;se for, o jogador acertou tudo e salta para vitoria

tentativa2:		MOV R6, 0				;inicializa primeiro contador de pecas
tenta_errada:	POP R2					;poe em R2 o valor da tentativa
				POP R1					;poe em R1 o valor da chave mestre
				INC R6					;incrementa contador de pecas
				MOV R5, 0				;inicializa segundo contador de pecas
				ROL R2, 3				;roda as pecas da tentativa para a direita
				PUSH R1					;poe chave stack
				PUSH R2					;poe tentativa rodada em stack
inic_errada:	CMP R6, 4				;se R6 > 4, ja verificou se pecas em sitio errado
				JMP.P ver_tracos		;se R6 > 4, salta para ver_tracos
				INC R5					;incrementa segundo contador pecas
				AND R1, 0E00h			;seleciona primeira peca da chave
				AND R2, 0E00h			;seleciona primeira peca da tentativa
				BR.Z roda_tent			;se peca da tentativa for 0, salta para roda_tent
				CMP R1, R2				;se pecas foram iguais, peca tentatica esta no sitio errado
				BR.Z p_errada			;se forem iguais salta para p_errada
roda_tent:		POP R2					;restablece tentativa em R2
				POP R1					;restablece chave em R1
				ROL R2, 3				;roda as pecas da tentativa para a esquerda
				ROL R1, 3				;roda as pecas da chave para a esqueda
				PUSH R1					;coloca "nova chave" no stack
				PUSH R2					;coloca "nova tentativa" no stack
verifica2:		CMP R5, 4				;se segundo contador for 4, ja comparou a peca da chave com todas as pecas da tentativa
				BR.NZ inic_errada		;se nao for 4, salta para inic_errada
				BR tenta_errada			;se for, salta para tenta_errada

p_errada:		MOV R1, 'o'				;poe o código ASCII de o em R1
				MOV M[FFFEh], R1		;escreve um o na janela de texto
				POP R2					;retoma o valor da tentativa a R2
				AND R2, 01FFh			;retira a peca igual da tentativa
				POP R1					;retoma o valor da chave a R1
				AND R1, 01FFh			;retira a peca igual da chave
				ROL R2, 3				;roda as pecas da tentativa para a esquerda
				ROL R1, 3				;roda as pecas da chave para a esqueda
				PUSH R1					;coloca "nova chave" no stack
				PUSH R2					;coloca "nova tentativa" no stack
				DEC R4					;decrementa contador de tracos
				JMP verifica2			;salta para verifica

p_certa:		MOV R1, 'x'				;poe o código ASCII de x em R1
				MOV M[FFFEh], R1		;escreve um x na janela de texto
				POP R2					;retoma o valor da tentativa a R2
				AND R2, 01FFh			;retira a peca igual da tentativa
				POP R1					;retoma o valor da chave a R1
				AND R1, 01FFh			;retira a peca igual da chave
				ROL R2, 3				;roda as pecas da tentativa para a esquerda
				ROL R1, 3				;roda as pecas da chave para a esqueda
				PUSH R1					;coloca "nova chave" no stack
				PUSH R2					;coloca "nova tentativa" no stack
				DEC R4					;decrementa contador de tracos
				JMP verifica			;salta para verifica

ver_tracos:		CMP R4, 0				;se contador de tracos for 0, nao falta por mais nenhum
				JMP.Z muda_linha		;se for 0, salta para muda_linha
				MOV R1, '-'				;poe o código ASCII de - em R1
				MOV M[FFFEh], R1		;escreve um - na janela de texto
				DEC R4					;decrementa contador de tracos
				BR ver_tracos			;salta para ver_tracos

inicializa:		MOV R1, SP_INICIAL		;poe o valor de SP_INICIAL em R1
				MOV SP, R1				;inicializa SP com o valor de R1
				MOV R7, INT_MASK
				MOV M[INT_MASK_ADDR], R7
				MOV R1, 1144h			;valor para calculo da primeira chave
				PUSH R1					;coloca esse valor no stack

random:			MOV R7, 0				;poe contador de pecas a 0
				MOV R1, M[SP+1]			;poe em R1 o valor da chave nao corrigida
				AND R1, 0001h			;seleciona o bit menos significativo
				BR.Z seZero				;se bit = 0, salta para seZero

naoZero:		POP R1					;poe em R1 o valor da chave nao corrigida
				ROR R1, 1				;roda todos os bits para a direita
				PUSH R1					;poe nova chave nao corrigida no stack
				PUSH R1					;poe a chave novamente no stack para ser corrigida
				BR corrige				;salta para a label que corrige a chave

seZero:			POP R1					;poe em R1 o valor da chave nao corrigida
				XOR R1, MASCARA			;faz um XOR da chave nao corrigida com o valor da mascara
				ROR R1, 1				;roda todos os bits para a direita
				PUSH R1					;poe nova chave nao corrigida no stack
				PUSH R1					;poe a chave novamente no stack para ser corrigida

corrige:		MOV R2, 6				;coloca em R2 o valor 6
				AND R1, 0007h			;seleciona a peca da direita da chave
				DIV R1, R2				;divide o valor da peca por 6
				INC R2					;incrementa o resto da divisao
				POP R1					;devolve o valor da chave a R1
				AND R1, 0FF8h			;seleciona as 3 pecas da esquerda
				ADD R1, R2				;adiciona a peca da direita
				ROR R1, 3				;roda as pecas para a direira
				PUSH R1					;poe nova chave no stack
				INC R7					;incrementa contador de pecas
				CMP R7, 4				;se as pecas ainda não estiverem todas corrigidas
				BR.NZ corrige			;salta para corrige

inicio:			MOV R1, FFFFh
				MOV M[LEDS], R1
				MOV R6, M[SP+1]			;poe em R6 o valor da chave mestre
				MOV R2, 0				;poe valor da tentativa a 0
				MOV R7, 0				;inicializa contador tentativas
				MOV R4, 5
				MOV M[TEMP_CONT], R4
				MOV R4, 1
				MOV M[TEMP_INIC], R4
				ENI
				JMP opcao				;salta para a rotina label opcao

reinicio:		CALL mensagem_recom
				NOP
mensagem_der:	POP R1					;retira chave corrigida do stack

				JMP random				;salta para random para gerar nova chave de jogo

mensagem_vit:	POP R2					;retira ultima entrada do stack
				POP R1					;retira ultima entrada do stack
				MOV R1, 000Ah			;codigo de mudanca de linha
				MOV M[FFFEh], R1		;muda de linha na janela de texto
				MOV R1, 'G'				;nas linhas seguintes, a mensagem
				MOV M[FFFEh], R1		;GANHOU! apararece na janela de texto
				MOV R1, 'A'
				MOV M[FFFEh], R1
				MOV R1, 'N'
				MOV M[FFFEh], R1
				MOV R1, 'H'
				MOV M[FFFEh], R1
				MOV R1, 'O'
				MOV M[FFFEh], R1
				MOV R1, 'U'
				MOV M[FFFEh], R1
				MOV R1, '!'
				MOV M[FFFEh], R1
				MOV R1, 000Ah			;codigo de mudanca de linha
				MOV M[FFFEh], R1		;muda de linha na janela de texto
				POP R1					;retira ultima entrada do stack
				MOV R1, M[SP +1]		;poe valor da ultima chave por corrigir em R1
				JMP random				;salta para random para gerar nova chave de jogo
