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
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    invoke WriteConsole, outputHandle, addr file_name_request, 31, NULL, NULL
    invoke ReadConsole, inputHandle, addr file_name, 260, addr console_count, NULL

    mov esi, offset file_name

    ; tratamento de string aqui

    invoke WriteConsole, outputHandle, addr x_request, 11, NULL, NULL
    invoke ReadConsole, inputHandle, addr X, 4, addr console_count, NULL

    invoke WriteConsole, outputHandle, addr y_request, 11, NULL, NULL
    invoke ReadConsole, inputHandle, addr Y, 4, addr console_count, NULL

    invoke WriteConsole, outputHandle, addr largura_request, 10, NULL, NULL
    invoke ReadConsole, inputHandle, addr largura, 4, addr console_count, NULL

    invoke WriteConsole, outputHandle, addr altura_request, 8, NULL, NULL
    invoke ReadConsole, inputHandle, addr altura, 4, addr console_count, NULL

    invoke CreateFile, addr file_name, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax

    invoke ReadFile, fileHandle, addr headerBuffer, 18, addr byteCount, 0
    invoke WriteFile, outputHandle, addr headerBuffer, 18, addr byteCount, 0

    invoke ReadFile, fileHandle, addr largura, 4, addr byteCount, 0
    invoke WriteFile, outputHandle, addr largura, 4, addr byteCount, 0

    mov eax, 32
    sub eax, 4
    invoke ReadFile, fileHandle, addr headerBuffer, eax, addr byteCount, 0
    invoke WriteFile, outputHandle, addr headerBuffer, eax, addr byteCount, 0

    movzx ecx, altura
    movzx eax, largura
    imul ecx, eax
    imul ecx, 3
    mov edx, 0

readLoop:
    invoke ReadFile, fileHandle, addr imageBuffer, 6480, addr byteCount, 0
    invoke WriteFile, outputHandle, addr imageBuffer, byteCount, addr byteCount, 0

    sub ecx, byteCount
    jnz readLoop

    invoke CloseHandle, fileHandle

end start
invoke ExitProcess, 0
