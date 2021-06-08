unit mcsAVR;

interface
uses
  Windows, sysUtils,   Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, Grids, DBGrids, DB, Math,  MMSystem,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,mcsRutinas,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,
  ComObj,Variants;
const
  ArchivoDeProgramaHumanoBytes:string = 'PROG_HUMANO_BYTES.ASM';
  ArchivoDeProgramaHumanoCiclos:string = 'PROG_HUMANO_CICLOS.ASM';
  ArchivoDeSalidaGenerado:string = 'PROG_GEN';
  ArchivoDeSalidaHumano:string = 'PROG_HUM';

const
  SIN_OPERANDO=1;
  CONSTANTE=2;
  NUMERO_BIT=3;
  BRANCH=4;
  DOS_REGISTROS=5;
  REGISTRO_CONSTANTE=6;
type
  {PARA LA ENTRADA Y LA SALIDA DEL PROGRAMA}
  registroDeTrabajo=(R0,R1,R20);
var
  {Registros de Entrada}
  {Registros de Salida}
  RegistroSalidaLOW:registroDeTrabajo=R0;{PARTE BAJA DE LA SALIDA EN LA TABLA ENTRADA-SALIDA}
  nBitsRegistroSalidaLOW:Integer=5; {BN} {numero de bits de PARTE BAJA DE LA SALIDA }
type
  instruccionAVR=record
    co:vectorInstruccion;
//  0- OC asignado :byte; {OC asignado (va desde 0) }
//  1- Operando:Byte; {Operando inmediato o número de bit}
//  2- tipoOperando:Byte; {1-Sin operando o es un Registro, 2-Operando Constante, 3-Número de bit}
//  3- Destino:byte; {Registro Destino }
//  4- Fuente:Byte; {Registro Fuente}
    mnemonico:string[15];{Mnemónico}
    ciclos:Byte;{Numero de ciclos de ejecucion}
    nBytes:Byte;{Numero de bytes de la instruccion}
  end;
  InstruccionesAVR=array of instruccionAVR;
var
  ISetAVR:InstruccionesAVR;
  NUMERO_DE_INSTRUCCIONES_AVR:Integer;
  ErrorAVR:string;
  estadistica:array[1..13] of string;
  NumeroProgramaGenerado:Integer;
  CantidadProgramasGenerados:Integer;
  TipoProgramaGenerado:string;
  TiempoInicio, TiempoFinal : TDateTime;

procedure calcularCiclosYbytesDeSecuencia(var ci:InstruccionesAVR;var s:Tseq;
            var nCiclos,nBytes:Integer);
procedure MemoAseq(var re:TMemo; var secuencia:Tseq;var memo:TMemo);
procedure RichEditAseq(var re:TRichEdit; var secuencia:Tseq;var memo:TMemo);

procedure leerInstruccionesAVRdeXLSabierto(var WorkSheet : Variant);
procedure leerParametrosAVRdeXLSabierto(var WorkSheet : Variant);

function vectorInstruccionAVRaCadenaASM(a:vectorInstruccion):string;

function leerBit(byteQueContieneAlBit:byte;numeroDeBit:byte):byte;
procedure escribirBit(valorDeBit:byte;var byteDestino:byte;numeroDeBit:byte);
function instruccionAVRaleatoria:vectorInstruccion;
procedure reemplazarInstruccionAVR(var v:vectorInstruccion);
{Rutinas de busqueda}
function hayCodigo(var ci:InstruccionesAVR;oc:Byte;var indice:Byte):Boolean;
function hayMnemonico(var ci:InstruccionesAVR;s:string;var indice:Integer):Boolean;
function hayInstruccion(var ci:InstruccionesAVR;s:string;var indice:Integer):Boolean;
function determinaBK(y:string):Byte;

function stringAinstruccionAVR(var ci:InstruccionesAVR;x:string;var res:vectorInstruccion):Boolean;
procedure mostrarTablaInstrucciones(var ci:InstruccionesAVR;var memo:TMemo);
procedure mostrarInstruccionesPermitidas(var ip:TiPermitidas;var memo:TMemo);
procedure mostrarSecuencia(var s:Tseq;var memo:TMemo);
procedure capturarEstadistica(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10:string);

