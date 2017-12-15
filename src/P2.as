;Este programa e um jogo de Mastermind, que gera uma chave secreta e que vai
;aceitando tentativas do utilizador em R2 ate este acertar na combinacao. Tem 12
;tentativas para acertar e depois de cada uma, aparece uma mensagem na janela de
;texto indicando quantas pecas e que o utilizador pos no sitio certo, quantas e
;que pos no sitio errado e quantas e que nao existem na chave.
SP_INICIAL		EQU FDFFh
IO_DISPLAY0		EQU FFF0h
IO_DISPLAY1		EQU FFF1h
IO_DISPLAY2		EQU FFF2h
IO_DISPLAY3		EQU FFF3h
CONTROL_LCD		EQU FFF4h
WRITE_LCD		EQU FFF5h
IO_TEMP_CONT		EQU FFF6h
IO_TEMP_INIC		EQU FFF7h
IO_LEDS			EQU FFF8h
INT_MASK_ADDR		EQU FFFAh
INT_MASK		EQU 1000010001111110b
CONTROL_TEXT		EQU FFFCh
WRITE_TEXT		EQU FFFEh
MASCARA			EQU 8016h
FIM_STR			EQU '@'

;VARIAVEIS
			ORIG 8000h
strFim			STR 'Fim do Jogo@'
strRecomeco		STR 'Carregue em IA para recomecar@'
strInicio		STR 'Carregue no botao IA para iniciar@'
strPontuacao		STR 'HIGHSCORE: @'

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
INTIA:			MOV R5, 1
			MOV M[IO_TEMP_INIC], R5
			MOV R4, 5
			RTI
TEMP:			SHR R1, 1
			MOV M[IO_LEDS], R1
			JMP.Z fim
			MOV R6, 5
			MOV M[IO_TEMP_CONT], R6
			MOV R6, 1
			MOV M[IO_TEMP_INIC], R6
			RTI

;CODIGO
muda_linha:		MOV R1, M[SP+5]
			ADD R1, 0100h
			AND R1, FF00h
			MOV M[CONTROL_TEXT], R1			;muda de linha na janela de texto
			POP R2					;retira ultima entrada do stack
			MOV R2, 0				;poe valor da tentativa a 0
			MOV R1, FFFFh
			MOV M[IO_LEDS], R1
			POP R3					;retira ultima entrada do stack
			ENI
opcao:			CMP R4, 5
			JMP.Z reinicio
			MOV R3, 4				;inicializa contador de tracos
			CMP R7, 12				;verifica o numero de tentativas
			JMP.Z se_perdeu			;se numero tentativas > 12, utilizador perde
			CMP R2, 01FFh				;verifica se utilizador já introduzio tentativa
			BR.NP opcao				;loop até utilizador introduizir tentativa

tentativa:		DSI
			INC R7					;incrementa numero de tentativas
			PUSH R7
			MOV R6, 10
			DIV R7, R6
			MOV M[IO_DISPLAY0], R6
			MOV R6, 10
			DIV R7, R6
			MOV M[IO_DISPLAY1], R6
			MOV R6, 10
			DIV R7, R6
			MOV M[IO_DISPLAY2], R6
			MOV R6, 10
			DIV R7, R6
			MOV M[IO_DISPLAY3], R6
			MOV R7, M[SP+4]
			ADD R7, 0100h
			AND R7, FF00h
			MOV M[CONTROL_TEXT], R7
			MOV R7, M[SP+4]
			POP R7
			MOV R6, 0				;inicia contador de pecas
			MOV R1, M[SP+1]
			PUSH R1					;coloca chave mestra no stack (outra vez)
			PUSH R2					;coloca tentativa no stack
tenta_certa:		INC R6					;incrementa contador de pecas
			AND R1, 0E00h			;isola primeira peca da chave
			AND R2, 0E00h			;isola primeira peca da tentativa
			CMP R1, R2				;verifica se sao iguais
			JMP.Z p_certa			;se iguais, salta para p_certa
			POP R2					;restablece tentativa em R2
			POP R1					;restablece chave em R1
			ROL R2, 3				;roda as pecas da tentativa para a esquerda
			ROL R1, 3				;roda as pecas da chave para a esqueda
			PUSH R1					;coloca 'nova chave' no stack
			PUSH R2					;coloca 'nova tentativa' no stack
verifica:		CMP R6, 4				;verifica se ja testou as 4 pecas
			BR.NZ tenta_certa		;se nao, salta para tenta_certa
			CMP R1, 0				;se a 'nova chave' com 0
			JMP.Z se_ganhou			;se for, o jogador acertou tudo e salta para fim

