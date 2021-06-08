unit ACG_MBS_TYPES_DINAMIC;

interface
uses
  Classes, sysUtils,math, StdCtrls, Grids,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  ACG_MBS_TYPES;
const
  N_CTBIF2_JMP2=0; N_ETIQ_BIF2=1; N_CTBIF1_JMP1=2; N_ETIQ_BIF1=3;
  NREC_RX=4; NFILA=5; NPROG=6; NSOL_A=7; NSOL_B=8; NSOL_R=9; NREC_TX=10;
  N_ETIQ_JMP1=11; N_DJNZ_BIF1=12; N_ETIQ_JMP2=13; N_DJNZ_BIF2=14;
  
const
  CODIGO_NINGUNA_TECLA_PRESIONADA=99;

  POBLACION_MAXIMA=100000;//10000;//100000;//90000;//80000;

  NUMERO_DE_PAREJAS_MAXIMO = 400;//1000;//500;//400;

  VALOR_MINIMO_CONDICION = -51;
  VALOR_MAXIMO_CONDICION = 255;

  VALOR_ALEATORIO_MINIMO_PESO = 1;
  VALOR_ALEATORIO_MAXIMO_PESO = 5;

  NUMERO_GRANDE_SMALLINT = 32767;{Numero mas grande SmallInt}
  NUMERO_EVALUACIONES_SIN_MEJORA = 100000;{Numero de valuaciones sin mejora}
  NUMERO_MAXIMO_DE_DEMES = 10;

  TAMANO_ARREGLO_PARA_SEGMENTOS = 20;{La cantidad de segmentos debe ser menor o igual}
var
  NUMERO_DE_REPRESENTANTES_DIN:Integer =2;//1;// 2;// 4;// 2;//3;//2;
  APLICACION_ACTIVADA:Boolean=True;

  NUMERO_DE_SEGMENTOS_EN_CC:Integer=10;
  TAMANO_POBLACION_DIN:Integer=200;//100 valor anterior
  TAMANO_MINIMO_DE_SECUENCIA_DIN:Integer=2;//3;//3;//2;//4; 31 AGOSTO 2020
  TAMANO_MAXIMO_DE_SECUENCIA_DIN:Integer=4;//4;//5;//4//8;  31 AGOSTO 2020
  NUMERO_MAXIMO_DE_EVALUACIONES:Integer;

  PROBABILIDAD_EN_SELECCION_DE_PADRES:Double = 0.4;//0.5;//0.6;// 0.4;//0.1;// 0.4;
  PROBABILIDAD_DE_MUTACION_DIN:Integer = 30;//100;// 30;
  PROBABILIDAD_DE_CRUZAMIENTO:Double = 0.3;
  PROBABILIDAD_INTERCAMBIO_DE_COLAS_EN_CROSSOVER:Integer = 30;

  REGISTRO_DE_SALIDA_BYTE_BAJO:string = 'R0';


type
  matrizDiagramasDeTiempo = array of vectorValoresSalidaB;

  matrizValoresDePartesProgramaDIN = array of vectorValoresSalida64;

  Tseq = array of vectorInstruccion;
  arregloEntero=array of Integer;

type
  estructuraVIDin = record
//    w:Real;
    viA,viB,viR0, viPx:Byte;
  end;
  estructuraControlDin = record
//    w:Real;
    wint:Smallint;
    cond:Smallint;
    iIni:Integer;
    iFin:Integer;
  end;
  Tcontrol = array of estructuraControlDin;
  estructuraTransferDin = record
//    w:Real;
    tipo:byte;
    iDes:integer;
    rDes:byte;
    iFue:integer;
    rFue:byte;
    inme:Byte;{valor inmediato en recuperacion CAMBIO 2016}
  end;
  Ttransfer = array of estructuraTransferDin;
//  RDatosSeq = record
//    s:Integer;{Tamaño}
//    f:vectorParaPartesF;{Adecuacion}
//    fsumaesc:Integer;{Entero menor de la Suma de elementos de f multiplicado por un valor}
//    fsuma:Integer;{Entero menor de la suma de elementos de f}
//    e:Integer;{Número de instrucción del primer error en dt}
//    u:Integer;{Número de instrucción ultimo en dt}
//    p:Integer;{Procedencia p=0 - cuantica; p=1 - multiobjetivo}
//  end;
  RDatosSeq = record
    s:Integer;{Tamaño}
    f:vectorParaPartesF;{Adecuacion}
    fsumaesc:Integer;{Entero menor de la Suma de elementos de f multiplicado por un valor}
    fsuma:Integer;{Entero menor de la suma de elementos de f}
    e:Integer;{Número de instrucción del primer error en dt}
    ie:Integer;
    iei:vectorParaPartesF;{indices de extremo izquierdo}
    u:Integer;{Indice ultimo maximo en dt}
    m:Integer;{Indice ultimo minimo en dt}
    p:Integer;{Procedencia p=0 - cuantica; p=1 - multiobjetivo}
  end;
  TdimCC=array[0..TAMANO_ARREGLO_PARA_SEGMENTOS-1] of integer;
  tipoSolucionDin=record
    dimCC:TdimCC;
//    VISol:estructuraVIDin;
    SeqSol:Tseq;
    rdsSol:RDatosSeq;
    ConSol:Tcontrol;
    TransSol:Ttransfer;
//    fSol:vectorParaPartesF;
    nPSol:vectorParaPartes;{Se usa en PKIP}
    nISol:vectorParaPartes;{Se usa en PKIP}
    LCDSol:rLCD;
    diferencia:Integer;

  end;

var
  mvrDin:matrizValoresDePartesProgramaDIN;
  SolDin:tipoSolucionDin;

  dtsObjetivo:matrizDiagramasDeTiempo;

