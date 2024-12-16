section .text
    global _start
_start:
    ; Print da mensagem inicial dividida em várias partes
    mov ecx, msg_ini1
    mov edx, len_msg_ini1
    call print_string
    mov ecx, msg_ini2
    mov edx, len_msg_ini2
    call print_string
    mov ecx, msg_ini3
    mov edx, len_msg_ini3
    call print_string
    mov ecx, msg_ini4
    mov edx, len_msg_ini4
    call print_string
    
    call ler_input         ; Lendo apenas 2 dígitos (podendo ser uma NewLine) da entrada do usuário
    lea esi, [input]       ; Usando o registrador ESI como apontador para acessar a memória
    mov ecx, 0x2           ; Definindo que vou tratar dois caracteres para o loop que vou usar na função abaixo
    
    call string_to_int     ; Convertendo a entrada para um número inteiro para poder realizar as operações
    
    mov [num_disc], eax    ; Guarda o valor em int no ondereço que reservei para o número de discos
    
    mov ecx, msg_alg1      ; Carrega a mensagem inicial
    mov edx, len_msg_alg1  ; Comprimento da mensagem
    call print_string      ; Chama a função para printar a msg
    
    call print_disc        ; Chamando a função para printar o símbolo ASCII guardado como int
    
    mov ecx, msg_alg2      ; Carrega a mensagem inicial
    mov edx, len_msg_alg2  ; Comprimento da mensagem
    call print_string      ; Chama a função para printar a msg   
    
    call torre_hanoi       ; Chamando o subprocedimento principal
    
    mov ecx, msg_final     ; Carrega a mensagem final
    mov edx, len_msg_final ; Comprimento da mensagem
    call print_string      ; Chama a função para printar a msg
    
    mov eax, 1             ; Finzalizando o programa
    xor ebx, ebx
    int 0x80   

ler_input:              ; Ler a string do usuário
    mov eax, 3          ; Número da chamada de sistema para ler
    mov ebx, 0          ; Descritor de arquivo (stdin)
    mov ecx, input      ; Lendo o input
    mov edx, 2          ; Tamanho máximo de entrada
    int 0x80            ; Chamando Kernel 
    ret                 ; Retorno

print_string:          ; Printa a string que armazenei em ecx na chamada da função
    mov eax, 4         ; Chamada de sistema Write
    mov ebx, 1         ; Chamada Sys_out
    int 0x80           ; Chamando Kernel
    ret                ; Retorna pro ponto onde foi chamada

print_disc:
    movzx eax, byte [num_disc]   ; Move o byte endereçado em num_disc para o registrador EAX extendido em 32 bits para realizar as operações aritméticas com os registradores de 32 bits 
    lea edi, [buffer + 4]        ; Aponta EDI para o buffer que vou "escrever" os bits da string 

    call int_to_string           ; Chama o subprocedimento para tranformar o caractere em string através da tabela ASCII
    
    mov eax, 4                   ; Número da chamada de sistema para imprimir
    mov ebx, 1                   ; Descritor de arquivo (stdout)
    lea ecx, [edi]               ; Carrega o endereço inicial da string convertida em ECX 
    lea edx, [buffer + 4]        ; Carrega o endereço final do buffer no registrador EDX
    sub edx, edi                 ; Calcula o comprimento da string subtraindo os endereços (endereço final - endereço inicial = número de bits da string)
    int 0x80                     ; Chamar interrupção do sistema
    ret

string_to_int:
    xor ebx, ebx                   ; Zera o acumulador `ebx` onde será formado o número inteiro
    prox_digito:
        cmp byte [esi], 0x0A       ; Verifica se o caractere atual é um '\n' (newline)
        je um_algarismo            ; Se for '\n', termina a conversão e vai para o fim
        movzx eax, byte [esi]      ; Carrega o caractere atual (1 byte) no registrador `eax`, expandindo com zeros
        inc esi                    ; Move o ponteiro `esi` para o próximo caractere
        sub al, '0'                ; Converte o caractere ASCII em seu valor numérico 
        imul ebx, 0xA              ; Multiplica o valor acumulado em `ebx` por 10 (desloca para a esquerda em base decimal)
        add ebx, eax               ; Adiciona o novo dígito convertido ao acumulador `ebx`
        loop prox_digito           ; Continua o loop enquanto o contador (ECX) não for zero
        mov eax, ebx               ; Move o valor final acumulado em `ebx` para `eax` (registrador de retorno padrão)
    um_algarismo:
        ret                        ; Retorna ao chamador com o número convertido em `eax`
        
