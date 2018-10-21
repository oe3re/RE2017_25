INCLUDE Irvine32.inc

.data

; za postavljanje ekrana
outHandle    DWORD ?
cellsWritten DWORD ?
scrSize COORD <80,25>
xyPos COORD <0,0>
titleStr BYTE "Minesweeper",0
windowRect	SMALL_RECT <0,0,8,8>
questionMsg byte "Da li zelite da napustite igru?", 0
gameoverMsg byte "Pogodili te minu. Igra je zavrsena", 0
newGameMsg byte "Da li zelite da zapocnete novu igru?", 0
winMsg byte "Pogodili ste sve mine. Igra je predjena", 0
captionQ byte "Izlazak", 0
captionG byte "Igra zavrsena", 0
captionNG byte "Nova igra?", 0
captionWin byte "Pobeda", 0

; za karaktere i boje
karakterPrazan = 0B0h
kursorX byte 4
kursorY byte 4
kursorBoja = yellow
pozadinaBoja = white
zastavaBoja = red
trenutnoPolje byte 0
minaBoja byte red
minaKarakter byte 0Fh
counter byte 0
dataX byte 0
dataY byte 0
kursorXX byte 0
kursorYY byte 0
pogodjene byte 0

matricaMina byte 0, 0, 0, 0, 0, 0, 0, 1, 0
			byte 0, 1, 0, 0, 0, 0, 0, 0, 1
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 1, 0, 0, 0, 0, 0
			byte 1, 0, 0, 0, 0, 0, 0, 1, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 1, 0, 0, 0, 1, 0, 0, 0
			byte 0, 0, 1, 0, 0, 0, 0, 1, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0

matricaMinaBroj byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0

; 0 - zatvoreno polje, 1 - otvoreno polje, 2 - zastava
matricaMinaPodatak byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0
			byte 0, 0, 0, 0, 0, 0, 0, 0, 0

.code

	; ******************************
	; for loop za popunjavanje ekrana
	; ******************************

popunjavanjeEkrana PROC
		mov eax, pozadinaBoja
		call SetTextColor
		mov ch, 9
		mov cl, 9
		mov dh, 0
		mov dl, 0
		mov al, karakterPrazan
	loop2:
	loop1:
		call Gotoxy
		call WriteChar
		inc dh
		cmp ch, dh
		jnz loop1
		mov dh, 0
		inc dl
		cmp cl, dl
		jnz loop2
	ret
popunjavanjeEkrana endp

	; ******************************
	; pocetna pozicija kursora
	; ******************************

pocetnaPozicijaKursora PROC
		mov eax, kursorBoja
		call SetTextColor
		mov dh, kursorY
		mov dl, kursorX
		call Gotoxy
		mov al, karakterPrazan
		call WriteChar
		call Crlf ;***
		mov eax, pozadinaBoja
		call SetTextColor
	ret
pocetnaPozicijaKursora endp

	; ******************************
	; broji mine oko jednog polja
	; ******************************

izracunavanje PROC
	mov cl, 9
	mov ch, 9
	xor ebx, ebx
	mov bl, dataY
	xor edx, edx
petlja:
	add edx, ebx
	dec cl
	cmp cl, 0
	jne petlja
	mov bl, dataX
	add edx, ebx
	mov esi, edx

	ret
izracunavanje endp

	; ******************************
	; broji mine oko jednog polja
	; ******************************