function RandomM(Nmax,m:integer):arregloEntero;
function RandomConPesosLineales(n:Integer):Integer;
procedure indicesDePadres(Nmax,m:Integer;var a,b:arregloEntero);
function IndiceEnSegmento(n,LongitudSegmento1:Integer):Integer;
procedure indicesDePadresEnSegmentos(longSeg1,longSeg2,m:Integer;var a,b,sa,sb:arregloEntero);

function calcularAdecuacionDT(var rdt:rLCD):vectorParaPartesF;
function calcularAdecuacionDTextenso(var rdt:rLCD):vectorParaPartesF;
procedure MatrizProgramaAMemo_DIN_conOC(var memo:TMemo;var s:tipoSolucionDin);
procedure MatrizProgramaAMemo_DIN(var memo:TMemo;var s:tipoSolucionDin;var nie:integer);
procedure valoresInicialesEnMatrizMVR_DIN(s:Integer);
procedure MostrarLocalizacionDeBitsDin(var memo:TMemo;var s:tipoSolucionDin);
procedure SecuenciaAMemo_PKIP_DIN(var memo:TMemo;var s:tipoSolucionDin;var nie:Integer);
procedure SecuenciaAMemo_PKIP_DIN_conOC(var memo:TMemo;var s:tipoSolucionDin);
procedure SecuenciaMenorAStringGrid(var mProg:Tseq;var mControl:Tcontrol;var SG:TStringGrid);
procedure SecuenciaDinamicaAStringGrid(var sol: tipoSolucionDin;var SG:TStringGrid);
procedure stringGridAmemo_PKIP_DIN(var SG:TStringGrid;var Memo:TMemo);
procedure PrimerasInstruccionesEnRich_LCD(var Memo:TMemo;var nig,nec:Integer);
function TransferConPesosYcondicionAleatorios:estructuraTransferDin;
function controlConPesosYcondicionAleatorios:estructuraControlDin;
function controlConPesosAleatoriosCondicionLineal:estructuraControlDin;
function LinealRandom(n : Integer): Integer;
function ExponencialRandom(N:Integer): Integer;
function QubicRandom: Double;

procedure mostrarControlDin(var Memo:TMemo;var x:Tcontrol);
function hallarUltimaInstruccionEnTcontrol(var x:Tcontrol):Integer;
function obtenerAdecuacionConInstruccionSalida(f:vectorParaPartesF;nI:vectorParaPartes):vectorParaPartesF;
function obtenerAdecuacionConTamano(f:vectorParaPartesF;
             var mControl:Tcontrol):vectorParaPartesF;
function obtenerAdecuacionConTiempoMaximoDeEjecucion(f:vectorParaPartesF;
             var mControl:Tcontrol):vectorParaPartesF;
function obtenerAdecuacionConTiempoMaximoDeEjecucionSCT(f:vectorParaPartesF;
             var mControl:Tcontrol;var mTransfer:Ttransfer):vectorParaPartesF;
function obtenerAdecuacionConTiempoMaximoDeEjecucionST(f:vectorParaPartesF;
             var mProg:Tseq;var mTransfer:Ttransfer):vectorParaPartesF;
function obtenerAdecuacionConTiempoMaximoDeEjecucionS(f:vectorParaPartesF;
             var mProg:Tseq):vectorParaPartesF;
function obtenerAdecuacionGAconInstruccionSalida(f:vectorParaPartesF;nI:vectorParaPartes):vectorParaPartesF;
function cumpleCondicionDin(numCondicion:integer):boolean;
procedure EquipararSecuenciaYcontrol(var x:Tseq;var y:Tcontrol);
procedure mostrarCadenasDT(var memo:TMemo;var xdts:matrizDiagramasDeTiempo);
procedure mostrarMatrizDiagramasDeTiempo_DIN(var Memo:TMemo;var x:mrLCD);
procedure mutarEliminando(var seq:Tseq);
procedure mutarInsertando(var seq:Tseq);
procedure mutarReemplazando(var seq:Tseq);
procedure mutarAdicionando(var seq:Tseq);
procedure mutarDuplicando(var seq:Tseq);
procedure convertirPesosARangos(var x:Tcontrol);

implementation
uses
  mcsAVR;
procedure SecuenciaDinamicaAStringGrid(var sol: tipoSolucionDin;var SG:TStringGrid);
procedure ponerEnSG(col:Integer;fil:Integer;s:string);
var
  sAux:string;
begin
  sAux:=SG.cells[col,fil];
  if sAux='' then
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      SG.cells[col,fil]:=s+':';
    end
    else
    begin
      SG.cells[col,fil]:=s;
    end;
  end
  else
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      SG.cells[col,fil]:=sAux+';'+s+':';
    end
    else
    begin
      SG.cells[col,fil]:=sAux+';'+s;
    end;
  end;
end;
var
  j,t:Integer;
  linea:string;
  OCcadena:string;
  CadenaMnemonico:cadena10;
  fila:Integer;
  vi:vectorInstruccion;
begin
  fila:=1;//Con fila:=0 se pierde la primera instrucción (2016)
  SG.rowCount:=fila+1;

  case CBII of
  PKIP_CC,CONV_CC:begin // WFS
    t:=vpnMaximo(sol.nISol);
  end;
  LCD_CC:begin // WFS OJO
    t:=sol.LCDSol.nUltimaInstDeDT;
  end;
  end;

  for j:=0 to t do
  begin
    linea:='';
    vi:=sol.SeqSol[j];
    OCcadena:=vectorInstruccionAVRaCadenaASM(vi);
    eliminarEspaciosLaterales(OCcadena);
    CadenaMnemonico:=extraerPrimeraPalabra(OCcadena);
    linea:=linea+CadenaMnemonico+' ';
    linea:=linea+OCcadena;//+'    '+cDir;

    SG.rowCount:=fila+1;
    SG.cells[NFILA,fila]:=IntToStr(j);
    ponerEnSG(NPROG,fila,linea);
    Inc(fila);
  end;
  SG.rowCount:=fila+1;
