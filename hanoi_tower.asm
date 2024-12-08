section .data
    ; Inicializando as strings que serão usadas
    msg_ini1 db '--------------', 10
    len_msg_ini1 equ $ - msg_ini1
    msg_ini2 db 'Torre de Hanoi', 10
    len_msg_ini2 equ $ - msg_ini2
    msg_ini3 db '--------------', 10
    len_msg_ini3 equ $ - msg_ini3
    msg_ini4 db 'Digite um número de discos (com no máximo 2 algarismos):'
    len_msg_ini4 equ $ - msg_ini4
    msg_final db '---------------', 10, 'Concluido!', 10, '---------------'
    len_msg_final equ $ - msg_final
    msg_alg1 db 'Algoritmo da Torre de Hanoi com '
    len_msg_alg1 equ $ - msg_alg1
    msg_alg2 db ' discos', 10
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
    input resb 3      ; Buffer para armazenar a entrada do usuário (um ou dois dígitos + quebra de linha)
    num_disc resb 1   ; Armazenamento do número de discos
    len_buffer resb 2 ; Buffer para armazenar a comprimento da string

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
    
    call ler_input         ; Lendo apenas no máximo dois bytes, porque se houver dois algarismo e um Newline(ENTER) eu só quero os algarismos
    lea esi, [input]
    mov ecx, 0x2
    
    call string_to_int ; Convertendo a minha entrada para um número inteiro para poder realizar as operações
    
    mov [num_disc], eax  ; Guarda o valor em int no ondereço que reservei para o número de discos
    
    mov ecx, msg_alg1     ; Print da mensagem inicial
    mov edx, len_msg_alg1
    call print_string       ; Chama a função para printar a msg
    
    call print_disc
    
    mov ecx, msg_alg2     ; Print da mensagem inicial
    mov edx, len_msg_alg2
    call print_string       ; Chama a função para printar a msg    
    
    call torre_hanoi     ; Chamando o subprocedimento principal
    
    mov ecx, msg_final
    mov edx, len_msg_final
    call print_string
    
    mov eax, 1           ; Finzalizando o programa
    xor ebx, ebx
    int 0x80   

ler_input:              ; Ler a string do usuário
    mov ecx, input      ; Lendo
    mov eax, 3          ; Número da chamada de sistema para ler
    mov ebx, 0          ; Descritor de arquivo (stdin)
    mov edx, 2          ; Tamanho máximo de entrada
    int 0x80            ; Chamando Kernel 
    ret                 ; Retorno

print_string:          ; Printa a string que armazenei em ecx na chamada da função
    mov eax, 4         ; Chamada de sistema Write
    mov ebx, 1         ; Chamada Sys_out
    int 0x80
    ret                ; Retorna pro ponto onde foi chamada

print_disc:
    movzx eax, byte [num_disc] ; Move o byte endereçado em num_disc para o registrador EAX estendendo através do movzx de 8 bits para 32, para realizar as instruções subsequentes como a div
    lea edi, [len_buffer + 4]      ; Carrega o endereço de memória apontado por EDI

    call converter_int_string  ; Chama o subprocedimento para tranformar o caractere em string através da tabela ASCII
    
    mov eax, 4              ; Número da chamada de sistema para imprimir
    mov ebx, 1              ; Descritor de arquivo (stdout)
    lea ecx, [edi]          ; Carrega o endereço inicial da string convertida em ECX 
    lea edx, [len_buffer + 4]   ; Carrega o endereço final do buffer no registrador EDX
    sub edx, ecx            ; Calcula o comprimento da string subtraindo os endereços (endereço final - endereço inicial = número de bits da string)
    int 0x80                ; Chamar interrupção do sistema
    ret

string_to_int:
    xor ebx, ebx
    prox_digito:
        cmp byte[esi], 0x0A         ; Verifica se é newline (ENTER)
        je um_algarismo       ; Se for ENTER, há apenas um dígito
        movzx eax, byte[esi]
        inc esi
        sub al, '0'
        imul ebx, 0xA
        add ebx, eax
        loop prox_digito
        mov eax, ebx
    um_algarismo:
        ret
        
converter_int_string:     ; Função que converte inteiros para string
    dec edi               ; Decrementa o conteúdo do registrador EDI para começar pelo bit menos significativo
    xor edx, edx          ; zerando o registrador EDX para armazenar o resto da div
    mov ecx, 10           ;  Move o valor 10 para o registrador ECX
    div ecx               ; Divide o valor contido nos registradores EDX:EAX por 10. O quociente é armazenado em EAX, e o resto em EDX.
    add dl, '0'           ; converte o dígito numérico para seu equivalente ASCII
    mov [edi], dl         ; Armazena o caractere convertido no endereço de memória apontado por EDI
    test eax, eax         ; Testa se o valor em EAX (quociente da divisão) é zero, se for é porque o número só tem 1 algarismo
    jnz converter_int_string ; Se não for zero, pula para a próxima iteração
    ret ; Retorno