izbrojiMine PROC
		mov dataX, ch
		mov dataY, cl
		mov counter, 0
		
	LOOPxy0:
		; x-1, y-1
		dec dataX
		dec dataY
		cmp dataX, 255
		je LOOPxy1
		cmp dataY, 255
		je LOOPxy1
		cmp dataX, 9
		je LOOPxy1
		cmp dataY, 9
		je LOOPxy1
		call izracunavanje
		xor eax, eax
		cmp [matricaMina + esi], 1
		jne LOOPxy1
		inc counter
	LOOPxy1: 
		; x, y-1
		inc dataX
		cmp dataX, 255
		je LOOPxy2
		cmp dataY, 255
		je LOOPxy2
		cmp dataX, 9
		je LOOPxy2
		cmp dataY, 9
		je LOOPxy2
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy2
		inc counter
	LOOPxy2:
		; x+1, y-1
		inc dataX
		cmp dataX, 255
		je LOOPxy3
		cmp dataY, 255
		je LOOPxy3
		cmp dataX, 9
		je LOOPxy3
		cmp dataY, 9
		je LOOPxy3
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy3
		inc counter		
	LOOPxy3:
		; x-1, y
		inc dataY
		dec dataX
		dec dataX
		cmp dataX, 255
		je LOOPxy4
		cmp dataY, 255
		je LOOPxy4
		cmp dataX, 9
		je LOOPxy4
		cmp dataY, 9
		je LOOPxy4
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy4
		inc counter
	LOOPxy4:
		; x+1, y
		inc dataX
		inc dataX
		cmp dataX, 255
		je LOOPxy5
		cmp dataY, 255
		je LOOPxy5
		cmp dataX, 9
		je LOOPxy5
		cmp dataY, 9
		je LOOPxy5
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy5
		inc counter
	LOOPxy5:
		; x-1, y+1
		dec dataX
		dec dataX
		inc dataY
		cmp dataX, 255
		je LOOPxy6
		cmp dataY, 255
		je LOOPxy6
		cmp dataX, 9
		je LOOPxy6
		cmp dataY, 9
		je LOOPxy6
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy6
		inc counter
	LOOPxy6:
		; x, y+1
		inc dataX
		cmp dataX, 255
		je LOOPxy7
		cmp dataY, 255
		je LOOPxy7
		cmp dataX, 9
		je LOOPxy7
		cmp dataY, 9
		je LOOPxy7
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy7
		inc counter
	LOOPxy7:
		; x+1, y+1
		inc dataX
		cmp dataX, 255
		je LOOPxy8
		cmp dataY, 255
		je LOOPxy8
		cmp dataX, 9
		je LOOPxy8
		cmp dataY, 9
		je LOOPxy8
		call izracunavanje
		cmp [matricaMina + esi], 1
		jne LOOPxy8
		inc counter
	LOOPxy8:
		; upis u matricu sa brojem mina
		dec dataX
		dec dataY
		call izracunavanje
		mov bl, counter
		add bl, 30h
		mov matricaMinaBroj[esi], bl
		mov cl, dataY
		mov ch, dataX
		mov eax, 0
		mov counter, al
	ret
izbrojiMine endp


	; ******************************
	; izracunavanje matrice mina
	; ******************************

popuniMatricu PROC
	xor cl, cl ; brojac za y
	xor ch, ch ; brojac za x
	FORX:
	FORY:
		call izbrojiMine
		inc ch
		cmp ch, 9
		jnz FORX
		mov ch, 0
		inc cl
		cmp cl, 9
		jnz FORY
	ret
popuniMatricu endp

	; ******************************
	; promena - nije otvoreno polje
	; ******************************
promenaNijeOtvoreno PROC
		mov dl, kursorX
		mov dh, kursorY
		call Gotoxy
		mov al, karakterPrazan
		call WriteChar
	ret
promenaNijeOtvoreno endp

	; ******************************
	; promena - otvoreno polje
	; ******************************
promenaOtvoreno PROC
		xor eax, eax
		mov al, kursorX
		mov dataX, al
		mov al, kursorY
		mov dataY, al
		call izracunavanje
		mov al, matricaMinaBroj[esi]
		mov dl, kursorX
		mov dh, kursorY
		call Gotoxy
		call WriteChar
	ret
promenaOtvoreno endp

	; ******************************
	; promena - zastava
	; ******************************
promenaZastava PROC
		mov eax, zastavaBoja
		call SetTextColor
		mov dl, kursorX
		mov dh, kursorY
		mov al, karakterPrazan
		call Gotoxy
		call WriteChar
		mov eax, pozadinaBoja
		call SetTextColor
	ret
