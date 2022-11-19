.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
mynum DWORD 0
mynum_factorial DWORD 0
mynum_flags WORD 0

.code

Factorial PROC
	push ebp     ;save old ebp
	mov ebp, esp ;set new ebp

	mov ecx, [ebp+8] ;need to put parameter in register before cmp
	cmp ecx, 0
	jz IsZero ;recursion ends when parameter is 0

	mov ebx, [ebp+8]
	dec ebx        ;take our parameter, dec by 1, and pass it off as an argument to the recursive call
	push ebx       ;put argument on stack
	call Factorial ;call procedure--every time we call it, we put eip, ebp, and mynum on the stack, overflowing it an mynums ~= 300, but nums as low as 13 will overflow mynums_factorial anyway.
	add esp, 4     ;remove parameter from stack
	imul eax, [ebp+8] ;multiply eax by the value returned by the recursion
	jmp EndFact

IsZero: mov eax, 1 ;0! = 1
EndFact: pop ebp   ;restore old ebp
	ret
Factorial ENDP

isPrime PROC
	push ebp           ;save old ebp
	mov ebp, esp       ;set new ebp

	mov ecx, [ebp+8]   ;need to store param in a register for cmp
	cmp ecx, 0         
	jng EndComposite   ;if it's nonpositive, just end.

	mov ebx, 1         ;ebx will be used as the denominator for PrimeTest

PrimeTest:	inc ebx  ;ebx=2 for the first loop because it is the first nontrivial factor
	mov eax, [ebp+8] ;put value of mynum in eax
	mov edx, 0       ;init for div
	div ebx          ;using unsigned division because all negative instances of mynum should already be handled
	cmp ebx, eax     ;All factors of n are integer pairs in range [1,n]. For all pairs (x,y), (y,x) is also a pair.
					 ;For all pairs (x,y), x>=y, AND x=y iff x=y=sqroot(n). Therefore, for all factors pairs of n, at least one element can be found inside the range [1,sqroot(n)].
					 ;If we find that x<y, we must have already failed to find a factor within that range, therefore the number is prime. In this code, x=ebx, y=eax after division. If this doesn't make sense, just trust me that it works.
	ja EndPrime      ;using unsigned conditional jump b/c all negative mynum should be handled already.
	cmp edx, 0
	jz EndComposite
	jmp PrimeTest    ;loop

EndPrime: mov eax, 1
	jmp Return
EndComposite: mov eax, 0
Return: pop ebp
	ret
isPrime ENDP

isEven MACRO arg_1
	cmp arg_1, 0
	jle NotEven
	mov eax, 01h        ;moves 0000...0001 to eax
	and eax, arg_1      ;if mynum is odd, eax will hold _000...0001.
	cmp eax, 0          ;if mynum is even, eax will hold all 0s.
	jnz NotEven
	or mynum_flags, 10b ;setting flag
NotEven:
	ENDM

main PROC
	;FACTORIAL RECURSIVE PROCEDURE
	cmp mynum, 0
	jl negMynum	   ;if mynum is negative, we will skip over this all

	push mynum     ;put mynum on stack as parameter
	call Factorial ;call procedure
	add esp, 4     ;remove parameter from stack
	mov mynum_factorial, eax
	jmp overNegMynum

negMynum: mov mynum_factorial, -1
overNegMynum:

	
	;ISPRIME PROCEDURE
	push mynum   ;put mynum on stack as parameter
	call isPrime
	add esp, 4   ;remove parameter from stack--at this point, esp and ebp should be the same at it was before push mynum.
	or mynum_flags, ax ;0 is stored in ax for non-positives and composites. 1 is stored in ax for positive primes.

	;ISEVEN MACRO
	isEven mynum

	invoke ExitProcess,0

main ENDP
end main