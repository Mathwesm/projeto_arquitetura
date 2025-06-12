
global add        ; Tornando a função add visível ao linker
global sub        ; Tornando a função sub visível ao linker
global mul        ; Tornando a função mul visível ao linker
global div        ; Tornando a função div visível ao linker
global main       ; Tornando a função main visível (ponto de entrada)
extern printf     ; Declara printf como função externa (da libc)
extern scanf      ; Declara scanf como função externa
extern puts       ; Declara puts como função externa

section .data
msg_div_zero db "Erro: divisão por zero!", 0             ; Mensagem de erro para divisão por zero
msg_format_s db "%s", 0                                  ; Formato para strings (printf/scanf)
msg_format_d db "%d", 0                                  ; Formato para inteiros
msg_input_1 db "Digite o primeiro número: ", 0           ; Mensagem de entrada do primeiro número
msg_input_2 db "Digite o segundo número: ", 0            ; Mensagem de entrada do segundo número
msg_result db "Resultado: %d", 10, 0                     ; Mensagem para exibir o resultado (\n = 10)
msg_invalid db "Opção inválida!", 0                      ; Mensagem de erro para opção inválida
msg_exit db "Programa encerrado.", 0                     ; Mensagem ao sair do programa
menu_str db "Escolha uma opção:", 10, "1. Soma", 10, "2. Subtração", 10, "3. Multiplicação", 10, "4. Divisão", 10, "5. Sair", 0


section .bss
op      resd 1        ; Reserva 4 bytes para armazenar a opção escolhida
num1    resd 1        ; Reserva 4 bytes para o primeiro número
num2    resd 1        ; Reserva 4 bytes para o segundo número

section .text



add:
    mov eax, edi   ; copia o primeiro número (edi) para eax
    add eax, esi   ; soma o segundo número (esi) a eax
    ret            ; retorna (eax já tem o resultado)

sub:
    mov eax, edi     ; Move o primeiro número para eax
    sub eax, esi     ; Subtrai o segundo número
    ret              ; Retorna o resultado

mul:
    mov eax, edi     ; Move o primeiro número para eax
    imul eax, esi    ; Multiplica eax * esi
    ret              ; Retorna o resultado

div:
    cmp esi, 0       ; Verifica se o divisor é 0
    jne .ok          ; Se não for zero, pula para .ok
    mov rdi, msg_div_zero ; Se for zero, carrega a mensagem de erro
    call puts        ; Exibe a mensagem
    xor eax, eax     ; Coloca 0 em eax como resultado padrão
    ret              ; Retorna
.ok:
    mov eax, edi     ; Move o numerador para eax
    cdq              ; Estende eax para edx:eax (divisão com sinal)
    idiv esi         ; Divide edx:eax por esi
    ret              ; Resultado da divisão está em eax


main:
    push rbp         ; Salva o base pointer anterior
    mov rbp, rsp     ; Define o novo base pointer

.loop:
    ; Exibe o menu
    mov rdi, msg_format_s ; rdi = formato "%s"
    mov rsi, menu_str     ; rsi = string do menu
    xor eax, eax          ; zera eax (convenção variádica do printf)
    call printf           ; chama printf("%s", menu_str)

    ; Lê a opção do usuário
    mov rdi, msg_format_d ; formato "%d"
    mov rsi, op           ; destino do número lido
    xor eax, eax
    call scanf            ; scanf("%d", &op)

    mov eax, [op]         ; carrega o valor de op
    cmp eax, 5
    je .exit              ; se for 5, encerra o programa

    cmp eax, 1
    jl .invalid           ; se for menor que 1, opção inválida
    cmp eax, 4
    jg .invalid           ; se for maior que 4, opção inválida

    ; Entrada do primeiro número
    mov rdi, msg_format_s
    mov rsi, msg_input_1
    xor eax, eax
    call printf

    mov rdi, msg_format_d
    mov rsi, num1
    xor eax, eax
    call scanf

    ; Entrada do segundo número
    mov rdi, msg_format_s
    mov rsi, msg_input_2
    xor eax, eax
    call printf

    mov rdi, msg_format_d
    mov rsi, num2
    xor eax, eax
    call scanf

    ; Carrega os argumentos para as funções
    mov eax, [op]         ; carrega a operação escolhida
    mov edi, [num1]       ; primeiro número → edi
    mov esi, [num2]       ; segundo número → esi

    ; Seleciona a operação
    cmp eax, 1
    je .call_soma
    cmp eax, 2
    je .call_sub
    cmp eax, 3
    je .call_multi
    cmp eax, 4
    je .call_div

.invalid:
    mov rdi, msg_invalid  ; mensagem de erro
    call puts             ; exibe mensagem
    jmp .loop             ; volta ao menu

; Chamadas de funções aritméticas
.call_soma:
    call add
    jmp .print_result

.call_sub:
    call sub
    jmp .print_result

.call_multi:
    call mul
    jmp .print_result

.call_div:
    call div
    jmp .print_result

; Impressão do resultado
.print_result:
    mov esi, eax          ; move resultado para esi (arg printf)
    mov rdi, msg_result   ; string "Resultado: %d\n"
    xor eax, eax
    call printf           ; imprime o resultado
    jmp .loop             ; volta ao menu

.exit:
    mov rdi, msg_exit     ; "Programa encerrado."
    call puts             ; imprime mensagem

    mov eax, 0            ; código de retorno 0
    leave                 ; desfaz stack frame (equiv. a: mov rsp, rbp + pop rbp)
    ret                   ; retorna da main