int_to_string:
    xor ecx, ecx             ; ECX será usado como contador de dígitos
    xor edx, edx             ; Limpa EDX para divisão
    mov ebx, 10              ; Divisor decimal para extrair dígitos

    continuar_conv:
        xor edx, edx         ; Limpa registrado de resto da divisão
        div ebx              ; Divide EAX por 10 (EAX = quociente, EDX = resto)
        add dl, '0'          ; Converte o dígito para ASCII
        dec edi              ; Move para o próximo espaço no buffer (de trás para frente)
        mov [edi], dl        ; Armazena o dígito no buffer
        inc ecx              ; Incrementa o contador de dígitos
        test eax, eax        ; Verifica se o quociente é 0
        jnz continuar_conv     ; Continua se ainda houver dígitos
    
                             ; Após o loop, EDI aponta para o início da string, ECX contém o comprimento
        ret

torre_hanoi:
    cmp byte [num_disc], 1  ; Caso base da recursão vendo se so tem 1 disco
    je caso_base            ; Se sim salta para o subprocedimento necessário
    jmp caso_recursivo      ; Senão salta para o subprocedimento que continnua a recursão
    
    caso_base:
        ; Imprime a mensagem "Mova disco X da Torre Y para a Torre Z"
        mov ecx, msg_mov1              ; Carrega a mensagem inicial "Mova disco"
        mov edx, len_msg_mov1          ; Comprimento da mensagem
        call print_string              ; Imprime a mensagem "Mova disco"
        
        call print_disc                ; Printando o disco 1
        
        mov ecx, msg_mov2              ; Carrega a mensagem "da Torre"
        mov edx, len_msg_mov2          ; Comprimento da mensagem
        call print_string              ; Imprime "da Torre"
        
        mov ecx, torre_orig            ; Carrega o identificador da torre de origem
        mov edx, len_torre_orig        ; Comprimento do identificador
        call print_string              ; Imprime o identificador da torre de origem
        
        mov ecx, msg_mov3              ; Carrega a mensagem "para a Torre"
        mov edx, len_msg_mov3          ; Comprimento da mensagem
        call print_string              ; Imprime "para a Torre"
        
        mov ecx, torre_dest            ; Carrega o identificador da torre de destino
        mov edx, len_torre_dest        ; Comprimento do identificador
        call print_string              ; Imprime o identificador da torre de destino
        
        mov ecx, pular_linha           ; Carrega a quebra de linha
        mov edx, len_pular_linha       ; Comprimento da quebra de linha
        call print_string              ; Imprime a quebra de linha
        
        jmp concluido                  ; Pulando para o subprocedimento de conclusão do algoritmo
        
    caso_recursivo:
        ; Diminui o número de discos em 1
        dec byte [num_disc]            ; Decresce o número de discos, preparando para trabalhar com o próximo subproblema menor
    
        ; Salva o estado atual na pilha para preservar os valores durante a recursão
        push word [num_disc]           ; Salva o número atual de discos na pilha
        push word [torre_orig]         ; Salva a torre de origem na pilha
        push word [torre_aux]          ; Salva a torre auxiliar na pilha
        push word [torre_dest]         ; Salva a torre de destino na pilha
    
        ; Troca a torre auxiliar com a torre de destino para a próxima chamada recursiva
        mov dx, [torre_aux]            ; Carrega o valor da torre auxiliar em `dx`
        mov cx, [torre_dest]           ; Carrega o valor da torre de destino em `cx`
        mov [torre_dest], dx           ; Atualiza a torre de destino com o valor da torre auxiliar
        mov [torre_aux], cx            ; Atualiza a torre auxiliar com o valor da torre de destino
    
        ; Chama a função recursiva novamente com o novo estado
        call torre_hanoi               ; Resolve o subproblema para mover `n-1` discos
    
        ; Restaura o estado anterior da pilha após a recursão
        pop word [torre_dest]          ; Restaura a torre de destino da pilha
        pop word [torre_aux]           ; Restaura a torre auxiliar da pilha
        pop word [torre_orig]          ; Restaura a torre de origem da pilha
        pop word [num_disc]            ; Restaura o número de discos da pilha
    
        ; Imprime a mensagem "Mova disco X da Torre Y para a Torre Z"
        mov ecx, msg_mov1              ; Carrega a mensagem inicial "Mova disco"
        mov edx, len_msg_mov1          ; Comprimento da mensagem
        call print_string              ; Imprime a mensagem "Mova disco"
    
        inc byte [num_disc]            ; Incrementa o número de discos temporariamente para imprimir o disco correto
        call print_disc                ; Imprime o número do disco a ser movido
        dec byte [num_disc]            ; Volta o número de discos ao estado original
    
        mov ecx, msg_mov2              ; Carrega a mensagem "da Torre"
        mov edx, len_msg_mov2          ; Comprimento da mensagem
        call print_string              ; Imprime "da Torre"
    
        mov ecx, torre_orig            ; Carrega o identificador da torre de origem
        mov edx, len_torre_orig        ; Comprimento do identificador
        call print_string              ; Imprime o identificador da torre de origem
    
        mov ecx, msg_mov3              ; Carrega a mensagem "para a Torre"
        mov edx, len_msg_mov3          ; Comprimento da mensagem
        call print_string              ; Imprime "para a Torre"
    
        mov ecx, torre_dest            ; Carrega o identificador da torre de destino
        mov edx, len_torre_dest        ; Comprimento do identificador
        call print_string              ; Imprime o identificador da torre de destino
    
        mov ecx, pular_linha           ; Carrega a quebra de linha
        mov edx, len_pular_linha       ; Comprimento da quebra de linha
        call print_string              ; Imprime a quebra de linha
    
        ; Troca novamente a torre auxiliar com a torre de origem para preparar a próxima recursão
        mov dx, [torre_aux]            ; Carrega o valor da torre auxiliar em `dx`
        mov cx, [torre_orig]           ; Carrega o valor da torre de origem em `cx`
        mov [torre_orig], dx           ; Atualiza a torre de origem com o valor da torre auxiliar
        mov [torre_aux], cx            ; Atualiza a torre auxiliar com o valor da torre de origem
    
        ; Chama a função recursiva novamente para resolver o segundo subproblema
        call torre_hanoi               ; Resolve o subproblema restante para mover `n-1` discos

    concluido:                         ; Algoritmo concluído 
        ret                            ; Retorno para onde o subprocedimento foi chamado
        
