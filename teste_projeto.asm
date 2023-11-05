.686
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib

.data

CRLF db 13, 10, 0 
file_name_request db "Insira o nome do arquivo .bmp: ", 0
file_name db 260 dup(0)  
x_request db "Valor de X: ", 0
X dd 0
y_request db "Valor de Y: ", 0
Y dd 0
altura_request db "Altura: ", 0
altura dw 0
largura_request db "Largura: ", 0
largura dw 0

fileHandle HANDLE 0
newFileHandle HANDLE 0
inputHandle dd 0
outputHandle dd 0

console_count dd 0

byteCount dd 0
headerBuffer db 54 dup(0)
imageBuffer db 6480 dup(0)

file_open_error_message db "Erro na abertura do arquivo!", 0
file_creation_error_message db "Erro na criação do arquivo!", 0

fotocensurada db "fotocensurada.bmp",0

.code
start:

    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    invoke WriteConsole, outputHandle, addr file_name_request, 31, NULL, NULL

    invoke ReadConsole, inputHandle, addr file_name, 260, addr console_count, NULL

    mov esi, offset file_name
    proximo:
    mov al, [esi] 
    inc esi
    cmp al, 13 
    jne proximo
    dec esi 
    xor al, al
    mov [esi], al

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
    cmp fileHandle, INVALID_HANDLE_VALUE
    je FileOpenError

    invoke CreateFile, addr fotocensurada, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov newFileHandle, eax
    cmp newFileHandle, INVALID_HANDLE_VALUE
    je FileCreationError

    invoke ReadFile, fileHandle, addr headerBuffer, 54, addr byteCount, 0
    invoke WriteFile, newFileHandle, addr headerBuffer, 54, addr byteCount, 0

    mov eax, 0
    movzx ecx, word ptr largura
    movzx edx, word ptr altura
    imul ecx, edx
    imul ecx, 3

    invoke SetFilePointer, fileHandle, 54, NULL, FILE_BEGIN

    readLoop:
        invoke ReadFile, fileHandle, addr imageBuffer, 6480, addr byteCount, 0
        test eax, eax
        jz readLoop_concluid
        invoke WriteFile, newFileHandle, addr imageBuffer, byteCount, addr byteCount, 0
        jmp readLoop

    readLoop_concluid:
        sub ecx, byteCount
        jnz readLoop

    invoke CloseHandle, fileHandle
    invoke CloseHandle, newFileHandle
    invoke ExitProcess, 0

FileOpenError:
    invoke StdOut, addr file_open_error_message
    invoke StdOut, addr CRLF
    jmp Exit

FileCreationError:
    invoke StdOut, addr file_creation_error_message
    invoke StdOut, addr CRLF
    jmp Exit

Exit:
    invoke ExitProcess, 1

end start
