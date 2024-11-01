.data
	b0:	.byte 1 
	b1:	.byte 2
	b2:	.byte 3
	b3:	.byte 4
	b4:	.byte 5


.macro pr_hex # a0 inteiro
.data
nl:	.string "\n"
.text
li a7, 34
ecall
la a0, nl
li a7, 4
ecall
.end_macro
 

.text
	# imprimindo os enderecos dos bytes
	# verifique no painel "Data Segment"
	# a localizacao dos bytes na memoria
	la a0, b0
	pr_hex
	la a0, b1
	pr_hex
	la a0, b2
	pr_hex
	la a0, b3
	pr_hex
	la a0, b4
	pr_hex
	
	#lendo um byte para um registrador
	# verifique o valor armazenado em a0 no painel ao lado
	la t0, b3
	lb a0, 0(t0)	
	 
	#lendo uma palavra para um registrador
	# verifique o valor armazenado em a1 no painel ao lado
	la t1, b0
	lw a1, 0(t1)
	
	
