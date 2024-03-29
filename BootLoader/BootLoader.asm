[ORG 0x00]	; 코드의 시작 주소를 0x00으로 설정
[BITS 16]	; 이하의 코드는 16비트 코드로 설정

SECTION .text	; text 섹션(세그먼트)fmf wjddml

jmp 0x07C0:START	; CS 세그먼트 레지스터에 0x07C0을 복사하면서, START 레이블로 이동

START:
	mov ax, 0x07C0	; 부트 로더의 시작 주소(0x7C00)를 세그먼트 레지스터 값으로 변환
	mov ds, ax		; DS 세그먼트 레지스터에 설정
	mov ax, 0xB800	; 비디오 메모리의 시작 주소(0xB800)를 세그먼트 레지스터 값으로 변환
	mov es, ax		; EX 세그먼트 레지스터에 설정

	mov si, 0		; SI 레지스터 초기화

.SCREENCLEARLOOP:	; 화면 지우는 루프
	mov byte [ es: si ], 0	; 비디오 메모리의 문자가 위치하는 주소에 0을 복사해서 문자를 삭제
	mov byte [ es: si + 1 ], 0x07	; 비디오 메모리의 속성이 위치하는 주소에 0x07을 복사

	add si, 2		; 문자와 속성을 설정했으므로 다음 위치로 이동

	cmp si, 80 * 25 * 2	; 화면의 전체 크기는 80 * 25임. 출력한 문자의 수를 비교하는 SI 레지스터와 비교

	jl .SCREENCLEARLOOP	; SI 레지스터가 80 * 25 * 2보다 작다면 아직 지우지 못한 영역이 있음
						; .SCREENCLEARLOOP 레이블로 이동해서 반복실행

	mov si, 0	; SI 레지스터(문자열 원본 인덱스 레지스터)를 초기화
	mov di, 0	; DI 레지스터(문자열 대상 인덱스 레지스터)를 초기화

.MESSAGELOOP:	; 메시지를 출력하는 루프
	mov cl, byte [ si + MESSAGE1 ]	; MESSAGE1의 주소에서 SI레지스터 값만큼 더한 위치의 문자를 CL레지스터에 복사
									; CL 레지스터는 CX 레지스터의 하위 1바이트를 의미
									; 문자열은 1바이트로 충분하므로 CX 레지스터의 하위 1바이트만 사용
	cmp cl, 0	; 복사된 문자와 0을 비교
	je .MESSAGEEND	; 복사한 문자의 값이 0이면 문자열 종료
					; .MESSAGEEND로 이동해서 문자 출력 끝냄
	
	mov byte [ es: di ], cl ; 0이 아니면 비디오 메모리 주소 0xB800:di에 문자를 출력

	add si, 1	; SI레지스터에 1을 더해서 다음 문자열으로 이동
	add di, 2	; DI레지스터에 2를 더해서 비디오 메모리의 다음 문자 위치로 이동

	jmp .MESSAGELOOP	; 메시지 출력 루프로 이동

.MESSAGEEND:	; 메시지 종료 루프
	jmp $	; 현재 위치에서 무한루프 수행

MESSAGE1: db 'Hello World!', 0	; 출력할 메시지 정의
								; 마지막은 0으로 설정해서 문자열의 끝을 표시함.

jmp $			; 현재 위치에서 무한루프 수행

times 510 - ( $ - $$ ) db 0x00
; $: 현재라인의 주소
; $$: 현재 섹션(.text)의 시작 주소
; $ - $$: 현재 섹션을 기준으로 하는 오프셋
; 510-($-$$) 현재부터 주소 510까지
; db 0x00: 1바이트를 선언하고 값은 0x00
; time: 반복 수행
; 현재 위치에서 주소 510까지 0x00으로 채우는 코드

db 0x55	; 1바이트를 선언하고 값은 0x55
db 0xAA ; 1바이트를 선언하고 값은 0xAA

; 주소 511, 512에 0x55, 0xAA를 써서 부트 섹터로 표기함