implementation
procedure capturarEstadistica(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10:string);
begin
  estadistica[1]:=s1;
  estadistica[2]:=s2;
  estadistica[3]:=s3;
  estadistica[4]:=s4;
  estadistica[5]:=s5;
  estadistica[6]:=s6;
  estadistica[7]:=s7;
  estadistica[8]:=s8;
  estadistica[9]:=s9;
  estadistica[10]:=s10;
end;
procedure mostrarSecuencia(var s:Tseq;var memo:TMemo);
var
  i,n:Integer;
begin
  n:=Length(s);
  for i:=0 to n-1 do
  begin
    memo.Lines.Add(IntToStr(s[i][0])+' '+
                   IntToStr(s[i][1])+' '+
                   IntToStr(s[i][2])+' '+
                   IntToStr(s[i][3])+' '+
                   IntToStr(s[i][4])
                   );
  end;
end;
procedure mostrarInstruccionesPermitidas(var ip:TiPermitidas;var memo:TMemo);
var
  i:Byte;
  s:string;
begin
  Memo.Lines.Add('INSTRUCCIONES USADA EN GP:');
  for i:=0 to NUMERO_DE_INSTRUCCIONES_DE_TABLA-1 do
  begin
    s:=vectorInstruccionAVRaCadenaASM(iPermitidas[i]);
    Memo.Lines.Add(IntToStr(iPermitidas[i][0])+' '+s);
  end;
end;
procedure mostrarTablaInstrucciones(var ci:InstruccionesAVR;var memo:TMemo);
var
  i:Byte;
begin
  Memo.Lines.Add('TABLA DE INSTRUCCIONES:');
  for i:=0 to NUMERO_DE_INSTRUCCIONES_AVR-1 do
  begin
    memo.Lines.Add(numFCad(ci[i].co[0],6)+' '+ci[i].mnemonico+' '+
                   numFCad(ci[i].co[2],6)+' '+numFCad(ci[i].co[3],6)+' '+
                   numFCad(ci[i].co[4],6));
  end;
end;
function stringAinstruccionAVR(var ci:InstruccionesAVR;x:string;
                               var res:vectorInstruccion):Boolean;
var
  i:Integer;
begin
  Result:=True;
  if hayInstruccion(ci,x,i) then
  begin
    Res[0]:=ci[i].co[0];
    Res[1]:=ci[i].co[1];
    Res[2]:=ci[i].co[2];
    Res[3]:=ci[i].co[3];
    Res[4]:=ci[i].co[4];
    if (Res[2]=2)or(Res[2]=3) then
    begin
      Res[1]:=determinaBK(x);
    end;
  end
  else
  begin
    Res[0]:=0;
    Res[1]:=0;
    Res[2]:=0;
    Res[3]:=0;
    Res[4]:=0;
    Result:=False;
  end;
end;
function hayBK(y:string;var bk:Byte):Boolean;
var
  posicion,tamano:Integer;
  t:string;
begin
  Result:=False;
  bk:=0;
  posicion:=Pos(',',y); tamano:=Length(y);
  if (posicion>0)and(tamano>posicion) then
  begin
    t:=Copy(y,posicion+1,tamano-posicion);
    eliminarEspaciosLaterales(t);
    bk:=Byte(StringBinDecHexALongint_0B0X0D(t));
    Result:=True;
  end;
end;
function hayNumerosDeRegistros(y:string;var Rd,Rr:Byte):Boolean;
var
  posicion,posicionR,tamano:Integer;
  t:string;
begin
  Result:=False;
  posicionR:=Pos('R',y);
  posicion:=Pos(',',y);
  tamano:=Length(y);
  if not( (posicionR=0)or(posicion=0)or(posicionR>posicion) )then
  begin
    t:=Copy(y,posicionR+1,posicion-posicionR-1);{Separa numero destino}
    eliminarEspaciosLaterales(t);
    Rd:= Byte(StringBinDecHexALongint_0B0X0D(t));
    t:=Copy(y,posicion+1,tamano-posicion); {Separa cadena despues de la coma}
    eliminarEspaciosLaterales(t);
    tamano:=Length(t);
    if (tamano>1)and(t[1]='R') then
    begin
      t:=Copy(t,2,tamano-1); {Separa numero fuente}
      eliminarEspaciosLaterales(t);
      Rr:= Byte(StringBinDecHexALongint_0B0X0D(t));
      if (Rd<32)and(Rr<32) then
      begin
        Result:=True;
      end;
    end;
  end;
