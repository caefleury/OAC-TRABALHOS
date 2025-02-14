# Relatório do Trabalho 6 - Caetano Korilo - 212006737

## Simulação da Constante Zero em XREGS[0]

Para simular o registrador x0 como uma constante zero, o código usa uma verificação que impede a escrita quando rd = "00000" e força a saída para zero quando rs1 ou rs2 = "00000". Na escrita: bloqueia escrita em x0. Na leitura: força saída.

```vhdl
if rd /= "00000" then
    regs(to_integer(unsigned(rd))) <= data;
end if;

ro1 <= (others => '0') when rs1 = "00000" else
       regs(to_integer(unsigned(rs1)));
```