end;

procedure convertirPesosARangos(var x:Tcontrol);
var
  i,t,inicio,fin:Integer;
begin
  t:=Length(x);
  if t=0 then Exit;
  inicio:=0;
  for i:=0 to t-1 do
  begin
    fin:=inicio+x[i].wint-1;
    x[i].iIni:=inicio;
    x[i].iFin:=fin;
    inicio:=fin+1;
  end;
end;
procedure mutarEliminando(var seq:Tseq);
var
  i,j,s:Integer;
  a:Tseq;
  p:Real;
begin
  s:=Length(seq);
  if s=0 then Exit;
  p:=Random;
  i:=Floor(p*(s-1));
  SetLength(a,s-1);
  for j:=0 to s-1 do
  begin
    if j<i then a[j]:=seq[j];
    if j>i then a[j-1]:=seq[j];
  end;
  SetLength(seq,s-1);
  seq:=Copy(a);
end;
procedure mutarInsertando(var seq:Tseq);
var
  i,j,s:Integer;
  a:Tseq;
  p:Real;
begin
  s:=Length(seq);
  if s=0 then Exit;
  p:=Random;
  i:=Floor(p*(s-1));
  SetLength(a,s+1);
  for j:=0 to s do
  begin
    if j<i then a[j]:=seq[j];
    if j=i then a[j]:=instruccionAleatoria;
    if j>i then a[j]:=seq[j-1];
  end;
  SetLength(seq,s+1);
  seq:=Copy(a);
end;
procedure mutarDuplicando(var seq:Tseq);
var
  i,j,s:Integer;
  a:Tseq;
  p:Real;
begin
  s:=Length(seq);
  if s=0 then Exit;
  p:=Random;
  i:=Floor(p*(s-1));
  SetLength(a,s+1);
  for j:=0 to s do
  begin
    if j<i then a[j]:=seq[j];
//    if j=i then a[j]:=instruccionAleatoria;
    if j>i then a[j]:=seq[j-1];
  end;
  if i=0 then
  begin
    a[i]:=instruccionAleatoria;
  end
  else
  begin
    a[i]:=seq[i-1];
  end;
  SetLength(seq,s+1);
  seq:=Copy(a);
end;
procedure mutarReemplazando(var seq:Tseq);
var
  i,s:Integer;
  p:Real;
begin
  s:=Length(seq);
  if s=0 then Exit;
  p:=Random;
  i:=Floor(p*(s-1));
  seq[i]:=instruccionAleatoria;
end;
procedure mutarAdicionando(var seq:Tseq);
var
  s:Integer;
begin
  s:=Length(seq);
  s:=s+1;
  SetLength(seq,s);
  seq[s-1]:=instruccionAleatoria;
end;

procedure mostrarMatrizDiagramasDeTiempo_DIN(var Memo:TMemo;var x:mrLCD);
var
  i,j:integer;
  linea:cadena100;
begin
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
//    Memo.Lines.add('Target Time Diagram:');
    linea:=IntToStr(i)+' ';
    for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
    begin
      linea:=linea+numCad(dtsObjetivo[i,j],4);
    end;
    Memo.Lines.add(linea);
//    Memo.Lines.add('Time Diagram:');
    linea:=IntToStr(i)+' ';
    for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
    begin
      linea:=linea+numCad(x[i].dt[j],4);
    end;
    Memo.Lines.add(linea);

    linea:='';
    for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
    begin
      linea:=linea+numCad(x[i].nI[j],4);
    end;
    Memo.Lines.add(linea);

//    Memo.Lines.add('nIntervalo:'+inttostr(x[i].nIntervalo)+
//                   '  nTiempo:'+inttostr(x[i].nTiempo)+
//                   '  nInstrUltimoCambio:'+inttostr(x[i].nInstruccionUltimoCambio)+
//                   '  nUltimaInstruccionDT:'+inttostr(x[i].nUltimaInstDeDT));

    Memo.Lines.Add('------------------------------------------------------------------------');
  end;
  Memo.Lines.add(FloatToStr(fmocc));
  Memo.Lines.Add('------------------------------------------------------------------------');
end;
procedure mostrarCadenasDT(var memo:TMemo;var xdts:matrizDiagramasDeTiempo);
var
  i,j:Integer;
  linea:string;
begin
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:='';
    for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
    begin
      linea:=linea+numCad(xdts[i,j],4);
    end;
    Memo.Lines.add(linea);
  end;
end;
procedure hallarIFinMasCercano(n:Integer;var y:Tcontrol;var fin,indice:Integer);
var
  i:Integer;
begin
  for i:=0 to Length(y)-1 do
  begin
    if y[i].iFin>=n then
    begin
      fin:=y[i].iFin;
      indice:=i;
      Exit;
    end;
  end;
  fin:=-1;
  indice:=-1;
end;
procedure EquipararSecuenciaYcontrol(var x:Tseq;var y:Tcontrol);
var
  tx,ty,uity,i,fin,indice:Integer;
