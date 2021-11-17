	.data
titGioc:.asciiz "\n\t\t\t\t\t-------------------------------------\n\t\t\t\t\t*** I N D O V I N A   N U M E R O ***\n\t\t\t\t\t-------------------------------------\n"
spgz:	.asciiz "Questo gioco divertente permette di sfidare i tuoi amici: vincerà chi avrà imppiegato meno tentativi per indovinare\nil numero che ho pensato! E tu sei pronto per il divertimento??\n"
numGioc:.asciiz "Quanti sono i giocatori? "
insGioc:.asciiz "Inserisci ora i nomi dei "
Gioc:	.asciiz " giocatori:\n"
curs:	.asciiz "> "
toccaA: .asciiz "\n--------------------\nOra tocca a: "
msgPns:	.asciiz "\nIo penso ad un numero da 1 a 100, e tu dovrai provare ad indovinarlo.\nTi dirò 'di più' o 'di meno' per aiutarti ad indovinare.\n"
msgP:	.asciiz "\n\t  Di più! Ritenta!\n"
msgM:	.asciiz "\n\t  Di meno! Ritenta!\n"
msggl:	.asciiz "\n\t\t\t>> COMPLIMENTI! HAI INDOVINATO AL "
msgglt:	.asciiz "° TENTATIVO <<\n"
msgTntv:.asciiz "\nTentativo n° "
msgIndv:.asciiz "\nQuale numero ho pensato?\t"
msgwnr:	.asciiz "\n----------\n\t\t\t\t\tIL VINCITORE È: "
msgPPr:	.asciiz "\n----------\n\t\t\t\t\t CI SONO PIÙ GIOCATORI AL PRIMO POSTO!\n"
msgPPrN:.asciiz "\tSONO ARRIVATI PRIMI:\n"
trattSp:.asciiz "\t\t\t    - "
msgCon:	.asciiz "\t\t\t\t  -- ha indovinato al "
msgCon2:.asciiz "\t\t\t\t\t-- hanno indovinato al "
msgTtvi:.asciiz "° tentativo --\n"

	.text
	.globl main
main:
	
.macro 	allocomemoria
	li $v0, 9
	li $a0, 640
	syscall	
.end_macro

.macro	refresh
 	li $t0 0
 	li $t1 0
 	add $t0 $s0 512	# inizializzo per la registrazione utenti
	add $t1 $s0 0	# inizializzo per array [nomeGioc|tentativi]
.end_macro


#quanti giocatori: 
	la $a0 titGioc
	li $v0 4
	syscall
	
	la $a0 spgz
	syscall
	
	la $a0 numGioc
 	syscall
 	
 	li $v0 5
 	syscall
 	move $s1 $v0
  
#Nomi Giocatori
 	
 	allocomemoria #ritorna in $v0 il puntatore alla memoria appena allocata
	move $s0, $v0
	
	la $a0 insGioc	# "Inserisci ora i nomi dei "
	li $v0 4
	syscall
	
	la $a0 ($s1)	# n°
	li $v0 1
	syscall
	
	la $a0 Gioc	# " giocatori: \n"
	li $v0 4
	syscall
	
	refresh
	
	li $t3 0
letturaNomiGiocatori:
	la $a0 ($t3)
	add $a0 $a0 1
	li $v0 1
	syscall
	
	la $a0 curs
	li $v0 4
	syscall
	
	la $a0 0($t0)
	li $a1 15		# al massimo 15 caratteri per il nome giocatore
	li $v0 8
	syscall
	
	sw $t0 ($t1)
	
	add $t0 $t0 32
	add $t3 $t3 1
	add $t1 $t1 8
	bne $t3 $s1 letturaNomiGiocatori
	li $t3 0
	
	refresh
manchePerGiocatore:	
	add $t3 $t3 1
		
 	la $a0 toccaA
 	li $v0 4
 	syscall
 	
 	lw $a0 ($t1)
 	syscall
 	
 	la $a0 msgPns
	syscall
 	
 	jal Manche
 	
 	sw $v0 4($t1)	# salvo i tentativi accanto al giocatore nell'array
 	
 	add $t1 $t1 8
 	bne $t3 $s1 manchePerGiocatore
 	j verificaVincitore
 	
