section .text
    global _start
_start:
    ; Print da mensagem inicial 
    mov ecx, msg_inicial            ; Movendo para ECX a msg inicial 
    mov edx, tam_msg_ini            ; Movendo para EDX o tamanho da msg
    call print_string               ; Chamando o subprocedimento que printa a msg
    
    call ler_input                  ; Lendo apenas 2 dígitos (podendo ser uma NewLine) da entrada do usuário
    
    call string_to_int              ; Convertendo a entrada para um número inteiro para poder realizar as operações
    
    mov [num_disc], eax             ; Guarda o valor em int (está em EAX dps da conversão) no endereço que reservei para o número de discos

    call print_especial             ; Chamando o subprocedimento que printa a msg com a entrada do usuário
    
    call torre_hanoi                ; Chamando o subprocedimento principal
    
    mov ecx, msg_final              ; Carrega a mensagem final
    mov edx, tam_msg_final          ; Comprimento da mensagem
    call print_string               ; Chama a função para printar a msg
    
    mov eax, 1                      ; Finzalizando o programa
    xor ebx, ebx
    int 0x80   

ler_input:                          ; Ler a string do usuário
    mov eax, 3                      ; Número da chamada de sistema para ler
    mov ebx, 0                      ; Descritor de arquivo (stdin)
    mov ecx, input                  ; Lendo o input
    mov edx, 2                      ; Tamanho máximo de entrada
    int 0x80                        ; Chamando Kernel 
    ret                             ; Retorno

print_string:                       ; Printa a string que armazenei em ecx na chamada da função
    mov eax, 4                      ; Chamada de sistema Write
    mov ebx, 1                      ; Chamada Sys_out
    int 0x80                        ; Chamando Kernel
    ret                             ; Retorna pro ponto onde foi chamada

print_especial:          
    call int_to_string              ; Chama o subprocedimento para tranformar o caractere em string através da tabela ASCII
    
    mov [disc], al                  ; Movendo para o espaço vazio 'disc' o valor de eax que está guardando o caractere do número de discos já convertido para string usando só os últimos 8 bits com al 
    
    mov ecx, msg_inicial2           ; Movendo para ECX a msg já preenchida 
    mov edx, tam_msg_ini2           ; Movendo para EDX o tamanho da msg
    
    mov eax, 4                      ; Chamada de sistema Write
    mov ebx, 1                      ; Chamada Sys_out
    int 0x80                        ; Chamando Kernel
    ret                             ; Retorna pro ponto onde foi chamada

print:
    call int_to_string              ; Chama o subprocedimento para tranformar o caractere em string através da tabela ASCII
    
    mov [disco], al                 ; Movendo para o espaço vazio 'disco' o valor de al que está guardando o caractere do número de discos já convertido para string
    
    mov al, [torre_orig]            ; Colocando o valor atual da torre de origem no registrador al
    mov [torre_1], al               ; Colocando o valor de al no espaço vazio de torre separado no print
    mov bl, [torre_dest]            ; Colocando o valor atual da torre de destino no registrador bl
    mov [torre_2], bl               ; Colocando o valor de bl no espaço vazio de torre separado no print
    
    mov eax, 4                      ; Número da chamada de sistema para imprimir
    mov ebx, 1                      ; Descritor de arquivo (stdout)
    mov ecx, msg                    ; Conteúdo da msg
    mov edx, tam_msg                ; Tamanho da msg
    int 0x80                        ; Chamar interrupção do sistema
    ret

string_to_int:
    lea esi, [input]                ; Usando o registrador ESI como apontador para acessar a memória
    mov ecx, 0x2                    ; Definindo que vou tratar dois caracteres para o loop que vou usar na função abaixo
    xor ebx, ebx                    ; Zera o acumulador `ebx` onde será formado o número inteiro
    prox_digito:
        cmp byte [esi], 0x0A        ; Verifica se o caractere atual é um '\n' (newline)
        je um_algarismo             ; Se for '\n', termina a conversão e vai para o fim
        movzx eax, byte [esi]       ; Carrega o caractere atual (1 byte) no registrador `eax`, expandindo com zeros
        inc esi                     ; Move o ponteiro `esi` para o próximo caractere pulando 8 bits
        sub al, '0'                 ; Converte o caractere ASCII em seu valor numérico 
        imul ebx, 0xA               ; Multiplica o valor acumulado em `ebx` por 10 (perceba que na primeira iteração o valor ainda é 0 em ebx)
        add ebx, eax                ; Adiciona o novo dígito convertido ao acumulador `ebx`
        loop prox_digito            ; Continua o loop enquanto o contador (ECX) não for zero
        mov eax, ebx                ; Move o valor final acumulado em `ebx` para `eax` (registrador de retorno padrão)
    um_algarismo:
        ret                         ; Retorna ao chamador com o número convertido em `eax`
        
