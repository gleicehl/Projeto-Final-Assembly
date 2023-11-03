.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
; entrada e saída
file_name_request db "Insira o nome do arquivo .bmp: ", 0
file_name db 260 dup(0)  ; string para nome do arquivo
x_request db "Valor de X: ", 0
X dd 0
y_request db "Valor de Y: ", 0
Y dd 0
altura_request db "Altura: ", 0
altura dw 0
largura_request db "Largura: ", 0
largura dw 0

; handles
fileHandle HANDLE 0
inputHandle dd 0
outputHandle dd 0

console_count dd 0

byteCount dd 0
headerBuffer db 54 dup(0)
imageBuffer db 6480 dup(0)

.code
start:
    ; Obtém os handles de entrada e saída padrão
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; Escreve a solicitação para inserir o nome do arquivo .bmp
    invoke WriteConsole, outputHandle, addr file_name_request, 31, NULL, NULL

    ; Lê o nome do arquivo .bmp inserido pelo usuário
    invoke ReadConsole, inputHandle, addr file_name, 260, addr console_count, NULL

    ; Inicializa esi com o endereço do nome do arquivo
    mov esi, offset file_name

    ; Tratamento de string

    mov esi, offset file_name ; Armazenar apontador da string em esi
    proximo:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo
    dec esi ; Apontar para caractere anterior
    xor al, al ; ASCII 0
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

    ; Solicita e lê o valor de X
    invoke WriteConsole, outputHandle, addr x_request, 11, NULL, NULL
    invoke ReadConsole, inputHandle, addr X, 4, addr console_count, NULL

    ; Solicita e lê o valor de Y
    invoke WriteConsole, outputHandle, addr y_request, 11, NULL, NULL
    invoke ReadConsole, inputHandle, addr Y, 4, addr console_count, NULL

    ; Solicita e lê o valor da largura
    invoke WriteConsole, outputHandle, addr largura_request, 10, NULL, NULL
    invoke ReadConsole, inputHandle, addr largura, 4, addr console_count, NULL

    ; Solicita e lê o valor da altura
    invoke WriteConsole, outputHandle, addr altura_request, 8, NULL, NULL
    invoke ReadConsole, inputHandle, addr altura, 4, addr console_count, NULL

    ; Cria o arquivo com os parâmetros fornecidos
    invoke CreateFile, addr file_name, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax

    ; Lê os primeiros 18 bytes do arquivo e escreve-os no arquivo de saída
    invoke ReadFile, fileHandle, addr headerBuffer, 18, addr byteCount, 0
    invoke WriteFile, outputHandle, addr headerBuffer, 18, addr byteCount, 0

    ; Lê os próximos 28 bytes do cabeçalho e escreve-os no arquivo de saída
    mov eax, 32
    sub eax, 4
    invoke ReadFile, fileHandle, addr headerBuffer, eax, addr byteCount, 0
    invoke WriteFile, outputHandle, addr headerBuffer, eax, addr byteCount, 0

    ; Converte a altura e a largura em 32 bits e multiplica-as por 3 para obter o número total de bytes a serem lidos
    movzx ecx, word ptr largura
    movzx eax, word ptr altura
    imul ecx, eax
    imul ecx, 3
    mov edx, 0

    ; Mova o ponteiro do arquivo para a posição correta para ler os dados da imagem
    invoke SetFilePointer, fileHandle, 54, NULL, FILE_BEGIN

    readLoop:
        ; Lê o arquivo em partes e escreve o conteúdo no arquivo de saída
        invoke ReadFile, fileHandle, addr imageBuffer, 6480, addr byteCount, 0
        invoke WriteFile, outputHandle, addr imageBuffer, byteCount, addr byteCount, 0

        ; Subtrai a quantidade de bytes lidos do número total de bytes a serem lidos e continua o loop se necessário
        sub ecx, byteCount
        jnz readLoop

    ; Fecha o arquivo
    invoke CloseHandle, fileHandle

    ; Finaliza o processo
    invoke ExitProcess, 0

end start