end;
function hayRegistroYbk(y:string;var Rd,bk:Byte):Boolean;
var
  posicion,posicionR,tamano:Integer;
  t:string;
begin
  Result:=False;
  posicionR:=Pos('R',y);
  posicion:=Pos(',',y);
  tamano:=Length(y);
  if not( (posicionR=0)or(posicion=0)or(posicionR>posicion) )then
  begin
    t:=Copy(y,posicionR+1,posicion-posicionR-1);{Separa numero destino}
    eliminarEspaciosLaterales(t);
    Rd:= Byte(StringBinDecHexALongint_0B0X0D(t));
    t:=Copy(y,posicion+1,tamano-posicion); {Separa cadena despues de la coma}
    eliminarEspaciosLaterales(t);
    tamano:=Length(t);
    if (tamano>0) then
    begin
      bk:= Byte(StringBinDecHexALongint_0B0X0D(t));
      if (Rd<32) then {Confirma si es numero de registro}
      begin
        Result:=True;
      end;
    end;
  end;
end;
function stringAviAVR(var ci:InstruccionesAVR;x:string;
                      var Res:vectorInstruccion; var indice:Integer):Boolean;
var
  i:Byte;
  posicionComa,tam:Integer;
  ss,s3:string;
begin
  Result:=False;
  indice:=0;
  ss:=x;
  s3:='';
  eliminarEspaciosLaterales(ss);
  tam:=Length(ss);
  if tam>3 then
  begin
    s3:=Copy(ss,1,3);
    if s3='MOV' then
    begin {Formar mnemonico de la tabla de instrucciones}
      ss:=s3+' Rd,Rr';
      if hayMnemonico(ci,ss,indice) then
      begin
        Res:=ci[indice].co;
        Result:=hayNumerosDeRegistros(x,res[3],res[4]);
        Exit;
      end;
    end;
    if s3='BST' then
    begin {Formar mnemonico de la tabla de instrucciones}
      ss:=s3+' Rd,b';
      if hayMnemonico(ci,ss,indice) then
      begin
        Res:=ci[indice].co;
        Result:=hayRegistroYbk(x,res[3],res[1]);
        if Res[1]>7 then Result:=False;{confirma si es numero de bit}
        Exit;
      end;
    end;
    if s3='JMP' then
    begin {Formar mnemonico de la tabla de instrucciones}
      ss:=s3+' k';
      Result:=hayMnemonico(ci,ss,indice);
      Res:=ci[indice].co;
      Exit;
    end;
  end;
  posicionComa:=Pos(',',ss);
  if posicionComa=0 then
  begin {Instruccion no tiene regundo registro, puerto, constante ni numero de bit}
    Result:=hayMnemonico(ci,ss,indice);
    Res:=ci[indice].co;
  end
  else
  begin
    if (ss[posicionComa+1]='R')or(ss[posicionComa+1]='P') then
    begin {El segundo operando es un registro o un puerto}
      Result:=hayMnemonico(ci,ss,indice);
    end
    else
    begin {El segundo operando es constante o numero de bit}
      ss:=Copy(ss,1,posicionComa)+'K';
      if hayMnemonico(ci,ss,indice) then
      begin {El segundo operando es constante}
        Result:=True;
      end
      else
      begin {El segundo operando es numero de bit}
        ss:=Copy(ss,1,posicionComa)+'b';
        Result:=hayMnemonico(ci,ss,indice);
      end;
    end;
    Res:=ci[indice].co;
    if (Res[2]=2)or(Res[2]=3) then
    begin
      Result:=hayBK(x,Res[1]);
    end;
  end;
end;
function determinaBK(y:string):Byte;
var
  posicion,tamano:Integer;
  t:string;
begin
  Result:=0;
  posicion:=Pos(',',y); tamano:=Length(y);
  if (posicion>0)and(tamano>posicion) then
  begin
    t:=Copy(y,posicion+1,tamano-posicion);
    eliminarEspaciosLaterales(t);
    Result:=Byte(StringBinDecHexALongint_0B0X0D(t));
  end
  else
  begin
    ErrorAVR:='Falta valor constante o numero de bit';
  end;