tentativa2:		MOV R6, 0				;inicializa primeiro contador de pecas
tenta_errada:		POP R2					;poe em R2 o valor da tentativa
			POP R1					;poe em R1 o valor da chave mestre
			INC R6					;incrementa contador de pecas
			MOV R5, 0				;inicializa segundo contador de pecas
			ROL R2, 3				;roda as pecas da tentativa para a direita
			PUSH R1					;poe chave stack
			PUSH R2					;poe tentativa rodada em stack
inic_errada:		CMP R6, 4				;se R6 > 4, ja verificou se pecas em sitio errado
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
			PUSH R1					;coloca 'nova chave' no stack
			PUSH R2					;coloca 'nova tentativa' no stack
verifica2:		CMP R5, 4				;se segundo contador for 4, ja comparou a peca da chave com todas as pecas da tentativa
			BR.NZ inic_errada		;se nao for 4, salta para inic_errada
			BR tenta_errada			;se for, salta para tenta_errada

p_errada:		MOV R1, M[SP+5]
			INC R1
			MOV M[CONTROL_TEXT], R1
			MOV M[SP+5], R1
			MOV R1, 'o'				;poe o código ASCII de o em R1
			MOV M[WRITE_TEXT], R1		;escreve um o na janela de texto
			POP R2					;retoma o valor da tentativa a R2
			AND R2, 01FFh			;retira a peca igual da tentativa
			POP R1					;retoma o valor da chave a R1
			AND R1, 01FFh			;retira a peca igual da chave
			ROL R2, 3				;roda as pecas da tentativa para a esquerda
			ROL R1, 3				;roda as pecas da chave para a esqueda
			PUSH R1					;coloca 'nova chave' no stack
			PUSH R2					;coloca 'nova tentativa' no stack
			DEC R3					;decrementa contador de tracos
			JMP verifica2			;salta para verifica

p_certa:		MOV R1, M[SP+5]
			INC R1
			MOV M[CONTROL_TEXT], R1
			MOV M[SP+5], R1
			MOV R1, 'x'				;poe o código ASCII de x em R1
			MOV M[WRITE_TEXT], R1		;escreve um x na janela de texto
			POP R2					;retoma o valor da tentativa a R2
			AND R2, 01FFh			;retira a peca igual da tentativa
			POP R1					;retoma o valor da chave a R1
			AND R1, 01FFh			;retira a peca igual da chave
			ROL R2, 3				;roda as pecas da tentativa para a esquerda
			ROL R1, 3				;roda as pecas da chave para a esqueda
			PUSH R1					;coloca 'nova chave' no stack
			PUSH R2					;coloca 'nova tentativa' no stack
			DEC R3					;decrementa contador de tracos
			JMP verifica			;salta para verifica

ver_tracos:		CMP R3, 0				;se contador de tracos for 0, nao falta por mais nenhum
			JMP.Z muda_linha		;se for 0, salta para muda_linha
			MOV R1, M[SP+5]
			INC R1
			MOV M[CONTROL_TEXT], R1
			MOV M[SP+5], R1
			MOV R1, '-'				;poe o código ASCII de - em R1
			MOV M[WRITE_TEXT], R1		;escreve um - na janela de texto
			DEC R3					;decrementa contador de tracos
			BR ver_tracos			;salta para ver_tracos

inicializa:		MOV R1, 8000h
			MOV M[CONTROL_LCD], R1		;inicializa display LCD
			MOV R1, SP_INICIAL		;poe o valor de SP_INICIAL em R1
			MOV SP, R1				;inicializa SP com o valor de R1
			PUSH R0
			MOV R1, INT_MASK
			MOV M[INT_MASK_ADDR], R1	;ativa interrupcoes
			CALL limpa_LCD
			MOV R7, 12
			CALL mensagem_LCD
			MOV R7, R0
			MOV R1, FFFFh
			MOV M[CONTROL_TEXT], R1 		;inicialziar janela de texto
			MOV R4, R0
			MOV R1, R0
			CALL mensagem_inic
			ENI
iteracoes:		INC R1					;no de iteracoes geram primeira chave
			CMP R4, 5
			BR.NZ iteracoes
			DSI
			CMP R1, 0
			BR salto
			INC R1
salto:			PUSH R1					;coloca esse valor no stack

random:			MOV R4, R0
			MOV R7, R0				;poe contador de pecas a 0
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
			SHL R2, 12
			POP R1					;devolve o valor da chave a R1
			AND R1, 0FF8h			;seleciona as 3 pecas da esquerda
			ADD R1, R2				;adiciona a peca da direita
			ROR R1, 3				;roda as pecas para a direira
			PUSH R1					;poe nova chave no stack
			INC R7					;incrementa contador de pecas
			CMP R7, 4				;se as pecas ainda não estiverem todas corrigidas
			BR.NZ corrige			;salta para corrige

