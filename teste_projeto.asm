.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib ;biblioteca p/ usar CreateFile
includelib \masm32\lib\masm32.lib   ;biblioteca p/ usar StrLen


.data
;entrada e saída
file_name_request db "Insira o nome do arquivo .bmp: ", 0h
file_name db 10 dup(0)  ;string p nome de arq
x_request db "Valor de X: ", 0h
X dd 0
y_request db "Valor de Y: ", 0h
Y dd 0
altura_request db "Altura: ", 0h
altura dw 0
largura_request db "Largura: ", 0h
largura dw 0

;handles
fileHandle HANDLE 0
inputHandle dd 0
outputHandle dd 0

console_count dd 0

byteCount dd 0
headerBuffer db 54 dup(0)
imageBuffer db 6480 dup(0)

.code
start:
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
    
    invoke WriteConsole, outputHandle, addr file_name_request, sizeof file_name_request, console_count, NULL
    invoke ReadConsole, inputHandle, addr file_name, sizeof file_name, addr console_count, NULL ; recebe o nome do arquivo

    mov esi, offset file_name   ; mov endereço de file_name pra ESI p/ conversão em dword

    ; tratamento de string aqui
    
    invoke WriteConsole, outputHandle, addr x_request, sizeof x_request, console_count, NULL
    invoke ReadConsole, inputHandle,  addr X, 4, console_count, NULL ; pede e lê X

    invoke WriteConsole, outputHandle, addr y_request, sizeof y_request, console_count, NULL
    invoke ReadConsole, inputHandle, addr Y, 4, console_count, NULL ; pede e lê Y

    invoke WriteConsole, outputHandle, addr largura_request, sizeof largura_request, console_count, NULL
    invoke ReadConsole, inputHandle, addr largura, 4, console_count, NULL ; pede e l� a largura

    invoke WriteConsole, outputHandle, addr altura_request, sizeof altura_request, console_count, NULL
    invoke ReadConsole, inputHandle, addr altura, 4, console_count, NULL ; pede e l� a altura

    ; lê o arquivo e passa ele para var fileHandle
    invoke CreateFile, addr file_name, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax

    invoke ReadFile, fileHandle, addr headerBuffer, 18, addr byteCount, 0 ; lê os primeiros 18 bytes
    invoke WriteFile, eax, addr headerBuffer, 18, addr byteCount, 0 ; escreve no arquivo de saída

    invoke ReadFile, fileHandle, addr largura, 4, addr byteCount, 0 ; lê o tamanho da largura
    invoke WriteFile, eax, addr largura, 4, addr byteCount, 0 ; escreve no arquivo de saída

    mov eax, 32
    sub eax, 4
    invoke ReadFile, fileHandle, addr headerBuffer, eax, addr byteCount, 0 ; lê os 32 bytes restantes do cabeçalho
    invoke WriteFile, outputHandle, addr headerBuffer, eax, addr byteCount, 0 ; escreve no arquivo de saída

    mov ecx, altura ; move o valor da altura para ecx
    imul ecx, largura ; multiplica a altura pela largura para calcular o número de pixels
    imul ecx, 3 ; multiplica por 3 para obter o número total de bytes a serem lidos
    mov edx, 0
    

readLoop:
    invoke ReadFile, fileHandle, addr imageBuffer, ecx, addr byteCount, 0 ; lê os bytes da imagem
    invoke WriteFile, outputHandle, addr imageBuffer, byteCount, addr byteCount, 0 ; escreve no arquivo de saída

    sub ecx, byteCount
    jnz readLoop ; repete o loop até que byteCount e ecx sejam iguais

    invoke CloseHandle, fileHandle

end start
invoke ExitProcess, 0