int_to_string:
    movzx eax, byte [num_disc]      ; Move o byte endereçado em num_disc para o registrador EAX extendido em 32 bits para realizar as operações aritméticas com os registradores de 32 bits 
    lea edi, [buffer + 4]           ; Aponta EDI para o buffer que vou "escrever" os bits da string 
    
    xor ecx, ecx                    ; ECX será usado como contador de dígitos
    xor edx, edx                    ; Limpa EDX para divisão
    mov ebx, 10                     ; Divisor decimal para extrair dígitos

    loop_conv:
        xor edx, edx                ; Limpa registrado de resto da divisão
        div ebx                     ; Divide EAX por 10 (EAX = quociente, EDX = resto)
        add dl, '0'                 ; Converte o dígito de resto da divisão para ASCII (pelo dl que é o correspondente do edi)
        dec edi                     ; Move para o próximo espaço no buffer (de trás para frente)
        mov [edi], dl               ; Armazena o dígito no buffer
        inc ecx                     ; Incrementa o contador de dígitos
        test eax, eax               ; Verifica se o quociente é 0
        jnz loop_conv               ; Continua se ainda houver dígitos
        mov al, [edi]               ; Armazenando em al(8 bits são suficientes) o valor final
    
                                    ; Após o loop, EDI aponta para o início da string formada e ECX contém o comprimento
        ret

torre_hanoi:
    cmp byte [num_disc], 1          ; Caso base da recursão vendo se so tem 1 disco
    je caso_base                    ; Se sim salta para o subprocedimento necessário
    jmp caso_recursivo              ; Senão salta para o subprocedimento que continnua a recursão
    
    caso_base:
        ; Imprime a mensagem "Mova disco 1 da Torre Y para a Torre Z"
        call print                  ; Chamando o subprocedimento que printa a msg do movimento do disco 1                  

        jmp concluido               ; Pulando para o subprocedimento de conclusão do algoritmo
        
    caso_recursivo:
        ; Diminui o número de discos em 1
        dec byte [num_disc]         ; Decresce o número de discos, preparando para trabalhar com o próximo subproblema menor
    
        ; Salva o estado atual na pilha para preservar os valores durante a recursão
        push word [num_disc]        ; Salva o número atual de discos na pilha
        push word [torre_orig]      ; Salva a torre de origem na pilha
        push word [torre_aux]       ; Salva a torre auxiliar na pilha
        push word [torre_dest]      ; Salva a torre de destino na pilha
    
        ; Troca a torre auxiliar com a torre de destino para a próxima chamada recursiva
        mov dx, [torre_aux]         ; Carrega o valor da torre auxiliar em `dx`
        mov cx, [torre_dest]        ; Carrega o valor da torre de destino em `cx`
        mov [torre_dest], dx        ; Atualiza a torre de destino com o valor da torre auxiliar
        mov [torre_aux], cx         ; Atualiza a torre auxiliar com o valor da torre de destino
    
        ; Chama a função recursiva novamente com o novo estado
        call torre_hanoi            ; Resolve o subproblema para mover `n-1` discos
    
        ; Restaura o estado anterior da pilha após a recursão
        pop word [torre_dest]       ; Restaura a torre de destino da pilha
        pop word [torre_aux]        ; Restaura a torre auxiliar da pilha
        pop word [torre_orig]       ; Restaura a torre de origem da pilha
        pop word [num_disc]         ; Restaura o número de discos da pilha
    
        inc byte [num_disc]         ; Incrementa o número de discos temporariamente para imprimir o disco correto
        ; Imprime a mensagem "Mova disco X da Torre Y para a Torre Z"    
        call print                                         
        
        dec byte [num_disc]         ; Volta o número de discos ao estado original
    
        ; Troca novamente a torre auxiliar com a torre de origem para preparar a próxima recursão
        mov dx, [torre_aux]         ; Carrega o valor da torre auxiliar em `dx`
        mov cx, [torre_orig]        ; Carrega o valor da torre de origem em `cx`
        mov [torre_orig], dx        ; Atualiza a torre de origem com o valor da torre auxiliar
        mov [torre_aux], cx         ; Atualiza a torre auxiliar com o valor da torre de origem
    
        ; Chama a função recursiva novamente para resolver o segundo subproblema
        call torre_hanoi            ; Resolve o subproblema restante para mover `n-1` discos
        
    concluido:                      ; Algoritmo concluído 
        ret                         ; Retorno para onde o subprocedimento foi chamado

section .data

    ; MENSAGENS DO PROGRAMA (com espaços vazio no meio para serem preenchidos durante a execução do programa)

    msg_inicial:
                 db '----------------', 10
                 db ' Torre de Hanoi', 10
                 db '----------------', 10
                 db 'Digite um número de discos (com no máximo 2 algarismos):'
                 tam_msg_ini equ $ - msg_inicial
                 
    msg_inicial2:
                 db 'Algoritmo da Torre de Hanoi com '
           disc  db ' '
                 db ' disco(s)', 10
                 tam_msg_ini2 equ $ - msg_inicial2
                 
    msg_final: 
            db '----------------', 10, 
            db '   Concluido!', 10
            db '----------------', 10
            tam_msg_final equ $ - msg_final
    
    msg: 
                    db 'Mova disco '
              disco db ' '
                    db ' da torre '
            torre_1 db ' '
                    db ' para a torre '
            torre_2 db ' ', 10
                    
            tam_msg equ $ - msg
            
    ; TORRES DO JOGO
             
    torre_orig db 'A', 0
    torre_aux db 'B', 0
    torre_dest db 'C', 0
    
section .bss
    input resb 2                    ; Buffer para armazenar a entrada do usuário 
    num_disc resb 1                 ; Armazenamento do número de discos como um número inteiro
    buffer resb 2                   ; Buffer para armazenar a string que vai ser printada sobre o número dos discos
