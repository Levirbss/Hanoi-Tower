# Projeto: Torre de Hanói em Assembly - Arquitetura de Computadores e Sistemas Operacionais ( Docente: Sérgio Vanderlei Cavalcante )

Discentes:

1. Juan Henrique Carneiro Aguiar Paes
2. Levi Do Rego Barros Serrano

Este projeto implementa a solução do problema da Torre de Hanói usando recursão com a linguagem Assembly.

## Descrição

A Torre de Hanói é um desafio matemático que consiste em mover uma pilha de discos de um pino para outro, seguindo três regras principais:

1. Apenas um disco pode ser movido por vez.
2. Cada movimento consiste em pegar o disco do topo de uma pilha e colocá-lo em outra.
3. Um disco maior nunca pode ficar em cima de um disco menor.

Este programa resolve o problema de forma recursiva, exibindo os movimentos necessários para transferir todos os discos.

## Algoritmo recursivo da Torre de Hanói

A Torre de Hanói é um exemplo clássico de problema que pode ser resolvido usando recursão. A solução recursiva é baseada em dividir o problema em partes menores até alcançar o caso mais simples: mover apenas um disco.

Basicamente para mover n discos da torre de origem para a torre de destino:

1. Primeiro, os n-1 discos superiores são movidos para a torre intermediária, usando a torre de destino como auxiliar.
2. Depois, o maior disco (o último da base) é movido diretamente para a torre de destino.
3. Por fim, os n-1 discos são movidos da torre intermediária para a torre de destino, usando a torre de origem como auxiliar.
   
A cada etapa, o problema é reduzido até que reste apenas um disco, momento em que o movimento é direto.

## Como Testar

1. Copie o código-fonte fornecido em "hanoi_tower.asm".
2. Cole o código no ambiente do compilador [tutorialspoint](https://www.tutorialspoint.com/compile_assembly_online.php).
3. Compile e execute o programa.
4. Digite a quantidade de discos de até 2 algarismos.

## Exemplo de Saída

Se você executar o programa com 3 discos, a saída será semelhante a:

```
---------------
Torre de Hanoi
---------------
Digite um número de discos (com no máximo 2 algarismos):3
Algoritmo da Torre de Hanoi com 3 disco(s)
Mova disco 1 da Torre A para a Torre C 
Mova disco 2 da Torre A para a Torre B
Mova disco 1 da Torre C para a Torre B 
Mova disco 3 da Torre A para a Torre C 
Mova disco 1 da Torre B para a Torre A 
Mova disco 2 da Torre B para a Torre C 
Mova disco 1 da Torre A para a Torre C 
----------------
   Concluido!
----------------
```
---