end;
function hayInstruccion(var ci:InstruccionesAVR;s:string;var indice:Integer):Boolean;
{ Busca en la tabla de instrucciones la instruccion s dada como mnemonico.
  Si hay devuelve TRUE y el indice}
var
  i:Byte;
  posicionComa:Integer;
  ss:string;
begin
  Result:=False;
  indice:=0;
  ss:=s;
  eliminarEspaciosLaterales(ss);
  posicionComa:=Pos(',',ss);
  if posicionComa=0 then
  begin {Instruccion no tiene regundo registro, puerto, constante ni numero de bit}
    Result:=hayMnemonico(ci,ss,indice);
  end
  else
  begin
    if (ss[posicionComa+1]='R')or(ss[posicionComa+1]='P') then
    begin {El segundo operando es un registro o un puerto}
      Result:=hayMnemonico(ci,ss,indice);
    end
    else
    begin {El segundo operando es constante o numero de bit}
      ss:=Copy(ss,1,posicionComa)+'K';
      if hayMnemonico(ci,ss,indice) then
      begin {El segundo operando es constante}
        Result:=True;
      end
      else
      begin {El segundo operando es numero de bit}
        ss:=Copy(ss,1,posicionComa)+'b';
        Result:=hayMnemonico(ci,ss,indice);
      end;
    end;
  end;
end;
function hayMnemonico(var ci:InstruccionesAVR;s:string;var indice:Integer):Boolean;
{Busca en la tabla de instrucciones el mnemonico s. }
var
  i:Byte;
  ss:string;
begin
  Result:=False;
  indice:=0;
  ss:=s;
  for i:=0 to NUMERO_DE_INSTRUCCIONES_AVR-1 do
  begin
    if ci[i].mnemonico=ss then
    begin
      indice:=i;
      Result:=True;
      Exit;
    end;
  end;
end;
function hayCodigo(var ci:InstruccionesAVR;oc:Byte;var indice:Byte):Boolean;
{ Busca en la tabla de instrucciones ci la instruccion dada por su OC.
  Si hay devuelve TRUE y el indice}
var
  i:Byte;
begin
  Result:=False;
  indice:=0;
  for i:=0 to NUMERO_DE_INSTRUCCIONES_AVR-1 do
  begin
    if ci[i].co[0]=oc then
    begin
      indice:=i;
      Result:=True;
      Exit;
    end;
  end;
end;

procedure cambiarValorConstante(var x:byte);
var
  n:integer;
  bTemp:Byte;
begin
  n:=random(8);
  bTemp:=1;
  x:=(x) xor (bTemp shl n);
end;
procedure reemplazarInstruccionAVR(var v:vectorInstruccion);
var
  nalea:Integer;
begin
  nalea:=Random(100);
  if nalea<70 then
  begin
    case v[2] of
      CONSTANTE:begin {Instruccion con valor constante}
          cambiarValorConstante(v[1]);
        end;
      NUMERO_BIT:begin {Instruccion con Numero de Bit}
          v[1]:=Random(8);
        end;
    end;
  end
  else
  begin
    v:=instruccionAVRaleatoria;
  end;
end;
function instruccionAVRaleatoria:vectorInstruccion;
var
  a:vectorInstruccion;
  indice:Integer;
begin
  indice:=Random(NUMERO_DE_INSTRUCCIONES_DE_TABLA);
  a:=iPermitidas[indice];
  if (a[2]=CONSTANTE) then
  begin {Tiene Dato Constante}
    a[1]:=random(VALOR_INMEDIATO_MAXIMOMASUNO);
  end;
  if (a[2]=NUMERO_BIT) then
  begin {Tiene Numero de Bit en Registro}
    a[1]:=random(8);
  end;
  instruccionAVRaleatoria:=a;
end;

function vectorInstruccionAVRaCadenaASM(a:vectorInstruccion):string;
var
  cadena:string;
  n:Integer;
  valorBK,valorD,valorF:string;
  indice:Byte;