begin
  tx:=Length(x);
  ty:=Length(y);
  uity:=y[ty-1].iFin;
  if uity=tx-1 then Exit;
  if tx-1<uity then
  begin
    {Buscar iFin mayor mas cercano a ultima instruccion de x}
    hallarIFinMasCercano(tx-1,y,fin,indice);
    SetLength(x,fin+1);
    {Completar x con instrucciones NOP}
    for i:=tx to fin do
    begin
      x[i]:=instruccionNOP;
    end;
    {Eliminar filas superiores en y}
    SetLength(y,indice+1);
    Exit;
  end;
  if tx-1>uity then
  begin
    {Eliminar filas superiores en x}
    SetLength(x,uity+1);
    Exit;
  end;
end;
function BitsIguales(direccion:integer;numeroBit,valorBit:Byte):boolean;
var
  bleido:byte;
begin
  case direccion of
    direccionP0:bleido:=microEje.pEMIC.APINS[0] and microEje.pEMIC.AreaSFR[direccionP0];
    direccionP1:bleido:=microEje.pEMIC.APINS[1] and microEje.pEMIC.AreaSFR[direccionP1];
    direccionP2:bleido:=microEje.pEMIC.APINS[2] and microEje.pEMIC.AreaSFR[direccionP2];
    direccionP3:bleido:=microEje.pEMIC.APINS[3] and microEje.pEMIC.AreaSFR[direccionP3];
  else
    bleido:=microEje.pEMIC.AreaSFR[direccion];
  end;
  if (bleido shr numeroBit)and 1=valorBit then
  begin
    Result:=TRUE;
  end
  else
  begin
    Result:=FALSE;
  end;
end;
function cumpleCondicionDin(numCondicion:integer):boolean;
var
  bleido,bleido2:byte;
  num:integer;
begin

  case numCondicion of
  0..7:
    begin //       $20:begin { JB BIT ADDR,CODE ADDR }
      Result:=BitsIguales(direccionACC,numCondicion,1);
      exit;
    end;
  8..15:
    begin //       $30:begin { JNB BIT ADDR,CODE ADDR }
      Result:=BitsIguales(direccionACC,numCondicion-8,0);
      exit;
    end;
  16:
    begin //       $60:begin { JZ CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if bleido=0 then Result:=TRUE else Result:=FALSE;
      exit;
    end;
  17:
    begin //       $70:begin { JNZ CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if bleido<>0 then Result:=TRUE else Result:=FALSE;
      exit;
    end;
  18:
    begin //       $40:begin { JC CODE ADDR }
      Result:=BitsIguales(direccionPSW,7,1);
      exit;
    end;
  19:
    begin //       $50:begin { JNC CODE ADDR }
      Result:=BitsIguales(direccionPSW,7,0);
      exit;
    end;
  20..27:
    begin //       $20:begin { JB BIT ADDR,CODE ADDR }
      Result:=BitsIguales(direccionB,numCondicion-20,1);
      exit;
    end;
  28..35:
    begin //       $30:begin { JNB BIT ADDR,CODE ADDR }
      Result:=BitsIguales(direccionB,numCondicion-28,0);
      exit;
    end;
  36..43:
    begin //       $20:begin { JB BIT ADDR,CODE ADDR }
      if PUERTO_USADO_P1_O_P2=1 then
      begin
        Result:=BitsIguales(direccionP1,numCondicion-36,1);
        exit;
      end;
      if PUERTO_USADO_P1_O_P2=2 then
      begin
        Result:=BitsIguales(direccionP2,numCondicion-36,1);
        exit;
      end;
    end;
  44..51:
    begin //       $30:begin { JNB BIT ADDR,CODE ADDR }
      if PUERTO_USADO_P1_O_P2=1 then
      begin
        Result:=BitsIguales(direccionP1,numCondicion-44,0);
        exit;
      end;
      if PUERTO_USADO_P1_O_P2=2 then
      begin
        Result:=BitsIguales(direccionP2,numCondicion-44,0);
        exit;
      end;
    end;
  end;
  Result:=FALSE;
end;
function obtenerAdecuacionConTiempoMaximoDeEjecucionS(f:vectorParaPartesF;
             var mProg:Tseq):vectorParaPartesF;
var
  i,nProg,tamano:integer;
begin
  nProg:=Length(mProg);
  if nProg=0 then
  begin
    Result:=f;
    Exit;
  end;
  tamano:=0;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] :=f[i]-(0.0001)*(nProg);
  end;
end;
function obtenerAdecuacionConTiempoMaximoDeEjecucionST(f:vectorParaPartesF;
             var mProg:Tseq;var mTransfer:Ttransfer):vectorParaPartesF;
var
  i,nProg,nTransfer,tamano:integer;
begin
  nProg:=Length(mProg);
  nTransfer:=Length(mTransfer);
  if nProg=0 then
  begin
    Result:=f;
    Exit;
  end;
  tamano:=0;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] :=f[i]-(0.0001)*(nProg+nTransfer);
  end;
end;
function obtenerAdecuacionConTiempoMaximoDeEjecucionSCT(f:vectorParaPartesF;
             var mControl:Tcontrol;var mTransfer:Ttransfer):vectorParaPartesF;
var
  i,nControl,nTransfer,tamano:integer;
begin
  nControl:=Length(mControl);
  nTransfer:=Length(mTransfer);
  if nControl=0 then
  begin
    Result:=f;
    Exit;
  end;
  tamano:=0;
  for i:=0 to nControl-1 do
  begin
    if mControl[i].iFin >=0 then
    begin
      case mControl[i].cond of
      VALOR_MINIMO_CONDICION..0:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1)+1;
        end;
      1:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1);
        end;
      2..VALOR_MAXIMO_CONDICION:begin
          tamano:=tamano+
             ((mControl[i].iFin-mControl[i].iIni+1+1)*(mControl[i].cond))+1
        end;
      end;
    end;
  end;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
