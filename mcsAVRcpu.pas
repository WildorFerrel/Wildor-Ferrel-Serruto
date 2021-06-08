unit mcsAVRcpu;

interface
uses
  Windows, sysUtils,   Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, Grids, DBGrids, DB, Math,  MMSystem,
  mcsRutinas,
  ACG_MBS_TYPES, ACG_MBS_TYPES_DINAMIC,
  mcsAVR;
const
  CAPACIDAD_MEMORIA_DE_DATOS=$20;//$60;    WFS 2020
  nZ=1; nC=0; nN=2; nV=3; nH=5; nT=6;
type
  Npuerto=(A,B,C,D,E,F,G,H,I,J,K,L);
  registrosAVR=array[0..CAPACIDAD_MEMORIA_DE_DATOS-1] of Byte;
  TmcsAVR=class
    r:registrosAVR;
    SREG:Byte;
    PORT:array[A..L] of Byte;
    DDR:array[A..L] of Byte;
    PIN:array[A..L] of Byte;
    public
    function ejecutarInstruccion(var instruccion:vectorInstruccion;nTec:Byte):Boolean;
    procedure mostrarRegistros(var memo:Tmemo);
    procedure ejecutarPrograma(var programa:Tseq;var memo:tmemo);
  end;
var
  AVRcpu:TmcsAVR;

implementation
uses
  ACG_MBS_KEYPAD;

procedure TmcsAVR.ejecutarPrograma(var programa:Tseq;var memo:tmemo);
var
  i,tamano:Integer;
  nTec:Byte;
begin
  tamano:=Length(programa);
  for i:=0 to tamano do
  begin
    ejecutarInstruccion(programa[i],nTec);
    memo.Lines.Add(IntToStr(i)+' oc: '+inttostr(programa[i][0]));
  end;

end;
procedure TmcsAVR.mostrarRegistros(var memo:Tmemo);
var
  cadena:string;
begin
  cadena:='R0='+ByteAStringHexadecimal(r[0])+' '+
          'R1='+ByteAStringHexadecimal(r[1])+' '+
          'R20='+ByteAStringHexadecimal(r[20])+' '+
          'SREG='+ByteAStringBinario(SREG)+' '+
          'PORTD='+inttostr(PORT[D])+' '+
          'DDRD='+inttostr(DDR[D])+' '+
          'PIND='+inttostr(PIN[D])+' '+
          'PORTA='+inttostr(PORT[A])+' '+
          'DDRA='+inttostr(DDR[A])+' '+
          'PINA='+inttostr(PIN[A]);
  memo.Lines.Add(cadena);
end;

function TmcsAVR.ejecutarInstruccion(var instruccion:vectorInstruccion;nTec:Byte):Boolean;
  function determinarN(entrada:byte):byte;
  begin
    Result:=(entrada shr 7)and 1;
  end;

  function determinarZ(entrada:byte):byte;
  begin
    if entrada = 0 then  Result:=1
    else Result:=0;
  end;
  function determinarZword(entrada:word):byte;
  begin
    if entrada = 0 then  Result:=1
    else Result:=0;
  end;

  function determinarH(entrada1,entrada2,acarreo:word):byte;
  begin
    if (entrada1 and $0F)+(entrada2 and $0F)+acarreo > $0F then
      Result:=1
    else
      Result:=0;
  end;

  function determinarV(entrada1,entrada2,acarreo:word):byte;
  var
    w:word;
  begin
    w:=entrada1+entrada2+acarreo;
    Result:=( (w and $80) shr 7)xor( (w and $100) shr 8);
  end;

  function determinarC(entrada1,entrada2,acarreo:word):byte;
  var
    w:word;
  begin
    w:=entrada1+entrada2+acarreo;
    if w > $FF then Result:=1 else Result:=0;
  end;
var
  OC,bK,tipo,fue,des:Byte;
  vC,des7,fue7:Byte;
  bitC,bitX:Byte;
  operandoW,desWord,fueWord:Word;
