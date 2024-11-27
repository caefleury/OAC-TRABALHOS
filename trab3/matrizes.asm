.data
    # dados das matrizes
    mat_a: .word    3, 7, 2,
                    15, 4, 8,
                    1, 9, 6
                     
    mat_b: .word    12, 5, 8,
                    3, 11, 7,
                    9, 4, 13
                     
    mat_r: .word    0:9    # matriz resultado (9 zeros)
                     
    # textos do sistema
    msg_menu:    .string "\n### Calculadora de Matriz ###\n"
    msg_op1:     .string "1) Adicao\n"
    msg_op2:     .string "2) Produto\n"
    msg_op3:     .string "3) Transpor\n"
    msg_op4:     .string "4) Visualizar\n"
    msg_op5:     .string "5) Encerrar\n"
    msg_escolha: .string "Digite sua escolha (1-5): "
    pula_linha:  .string "\n"
    espaco:      .string " "
    
    # cabecalhos
    txt_mat_a:   .string "\n>> Matriz Principal:\n"
    txt_mat_b:   .string "\n>> Matriz Secundaria:\n"
    txt_result:  .string "\n>> Resultado:\n"
    
    # mensagens operacoes
    txt_soma:    .string "\n>> Realizando Adicao <<\n"
    txt_mult:    .string "\n>> Calculando Produto <<\n"
    txt_trans:   .string "\n>> Gerando Transposta <<\n"
    txt_view:    .string "\n>> Visualizando Matriz <<\n"
    
    # mensagem inicial
    txt_inicio:  .string "\n=== Matrizes de Teste ===\nAs seguintes matrizes serao utilizadas nas operacoes:\n"

.text
.globl main

# rotina principal
main:
    # exibe matrizes de teste iniciais
    la a0, txt_inicio
    li a7, 4
    ecall
    
    la a0, txt_mat_a
    li a7, 4
    ecall
    la a0, mat_a
    li a1, 3
    jal ra, mostrar
    
    la a0, txt_mat_b
    li a7, 4
    ecall
    la a0, mat_b
    li a1, 3
    jal ra, mostrar
    
    # loop principal do menu
    loop_principal:
        # exibe menu
        la a0, msg_menu
        li a7, 4
        ecall
        la a0, msg_op1
        ecall
        la a0, msg_op2
        ecall
        la a0, msg_op3
        ecall
        la a0, msg_op4
        ecall
        la a0, msg_op5
        ecall
        la a0, msg_escolha
        ecall
        
        # captura escolha
        li a7, 5
        ecall
        
        # analisa opcao
        li t0, 1
        beq a0, t0, exec_soma
        li t0, 2
        beq a0, t0, exec_mult
        li t0, 3
        beq a0, t0, exec_trans
        li t0, 4
        beq a0, t0, exec_view
        li t0, 5
        beq a0, t0, finalizar
        j loop_principal

exec_soma:
    # cabecalho
    la a0, txt_soma
    li a7, 4
    ecall
    
    # primeira matriz
    la a0, txt_mat_a
    li a7, 4
    ecall
    la a0, mat_a
    li a1, 3
    jal ra, mostrar
    
    # segunda matriz
    la a0, txt_mat_b
    li a7, 4
    ecall
    la a0, mat_b
    li a1, 3
    jal ra, mostrar
    
    # calcula
    la a0, mat_a     
    la a1, mat_b     
    la a2, mat_r     
    li a3, 3         
    jal ra, adicionar
    
    # mostra resultado
    la a0, txt_result
    li a7, 4
    ecall
    la a0, mat_r
    li a1, 3
    jal ra, mostrar
    j loop_principal

exec_mult:
    # cabecalho
    la a0, txt_mult
    li a7, 4
    ecall
    
    # primeira matriz
    la a0, txt_mat_a
    li a7, 4
    ecall
    la a0, mat_a
    li a1, 3
    jal ra, mostrar
    
    # segunda matriz
    la a0, txt_mat_b
    li a7, 4
    ecall
    la a0, mat_b
    li a1, 3
    jal ra, mostrar
    
    # calcula
    la a0, mat_a    
    la a1, mat_b     
    la a2, mat_r     
    li a3, 3         
    jal ra, multiplicar
    
    # mostra resultado
    la a0, txt_result
    li a7, 4
    ecall
    la a0, mat_r
    li a1, 3
    jal ra, mostrar
    j loop_principal

exec_trans:
    # cabecalho
    la a0, txt_trans
    li a7, 4
    ecall
    
    # matriz entrada
    la a0, txt_mat_a
    li a7, 4
    ecall
    la a0, mat_a
    li a1, 3
    jal ra, mostrar
    
    # calcula
    la a0, mat_a    
    la a1, mat_r     
    li a2, 3         
    jal ra, transpor
    
    # mostra resultado
    la a0, txt_result
    li a7, 4
    ecall
    la a0, mat_r
    li a1, 3
    jal ra, mostrar
    j loop_principal

