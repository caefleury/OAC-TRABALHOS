.data
    .align 2
    dados: .space 128

.text

main:
    addi   t1, zero, 5

    addi   t2, zero, 12

    addi   t3, zero, 12

    addi   t6, zero, -4

    add    a0, t1, t2

    sub    a1, t3, t2

    bne    t2, t3, test_function

test_function:
    addi   t0, zero, 4    

    la     s0, dados      

    sw     t1, 0(s0)      

    sw     t2, 4(s0)      

    lw     t5, 0(s0)      

    addi   t5, t5, 10     
    
    sw     t5, 4(s0)      
