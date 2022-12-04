.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data

table BYTE  48 DUP (' '), "**********", 7 DUP (' ')
      BYTE  "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 6 DUP (' ')
      BYTE  "abcdefghijklmnopqrstuvwxyz", 133 DUP (' ')

source BYTE "Lovelace123", 0
dest   BYTE "Turing01234", 0

char1 BYTE ? ; I (HOPEFULLY) MADE THIS EASY TO GRADE--Add char1 to watch and set a breakpoint on line 33.

.code
main proc

    cld                         ; set DF
    lea ebx, table              ; prep the translation table
    lea esi, source             ; set esi to source address
    lea edi, dest               ; set edi to dest address
    mov ecx, LENGTHOF source    ; prepare with length of source
Translate: lodsb                ; load a char
    xlat                        ; change it
    stosb                       ; store it
    loop Translate              ; do it until we're done

    ; the following is reused code from CSC3410-StringOperations.asm, included for convenience.

    lea esi, dest                    ; Move address of array to esi
ShowChar: mov  al, BYTE PTR [esi]    ; Move first element of dest to al
          mov char1, al              ; Move character in al to char1
          add  esi, 1                ; point at next element
		  cmp    BYTE PTR [esi], 0   ; see if we hit the end
          je     endWhileNoNull2     ; if so, end
          loop ShowChar              ; repeat
          endWhileNoNull2:
   mov    ecx, 0  

	invoke ExitProcess,0
main endp
end main