torre_hanoi:
    cmp byte [num_disc], 1  ; Caso base da recursão vendo se so tem 1 disco
    je caso_base            ; Se sim salta para o subprocedimento necessário
    jmp caso_recursivo      ; Senão salta para o subprocedimento que continnua a recursão
    
    caso_base:
        mov ecx, msg_mov1   ; Movendo para ecx 'Movimente o disco '
        mov edx, len_msg_mov1
        call print_string
        
        call print_disc     ; Printando o disco 1
        
        mov ecx, msg_mov2   ; Movendo para ecx ' da torre '
        mov edx, len_msg_mov2
        call print_string
        
        mov ecx, torre_orig ; Movendo para ecx a torre de origem no momento
        mov edx, len_torre_orig
        call print_string
        
        mov ecx, msg_mov3   ; Movendo para ecx ' para a torre '
        mov edx, len_msg_mov3
        call print_string
        
        mov ecx, torre_dest ; Movendo para ecx a torre de destino no momento
        mov edx, len_torre_dest
        call print_string
        
        mov ecx, pular_linha ; Movendo para ecx a quebra de linha para continuar os prints
        mov edx, len_pular_linha
        call print_string
        
        jmp concluido        ; Pulando para o final para printar a msg e retornar pro programa principal
        
    caso_recursivo:
        
        dec byte [num_disc] ; Decrescimento na quantidade de discos
        
        push word [num_disc] ; Coloca o valor da quantidade atual de discos na pilha, para a primeira recursão e suas "filhas" não interferirem na chamada atual da função

        push word [torre_orig] ; Coloca o valor de coluna origem na pilha, para as recursões futuras não influenciarem nos valores da chamada atual da função
        push word [torre_aux] ; Coloca o valor de coluna auxiliar na pilha, para as recursões futuras não influenciarem nos valores da chamada atual da função
        push word [torre_dest] ; Coloca o valor de coluna destino na pilha, para as recursões futuras não influenciarem nos valores da chamada atual da função
        
        ; Trocando o valor da coluna auxiliar com o valor da coluna de destino
        mov dx, [torre_aux] ; Armazena o valor da coluna auxiliar no registrador dx
        mov cx, [torre_dest] ; Armazena o valor da coluna destino no registrador cx
        mov [torre_dest], dx ; Move o valor de dx(coluna auxiliar) para a coluna destino
        mov [torre_aux], cx ; Move o valor de cx(coluna destino) para a coluna auxiliar
        
        call torre_hanoi ; Recursão
        
        pop word [torre_dest] ; Obtém o valor de coluna destino na pilha, para as recursões passadas não influenciarem nos valores da chamada atual da função
        pop word [torre_aux] ; Obtém o valor de coluna auxiliar na pilha, para as recursões passadas não influenciarem nos valores da chamada atual da função
        pop word [torre_orig] ; Obtém o valor de coluna origem na pilha, para as recursões passadas não influenciarem nos valores da chamada atual da função
        
        pop word [num_disc] ; Obtém o valor guardado na pilha, para que as recursões anteriores não interfiram na recursão abaixo
        
        mov ecx, msg_mov1 ; Armazenar string em ecx
        mov edx, len_msg_mov1
        call print_string
        
        inc byte [num_disc] ; Aumento da quantidade de discos para o decréscimo anterior não influenciar na exibição do valor do disco que será movido
        call print_disc ; Função que exibe a quantidade de discos atual, que também é o disco que está sendo movido, assumindo que o disco 1 é o menor e o número vai crescendo de acordo com o tamanho do disco
        dec byte [num_disc] ; Decréscimo para retornar o valor anterior ao acréscimo que foi feito anteriormente
        
        mov ecx, msg_mov2 ; Armazenar string em ecx
        mov edx, len_msg_mov2
        call print_string
        
        mov ecx, torre_orig ; Move o valor da coluna origem para ecx
        mov edx, len_torre_orig
        call print_string
        
        mov ecx, msg_mov3 ; Armazenar string em ecx
        mov edx, len_msg_mov3
        call print_string
        
        mov ecx, torre_dest ; Move o valor da destino origem para ecx
        mov edx, len_torre_dest
        call print_string
        
        mov ecx, pular_linha ; Armazenar string em ecx, neste caso é uma quebra de linha
        mov edx, len_pular_linha
        call print_string
        
        ; Trocando o valor da coluna auxiliar com o valor da coluna de origem
        mov dx, [torre_aux] ; Armazena o valor da coluna auxiliar no registrador dx
        mov cx, [torre_orig] ; Armazena o valor da coluna origem no registrador cx
        mov [torre_orig], dx ; Move o valor de cx(coluna origem) para a coluna auxiliar
        mov [torre_aux], cx ; Move o valor de cx(coluna auxiliar) para a coluna origem
        call torre_hanoi ; Recursão
    
    concluido:
        ret
