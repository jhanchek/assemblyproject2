.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
s1 BYTE "Bob", 0
s2 BYTE "Bob", 0
s3 BYTE "Bob", 0

stringorder WORD 0

table BYTE  48 DUP (' '), "0123456789", 7 DUP (' ')
      BYTE  "abcdefghijklmnopqrstuvwxyz", 6 DUP (' ')
      BYTE  "abcdefghijklmnopqrstuvwxyz", 133 DUP (' ')

temp BYTE ?

.code
main proc

;CONVERTING STRINGS TO LOWERCASE
	lea eax, s1		;prep our 3 strings in the stack
	push eax
	lea eax, s2
	push eax
	lea eax, s3
	push eax

	lea ebx, table  ;prep the translation table
	mov ecx, 3      ;prep ecx w/ 3 because we pushed 3 strings
PrepStr:
	pop esi			;grab one string
	mov edi, esi	;have it in both esi and edi
ConvertStr:
	lodsb           ;copy character from string
	cmp al, 0		
	je DoneCvrt		;leave if we hit null byte
	xlat            ;translate character
	stosb           ;copy character back into string
	jmp ConvertStr
DoneCvrt:
	loop PrepStr

	;SUMMARY of the following section:
	;after PART 1, stringorder can be 210 or 120.
	;after PART 2, string order can change from 210 to 212 or 311, or from 120 to 122 or 221.
	;after PART 3, string order can change from 122 to 123 or 132, or 311 to 321 or 312, or 221 to 231, or 212 to 213.
	;the reason 221 and 212 only have one outcome in part 3 is because alphabetic order is transitive--if 1 is higher than two and lower than 3, 3 must always be higher than 2 (this would be 221->231)

;TESTING S1 AND S2
	mov ecx, LENGTHOF s1 ;as long as ecx is at least and at most as long as ONE of the strings, the sorting will execute properly.
	lea esi, s1		;prep s1
	lea edi, s2		;prep s2

	repe cmpsb		;compare strings until they differ
	jbe s1_first	;if the strings are equal, the first one in the list in considered first alphabetically.
	jmp s1_later
s1_first:
	add stringorder, 120h ;1 can be, at most, first. 2 can be, at most, second.
jmp PartOneDone
s1_later:
	add stringorder, 210h ;1 can be, at most, second. 1 can be, at most, first.
PartOneDone:

;TESTING S1 AND S3
	mov ecx, LENGTHOF s3 ;as long as ecx is at least and at most as long as ONE of the strings, the sorting will execute properly.
	lea esi, s3		;prep s1
	lea edi, s1		;prep s3

	repe cmpsb		;compare strings until they differ
	jb s3_first		;if the strings are equal, the first one in the list in considered first alphabetically.
	jmp s3_later
s3_first:
	add stringorder, 101h ;if 3 is greater, it can be, at most, first, so we add 1h. if 1 was in first before this, it lost the tie and is now second. if 1 was in second before this, it has now been last twice so it must be in third place. Therefore we add 100h.
jmp PartTwoDone
s3_later:
	add stringorder, 2h ;if 3 is less than, it can be, at most, second. 
PartTwoDone:

;TESTING S2 AND S3
	mov ecx, LENGTHOF s2 ;as long as ecx is at least and at most as long as ONE of the strings, the sorting will execute properly.
	lea esi, s2		;prep s2
	lea edi, s3		;prep s3

	repe cmpsb		;compare strings until they differ
	jbe s2_first	;if the strings are equal, the first one in the list in considered first alphabetically.
	jmp s2_later
s2_first:
	add stringorder, 1h ;if 2 is greater, it should mean 3 is less than, thus we add 1h to push 3 back one place in the ranking
jmp PartThreeDone
s2_later:
	add stringorder, 10h ;if 2 is less than, we add 10 to push 2 back one place in the ranking.
PartThreeDone:

	invoke ExitProcess,0
main endp
end main