begin
  Result:=True;
  OC:=instruccion[0];
  bK:=instruccion[1];
  tipo:=instruccion[2];
  des:=instruccion[3];
  fue:=instruccion[4];
  case OC of
    0: { 0	NOP	1	1	No operation		None }
        begin
        end;
    1,2,3,4,5,6: { 1	ADD Rd,Rr	   1	1	Add two Registers 	Rd <-- Rd + Rr 	Z,C,N,V,H }
       begin
         escribirBit(determinarZ(r[des]+r[fue]),SREG,nZ);
         escribirBit(determinarC(r[des],r[fue],0),SREG,nC);
         escribirBit(determinarN(r[des]+r[fue]),SREG,nN);
         escribirBit(determinarV(r[des],r[fue],0),SREG,nV);
         escribirBit(determinarH(r[des],r[fue],0),SREG,nH);
         r[des]:=r[des]+r[fue];
       end;
    7,8,9,10,11,12: { 7	ADC R0,R1	1	1	Add with Carry two Registers	Rd <-- Rd + Rr + C 	Z,C,N,V,H }
       begin
         vC:=leerBit(SREG,nC);
         escribirBit(determinarZ(r[des]+r[fue]+vC),SREG,nZ);
         escribirBit(determinarC(r[des],r[fue],+vC),SREG,nC);
         escribirBit(determinarN(r[des]+r[fue]+vC),SREG,nN);
         escribirBit(determinarV(r[des],r[fue],+vC),SREG,nV);
         escribirBit(determinarH(r[des],r[fue],+vC),SREG,nH);
         r[des]:=r[des]+r[fue]+vC;
       end;
    13,14,15,16,17,18: { 13	SUB R0,R1	1	1	Subtract two Registers	Rd <-- Rd - Rr 	Z,C,N,V,H }
       begin
         escribirBit(determinarZ(r[des]-r[fue]),SREG,nZ);
         escribirBit(determinarC(r[des],-r[fue],0),SREG,nC);
         escribirBit(determinarN(r[des]-r[fue]),SREG,nN);
         escribirBit(determinarV(r[des],-r[fue],0),SREG,nV);
         escribirBit(determinarH(r[des],-r[fue],0),SREG,nH);
         r[des]:=r[des]-r[fue];
       end;
    19,20,21: { 19	SUBI R0,K	2	1	Subtract Constant from Register 	Rd <-- Rd - K	Z,C,N,V,H }
       begin
         escribirBit(determinarZ(r[des]-bK),SREG,nZ);
         escribirBit(determinarC(r[des],-bK,0),SREG,nC);
         escribirBit(determinarN(r[des]-bK),SREG,nN);
         escribirBit(determinarV(r[des],-bK,0),SREG,nV);
         escribirBit(determinarH(r[des],-bK,0),SREG,nH);
         r[des]:=r[des]-bK;
       end;
    22,23,24,25,26,27: { 22	SBC R0,R1	1	1	Subtract with Carry two Registers 	Rd <-- Rd - Rr - C 	Z,C,N,V,H }
       begin
         vC:=leerBit(SREG,nC);
         escribirBit(determinarZ(r[des]-r[fue]-vC),SREG,nZ);
         escribirBit(determinarC(r[des],-r[fue],-vC),SREG,nC);
         escribirBit(determinarN(r[des]-r[fue]-vC),SREG,nN);
         escribirBit(determinarV(r[des],-r[fue],-vC),SREG,nV);
         escribirBit(determinarH(r[des],-r[fue],-vC),SREG,nH);
         r[des]:=r[des]-r[fue]-vC;
       end;
    28,29,30: { 28	SBCI R0,K	2	1	Subtract with Carry Constant from Reg 	Rd <-- Rd - K - C	Z,C,N,V,H }
       begin
         vC:=leerBit(SREG,nC);
         escribirBit(determinarZ(r[des]-bK-vC),SREG,nZ);
         escribirBit(determinarC(r[des],-bK,-vC),SREG,nC);
         escribirBit(determinarN(r[des]-bK-vC),SREG,nN);
         escribirBit(determinarV(r[des],-bK,-vC),SREG,nV);
         escribirBit(determinarH(r[des],-bK,-vC),SREG,nH);
         r[des]:=r[des]-bK-vC;
       end;
    31,32,33,34,35,36: { 31	AND R0,R1	1	1	Logical AND Registers 	Rd <-- Rd and Rr 	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] and r[fue]),SREG,nZ);
         escribirBit(determinarN(r[des] and r[fue]),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] and r[fue];
       end;
    37,38,39: { 37	ANDI R0,K	2	1	Logical AND Register and Constant 	Rd <-- Rd and K	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] and bK),SREG,nZ);
         escribirBit(determinarN(r[des] and bK),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] and bK;
       end;
    40,41,42,43,44,45: { 40	OR R0,R1	1	1	Logical OR Registers	Rd <-- Rd v Rr 	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] or r[fue]),SREG,nZ);
         escribirBit(determinarN(r[des] or r[fue]),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] or r[fue];
       end;
    46,47,48: { 46	ORI R0,K	2	1	Logical OR Register and Constant	Rd <-- Rd v K	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] or bK),SREG,nZ);
         escribirBit(determinarN(r[des] or bK),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] or bK;
       end;
    49,50,51,52,53,54: { 49	EOR R0,R1	1	1	Exclusive OR Registers	Rd <-- Rd xor Rr 	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] xor r[fue]),SREG,nZ);
         escribirBit(determinarN(r[des] xor r[fue]),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] xor r[fue];
       end;
    55,56,57: { 55	COM R0	1	1	One’s Complement	Rd <-- 0xFF - Rd 	Z,C=1,N,V=0 }
       begin
         escribirBit(determinarZ(255-r[des]),SREG,nZ);
         escribirBit(1,SREG,nC);
         escribirBit(determinarN(255-r[des]),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=255-r[des];
       end;
    58,59,60: { 58	NEG R0	1	1	Two’s Complement	Rd <-- 0x00 - Rd 	Z,C,N,V,H }
       begin
         escribirBit(determinarZ(-r[des]),SREG,nZ);
         escribirBit(determinarC(0,-r[des],0),SREG,nC);
         escribirBit(determinarN(-r[des]),SREG,nN);
         escribirBit(determinarV(0,-r[des],0),SREG,nV);
         escribirBit(determinarH(0,-r[des],0),SREG,nH);
         r[des]:=0-r[des];
       end;
    64,65,66: { 64	CBR R0,K	2	1	Clear Bit(s) in Register	Rd <-- Rd and (0xFF - K) 	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] and (255-bK)),SREG,nZ);
         escribirBit(determinarN(r[des] and (255-bK)),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] and (255-bK);
       end;
    67,68,69: { 67	INC R0	1	1	Increment 	Rd <-- Rd + 1	Z,N,V }
       begin
         escribirBit(determinarZ(r[des]+1),SREG,nZ);
         escribirBit(determinarN(r[des]+1),SREG,nN);
         escribirBit(determinarV(r[des],1,0),SREG,nV);
         r[des]:=r[des] + 1;
       end;
    70,71,72: { 70	DEC R0	1	1	Decrement 	Rd <-- Rd <-- 1	Z,N,V }
       begin
         operandoW:=65535;{-1 en 16 bits}
         escribirBit(determinarZ(r[des]-1),SREG,nZ);
         escribirBit(determinarN(r[des]-1),SREG,nN);
         escribirBit(determinarV(r[des],operandoW,0),SREG,nV);
         r[des]:=r[des] - 1;
       end;
    73,74,75: { 73	TST R0	1	1	Test for Zero or Minus	Rd <-- Rd and Rd 	Z,N,V=0 }
       begin
         escribirBit(determinarZ(r[des] and r[des]),SREG,nZ);
         escribirBit(determinarN(r[des] and r[des]),SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] and r[des];
       end;
    76,77,78: { 76	CLR R0	1	1	Clear Register	Rd <-- Rd xor Rd 	Z=1,N=0,V=0 }
       begin
         escribirBit(1,SREG,nZ);
         escribirBit(0,SREG,nN);
         escribirBit(0,SREG,nV);
         r[des]:=r[des] xor r[des];
       end;
    79,80,81: { 79	SER R0	1	1	Set Register	Rd <-- 0xFF	None }
       begin
         r[des]:=255;
       end;
    82,83,84: { 82	MUL R0,R1	1	2	Multiply Unsigned 	R1:R0 <-- Rd x Rr	Z,C }
       begin
         operandoW:=r[des] * r[fue];
         r[1]:=operandoW shr 8;
         r[0]:=operandoW and $00FF;
         escribirBit(determinarZword(operandoW),SREG,nZ);
         escribirBit(leerBit(r[1],7),SREG,nC);
       end;
    85,86,87: { 85	MULS R0,R1	1	2	Multiply Signed 	R1:R0 <-- Rd x Rr	Z,C }
       begin
         //operandoW:=r[des] * r[fue];
         des7:=leerBit(r[des],7);
         fue7:=leerBit(r[fue],7);
         if des7=1 then desWord:=1+not(r[des]) else desWord:=r[des];
         if fue7=1 then fueWord:=1+not(r[fue]) else fueWord:=r[fue];
         operandoW:=desWord*fueWord;
         if ((des7=1)and(fue7=0)) or ((des7=0)and(fue7=1)) then
         begin
           operandoW:=1+not(operandoW)
         end;
         r[1]:=operandoW shr 8;
         r[0]:=operandoW and $00FF;
         escribirBit(determinarZword(operandoW),SREG,nZ);
         escribirBit(leerBit(r[1],7),SREG,nC);
       end;
    92,93,94: { 92	LSL R0	1	1	0	0		Logical Shift Left	Rd(n+1) <-- Rd(n), Rd(0) <-- 0 	Z,C,N,V }
       begin {Equivale a ADD Rd,Rd}
         escribirBit(determinarZ(r[des]+r[des]),SREG,nZ);
         escribirBit(determinarC(r[des],r[des],0),SREG,nC);
         escribirBit(determinarN(r[des]+r[des]),SREG,nN);
         escribirBit(determinarV(r[des],r[des],0),SREG,nV);
         //escribirBit(determinarH(),SREG,nH);
         r[des]:=r[des]+r[des];
       end;
    95,96,97: { 95	LSR R0	1	1	0	0	Logical Shift Right 	Rd(n) <-- Rd(n+1), Rd(7) <-- 0 	Z,C,N,V }
       begin
         escribirBit(leerBit(r[des],0),SREG,nC);{Bit 0 pasa a C}
         r[des]:=(r[des] shr 1) and $7F;        {Bit 7 es igual a 0 (N=0)}
         escribirBit(determinarZ(r[des]),SREG,nZ);
         escribirBit(0,SREG,nN);
         {V=N xor C, for N and C after the shift.}
         escribirBit(leerBit(SREG,nN) xor leerBit(SREG,nC),SREG,nV);
       end;
    98,99,100: { 98	ROL R0	1	1	0	0	Rotate Left Through Carry 	Rd(0)<--C,Rd(n+1)<-- Rd(n),C<--Rd(7) 	Z,C,N,V }
       begin
         bitC:=leerBit(SREG,nC);
         escribirBit(leerBit(r[des],7),SREG,nC);{Bit 7 pasa a C}
         r[des]:=(r[des] shl 1);
         escribirBit(bitC,r[des],0);{C pasa a Bit 0}
         escribirBit(determinarZ(r[des]),SREG,nZ);
         escribirBit(determinarN(r[des]),SREG,nN);
         {V=N xor C, for N and C after the shift.}
         escribirBit(leerBit(SREG,nN) xor leerBit(SREG,nC),SREG,nV);
       end;
    101,102,103: { 101	ROR R0	1	1	0	0	Rotate Right Through Carry	Rd(7)<--C,Rd(n)<-- Rd(n+1),C<--Rd(0) 	Z,C,N,V }
       begin
         bitC:=leerBit(SREG,nC);
         escribirBit(leerBit(r[des],0),SREG,nC);{Bit 0 pasa a C}
         r[des]:=(r[des] shr 1);
         escribirBit(bitC,r[des],7);{C pasa a Bit 7}
         escribirBit(determinarZ(r[des]),SREG,nZ);
         escribirBit(determinarN(r[des]),SREG,nN);
         {V=N xor C, for N and C after the shift.}
         escribirBit(leerBit(SREG,nN) xor leerBit(SREG,nC),SREG,nV);
       end;
    104,105,106: { 104	ASR R0	1	1	0	0	Arithmetic Shift Right	Rd(n) <-- Rd(n+1), n=0..6	Z,C,N,V }
       begin
         bitX:=leerBit(r[des],7);
         escribirBit(leerBit(r[des],0),SREG,nC);{Bit 0 pasa a C}
         r[des]:=(r[des] shr 1);
         escribirBit(bitX,r[des],7);{Bit 7 se conserva}
         escribirBit(determinarZ(r[des]),SREG,nZ);
         escribirBit(determinarN(r[des]),SREG,nN);
         {V=N xor C, for N and C after the shift.}
         escribirBit(leerBit(SREG,nN) xor leerBit(SREG,nC),SREG,nV);
       end;
    107,108,109: { 107	SWAP R0	1	1	0	0	Swap Nibbles	Rd(3:0)<--Rd(7:4),Rd(7:4)<--Rd(3:0)	None }
       begin
         r[des]:= (r[des] shr 4) or (r[des] shl 4);
       end;
    110,111,112: { 110	BST R0,b	3	1	0	0	Bit Store from Register to T	T <-- Rr(b)	T }
       begin
         escribirBit(leerBit(r[fue],bK),SREG,nT);
       end;
    113,114,115: { 113	BLD R0,b	3	1	0	0	Bit load from T to Register 	Rd(b) <-- T	None }
       begin
         escribirBit(leerBit(SREG,nT),r[des],bK);
       end;
    116: { 116	SEC	1	1	0	0	Set Carry 	C <-- 1	C }
       begin
         escribirBit(1,SREG,nC);
       end;
    117: { 117	CLC	1	1	0	0	Clear Carry 	C <-- 0	C }
       begin
         escribirBit(0,SREG,nC);
       end;
    118: { 118	SEN	1	1	0	0	0	0	1	0	0	Set Negative Flag 	N <-- 1	N }
       begin
         escribirBit(1,SREG,nN);
       end;
    119: { 119	CLN	1	1	0	0	0	0	1	0	0	Clear Negative Flag 	N <-- 0	N }
       begin
         escribirBit(0,SREG,nN);
       end;
    120: { 120	SET	1	1	0	0	0	0	0	0	0	Set T in SREG 	T <-- 1	T }
       begin
         escribirBit(1,SREG,nT);
       end;
    121: { 121	CLT	1	1	0	0	0	0	0	0	0	Clear T in SREG 	T <-- 0	T }
       begin
         escribirBit(0,SREG,nT);
       end;
    122: { 122	SEH	1	1	0	0	0	0	0	0	1	Set Half Carry Flag in SREG 	H <-- 1	H }
       begin
         escribirBit(1,SREG,nH);
       end;
    123: { 123	CLH	1	1	0	0	0	0	0	0	1	Clear Half Carry Flag in SREG 	H <-- 0	H }
       begin
         escribirBit(0,SREG,nH);
       end;
    124,125,126,127,128,129: { 124	MOV R0,R1	1	1	0	1	Move Between Registers	Rd <-- Rr	None }
       begin
         r[des]:=r[fue];
       end;
    130,131,132: { 130	LDI R0,K	2	1	0	0	Load Immediate	Rd <-- K 	None }
       begin
         r[des]:=bK;
       end;
    61,62,63: { 61	IN R0,PIND	1	1	0	0	In Port 	Rd <-- P 	None }
       begin
          if valoresDePinesEnConexionConTecladoValidos(AVRcpu,nTec) then
          begin
            r[des]:=PIN[D];
          end
          else
          begin
            Result:=False;
          end;
       end;
    133,134,135: { 133	OUT PORTD,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         PORT[D]:=r[fue];
       end;
    136,137,138: { 136	OUT DDRD,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         DDR[D]:=r[fue];
       end;
    88: { 88	SBI PORTD,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,PORT[D],bK);
       end;
    89: { 89	SBI DDRD,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,DDR[D],bK);
       end;
    90: { 90	CBI PORTD,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,PORT[D],bK);
       end;
    91: { 91	CBI DDRD,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,DDR[D],bK);
       end;
    139,140,141: { 61	IN R0,PINA	1	1	0	0	In Port 	Rd <-- P 	None }
       begin
          if valoresDePinesEnConexionConTecladoValidos(AVRcpu,nTec) then
          begin
            r[des]:=PIN[A];
          end
          else
          begin
            Result:=False;
          end;
       end;
    142,143,144: { 133	OUT PORTA,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         PORT[A]:=r[fue];
       end;
    145,146,147: { 136	OUT DDRA,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         DDR[A]:=r[fue];
       end;
    148: { 88	SBI PORTA,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,PORT[A],bK);
       end;
    149: { 89	SBI DDRA,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,DDR[A],bK);
       end;
    150: { 90	CBI PORTA,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,PORT[A],bK);
       end;
    151: { 91	CBI DDRA,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,DDR[A],bK);
       end;
    156: { 156	MOV Rd,Rr	1	1	0	1	Move Between Registers	Rd <-- Rr	None }
       begin
         r[des]:=r[fue];
       end;
    157: { 157	BST Rd,b	3	1	0	0	Bit Store from Register to T	T <-- Rr(b)	T }
       begin
         escribirBit(leerBit(r[fue],bK),SREG,nT);
       end;
    159,160,161: { 61	IN R0,PINC	1	1	0	0	In Port 	Rd <-- P 	None }
       begin {El LCD se conecata al puerto L}
          r[des]:=PIN[C];
       end;
    162,163,164: { 133	OUT PORTC,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         PORT[C]:=r[fue];
       end;
    165,166,167: { 136	OUT DDRC,R0	1	1	0	0	Out Port	P <-- Rr 	None }
       begin
         DDR[C]:=r[fue];
       end;
    168: { 88	SBI PORTC,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,PORT[C],bK);
       end;
    169: { 89	SBI DDRC,b	3	2		Set Bit in I/O Register 	I/O(P,b) <-- 1 	None }
       begin
         escribirBit(1,DDR[C],bK);
       end;
    170: { 90	CBI PORTC,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,PORT[C],bK);
       end;
    171: { 91	CBI DDRC,b	3	2		Clear Bit in I/O Register 	I/O(P,b) <-- 0 	None }
       begin
         escribirBit(0,DDR[C],bK);
       end;
  end;
end;
end.