begin
  if hayCodigo(ISetAVR,a[0],indice) then
  begin
    cadena:=ISetAVR[indice].mnemonico;
  end
  else
  begin
    cadena:='XXXXX';
  end;
  case a[2] of
  CONSTANTE:begin {Tiene valor constante}
      n:=Pos(',K',cadena);
      if n>0 then
      begin
        valorBK:=IntToStr(a[1]);
        cadena:=Copy(cadena,1,n)+valorBK;
      end;
    end;
  NUMERO_BIT:begin {Tiene numero de bit de Registro}
      n:=Pos(',b',cadena);
      if n>0 then
      begin
        valorBK:=IntToStr(a[1]);
        cadena:=Copy(cadena,1,n)+valorBK;
      end;
    end;
  DOS_REGISTROS:begin {Tiene dos numeros de Registro}
      n:=Pos(',',cadena);
      if n>0 then
      begin
        valorD:=IntToStr(a[3]);
        valorF:=IntToStr(a[4]);
        cadena:=Copy(cadena,1,n-2)+valorD+',R'+valorF;
      end;
    end;
  REGISTRO_CONSTANTE:begin {Tiene un Registro y una constante}
      n:=Pos(',',cadena);
      if n>0 then
      begin
        valorD:=IntToStr(a[3]);
        valorBK:=IntToStr(a[1]);
        cadena:=Copy(cadena,1,n-2)+valorD+','+valorBK;
      end;
    end;
  end;
  Result:=cadena;
end;
procedure leerParametrosAVRdeXLSabierto(var WorkSheet : Variant);
begin
  NUMERO_DE_SEGMENTOS_EN_CC:=WorkSheet.Cells[2, 2].Value;
  TAMANO_POBLACION_DIN:=WorkSheet.Cells[3, 2].Value;
  TAMANO_MINIMO_DE_SECUENCIA_DIN:=WorkSheet.Cells[4, 2].Value;
  TAMANO_MAXIMO_DE_SECUENCIA_DIN:=WorkSheet.Cells[5, 2].Value;
  NUMERO_MAXIMO_DE_EVALUACIONES:=WorkSheet.Cells[6, 2].Value;

  PROBABILIDAD_EN_SELECCION_DE_PADRES:=WorkSheet.Cells[8, 2].Value;
  PROBABILIDAD_DE_MUTACION_DIN:=WorkSheet.Cells[9, 2].Value;
  PROBABILIDAD_DE_CRUZAMIENTO:=WorkSheet.Cells[10, 2].Value;
  PROBABILIDAD_INTERCAMBIO_DE_COLAS_EN_CROSSOVER:=WorkSheet.Cells[11, 2].Value;

  REGISTRO_DE_SALIDA_BYTE_BAJO:= WorkSheet.Cells[13, 2].Value;
end;
procedure leerInstruccionesAVRdeXLSabierto(var WorkSheet : Variant);
var
  cad:string;
  cadenas:array[1..13] of string;
  nfilas,nfilasPermitidas,i,j,k:Integer;
begin
  nfilas:=0;
  repeat {Determina la cantidad de filas del archivo excel}
    Inc(nfilas);
    cad:= WorkSheet.Cells[nfilas, 1].Value;
  until cad='';
  nfilas:=nfilas-1; {Cantidad de filas del archivo excel}
  SetLength(ISetAVR,nfilas-1);
  NUMERO_DE_INSTRUCCIONES_AVR:=nfilas-1;{La primera fila del archivo es el encabezado}
  nfilasPermitidas:=0;
  for i:=2 to nfilas do
  begin {Determina la cantidad de filas Permitidas del archivo excel}
    cad:=WorkSheet.Cells[i, 2].Value;
    eliminarEspaciosLaterales(cad);
    if cad='SI' then Inc(nfilasPermitidas);
  end;
  SetLength(iPermitidas,nfilasPermitidas);
  NUMERO_DE_INSTRUCCIONES_DE_TABLA:=nfilasPermitidas;
  k:=0;
  for i:=2 to nfilas do
  begin
    for j:=1 to 13 do
    begin
      cadenas[j]:=WorkSheet.Cells[i, j].Value;
      eliminarEspaciosLaterales(cadenas[j]);
    end;
    ISetAVR[i-2].co[0]:=StrToInt(cadenas[1]);{OC}
    ISetAVR[i-2].co[1]:=0;         {bK}
    ISetAVR[i-2].co[2]:=StrToInt(cadenas[4]);{Tipo}
    ISetAVR[i-2].co[3]:=StrToInt(cadenas[6]);{Destino}
    ISetAVR[i-2].co[4]:=StrToInt(cadenas[7]);{Fuente}
    ISetAVR[i-2].mnemonico:=cadenas[3];{Mnemonico}
    ISetAVR[i-2].ciclos:=StrToInt(cadenas[5]);{Clock}
    ISetAVR[i-2].nBytes:=StrToInt(cadenas[13]);{Numero de Bytes}
    if cadenas[2]='SI' then
    begin
      iPermitidas[k][0]:=StrToInt(cadenas[1]);{OC}
      iPermitidas[k][1]:=0;         {bK}
      iPermitidas[k][2]:=StrToInt(cadenas[4]);{Tipo}
      iPermitidas[k][3]:=StrToInt(cadenas[6]);{Destino}
      iPermitidas[k][4]:=StrToInt(cadenas[7]);{Fuente}
      inc(k);
    end;
  end;
