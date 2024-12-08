section .data
    ; Inicializando as strings que serão usadas todas prosseguidas por um 0 para usarmos como uma forma de imprimir a mensagem sem precisar especificar o número de bits que ela ocupa
    msg_ini db '--------------', 10, 'Torre de Hanoi', 10, '--------------', 10, 'Digite um número de discos (com no máximo 2 algarismos):', 0
    msg_final db '---------------', 10, 'Hanoi concluída', 10, '---------------', 0
    torre_orig db   'A ', 0
    torre_aux db    'B ', 0
    torre_dest db   'C ', 0
    msg_mov1 db     'Mova disco ', 0
    msg_mov2 db     ' da Torre ', 0
    msg_mov3 db     ' para a Torre ', 0
    pular_linha db 10
section .bss
    input resb 3      ; Buffer para armazenar a entrada do usuário (um ou dois               dígitos + quebra de linha)
    num_disc resb 1   ; Armazenamento do número de discos
    len_buffer resb 2 ; Buffer para armazenar a comprimento da string
    
section .text

    global _start
    
_start:
    
    mov ecx, msg_ini     ; Print da mensagem inicial
    call print_fim_0       ; Chama a função para printar a msg
    
    call ler_input         ; Lendo apenas no máximo dois bytes, porque se houver dois algarismo e um Newline(ENTER) eu só quero os algarismos
    lea esi, [input]
    mov ecx, 0x2
    
    call string_to_int ; Convertendo a minha entrada para um número inteiro para poder realizar as operações
    
    mov [num_disc], eax  ; Guarda o valor em int no ondereço que reservei para o número de discos
    
    call torre_hanoi     ; Chamando o subprocedimento principal
    
    mov ecx, msg_final
    call print_fim_0
    
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
print_fim_0:                   ; Print para quando a string termina em 0 para printar sem as msg "sem saber" o tamanho delas
    loop_print:
        mov al, byte[ecx]          ; Carregar o primeiro
        cmp al, 0               ; Verificar se é o final da string
        je end_print            ; Se for, sair da função
        call print_ecx        ; Se não chama o subprocedimento de print que não se preocupa com o final 0
        inc ecx                 ; Move para o próximo caractere
        jmp loop_print          ; Repete o loop

    end_print:                  ; Saída do loop
        ret                     ; Retorno
print_ecx:          ; Printa a string que armazenei em ecx na chamada da função
    mov eax, 4      ; Chamada de sistema Write
    mov ebx, 1      ; Chamada Sys_out
    mov edx, 1      ; Tamanho do caractere
    int 0x80
    ret             ; Retorna pro ponto onde foi chamada
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
        call print_fim_0
        
        call print_disc     ; Printando o disco 1
        
        mov ecx, msg_mov2   ; Movendo para ecx ' da torre '
        call print_fim_0
        
        mov ecx, torre_orig ; Movendo para ecx a torre de origem no momento
        call print_fim_0
        
        mov ecx, msg_mov3   ; Movendo para ecx ' para a torre '
        call print_fim_0
        
        mov ecx, torre_dest ; Movendo para ecx a torre de destino no momento
        call print_fim_0
        
        mov ecx, pular_linha ; Movendo para ecx a quebra de linha para continuar os prints
        call print_ecx
        
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
        call print_fim_0 ; Printar o que está em ecx
        
        inc byte [num_disc] ; Aumento da quantidade de discos para o decréscimo anterior não influenciar na exibição do valor do disco que será movido
        call print_disc ; Função que exibe a quantidade de discos atual, que também é o disco que está sendo movido, assumindo que o disco 1 é o menor e o número vai crescendo de acordo com o tamanho do disco
        dec byte [num_disc] ; Decréscimo para retornar o valor anterior ao acréscimo que foi feito anteriormente
        
        mov ecx, msg_mov2 ; Armazenar string em ecx
        call print_fim_0 ; Printar o que está em ecx
        
        mov ecx, torre_orig ; Move o valor da coluna origem para ecx
        call print_fim_0 ; Printar o que está em ecx
        
        mov ecx, msg_mov3 ; Armazenar string em ecx
        call print_fim_0 ; Printar o que está em ecx
        
        mov ecx, torre_dest ; Move o valor da destino origem para ecx
        call print_fim_0 ; Printar o que está em ecx
        
        mov ecx, pular_linha ; Armazenar string em ecx, neste caso é uma quebra de linha
        call print_ecx ; Printar o que está em ecx
        
        ; Trocando o valor da coluna auxiliar com o valor da coluna de origem
        mov dx, [torre_aux] ; Armazena o valor da coluna auxiliar no registrador dx
        mov cx, [torre_orig] ; Armazena o valor da coluna origem no registrador cx
        mov [torre_orig], dx ; Move o valor de cx(coluna origem) para a coluna auxiliar
        mov [torre_aux], cx ; Move o valor de cx(coluna auxiliar) para a coluna origem
        call torre_hanoi ; Recursão
    
    concluido:
        ret