//    Result[i] :=f[i]+(1/(tamano+1));
//    Result[i] :=f[i]+(0.5/(tamano+1));
//    Result[i] :=f[i]+(2/(tamano+1));
//    Result[i] :=f[i]+(1/(tamano+nTransfer+1));
    Result[i] :=f[i]-(0.0001)*(tamano+nTransfer);
  end;
end;
function obtenerAdecuacionConTiempoMaximoDeEjecucion(f:vectorParaPartesF;
             var mControl:Tcontrol):vectorParaPartesF;
var
  i,nControl,tamano:integer;
begin
  nControl:=Length(mControl);
  if nControl=0 then
  begin
    Result:=f;
    Exit;
  end;
  tamano:=0;
  for i:=0 to nControl-1 do
  begin
    if mControl[i].iFin >=0 then
    begin
      case mControl[i].cond of
      VALOR_MINIMO_CONDICION..0:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1)+1;
        end;
      1:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1);
        end;
      2..VALOR_MAXIMO_CONDICION:begin
          tamano:=tamano+
             ((mControl[i].iFin-mControl[i].iIni+1+1)*(mControl[i].cond))+1
        end;
      end;
    end;
  end;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
//    Result[i] :=f[i]+(1/(tamano+1));
//    Result[i] :=f[i]+(0.5/(tamano+1));
//    Result[i] :=f[i]+(2/(tamano+1));
    Result[i] :=f[i]-(0.001)*(tamano);
  end;
end;
function obtenerAdecuacionConTamano(f:vectorParaPartesF;
             var mControl:Tcontrol):vectorParaPartesF;
var
  i,nControl,tamano:integer;
begin
  nControl:=Length(mControl);
  if nControl=0 then
  begin
    Result:=f;
    Exit;
  end;
  tamano:=0;
  for i:=0 to nControl-1 do
  begin
    if mControl[i].iFin >=0 then
    begin
      case mControl[i].cond of
      VALOR_MINIMO_CONDICION..0:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1)+1;
        end;
      1:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1);
        end;
      2..VALOR_MAXIMO_CONDICION:begin
          tamano:=tamano+(mControl[i].iFin-mControl[i].iIni+1)+2
        end;
      end;
    end;
  end;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] :=f[i]+(1/(tamano+1));
  end;
end;
function obtenerAdecuacionGAconInstruccionSalida(f:vectorParaPartesF;nI:vectorParaPartes):vectorParaPartesF;
var
  i,n:integer;
begin
  n:=vpnMaximo(nI);
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] :=f[i]+(1/(n+1));
  end;
end;
function obtenerAdecuacionConInstruccionSalida(f:vectorParaPartesF;nI:vectorParaPartes):vectorParaPartesF;
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] :=f[i]+(1/(nI[i]+1));
//    Result[i] :=f[i]+(2/(nI[i]+1));
  end;
end;
function hallarUltimaInstruccionEnTcontrol(var x:Tcontrol):Integer;
var
  i,m,n:Integer;
begin
  m:=Length(x);
  if m>0 then
  begin
    for i:=m-1 downto 0 do
    begin
      if x[i].iFin>=0 then
      begin
        Result:= x[i].iFin;
        Exit;
      end;
    end;
    Result:=-1;
  end
  else
  begin
    Result:=-1;
  end;
end;
procedure mostrarControlDin(var Memo:TMemo;var x:Tcontrol);
var
  j:integer;
  linea:cadena100;
begin
  Memo.Lines.add('LEVEL-1 FLOW CONTROL OPERATIONS:');
  Memo.Lines.add('No  START   END  COND  WEIGHT  Description');
  for j:=0 to Length(x)-1 do
  begin
    linea:=numCad(j,2)+' ';
    linea:=linea+numCad(x[j].iIni,6);
    linea:=linea+numCad(x[j].iFin,6);
    linea:=linea+numCad(x[j].cond,6);

    linea:=linea+'  '+IntToStr(x[j].wint)+'  ';
    case x[j].cond of
    1:linea:=linea+'  Single execution';
    2..VALOR_MAXIMO_CONDICION:linea:=linea+'  Loop';
    VALOR_MINIMO_CONDICION..0:linea:=linea+'  Conditional jump';
    else
      linea:=linea+'  Unknown Operation';
    end;
    Memo.Lines.add(linea);
  end;
end;
function TransferConPesosYcondicionAleatorios:estructuraTransferDin;
var
  x:estructuraTransferDin;
begin
  x.tipo:=random(CANTIDAD_DE_TIPOS_TRANSFERENCIA);
  x.inme:=random(VALOR_INMEDIATO_MAXIMOMASUNO);//Valor inmediato
  x.rDes:=Random(NUMERO_DE_REGISTROS);
  x.rFue:=Random(NUMERO_DE_REGISTROS);;
  x.iDes:=random(2*TAMANO_MINIMO_DE_SECUENCIA_DIN -2)+2;
  x.iFue:=random(integer(x.iDes-1));
  Result:=x;
end;
function controlConPesosYcondicionAleatorios:estructuraControlDin;
var
  x:estructuraControlDin;
  n:Integer;
begin
  x.wint:=VALOR_ALEATORIO_MINIMO_PESO+
       Random(VALOR_ALEATORIO_MAXIMO_PESO-VALOR_ALEATORIO_MINIMO_PESO+1);
//  x.cond:=Random(VALOR_MAXIMO_CONDICION-VALOR_MINIMO_CONDICION+1)+VALOR_MINIMO_CONDICION;
  n:=Random(300); {Igual probabilidad}
  if n<100 then
  begin {Salto condicional}
    x.cond:=(-1)*Random((-1)*VALOR_MINIMO_CONDICION+1)
  end
  else
  begin
    if n<200 then
    begin {Bucle}
      x.cond:=Random(VALOR_MAXIMO_CONDICION+1);
    end
    else
    begin {Ejecucion unica}
      x.cond:=1;
    end;
  end;
  Result:=x;