end;
function leerBit(byteQueContieneAlBit:byte;numeroDeBit:byte):byte;
begin
  Result:=(byteQueContieneAlBit shr numeroDeBit)and 1;
end;

procedure escribirBit(valorDeBit:byte;var byteDestino:byte;numeroDeBit:byte);
begin
  if valorDeBit and 1=0 then
  begin
    byteDestino:=(not(1 shl numeroDeBit))and byteDestino;
  end
  else
  begin
    byteDestino:=(1 shl numeroDeBit)or byteDestino;
  end;
end;
procedure RichEditAseq(var re:TRichEdit; var secuencia:Tseq;var memo:TMemo);
var
  numeroLineas,i,nfilas,indice:Integer;
  s:Tseq;
  v:vectorInstruccion;
begin
  numeroLineas:=re.Lines.Count;
  SetLength(s,numeroLineas);
  nfilas:=0;
  for i:=0 to numeroLineas-1 do
  begin {Determinar Numero de Instrucciones}
    if stringAviAVR(ISetAVR,re.Lines[i],v, indice) then
    begin
      s[nfilas]:=v;
      Inc(nfilas);
    end;
  end;{nfilas es Numero de instrucciones validas}

  Memo.Lines.Add('Secuencia s: '+inttostr(nfilas)+' '+inttostr(numeroLineas));

  mostrarSecuencia(s,memo);

  SetLength(secuencia,nfilas);
  secuencia:=Copy(s,0,nfilas);
  for i:=0 to nfilas-1 do
  begin
    memo.Lines.Add(vectorInstruccionAVRaCadenaASM(secuencia[i]));
  end;

end;
procedure MemoAseq(var re:TMemo; var secuencia:Tseq;var memo:TMemo);
{Ensambla programa de re para obtener la Secuencia.
 Para verificar desensambla la secuencia y el resultado se coloca en memo}
var
  numeroLineas,i,nfilas,indice:Integer;
  s:Tseq;
  v:vectorInstruccion;
begin
  numeroLineas:=re.Lines.Count;
  SetLength(s,numeroLineas);
  nfilas:=0;
  for i:=0 to numeroLineas-1 do
  begin {Determinar Numero de Instrucciones}
    if stringAviAVR(ISetAVR,re.Lines[i],v, indice) then
    begin
      s[nfilas]:=v;
      Inc(nfilas);
    end;
  end;{nfilas es Numero de instrucciones validas}

  SetLength(secuencia,nfilas);
  secuencia:=Copy(s,0,nfilas);

  memo.Clear;
  Memo.Lines.Add('Ensamblado: '+inttostr(nfilas));

  mostrarSecuencia(secuencia,memo);

  Memo.Lines.Add('Desensamblado: ');
  for i:=0 to nfilas-1 do
  begin
    memo.Lines.Add(IntToStr(i)+' '+vectorInstruccionAVRaCadenaASM(secuencia[i]));
  end;
end;
procedure calcularCiclosYbytesDeSecuencia(var ci:InstruccionesAVR;var s:Tseq;
            var nCiclos,nBytes:Integer);
var
  i,tamano:Integer;
  indice:Byte;
begin
  tamano:=Length(s);
  nCiclos:=0;
  nBytes:=0;
  for i:=0 to tamano-1 do
  begin
    if hayCodigo(ci,s[i][0],indice) then
    begin
      nCiclos:=nCiclos+ci[indice].ciclos;
      nBytes:=nBytes+ci[indice].nBytes;
    end;
  end;
end;
end.