exec_view:
    # cabecalho
    la a0, txt_view
    li a7, 4
    ecall
    
    la a0, mat_a
    li a1, 3
    jal ra, mostrar
    j loop_principal

finalizar:
    li a7, 10
    ecall

# funcoes auxiliares
# ler_elemento(lin, col) -> retorna em a0
# args: a0 = lin, a1 = col
ler_elemento:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li t0, 3          
    mul t1, a0, t0    
    add t1, t1, a1    
    li t2, 4
    mul t1, t1, t2    
    
    la t0, mat_a
    add t0, t0, t1    
    lw a0, 0(t0)      
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# gravar_elemento(lin, col, val)
# args: a0 = lin, a1 = col, a2 = val
gravar_elemento:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li t0, 3          
    mul t1, a0, t0    
    add t1, t1, a1    
    li t2, 4
    mul t1, t1, t2    
    
    la t0, mat_r
    add t0, t0, t1    
    sw a2, 0(t0)      
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# adicionar(m1, m2, mr, tam)
# args: a0 = m1, a1 = m2, a2 = mr, a3 = tam
adicionar:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    
    mv s0, zero      
    loop_soma1:
        mv s1, zero  
        loop_soma2:
            mul t0, s0, a3    
            add t0, t0, s1    
            li t1, 4
            mul t0, t0, t1    
            
            add t1, a0, t0
            lw t2, 0(t1)      
            add t1, a1, t0
            lw t3, 0(t1)      
            
            add t4, t2, t3
            
            add t1, a2, t0
            sw t4, 0(t1)
            
            addi s1, s1, 1
            blt s1, a3, loop_soma2
            
        addi s0, s0, 1
        blt s0, a3, loop_soma1
    
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret

# multiplicar(m1, m2, mr, tam)
# args: a0 = m1, a1 = m2, a2 = mr, a3 = tam
multiplicar:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    
    mv s0, zero      
    loop_mult1:
        mv s1, zero  
        loop_mult2:
            li t4, 0        
            mv s2, zero     
            
            loop_mult3:
                mul t0, s0, a3    
                add t0, t0, s2    
                li t1, 4
                mul t0, t0, t1    
                
                mul t1, s2, a3    
                add t1, t1, s1    
                li t2, 4
                mul t1, t1, t2    
                
                add t2, a0, t0
                lw t2, 0(t2)      
                add t3, a1, t1
                lw t3, 0(t3)      
                
                mul t5, t2, t3
                add t4, t4, t5
                
                addi s2, s2, 1
                blt s2, a3, loop_mult3
            
            mul t0, s0, a3    
            add t0, t0, s1    
            li t1, 4
            mul t0, t0, t1    
            add t1, a2, t0
            sw t4, 0(t1)
            
            addi s1, s1, 1
            blt s1, a3, loop_mult2
            
        addi s0, s0, 1
        blt s0, a3, loop_mult1
    
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret

# transpor(m1, mr, tam)
# args: a0 = entrada, a1 = result, a2 = tam
transpor:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    
    mv s0, zero      
    loop_trans1:
        mv s1, zero  
        loop_trans2:
            mul t0, s0, a2    
            add t0, t0, s1    
            li t1, 4
            mul t0, t0, t1    
            
            mul t1, s1, a2    
            add t1, t1, s0    
            li t2, 4
            mul t1, t1, t2    
            
            add t2, a0, t0
            lw t3, 0(t2)
            add t2, a1, t1
            sw t3, 0(t2)
            
            addi s1, s1, 1
            blt s1, a2, loop_trans2
            
        addi s0, s0, 1
        blt s0, a2, loop_trans1
    
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret

# mostrar(m1, tam)
# args: a0 = matriz, a1 = tam
mostrar:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    sw s3, 0(sp)
    
    mv s0, a0        
    mv s1, a1        
    mv s2, zero      
    
    loop_most1:
        mv s3, zero  
        loop_most2:
            mul t0, s2, s1    
            add t0, t0, s3    
            li t1, 4
            mul t0, t0, t1    
            
            add t1, s0, t0
            lw a0, 0(t1)
            li a7, 1
            ecall
            
            la a0, espaco
            li a7, 4
            ecall
            
            addi s3, s3, 1
            blt s3, s1, loop_most2
            
        la a0, pula_linha
        li a7, 4
        ecall
        
        addi s2, s2, 1
        blt s2, s1, loop_most1
    
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    ret