end;
function controlConPesosAleatoriosCondicionLineal:estructuraControlDin;
var
  x:estructuraControlDin;
begin
  x.wint:=VALOR_ALEATORIO_MINIMO_PESO+
       Random(VALOR_ALEATORIO_MAXIMO_PESO-VALOR_ALEATORIO_MINIMO_PESO+1);
//  x.w:=Random;
  x.cond:=1;
  Result:=x;
end;
procedure PrimerasInstruccionesEnRich_LCD(var Memo:TMemo;var nig,nec:Integer);
begin
  Memo.Lines.add(';-----------------------');Inc(nec);
  Memo.Lines.add('; LCD');Inc(nec);
  Memo.Lines.add('; inicialization');Inc(nec);
  Memo.Lines.add('; program');Inc(nec);
  Memo.Lines.add(';-----------------------');Inc(nec);
  Memo.Lines.add('        '+'MOV A,#0');Inc(nig);
  Memo.Lines.add('        '+'MOV B,A');Inc(nig);
  Memo.Lines.add('        '+'MOV R0,A');Inc(nig);
  Memo.Lines.add('        '+'MOV P1,#0FFH');Inc(nig);
  Memo.Lines.add('        '+'MOV PSW,#0');Inc(nig);
  Memo.Lines.add(';START OF THE');Inc(nec);
  Memo.Lines.add(';GENERATED PROGRAM');Inc(nec);
end;
procedure stringGridAmemo_PKIP_DIN(var SG:TStringGrid;var Memo:TMemo);
procedure separarCadenas(x:string;var c:tipoCadenasSeparadas);
var
  i:Integer;
  contador:Integer;
  xCola:string;
  posSeparador:byte;
  tamano:integer;
begin
  contador:=0;
  tamano:=length(x);
  if tamano=0 then
  begin
    c[0]:='FINALBLOQUE';
    exit;
  end;
  while tamano>0 do
  begin
    posSeparador:=pos(';',x);
    if posSeparador>0 then
    begin
      c[contador]:=copy(x,1,posSeparador-1);
      Inc(contador);
      xCola:=copy(x,posSeparador+1,tamano-posSeparador);
    end
    else
    begin
      c[contador]:=x;
      Inc(contador);
      xCola:='';
    end;
    x:=xCola;
    tamano:=length(x);
  end;
  c[contador]:='FINALBLOQUE';
end;
var
  i,j,k,m:integer;
  sLinea:string;
  c:tipoCadenasSeparadas;
begin
  m:=0;// 2020
  case CBII of
  LCD_GP,PKIP_GP:begin
      m:=1;{solo debe ser mayor que 0}
    end;
  PKIP_SC_GP:begin
      m:=1;
    end;
  end;
  if (m>=0) then
  begin
    for i:=0 to SG.rowCount do
    begin
      for j:=0 to SG.ColCount do
      begin
        sLinea:=SG.cells[j,i];
        if (sLinea<>'')and(j<>NFILA) then
        begin
            separarCadenas(sLinea,c);
            k:=0;
            while c[k]<>'FINALBLOQUE' do
            begin
              if (j=N_ETIQ_BIF1)or(j=N_ETIQ_BIF2)or(j=N_ETIQ_JMP2)or(j=N_ETIQ_JMP1) then
              begin
                Memo.Lines.add(c[k]);
              end
              else
              begin
                Memo.Lines.add('    '+c[k]);
                //n:=Pos('PORT',instruccionS);
                if Pos('PORT',c[k])>0 then
                begin
                  Memo.Lines.Add('    CALL DELAY');
                end;
              end;
              Inc(k);
            end;
        end;
      end;
    end;
  end;
//  Memo.Lines.add('; End of the');
//  Memo.Lines.add('; evolved program.');
end;
procedure SecuenciaMenorAStringGrid(var mProg:Tseq;var mControl:Tcontrol;var SG:TStringGrid);
procedure ponerEnSG(col:Integer;fil:Integer;s:string);
var
  sAux:string;
begin
  sAux:=SG.cells[col,fil];
  if sAux='' then
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      SG.cells[col,fil]:=s+':';
    end
    else
    begin
//      SG.cells[col,fil]:='        '+s;
      SG.cells[col,fil]:=s;
    end;
  end
  else
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      SG.cells[col,fil]:=sAux+';'+s+':';
    end
    else
    begin
//      SG.cells[col,fil]:=sAux+';'+'        '+s;
      SG.cells[col,fil]:=sAux+';'+s;
    end;
  end;
end;
var
  j,ts,ui:Integer;
  linea:string;
  OCcadena:string;
  CadenaMnemonico:cadena10;
  fila:Integer;
begin
  fila:=1;//Con fila:=0 se pierde la primera instrucción (2016)
  SG.rowCount:=fila+1;
  ts:=Length(mProg);
  ui:=hallarUltimaInstruccionEnTcontrol(mControl);
  if ui<0 then Exit;
  for j:=0 to ui do
  begin
    linea:='';
    OCcadena:=vectorInstruccionAcadenaASM(mProg[j],0);
    eliminarEspaciosLaterales(OCcadena);
    CadenaMnemonico:=extraerPrimeraPalabra(OCcadena);
    linea:=linea+CadenaMnemonico+' ';
    linea:=linea+OCcadena;//+'    '+cDir;

    SG.rowCount:=fila+1;
    SG.cells[NFILA,fila]:=IntToStr(j);
    ponerEnSG(NPROG,fila,linea);
    Inc(fila);
  end;
  SG.rowCount:=fila+1;