;Seção de dados já inicializados na memória
section .data
    ; Inicializando as strings que serão usadas
    msg_ini1 db '---------------', 10
    len_msg_ini1 equ $ - msg_ini1
    msg_ini2 db 'Torre de Hanoi', 10
    len_msg_ini2 equ $ - msg_ini2
    msg_ini3 db '---------------', 10
    len_msg_ini3 equ $ - msg_ini3
    msg_ini4 db 'Digite um número de discos (com no máximo 2 algarismos):'
    len_msg_ini4 equ $ - msg_ini4
    msg_final db '----------------', 10, '   Concluido!', 10, '----------------'
    len_msg_final equ $ - msg_final
    msg_alg1 db 'Algoritmo da Torre de Hanoi com '
    len_msg_alg1 equ $ - msg_alg1
    msg_alg2 db ' disco(s)', 10
    len_msg_alg2 equ $ - msg_alg2
    torre_orig db 'A '
    len_torre_orig equ $ - torre_orig
    torre_aux db 'B '
    len_torre_aux equ $ - torre_aux
    torre_dest db 'C '
    len_torre_dest equ $ - torre_dest
    msg_mov1 db 'Mova disco '
    len_msg_mov1 equ $ - msg_mov1
    msg_mov2 db ' da Torre '
    len_msg_mov2 equ $ - msg_mov2
    msg_mov3 db 'para a Torre '
    len_msg_mov3 equ $ - msg_mov3
    pular_linha db 10
    len_pular_linha equ $ - pular_linha

section .bss
    input resb 2      ; Buffer para armazenar a entrada do usuário 
    num_disc resb 1   ; Armazenamento do número de discos como um número inteiro
    buffer resb 2     ; Buffer para armazenar a string que vai ser printada sobre o número dos discos