inicio:			MOV R1, FFFFh
			MOV M[IO_LEDS], R1
			MOV R2, R0				;poe valor da tentativa a 0
			MOV M[IO_DISPLAY0], R2
			MOV M[IO_DISPLAY1], R2
			MOV M[IO_DISPLAY2], R2
			MOV M[IO_DISPLAY3], R2
			MOV R7, R0				;inicializa contador tentativas
			MOV R4, 5
			MOV M[IO_TEMP_CONT], R4
			MOV R4, 1
			MOV M[IO_TEMP_INIC], R4
			MOV R4, R0
			ENI
			JMP opcao				;salta para a rotina label opcao

reinicio:		DSI
			MOV R7, R0
			MOV M[IO_TEMP_INIC], R7		;para temporizador
			POP R4
			MOV R4, R0
			CALL mensagem_recom
			ENI
ciclo_reinicio:		CMP R4, 5
			JMP.Z random
			BR ciclo_reinicio

se_ganhou:		DSI
			CMP R7, M[SP+5]
			BR.NN fim
			CALL mensagem_LCD
			BR fim
se_perdeu:		DSI
			PUSH R1
fim:			CALL mensagem_fim
			CALL mensagem_recom
			POP R2
			POP R1
			POP R1
			JMP random
; MENSAGENS
mensagem_inic:		PUSH R1
			PUSH R2
			PUSH R3
			MOV R1, 0000h
			MOV M[CONTROL_TEXT], R1			;posiciona cursor na primeira coluna
			MOV R2, strInicio

ciclo_inic:		MOV R3, M[R2]
			CMP R3, FIM_STR
			JMP.Z fim_mensagem
			INC R2
			MOV M[WRITE_TEXT], R3
			INC R1
			MOV M[CONTROL_TEXT], R1			; INC CURSOR
			BR ciclo_inic

mensagem_fim:		PUSH R1
			PUSH R2
			PUSH R3
			MOV R1, R0
			MOV M[IO_TEMP_INIC], R1		;para temporizador
			MOV R1, M[SP+3]
			ADD R1, 0100h
			AND R1, FF00h
			MOV M[CONTROL_TEXT], R1
			MOV R2, strFim
ciclo_fim:		MOV R3, M[R2]
			CMP R3, FIM_STR
			JMP.Z fim_mensagem
			INC R2
			MOV M[WRITE_TEXT], R3
			INC R1
			MOV M[CONTROL_TEXT], R1 ; INC CURSOR
			BR ciclo_fim

mensagem_recom:		PUSH R1
			PUSH R2
			PUSH R3
			MOV R1, M[SP+3]
			ADD R1, 0100h
			AND R1, FF00h
			MOV M[CONTROL_TEXT], R1
			MOV M[SP+3], R1			;posiciona cursor nas primeiras coluna da linha seguinte
			MOV R2, strRecomeco
			MOV R4, R0
ciclo_recom:		MOV R3, M[R2]
			CMP R3, FIM_STR
			BR.Z ciclo_reinicio2
			INC R2
			MOV M[WRITE_TEXT], R3
			INC R1
			MOV M[CONTROL_TEXT], R1 ; INC CURSOR
			BR ciclo_recom
ciclo_reinicio2:	CMP R4, 5
			JMP.Z return
			BR ciclo_reinicio2
return:			JMP fim_mensagem

mensagem_LCD:		MOV R1, 8000h
			MOV M[CONTROL_TEXT], R1
			MOV R2, strPontuacao
ciclo_LCD1:		MOV R3, M[R2] ; uma letra de cada vez
			CMP R3, FIM_STR
			BR.Z resultado
			INC R2
			MOV M[WRITE_LCD],R3
			INC R1
			MOV M[CONTROL_LCD],R1 ; INC CURSOR
			BR ciclo_LCD1
resultado:		MOV R3, 10
			DIV R7, R3
			ADD R7, 48
			MOV M[WRITE_LCD], R7
			INC R1
			MOV M[CONTROL_LCD],R1 ; INC CURSOR
			ADD R3, 48
			MOV M[WRITE_LCD], R3
			RET

fim_mensagem:		POP R3
			POP R2
			POP R1
			RET

limpa_LCD:		PUSH R1
			MOV R1, 8010h
			MOV M[CONTROL_LCD], R1	;limpa display LCD
			POP R1
			RET