end;
procedure MostrarLocalizacionDeBitsDin(var Memo:TMemo;var s:tipoSolucionDin);
var
  cProg:string;
  nR,nBR:vectorParaPartes;
  i:Integer;
  linea:string;
begin
    for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
    begin
      nR[i]:=s.nPSol[i] div 8;
      nBR[i]:=s.nPSol[i] mod 8;
    end;
    linea:='BIT LOCATION:      ';
    for i:=NUMERO_DE_PARTES_DE_SALIDA - 1 downto 0 do
    begin
      linea:=linea+'Bit'+intToStr(i)+'  ';
    end;
    Memo.Lines.Add(linea);
    Memo.Lines.Add('Register:        '+cadenaDeVectorParaPartes(nR,True));
    Memo.Lines.Add('Bit in Register: '+cadenaDeVectorParaPartes(nBR,False));
    Memo.Lines.Add('Number of Instr: '+cadenaDeVectorParaPartes(s.nISol,False));
    cProg:=numFCad(sumarElementosVectorParaPartesF(s.rdsSol.f),6);
    Memo.Lines.Add('--------------------------------------------------------------');
    Memo.Lines.Add('FITNESS:         '+cadenaDeVectorParaPartesF(s.rdsSol.f));
    Memo.Lines.Add('TOTAL FITNESS:'+cProg);

end;
procedure valoresInicialesEnMatrizMVR_DIN(s:Integer);
var
  i,k:integer;
begin
  SetLength(mvrDin,s);
  for i:=0 to s-1 do
  begin
    for k:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
    begin
      mvrDin[i][k]:=0;
    end;
  end;
end;
procedure SecuenciaAMemo_PKIP_DIN(var memo:TMemo;var s:tipoSolucionDin;var nie:Integer);
var
  j,t:Integer;
  linea:string;
begin
//    Memo.Lines.Add('INSTRUCTION SEQUENCE: ');
//    Memo.Lines.Add('   No  OpCODE  MNEMONIC');
//  t:=Length(s.progSol);
//  t:=s.LCDSol.nUltimaInstDeDT;
//  for j:=0 to t-1 do
  t:=Length(s.SeqSol);
  nie:=nie+t;
  for j:=0 to t-1 do
  begin
    linea:='        '+vectorInstruccionAcadenaASM(s.SeqSol[j],0);
    Memo.Lines.Add(linea);
  end;
end;
procedure SecuenciaAMemo_PKIP_DIN_conOC(var memo:TMemo;var s:tipoSolucionDin);
var
  j,t:Integer;
  linea:string;
begin
  t:=Length(s.SeqSol);
  for j:=0 to t-1 do
  begin
    linea:='  ';
      if j<10 then linea:=linea+' ';
      if j<100 then linea:=linea+' ';
      linea:=linea+IntToStr(j)+'  ';{Pone Numero de Fila}
    linea:=linea+'  '+vectorInstruccionAVRaCadenaASM(s.SeqSol[j]);
    Memo.Lines.Add(linea);
  end;
end;
procedure MatrizProgramaAMemo_DIN_conOC(var memo:TMemo;var s:tipoSolucionDin);
var
  j,t,n:Integer;
  linea:string;
  instruccionS:string;
begin
  t:=s.rdsSol.u+1;
  for j:=0 to t-1 do
  begin
    instruccionS:=vectorInstruccionAVRaCadenaASM(s.SeqSol[j]);
    linea:='    '+instruccionS;
    Memo.Lines.Add(linea);
    n:=Pos('PORT',instruccionS);
    if n>0 then
    begin
      Memo.Lines.Add('    CALL DELAY');
    end;
  end;
end;
procedure MatrizProgramaAMemo_DIN(var memo:TMemo;var s:tipoSolucionDin;var nie:integer);
var
  j,t:Integer;
  linea:string;
begin

//  t:=s.LCDSol.nUltimaInstDeDT;
  t:=s.rdsSol.u;
  nie:=nie+t+1;
//  for j:=0 to t-1 do
  for j:=0 to t do
  begin
    linea:='        '+vectorInstruccionAcadenaASM(s.SeqSol[j],0);
    Memo.Lines.Add(linea);
  end;
end;
function calcularAdecuacionDT(var rdt:rLCD):vectorParaPartesF;
var
  i,j:Integer;
  f:vectorParaPartesF;
  a,g,b:Byte;
  bb:SmallInt;
begin
  anularVectorParaPartesF(f);
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do {PRUEBA}
  begin
    a:=dtObjetivo[j];
    bb:=rdt.dt[j];
    if bb>=0 then
    begin
      b:=Byte(bb);
      for i:=0 to 7 do
      begin
        g:=byte((not(((a shr i)and 1)xor((b shr i)and 1)))and 1);
        if g=1 then
        begin
          f[i]:=f[i]+(NUMERO_DE_CADENAS_DE_SALIDA-j);// 2020 se activa
//          f[i]:=f[i]+2*(NUMERO_DE_CADENAS_DE_SALIDA-j);// 2020 se activa
        end;
      end;
    end;
  end;
  Result:=f;
end;
function calcularAdecuacionDTNuevo(var rdt:rLCD):vectorParaPartesF;
var
  i,j:Integer;
  f:vectorParaPartesF;
  a,g,b:Byte;
  bb:SmallInt;
  sigueIgual:Boolean;
begin
  anularVectorParaPartesF(f);
  sigueIgual:=True;
  for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
  begin
    a:=dtObjetivo[j];
    bb:=rdt.dt[j];
    if bb<>a then sigueIgual:=False;
    if bb>=0 then {Si bb=-1 no se cuenta}
    begin
      b:=Byte(bb);
      for i:=0 to 7 do
      begin
        g:=byte((not(((a shr i)and 1)xor((b shr i)and 1)))and 1);
        if g=1 then
        begin
          if sigueIgual then
          begin
            f[i]:=f[i]+(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-j);