promenaZastava endp

	; ******************************
	; u 'trenutnoPolje' upisuje se podatak o trenutnom polju iz 'matricaMinaPodatak'
	; ******************************
izracunajTrenutnoPolje PROC
		xor eax, eax
		mov al, kursorX
		mov dataX, al
		mov al, kursorY
		mov dataY, al
		call izracunavanje
		mov al, matricaMinaPodatak[esi]
		mov trenutnoPolje, al
	ret
izracunajTrenutnoPolje endp

	; ******************************
	; u 'trenutnoPolje' upisuje se podatak o trenutnom polju iz 'matricaMinaPodatak'
	; ******************************
izracunajTrenutnoPolje1 PROC
		xor eax, eax
		mov al, kursorXX
		mov dataX, al
		mov al, kursorYY
		mov dataY, al
		call izracunavanje
		mov al, matricaMinaPodatak[esi]
		mov trenutnoPolje, al
	ret
izracunajTrenutnoPolje1 endp

	; ******************************
	; otvara novo polje
	; koriste se kursorXX i kursorYY da bi se sacuvale vrednosti trenutnog kursora
	; ******************************
otvaranjePolja PROC
		; otvara polje
		xor eax, eax
		mov al, kursorXX
		mov dataX, al
		mov al, kursorYY
		mov dataY, al
		call izracunavanje
		mov al, matricaMinaBroj[esi]
		mov dl, kursorXX
		mov dh, kursorYY
		call Gotoxy
		call WriteChar
		mov eax, pozadinaBoja
		call SetTextColor

		; menja stanje polja u matrici (polje je sada otvoreno)
		xor eax, eax
		mov al, kursorXX
		mov dataX, al
		mov al, kursorYY
		mov dataY, al
		call izracunavanje
		xor ebx, ebx
		mov bl, 1
		mov matricaMinaPodatak[esi], bl

		; proverava da li je broj mina 0
		xor edx, edx
		mov dl, matricaMinaBroj[esi]
		cmp dl, 30h
		je NULA
		jmp NIJE_NULA1
	NULA:
		; otvara sva polja okolo
		; x-1, y-1
		dec kursorXX
		dec kursorYY
		cmp kursorXX, 255
		je nula1
		cmp kursorXX, 9
		je nula1
		cmp kursorYY, 255
		je nula1
		cmp kursorYY, 9
		je nula1
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula1
		call otvaranjePolja
	nula1:
		; x, y-1
		inc kursorXX
		cmp kursorXX, 255
		je nula2
		cmp kursorXX, 9
		je nula2
		cmp kursorYY, 255
		je nula2
		cmp kursorYY, 9
		je nula2
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula2
		call otvaranjePolja
	nula2:
		; x+1, y-1
		inc kursorXX
		cmp kursorXX, 255
		je nula3
		cmp kursorXX, 9
		je nula3
		cmp kursorYY, 255
		je nula3
		cmp kursorYY, 9
		je nula3
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula3
		call otvaranjePolja
	nula3:
		; x-1, y
		inc kursorYY
		dec kursorXX
		dec kursorXX
		cmp kursorXX, 255
		je nula4
		cmp kursorXX, 9
		je nula4
		cmp kursorYY, 255
		je nula4
		cmp kursorYY, 9
		je nula4
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula4
		call otvaranjePolja
	nula4:
		; x+1, y
		inc kursorXX
		inc kursorXX
		cmp kursorXX, 255
		je nula5
		cmp kursorXX, 9
		je nula5
		cmp kursorYY, 255
		je nula5
		cmp kursorYY, 9
		je nula5
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula5
		call otvaranjePolja
	nula5:
		; x-1, y+1
		inc kursorYY
		dec kursorXX
		dec kursorXX
		cmp kursorXX, 255
		je nula6
		cmp kursorXX, 9
		je nula6
		cmp kursorYY, 255
		je nula6
		cmp kursorYY, 9
		je nula6
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula6
		call otvaranjePolja
	nula6:
		; x, y+1
		inc kursorXX
		cmp kursorXX, 255
		je nula7
		cmp kursorXX, 9
		je nula7
		cmp kursorYY, 255
		je nula7
		cmp kursorYY, 9
		je nula7
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je nula7
		call otvaranjePolja
	nula7:
		; x+1, y+1
		inc kursorXX
		cmp kursorXX, 255
		je NIJE_NULA
		cmp kursorXX, 9
		je NIJE_NULA
		cmp kursorYY, 255
		je NIJE_NULA
		cmp kursorYY, 9
		je NIJE_NULA
		call izracunajTrenutnoPolje1
		cmp trenutnoPolje, 1
		je NIJE_NULA
		call otvaranjePolja
	NIJE_NULA:
		dec kursorXX
		dec kursorYY
	NIJE_NULA1:
	ret
