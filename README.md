# Projeto: Torre de Hanói em Assembly

Este projeto implementa a solução do problema da Torre de Hanói usando a linguagem Assembly.

## Descrição

A Torre de Hanói é um desafio matemático que consiste em mover uma pilha de discos de um pino para outro, seguindo três regras principais:

1. Apenas um disco pode ser movido por vez.
2. Cada movimento consiste em pegar o disco do topo de uma pilha e colocá-lo em outra.
3. Um disco maior nunca pode ficar em cima de um disco menor.

Este programa resolve o problema de forma recursiva, exibindo os movimentos necessários para transferir todos os discos.

## Como Testar

1. Copie o código-fonte fornecido.
2. Cole o código no ambiente do compilador "[tutorialspoint](https://www.tutorialspoint.com/compile_assembly_online.php)".
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