Manche:	#faccio numero random e implemento le possibilità tramite syscall

	li $v0 30	#
	syscall		# genero numero random
	
	li $t0 101	# da 0 a 100	
	divu $a0 $t0	# e lo metto in t6
	mfhi $t6	#

	li $t5 0

Tentativi:
	add $t5 $t5 1	# incremento contatore	
	la $a0, msgTntv	# "tentativo n° "
	li $v0, 4
 	syscall
 	
 	la $a0 ($t5)
 	li $v0 1	# n° del tentativo
 	syscall
	
	la $a0, msgIndv	# "Indovina che numero ho pensato"
	li $v0, 4
 	syscall
 	
 	li $v0 5	#leggo numero dall'utente
 	syscall	
 	move $t0 $v0
 	
 	bne $t6 $t0 alii#se il numero è indovinato, segue questa procedura!
 	la $a0 msggl	# "Complimenti numero indovinato al "
	li $v0 4
 	syscall
 	
 	la $a0 ($t5)	# //numero del tentativo in cui ho indovinato//
	li $v0 1
 	syscall
 	
 	la $a0 msgglt	# "° tentativo!"
	li $v0 4
 	syscall
 	
 	j proseg
 	
alii:	bgt $t0 $t6 dimeno
 	blt $t0 $t6 dipiù

dipiù:
	la $a0, msgP	# "di più, ci sei quasi"
	li $v0, 4
 	syscall
	j proseg
dimeno:
	la $a0, msgM	# "di meno, ci sei quasi"
	li $v0, 4
 	syscall
	j proseg
 	
proseg:	bne $t0 $t6 Tentativi
	move $v0 $t5	# salvo il numero tentativi per uscire dalla procedura
 	jr $ra

verificaVincitore:	
	refresh
	add $t1 $t1 -4
	li $t2 2000
	li $t3 0
loop:	add $t1 $t1 8
	lw $t4 ($t1)
	
	bgt $t4 $t2 prosegui
	move $t2 $t4
	la $t5 ($t1) # salva indirizzo del numero minore. Per il nome dovrò fare add $t1 $t1 -4

prosegui:
	add $t3 $t3 1
	bne $t3 $s1 loop

# controlla il vincitore ma anche se c'è stato un pareggio per il primo posto!
#controlla pareggi
	refresh	
	add $t1 $t1 -4
	li $t3 0

loopSp:	add $t1 $t1 8		# loop controllo spareggio
	lw $t4 ($t1)		
	bne $t4 $t2 prosSp
	add $sp $sp -4
	add $t4 $t1 -4
	sw $t4 ($sp)
	add $t7 $t7 1	# $t7 contatore elementi inseriti in $sp
			# è anche il FLAG che indica se ci sono stati e quanti giocatori primi
prosSp:	add $t3 $t3 1
	bne $t3 $s1 loopSp

# comunica il vincitore
	bgt $t7 1 piuPrimi
	la $a0 msgwnr
	li $v0 4
	syscall
	
	add $t5 $t5 -4
	lw $a0 ($t5)
	syscall
#ha indovinato al n° tentativo	
	la $a0 msgCon			
	syscall
	
	add $t5 $t5 4
	lw $a0 ($t5)
	li $v0 1
	syscall	
	
	la $a0 msgTtvi
	li $v0 4
	syscall				
	j fineDelGioco

piuPrimi:
	la $a0 msgPPr
	li $v0 4
	syscall
	
	la $a0 msgPPrN
	syscall
	
	li $t3 0
elencPr:
	la $a0 trattSp
	syscall
	
	add $t3 $t3 1
	lw $a0 ($sp)	
	lw $a0 ($a0)
	syscall
	
	add $sp $sp 4
	bne $t3 $t7 elencPr
#hanno indovinato al n° tentativo	
	la $a0 msgCon2			
	syscall
	
	lw $a0 ($t5)
	li $v0 1
	syscall	
	
	la $a0 msgTtvi
	li $v0 4
	syscall																							
fineDelGioco:
	li $v0 10
	syscall
	
	
	