otvaranjePolja endp

	; ******************************
	; kada je mina pogodjena, otvaraju se sva polja i naznacene mine
	; ******************************
pogodjenaMina PROC
	; poruka za zavrsetak igre
	INVOKE MessageBox, NULL, ADDR gameoverMsg,
	ADDR captionG, MB_OK
	; otkrivanje svih mina
	xor esi, esi
	xor ecx, ecx
loopMx:
loopMy:
	mov dataX, ch
	mov datay, cl
	call izracunavanje
	mov ch, dataX
	mov cl, dataY
	cmp matricaMina[esi], 1
	je loopM1
	jmp loopM2
loopM1:
	mov al, minaBoja
	call SetTextColor
	mov dh, cl
	mov dl, ch
	mov al, minaKarakter
	call Gotoxy
	call WriteChar
loopM2:
	mov matricaMinaBroj[esi], 0
	mov matricaMinaPodatak[esi], 0
	inc ch
	cmp ch, 9
	jne loopMx
	xor ch, ch
	inc cl
	cmp cl, 9
	jne loopMy
	ret
pogodjenaMina endp

	; ******************************
	; main program
	; ******************************

main PROC

	INVOKE GetStdHandle,STD_OUTPUT_HANDLE
	mov outHandle,eax

	INVOKE SetConsoleScreenBufferSize,
	  outHandle,scrSize

	INVOKE SetConsoleCursorPosition, outHandle, xyPos

	INVOKE SetConsoleTitle, ADDR titleStr

	INVOKE SetConsoleWindowInfo,
		outHandle,
		TRUE,
		ADDR windowRect

	