//          f[i]:=f[i]+2*(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-j);
          end
          else
          begin
            f[i]:=f[i]+1.0;
          end;
        end;
      end;
    end;
  end;
  Result:=f;
end;
function calcularAdecuacionDTextenso(var rdt:rLCD):vectorParaPartesF;
var
  i,j:Integer;
  f:vectorParaPartesF;
  a,g,b:Byte;
  bb:SmallInt;
begin
  anularVectorParaPartesF(f);
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do {PRUEBA}
  begin
    a:=dtObjetivo[j];
    bb:=rdt.dt[j];
    if bb>=0 then
    begin
      b:=Byte(bb);
      for i:=0 to 7 do
      begin
        g:=byte((not(((a shr i)and 1)xor((b shr i)and 1)))and 1);
        if g=1 then
        begin
//          f[i]:=f[i]+(NUMERO_DE_CADENAS_DE_SALIDA-j);
//          f[i]:=f[i]+1.0;
//          f[j]:=f[j]+1.0;
          f[j]:=f[j]+(NUMERO_DE_CADENAS_DE_SALIDA-j);
        end;
      end;
    end;
  end;
  Result:=f;
end;
function IndiceEnSegmento(n,LongitudSegmento1:Integer):Integer;
begin
  if n<LongitudSegmento1 then
  begin
    Result:=n;
  end
  else
  begin
    Result:=n-LongitudSegmento1;
  end;
end;

function RandomConPesosLineales(n:Integer):Integer;
{Devuelve numero aleatorio entre 0 y n-1 con probabilidades linealmente variables,
0 tiene la mayor probabilidad n-1 la menor}
var
  tope,m,i:Integer;
begin
  tope:=(n*(n+1)) div 2;
  m:=Random(tope);
  for i:=0 to n do
  begin
    if (i*(i+1) div 2) > m then
    begin
      Result:=(n-1)-(i-1);
      Exit;
    end;
  end;
end;
function QubicRandom: Double;
var
  a:Double;
begin
  a:=Random;
  Result := (1-a)*(1-a)*(1-a);
end;
function LinealRandom(n : Integer): Integer;
begin
//  Result := (-Ln(1.0 - Random) / Lambda);
  Result := Floor((1-n)* Random + n);
end;
function ExponencialRandom(N:Integer): Integer;
var
  logar,ln000001:Double;
begin
//  Result := (-Ln(1.0 - Random) / Lambda);
  ln000001:=Ln(0.000001);
  logar:= (N+1)*(Ln(1.0 - Random + 0.000001)/ln000001);
  Result:=Trunc(abs(logar));
//  Result := (-Ln((1.0 - Random)/lambda) / Lambda);
end;
procedure indicesDePadres(Nmax,m:Integer;var a,b:arregloEntero);
{Devuelve m pares a[i], b[i] (a[i]<>b[i]) menores a Nmax}
var
  i:Integer;
begin
  SetLength(a,m);
  SetLength(b,m);

  if Nmax<=1 then Exit;
  for i:= 0 to m - 1 do
  begin
    a[i]:=RandomConPesosLineales(Nmax);
    repeat
      b[i]:=RandomConPesosLineales(Nmax);
    until b[i]<>a[i];
  end;
end;
procedure indicesDePadresEnSegmentos(longSeg1,longSeg2,m:Integer;var a,b,sa,sb:arregloEntero);
{longSeg1-tamaño P1t, longSeg2-tamaño P2t; m-cantidad de parejas
Devuelve m pares a[i], b[i].
a[i]-Indice en P1t (sa[i]=1) o en P2t (sa[i]=2)
b[i]-Indice en P1t (sb[i]=1) o en P2t (sb[i]=2)  }
var
  i,Nmax:Integer;
begin
  SetLength(a,m);
  SetLength(b,m);
  SetLength(sa,m);
  SetLength(sb,m);
  {Indices en un solo segmento}
  Nmax:=longSeg1+longSeg2;
  if Nmax<=1 then Exit;
  for i:= 0 to m - 1 do
  begin
//    a[i]:=RandomConPesosLineales(Nmax);
    a[i]:=Trunc(Nmax*QubicRandom);
    repeat
//    b[i]:=RandomConPesosLineales(Nmax);
      b[i]:=Trunc(Nmax*QubicRandom);
    until b[i]<>a[i];
  end;
  {Indices en dos segmentos}
  for i:= 0 to m - 1 do
  begin
    if a[i]<longSeg1 then
    begin
      sa[i]:=1;
    end
    else
    begin
      a[i]:=a[i]-longSeg1;
      sa[i]:=2;
    end;
    if b[i]<longSeg1 then
    begin
      sb[i]:=1;
    end
    else
    begin
      b[i]:=b[i]-longSeg1;
      sb[i]:=2;
    end;
  end;
end;
function RandomM(Nmax,m:integer):arregloEntero;
{Devuelve arreglo con m números aleatorios diferentes menores a Nmax}
var
  i,j,aux:Integer;
  a:arregloEntero;
  hay:Boolean;
begin
  SetLength(a,m);
  a[0]:=Random(Nmax);
  for i:= 1 to m - 1 do
  begin
    hay:=False;
    repeat
      aux:=Random(Nmax);
      for j:=0 to i-1 do
      begin
        if aux=a[j] then
        begin
          hay:=True;
          Break;
        end;
      end;
    until not(hay);
    a[i]:=aux;
  end;
  RandomM:=Copy(a);
end;
end.