POCETAK:
	call popuniMatricu

	call popunjavanjeEkrana

	call pocetnaPozicijaKursora	

	; ******************************
	; unos karaktera
	; ******************************
		xor al, al
	loopKey:
		mov eax, 50
		call Delay
		call ReadKey
		jz loopKey
		
		; ******************************
		; levo
		; ******************************

	_if1: 
		cmp al, 'a'
		je THEN1
		jmp ENDIF1
	THEN1:
		call izracunajTrenutnoPolje

		; provera da nije kraj ekrana
		cmp kursorX, 0
		je ENDIF1

		; vraca pozadinu
		cmp trenutnoPolje, 0
		je A0
		jmp AX0
	A0:
		call promenaNijeOtvoreno
	AX0:
		cmp trenutnoPolje, 1
		je A1
		jmp AX1
	A1:
		call promenaOtvoreno
	AX1:
		cmp trenutnoPolje, 2
		je A2
		jmp AX2
	A2:
		call promenaZastava
	AX2:

		; pomera kursor
		mov eax, kursorBoja
		call SetTextColor
		dec kursorX
		call izracunajTrenutnoPolje
		cmp trenutnoPolje, 0
		je B0
		jmp BX0
	B0:
		call promenaNijeOtvoreno
	BX0:
		cmp trenutnoPolje, 1
		je B1
		jmp BX1
	B1:
		call promenaOtvoreno
	BX1:
		cmp trenutnoPolje, 2
		je B2
		jmp BX2
	B2:
		call promenaZastava
	BX2:
		mov eax, pozadinaBoja
		call SetTextColor
	ENDIF1:

		; ******************************
		; desno
		; ******************************

	_if2: 
		cmp al, 'd'
		je THEN2
		jmp ENDIF2
	THEN2:
		call izracunajTrenutnoPolje

		; provera da nije kraj ekrana
		cmp kursorX, 8
		je ENDIF2

		; vraca pozadinu
		cmp trenutnoPolje, 0
		je C0
		jmp CX0
	C0:
		call promenaNijeOtvoreno
	CX0:
		cmp trenutnoPolje, 1
		je C1
		jmp CX1
	C1:
		call promenaOtvoreno
	CX1:
		cmp trenutnoPolje, 2
		je C2
		jmp CX2
	C2:
		call promenaZastava
	CX2:

		; pomera kursor
		mov eax, kursorBoja
		call SetTextColor
		inc kursorX
		call izracunajTrenutnoPolje
		cmp trenutnoPolje, 0
		je D0
		jmp DX0
	D0:
		call promenaNijeOtvoreno
	DX0:
		cmp trenutnoPolje, 1
		je D1
		jmp DX1
	D1:
		call promenaOtvoreno
	DX1:
		cmp trenutnoPolje, 2
		je D2
		jmp DX2
	D2:
		call promenaZastava
	DX2:
		mov eax, pozadinaBoja
		call SetTextColor
	ENDIF2:

		; ******************************
		; gore
		; ******************************

	_if3: 
		cmp al, 'w'
		je THEN3
		jmp ENDIF3
	THEN3:
		call izracunajTrenutnoPolje

		; provera da nije kraj ekrana
		cmp kursorY, 0
		je ENDIF3

		; vraca pozadinu
		cmp trenutnoPolje, 0
		je E0
		jmp EX0
	E0:
		call promenaNijeOtvoreno
	EX0:
		cmp trenutnoPolje, 1
		je E1
		jmp EX1
	E1:
		call promenaOtvoreno
	EX1:
		cmp trenutnoPolje, 2
		je E2
		jmp EX2
	E2:
		call promenaZastava
	EX2:

		; pomera kursor
		mov eax, kursorBoja
		call SetTextColor
		dec kursorY
		call izracunajTrenutnoPolje
		cmp trenutnoPolje, 0
		je F0
		jmp FX0
	F0:
		call promenaNijeOtvoreno
	FX0:
		cmp trenutnoPolje, 1
		je F1
		jmp FX1
	F1:
		call promenaOtvoreno
	FX1:
		cmp trenutnoPolje, 2
		je F2
		jmp FX2
	F2:
		call promenaZastava
	FX2:
		mov eax, pozadinaBoja
		call SetTextColor
	ENDIF3:

		; ******************************
		; dole
		; ******************************

	_if4: 
		cmp al, 's'
		je THEN4
		jmp ENDIF4
	THEN4:
		call izracunajTrenutnoPolje

		; provera da nije kraj ekrana
		cmp kursorY, 8
		je ENDIF4

		; vraca pozadinu
		cmp trenutnoPolje, 0
		je G0
		jmp GX0
	G0:
		call promenaNijeOtvoreno
	GX0:
		cmp trenutnoPolje, 1
		je G1
		jmp GX1
	G1:
		call promenaOtvoreno
	GX1:
		cmp trenutnoPolje, 2
		je G2
		jmp GX2
	G2:
		call promenaZastava
	GX2:

		; pomera kursor
		mov eax, kursorBoja
		call SetTextColor
		inc kursorY
		call izracunajTrenutnoPolje
		cmp trenutnoPolje, 0
		je H0
		jmp HX0
	H0:
		call promenaNijeOtvoreno
	HX0:
		cmp trenutnoPolje, 1
		je H1
		jmp HX1
	H1:
		call promenaOtvoreno
	HX1:
		cmp trenutnoPolje, 2
		je H2
		jmp HX2
	H2:
		call promenaZastava
	HX2:
		mov eax, pozadinaBoja
		call SetTextColor
	ENDIF4:

		; ******************************
		; otvaranje polja
		; ******************************
	_if5: cmp al, 32 ; spacebar
		je THEN5
		jmp ENDIF5
	THEN5:
		call izracunajTrenutnoPolje

		; provera da nije otvoreno polje ili zastava (onda nista ne radi)
		cmp trenutnoPolje, 1
		je ENDIF5
		cmp trenutnoPolje, 2
		je ENDIF5

		xor eax, eax
		mov al, kursorX
		mov dataX, al
		mov al, kursorY
		mov dataY, al
		call izracunavanje
		mov al, matricaMina[esi]
		cmp al, 1
		je lastLoop
		jmp lastLoop1
	lastLoop:
		call pogodjenaMina
		jmp lastLoop2
	lastLoop1:
		xor eax, eax
		mov al, kursorX
		mov kursorXX, al
		mov al, kursorY
		mov kursorYY, al
		call otvaranjePolja
		
		; postavlja kursor
		mov eax, kursorBoja
		call SetTextColor
		call promenaOtvoreno
		mov eax, pozadinaBoja
		call SetTextColor

	ENDIF5:
		; ******************************
		; postavljanje zastave
		; ******************************
	_if6: cmp al, 15 ; left Shift
		jne THEN6
		jmp ENDIF6
	THEN6:
		call izracunajTrenutnoPolje
		cmp trenutnoPolje, 1
		je ENDIF6
		cmp trenutnoPolje, 0
		je postavi
		jmp ukloni
	postavi:
		call promenaZastava
		
		; menja stanje polja u matrici (polje je sada zastava)
		xor eax, eax
		mov al, kursorX
		mov dataX, al
		mov al, kursorY
		mov dataY, al
		call izracunavanje
		xor ebx, ebx
		mov bl, 2
		mov matricaMinaPodatak[esi], bl
		; povecava broj pogodjenih mina ukoliko se mina nalazi na polju
		cmp matricaMina[esi], 1
		je POG
		jmp ENDIF6
	POG:
		inc pogodjene
		cmp pogodjene, 10
		je POBEDA
		jmp ENDIF6
	POBEDA:
		INVOKE MessageBox, NULL, ADDR winMsg,
		ADDR captionWin, MB_OK

		jmp lastLoop2
	NPOG:
		jmp ENDIF6
	ukloni:
		call promenaNijeOtvoreno

		; menja stanje polja u matrici (polje je sada neotvoreno)
		xor eax, eax
		mov al, kursorX
		mov dataX, al
		mov al, kursorY
		mov dataY, al
		call izracunavanje
		xor ebx, ebx
		mov bl, 0
		mov matricaMinaPodatak[esi], bl
		; smanjuje broj pogodjenih mina ukoliko se mina nalazila na tom polju
		cmp matricaMina[esi], 1
		je POG1
		jmp ENDIF6
	POG1:
		dec pogodjene

	ENDIF6:

		; ******************************
		; izlazak iz igrice
		; ******************************
	_if7: cmp al, 27 ; esc
		je THEN7
		jmp ENDIF7
	THEN7:
		INVOKE MessageBox, NULL, ADDR questionMsg,
		ADDR captionQ, MB_YESNO + MB_ICONQUESTION
		cmp eax, IDYES
		je lastLoop2
	ENDIF7:
		jmp loopKey
	
	lastLoop2:
		; nova igra?
		INVOKE MessageBox, NULL, ADDR newGameMsg,
		ADDR captionNG, MB_YESNO + MB_ICONQUESTION
		cmp eax, IDYES
		je NOVAIGRA
		jmp KRAJ
	NOVAIGRA:
		jmp POCETAK
	KRAJ:

	INVOKE ExitProcess,0
main ENDP
END main
