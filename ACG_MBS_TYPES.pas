unit ACG_MBS_TYPES;

interface
uses
  Classes, sysUtils,math,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion;

const
  EPSILON = 0.01;//0.01;// 0.3;//0.05;//0.1;//0.01;

  PROBABILIDAD_DE_MUTACION = 30;
  NUMERO_DE_INSTRUCCIONES_DE_TABLA_SIN_R7 = 58;
  NUMERO_DE_INSTRUCCIONES_DE_TABLA_SIN_R7_CON_INME =58+2 + 6;
  NUMERO_DE_INSTRUCCIONES_DE_TABLA_CON_R7 = 58+3;
const
  CANTIDAD_DE_DIRECCIONES_DE_BITS = 3*8;{Cantidad de Direcciones de bits: P1 o P2, ACC y B}

  CANTIDAD_DE_TIPOS_TRANSFERENCIA = 4;

  NUMERO_DE_REPRESENTANTES = 2;

  VALOR_INMEDIATO_MAXIMOMASUNO = 256;

  TAMANO_POBLACION = 500;

  NUMERO_DE_REGISTROS = 3;
  NUMERO_BYTES_POR_INSTRUCCION = 5;// 3;

  NUMERO_MAX_DE_CADENAS_DE_SALIDA = 256;

  NUMERO_MAXIMO_DE_REPETICIONES_NIVEL_1 = 16;
  NUMERO_MAXIMO_DE_REPETICIONES_NIVEL_2 = 16;

  NUMERO_DE_CONDICIONES_DE_SALTO = 20;//29;
  {De 0 a 7  comprueba valor 1 del bit en ACC}
  {De 8 a 15 comprueba valor 0 del bit en ACC}
  {16 JZ} {17 JNZ} {18 JC} {19 JNC}
const
  NUMERO_MAX_DE_INSTRUCCIONES_EN_SECUENCIA = 120;
  NUMERO_MAX_DE_OPERACIONES_DE_CONTROL_NIVEL_1 = 40;
  NUMERO_MAX_DE_OPERACIONES_DE_CONTROL_NIVEL_2 = 20;
  NUMERO_MAX_DE_OPERACIONES_DE_TRANSFERENCIA = 30;
var
  NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA:Integer;// = 80;
  NUMERO_DE_OPERACIONES_DE_CONTROL_NIVEL_1:Integer;// = 20;
  NUMERO_DE_OPERACIONES_DE_CONTROL_NIVEL_2:Integer;// = 6;
  NUMERO_DE_OPERACIONES_DE_TRANSFERENCIA:Integer;// = 10;

  PUERTO_USADO_P1_O_P2:Integer;{1-Se usa puerto P1; 2-Se usa puerto P2}
type
  T_CBII=(LCD_CC,PKIP_CC,BN_BCD_CC,BCD_LCD_CC,HOME_CC,CONV_CC,
  {           0       1      2       3       4       }
  LCD_GP,PKIP_GP,PKIP_SC_GP,TP_GP,LCD_QIGP,TP_QIGP,PKIP_QIGP,PKIP_SCT_GP,PKIP_SCT,LCD_SCT);
  {   5       6        7      8       9        10         11      12}
var
  CBII:T_CBII;
  ESEQ,ECON,ETRAN:Boolean;{Existe Secuencia, Existe Control, Existe Transferencia}
//  ESPKIP,ESLCD,ESTP:Boolean;
  TAMANO_MATRIZ_NSGAII:Integer;
  FOR_TODAS_ESPECIES:Integer;
  FOR_CADA_ESPECIE:Integer;
const
  NUMERO_MAXIMO_DE_PARTES_DE_SALIDA = 24;

  NUMERO_DE_PARTES_EN_MEMORIA = 24;//6;

var
{Variables a Transferir en Archivo .SOD}
  NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA:Integer;
  NUMERO_DE_CADENAS_DE_SALIDA:Integer;
  NUMERO_DE_BITS_POR_PARTE:Integer;
  NUMERO_DE_PARTES_DE_SALIDA:Integer;
  NUMERO_DE_PARTES_DE_ENTRADA:Integer; // WFS 2020B

type
  PvectorInstruccion = ^vectorInstruccion;
  vectorInstruccion = array [0..NUMERO_BYTES_POR_INSTRUCCION - 1]of byte;
(*
    0-NroOrden:byte; {OC asignado }
    1-Operando:Byte; {Operando inmediato o número de bit}
    2-tipoOperando:Byte; {1-No hay, 2-Operando inmediato, 3-Número de bit}
*)
  PmatrizPrograma = ^matrizPrograma;
  matrizPrograma = array [0..NUMERO_MAX_DE_INSTRUCCIONES_EN_SECUENCIA-1]of vectorInstruccion;

  vectorValoresSalidaB = array [0..NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1]of byte;
  vectorValoresSalidaW = array [0..NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1]of word;
  vectorValoresSalidaSI = array [0..NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1]of SmallInt;

  MatrizValoresSalidaW = array [0..NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1,0..1]of word;
  {Columna 0-Estado Anterior; Columna 1-Estado Posterior y Salida  2016 MARZO 18}
  vectorValoresSalida64 = array [0..NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1]of int64;
const
  COL_ENTRADA=0; COL_SALIDA=1;
  DIR_REG_SOLUCION=5;//16;//$20;{Dirección en RAM donde se deposita la solución}
  I_V_A=$28;//40; {Direccion del Valor inicial}
  DIR_REG_RAM_TRANSFERENCIA=$29;//$21;
  DIR_REG_RAM_SALTOS_BIF1=$49;//$31;
  DIR_REG_RAM_SALTOS_BIF2=$69;//$41;
  ENUMERACION_DE_SALTOS_BIF1=101;{Corresponde a etiqueta SAL101}
  ENUMERACION_DE_SALTOS_BIF2=201;{Corresponde a etiqueta SAL201}

type
  matrizValoresDePartesPrograma =
    array[-1..NUMERO_MAX_DE_INSTRUCCIONES_EN_SECUENCIA-1]of vectorValoresSalida64;
//  matrizValoresDePartesObjetivo = // WFS 2020B
//    array[-1..NUMERO_MAXIMO_DE_PARTES_DE_SALIDA-1]of vectorValoresSalidaB;
  matrizValoresDePartesObjetivo =
    array[-1..NUMERO_MAXIMO_DE_PARTES_DE_SALIDA-1]of vectorValoresSalidaW;
  {Fila -1-Estado Anterior; Filas 0,1,2, ... -Estado Posterior y Salida  2016 MARZO 18}
const
  FIL_EST_ANT=-1;
type
  vectorParaPartes =
    array[0..NUMERO_MAXIMO_DE_PARTES_DE_SALIDA-1]of integer;
  vectorParaPartesF =
    array[0..NUMERO_MAXIMO_DE_PARTES_DE_SALIDA-1]of Real;

  vectorMarcas = array[0..NUMERO_MAX_DE_INSTRUCCIONES_EN_SECUENCIA-1]of integer;
  vectorMarcasBooleanas = array[-1..NUMERO_MAX_DE_INSTRUCCIONES_EN_SECUENCIA-1]of boolean;


type
  estructuraControl = record
    tipo:byte;{0-bucle, 1-corre, 2-salto}
    iIni:byte;
    iFin:byte;
    cond:Smallint;
  end;
type
  estructuraTransferencia = record
    tipo:byte;
    iDes:integer;
    rDes:byte;
    iFue:integer;
    rFue:byte;
    inme:Byte;{valor inmediato en recuperacion CAMBIO 2016}
  end;

  matrizControl = array [0..NUMERO_MAX_DE_OPERACIONES_DE_CONTROL_NIVEL_1-1]of estructuraControl;
  matrizTransferencia = array [0..NUMERO_MAX_DE_OPERACIONES_DE_TRANSFERENCIA-1]of estructuraTransferencia;
  esControl = record
    bif1:matrizControl;
    bif2:matrizControl;
  end;
  esTransferencia = record
    rec:matrizTransferencia;
  end;
//type
//  rLCD = record
//    nInstruccionUltimoCambio:Integer;
//    nUltimaInstDeDT:Integer;
//    nPrimeraDiferenciaEnDT:Integer;
//    nTiempo:Integer;
//    nIntervalo:Integer; {Conteo de intervalo a partir de 0}
//    P1anterior:Byte;
//    dt:vectorValoresSalidaSI;
//    nI:vectorValoresSalidaB;
//  end;
//  mrLCD = array of rLCD;
//
//  tipoSolucion=record
//    pereSol:esTransferencia;
//    contSol:esControl;
//    progSol:matrizPrograma;
//    fSol:vectorParaPartesF;
//    nPSol:vectorParaPartes;{Se usa en PKIP}
//    nISol:vectorParaPartes;{Se usa en PKIP}
//    LCDSol:rLCD;
//
//  end;
type
  rLCD = record
    nInstruccionUltimoCambio:Integer;
    nUltimaInstDeDT:Integer;
    nPrimeraDiferenciaEnDT:Integer;{número de instruccion en secuencia}
    iPrimeraDiferenciaEnDT:Integer;{indice en cadena de salida}
    indicesIzquierdos:vectorParaPartesF;{extremo izquierdo de cada bit de dt}

    nTiempo:Integer;
    nIntervalo:Integer; {Conteo de intervalo a partir de 0}
    P1anterior:Byte;
    dt:vectorValoresSalidaSI;{Diagramas de tiempo}
    nI:vectorValoresSalidaB;{arreglo de números de instrucción de cambio en dt}
  end;
  mrLCD = array of rLCD;

  tipoSolucion=record
    pereSol:esTransferencia;
    contSol:esControl;
    progSol:matrizPrograma;
    fSol:vectorParaPartesF;
    nPSol:vectorParaPartes;{Se usa en PKIP}
    nISol:vectorParaPartes;{Se usa en PKIP}
    LCDSol:rLCD;

  end;

var {VARIABLES GLOBALES}
  microEje:TmcsEje;
  microAyu:TmcsEje; //Para Ensamblar y crear archivo HEX

  mvr:matrizValoresDePartesPrograma;
  regA,regB,regR:byte;

  sol:tipoSolucion;

  regLCD:rLCD;
  mregLCD:mrLCD;
  vectorDifLCD:vectorParaPartesF;
  nombreArchivoEntradaXLS:string;

var {VARIABLES GLOBALES}
//  mejoro:Boolean;
//  soloEspecie0:Boolean;
  haySolucion:Boolean;{Es TRUE cuando se cumple condicion de parada fmocc=fMoccMax}
  fmocc:Real;   {Adecuación mayor encontrada}
  tmocc:integer;{Número de generación}
  nemocc:integer;{Número de evaluación}
  pormocc:double;{Porcentaje}
  fMoccMax:Integer;{Adecuación máxima}

  nesnuevo:Integer; {NO USADO}
  seqSize:Integer;{Para decrementar el tamano}


var vObjetivo:MatrizValoresSalidaW;
var dtObjetivo:vectorValoresSalidaB;

var mvpo:matrizValoresDePartesObjetivo;

var vectorProgramaNulo:matrizPrograma;
var vectorMarcasNulas:vectorMarcas;
var vectorParaPartesNulo:vectorParaPartes;
var vectorParaPartesFNulo:vectorParaPartesF;
type
//  TiPermitidas_Sin_R7 = array[0..NUMERO_DE_INSTRUCCIONES_DE_TABLA_SIN_R7-1]of vectorInstruccion;
//  TiPermitidas_Con_R7 = array[0..NUMERO_DE_INSTRUCCIONES_DE_TABLA_CON_R7-1]of vectorInstruccion;
//  TiPermitidas_Sin_R7_con_inme =
//    array[0..NUMERO_DE_INSTRUCCIONES_DE_TABLA_SIN_R7_CON_INME-1]of vectorInstruccion;
  TiPermitidas = array of vectorInstruccion;

var instruccionNOP:vectorInstruccion = (	$0	,	$0	,	$0  ,	$0	,	$0	); //	NOP
{Nueva Tabla de Instrucciones}
var iPermitidas : TiPermitidas;
  NUMERO_DE_INSTRUCCIONES_DE_TABLA:Integer;

type
  resultadoPareto = (cp_igual, cp_domina, cp_inferior, cp_indiferente);
var
  tmascarasB:array[1..8]of byte = ($01,$03,$07,$0F,$1F,$3F,$7F,$FF);
  tmascaras64:array[1..8]of int64 = ($01,$03,$07,$0F,$1F,$3F,$7F,$FF);
(******************** Procedimientos de VectorParaPartes **********************)
function VectorParaPartesString(var x:vectorParaPartes):string;
function vectorParaPartesRealAenteroEscalado(
           f:vectorParaPartesF;escala:Real):vectorParaPartes;
procedure VectorParaPartesAleatorio(var x:vectorParaPartes);
procedure anularVectorParaPartes(var x:vectorParaPartes);
procedure anularVectorParaPartesF(var x:vectorParaPartesF);
function esVectorParaPartesFnulo(var x:vectorParaPartesF):Boolean;
function vpnMaximo(var x:vectorParaPartes):integer;
function sumarElementosVectorParaPartes(var x:vectorParaPartes):integer;
function sumarElementosVectorParaPartesF(var x:vectorParaPartesF):Real;
procedure dividirVectorParaPartes(var x:vectorParaPartes;y:integer);
procedure dividirVectorParaPartesF(var x:vectorParaPartesF;y:Real);
procedure sumarVectoresParaPartes(var x,y:vectorParaPartes);
procedure sumarVectoresParaPartesF(var x,y:vectorParaPartesF);
procedure sumarConstanteAVectorParaPartesF(var x:vectorParaPartesF;constante:Real);
function cadenaDeVectorParaPartesF(var x:vectorParaPartesF):string;
function cadenaDeVectorParaPartes(var x:vectorParaPartes;EsRegistro:Boolean):string;

procedure convertirObjetivoW(var x:MatrizValoresSalidaW;var y:matrizValoresDePartesObjetivo);
function instruccionAleatoria:vectorInstruccion;
function comparacionParetoF(var x,y:vectorParaPartesF):resultadoPareto;
function comparacionPareto(var x,y:vectorParaPartes):resultadoPareto;

procedure realizarCrossoverIntercambiandoInstruccionPorIndice(i:integer;var x1,x2:matrizPrograma);
procedure realizarInstruccion(vi:vectorInstruccion);
function cumpleCondicion(numCondicion:integer):boolean;
procedure valoresInicialesEnMatrizMVR;
function vectorInstruccionAcadenaASM(a:vectorInstruccion;contador:longint):string;
function vectorInstruccionAcadenaHEX(a:vectorInstruccion):string;
function numCad(n,nc:Integer):string;
function numFCad(r:Real;nc:Integer):string;
procedure anularVectorValoresSalidaB(var x:vectorValoresSalidaB);
procedure limpiarVectorValoresSalidaSI(var x:vectorValoresSalidaSI);

procedure generarProgramaAleatorio(var x:matrizPrograma);
procedure MutarInstruccionPorIndice(var x:vectorInstruccion);
procedure borrarRegistroLCD(var r:rLCD);
procedure borrarMatrizRegistroLCD(var mr:mrLCD);
procedure ArreglarDiagramaDeTiempo;
function NumeroDeBitADireccionDeBit(nb:Byte):Byte;
function DireccionDeBitANumeroDeBit(db:Byte):Byte;
function ByteUnoEsDireccionBit(x:byte):Boolean;
function ByteUnoEsInmediato(x:byte):Boolean;

procedure anularVectorParaPartesDTF(var x:vectorParaPartesF);
function vpnMaximoDTF(var x:vectorParaPartesF):Real;
function cadenaDeVectorParaPartesDTF(var x:vectorParaPartesF):string;
implementation
function cadenaDeVectorParaPartesDTF(var x:vectorParaPartesF):string;
var
  i:integer;
  b:cadena20;
  z:string;
begin
  z:='';
  for i:=NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 downto 0 do
  begin
    b:=numFCad(x[i],6);
    z:=z+b ;
  end;
  cadenaDeVectorParaPartesDTF:=z;
end;
function vpnMaximoDTF(var x:vectorParaPartesF):Real;
var
  i:integer;
  a:Real;
begin
  a:=x[0];
  for i := 1 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 do
  begin
    if(x[i] > a)then
    begin
      a:=x[i];
    end;
  end;
  Result:=a;
end;
procedure anularVectorParaPartesDTF(var x:vectorParaPartesF);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 do
  begin
    x[i] := 0;
  end;
end;
function VectorParaPartesString(var x:vectorParaPartes):string;
var
  i:integer;
  cad:string;
begin
  cad:='    ';
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    cad := cad+IntToStr(x[i])+'  ';
  end;
  Result:=cad;
end;
function vectorParaPartesRealAenteroEscalado(
           f:vectorParaPartesF;escala:Real):vectorParaPartes;
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    Result[i] := Floor(f[i]*escala);
  end;
end;
procedure ArreglarDiagramaDeTiempo;
var
  j:Integer;
begin
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    dtObjetivo[j]:=Byte((vObjetivo[j,COL_SALIDA]));
  end;
end;

procedure borrarRegistroLCD(var r:rLCD);
begin
  r.nInstruccionUltimoCambio:=-1;
  r.nUltimaInstDeDT:=-1;
  r.nPrimeraDiferenciaEnDT:=-1;
  r.nTiempo:=0;
  r.nIntervalo:=0;
  r.P1anterior:=0;
  limpiarVectorValoresSalidaSI(r.dt);
  anularVectorValoresSalidaB(r.nI);
end;
procedure borrarMatrizRegistroLCD(var mr:mrLCD);
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    borrarRegistroLCD(mr[i]);
  end;
end;

procedure anularVectorValoresSalidaB(var x:vectorValoresSalidaB);
var
  i:integer;
begin
  for i:=0 to NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1 do
  begin
    x[i] := 0;
  end;
end;
procedure limpiarVectorValoresSalidaSI(var x:vectorValoresSalidaSI);
var
  i:integer;
begin
  for i:=0 to NUMERO_MAX_DE_CADENAS_DE_SALIDA - 1 do
  begin
    x[i] := -1;
  end;
end;
function numCad(n,nc:Integer):string;
var
  c:string;
begin
  Str(n:nc,c);
  numCad:=c;
end;
function numFCad(r:Real;nc:Integer):string;
var
  c:string;
begin
  Str(r:nc:0,c);
  numFCad:=c;
end;
function vectorInstruccionAcadenaHEX(a:vectorInstruccion):string;
var
  OCbyte,B2,B3:byte;
  numeroBytes:byte;
  OCcadena:string;
  cadenaCodigoMaquina:cadena10;
begin
  OCbyte:= a[0];
  OCcadena:=ISet.JuegoI[OCbyte].mnemonic;
  numeroBytes:=ISet.JuegoI[OCbyte].No_bytes;
  cadenaCodigoMaquina:=ByteAStringHexadecimal(OCbyte);
  case numeroBytes of               { Colocar los bytes B2 y B3 }
  1:begin
      cadenaCodigoMaquina:=cadenaCodigoMaquina+'    ';
    end;
  2:begin
      B2:=a[1];
      cadenaCodigoMaquina:=
        cadenaCodigoMaquina+ByteAStringHexadecimal(B2);
      cadenaCodigoMaquina:=cadenaCodigoMaquina+'  ';

    end;
  3:begin
      B2:=a[1];
      cadenaCodigoMaquina:=
        cadenaCodigoMaquina+ByteAStringHexadecimal(B2);
      B3:=a[2];
      cadenaCodigoMaquina:=
        cadenaCodigoMaquina+ByteAStringHexadecimal(B3);
    end;
  end;
  vectorInstruccionAcadenaHEX:=cadenaCodigoMaquina;
end;

function vectorInstruccionAcadenaASM(a:vectorInstruccion;contador:longint):string;
var
  dirConDesplaza:longint;
  OCbyte,B2,B3,Bayuda:byte;
  carAyuda:char;
  numeroBytes:byte;

  posDEn:byte;
  direccionAbsoluta:word;

  tipoOperando1,tipoOperando2,tipoOperando3:char;
  nombreRegistro:cadena20;

  OCcadena:string;
begin
  OCbyte:=a[0];
  B2:=a[1];
  B3:=a[2];

  OCcadena:=ISet.JuegoI[OCbyte].mnemonic;
  carAyuda:=ISet.JuegoI[OCbyte].ayudaEns;
  numeroBytes:=ISet.JuegoI[OCbyte].No_bytes;

  tipoOperando1:=ISet.JuegoI[OCbyte].tipoO1;
  tipoOperando2:=ISet.JuegoI[OCbyte].tipoO2;
  tipoOperando3:=ISet.JuegoI[OCbyte].tipoO3;

  case carAyuda of
  'R':begin { Direccionamiento Relativo }
        case numeroBytes of
        2:begin
            posDEn:=pos('n',OCcadena);
            delete(OCcadena,posDEn,1);
            if B2<128 then
              dirConDesplaza:=contador+B2
            else
              dirConDesplaza:=contador-( (not (B2)) +1);

            begin
              if posDEn<=length(OCcadena) then
                insert(WordAStringHexadecimal(dirConDesplaza),OCcadena,posDEn)
              else
                OCcadena:=OCcadena+WordAStringHexadecimal(dirConDesplaza);
            end;

          end;
        3:begin
            posDEn:=pos('n',OCcadena);
            delete(OCcadena,posDEn,1);
            if posDEn<=length(OCcadena) then
              insert(IntToStr(B2),OCcadena,posDEn)
            else OCcadena:=OCcadena+IntToStr(B2);
            posDEn:=pos('n',OCcadena);
            delete(OCcadena,posDEn,1);
            if B3<128 then
              dirConDesplaza:=contador+B3
            else
              dirConDesplaza:=contador-( (not (B3)) +1);


            begin
              if posDEn<=length(OCcadena) then
                insert(WordAStringHexadecimal(dirConDesplaza),OCcadena,posDEn)
              else
                OCcadena:=OCcadena+WordAStringHexadecimal(dirConDesplaza);
            end;

          end;
        end;
      end;
  'B':begin { Direccionamiento directo un solo Byte }
        posDEn:=pos('n',OCcadena);
        delete(OCcadena,posDEn,1);

        //2002-03-01
        if (tipoOperando1='D')or(tipoOperando2='D')then
        begin //Es direccion de memoria de datos
          if esDireccionRegistro(B2,nombreRegistro) then
          begin //Es direccion de Registro SFR
            if posDEn<=length(OCcadena) then
              insert(nombreRegistro,OCcadena,posDEn)
            else OCcadena:=OCcadena+nombreRegistro;
          end
          else
          begin
            if posDEn<=length(OCcadena) then
              insert(IntToStr(B2),OCcadena,posDEn)
            else OCcadena:=OCcadena+IntToStr(B2);
          end;
        end
        else
        begin //Es direccion de Bit u operando inmediato
          if posDEn<=length(OCcadena) then
            insert(IntToStr(B2),OCcadena,posDEn)
          else OCcadena:=OCcadena+IntToStr(B2);
        end;

      end;
  'D':begin { Direccionamiento directo Dos bytes }
        if OCbyte=133 then { En la Instruccion MOV direct,direct }
        begin              { es necesario intercambiar operandos }
          Bayuda:=B2;
          B2:=B3;
          B3:=Bayuda;
        end;

        posDEn:=pos('n',OCcadena);
        delete(OCcadena,posDEn,1);
        //2002-03-01
        if (tipoOperando1='D') then
        begin //Es direccion de memoria de datos
          if esDireccionRegistro(B2,nombreRegistro) then
          begin //Es direccion de Registro SFR
            if posDEn<=length(OCcadena) then
              insert(nombreRegistro,OCcadena,posDEn)
            else OCcadena:=OCcadena+nombreRegistro;
          end
          else
          begin
            if posDEn<=length(OCcadena) then
              insert(IntToStr(B2),OCcadena,posDEn)
            else OCcadena:=OCcadena+IntToStr(B2);
          end;
        end
        else
        begin //Es direccion de Bit u operando inmediato
          if posDEn<=length(OCcadena) then
            insert(IntToStr(B2),OCcadena,posDEn)
          else OCcadena:=OCcadena+IntToStr(B2);
        end;

        posDEn:=pos('n',OCcadena);
        delete(OCcadena,posDEn,1);
        //2002-03-01
        if (tipoOperando2='D') then
        begin //Es direccion de memoria de datos
          if esDireccionRegistro(B3,nombreRegistro) then
          begin //Es direccion de Registro SFR
            if posDEn<=length(OCcadena) then
              insert(nombreRegistro,OCcadena,posDEn)
            else OCcadena:=OCcadena+nombreRegistro;
          end
          else
          begin
            if posDEn<=length(OCcadena) then
              insert(ByteAStringHexadecimal(B3),OCcadena,posDEn)
            else OCcadena:=OCcadena+ByteAStringHexadecimal(B3);
          end;
        end
        else
        begin //Es direccion de Bit u operando inmediato
          if posDEn<=length(OCcadena) then
            insert(ByteAStringHexadecimal(B3),OCcadena,posDEn)
          else OCcadena:=OCcadena+ByteAStringHexadecimal(B3);
        end;

      end;
  'W':begin { Direccionamiento directo un Word (dos bytes) }
        posDEn:=pos('n',OCcadena);
        delete(OCcadena,posDEn,1);

        begin
          OCcadena:=OCcadena+IntToStr(B2)+
                             ByteAStringHexadecimal(B3)
        end;

      end;
  '0'..'9': { Direccionamiento Absoluto }
      begin
        posDEn:=pos('n',OCcadena);
        delete(OCcadena,posDEn,1);
        direccionAbsoluta:= (OCbyte shr 5)*256+B2;

        begin
          OCcadena:=OCcadena+WordAStringHexadecimal(direccionAbsoluta);
        end;

      end;
  end;
  vectorInstruccionAcadenaASM:=OCcadena;
end;

procedure realizarInstruccion(vi:vectorInstruccion);
begin
  microEje.pEMIC.OCR:=vi[0];
  microEje.pEMIC.B2:=vi[1];
  microEje.pEMIC.B3:=vi[2];
  microEje.ejecutarInstruccion(microEje.pEMIC.OCR);
end;

procedure valoresInicialesEnMatrizMVR;
var
  i,k:integer;
  rint64,aint64,bint64:int64;
begin
  for k:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    rint64:= (int64(byte(mvpo[FIL_EST_ANT,k])))and $0FF; //Lee R0
    aint64:= (int64(byte(mvpo[FIL_EST_ANT,k])))and $0FF;//Lee ACC
    bint64:= (int64(byte(mvpo[FIL_EST_ANT,k])))and $0FF;//Lee B
//    mvr[-1][k]:= aint64 or (bint64 shl 8) or (rint64 shl 16);
    mvr[-1][k]:= aint64 or (bint64 shl 8) or (rint64 shl 16) or ((aint64 and bint64) shl 40) or
                 ((aint64 or bint64) shl 48) or ((aint64 xor bint64) shl 24) or ((not aint64) shl 32);
  end;
  for i:=0 to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA-1 do
  begin
    for k:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
    begin
      mvr[i][k]:=0;
    end;
  end;
end;
function cumpleCondicion(numCondicion:integer):boolean;
var
  bleido,bleido2:byte;
  num:integer;
begin
  case numCondicion of
  0..7:
    begin //       $20:begin { JB BIT ADDR,CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if (bleido shr numCondicion)and 1=1 then
      begin
        cumpleCondicion:=TRUE;
      end
      else
      begin
        cumpleCondicion:=FALSE;
      end;
      exit;
    end;
  8..15:
    begin //       $30:begin { JNB BIT ADDR,CODE ADDR }
      num:=numCondicion-8;
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if (bleido shr num)and 1=0 then
      begin
        cumpleCondicion:=TRUE;
      end
      else
      begin
        cumpleCondicion:=FALSE;
      end;
      exit;
    end;
  16:
    begin //       $60:begin { JZ CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if bleido=0 then cumpleCondicion:=TRUE else cumpleCondicion:=FALSE;
      exit;
    end;
  17:
    begin //       $70:begin { JNZ CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionACC];
      if bleido<>0 then cumpleCondicion:=TRUE else cumpleCondicion:=FALSE;
      exit;
    end;
  18:
    begin //       $40:begin { JC CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionPSW];
      if (bleido shr 7)and 1=1 then cumpleCondicion:=TRUE else cumpleCondicion:=FALSE;
      exit;
    end;
  19:
    begin //       $50:begin { JNC CODE ADDR }
      bleido:=microEje.pEMIC.AreaSFR[direccionPSW];
      if (bleido shr 7)and 1=0 then cumpleCondicion:=TRUE else cumpleCondicion:=FALSE;
      exit;
    end;
  end;
  cumpleCondicion:=FALSE;
end;
function NumeroDeBitADireccionDeBit(nb:Byte):Byte;
begin
  case PUERTO_USADO_P1_O_P2 of
  1:begin
      case nb of
      0..7:NumeroDeBitADireccionDeBit:=nb+direccionP1;
      8..15:NumeroDeBitADireccionDeBit:=nb-8+direccionACC;
      16..23:NumeroDeBitADireccionDeBit:=nb-16+direccionB;
      end;
    end;
  2:begin
      case nb of
      0..7:NumeroDeBitADireccionDeBit:=nb+direccionP2;
      8..15:NumeroDeBitADireccionDeBit:=nb-8+direccionACC;
      16..23:NumeroDeBitADireccionDeBit:=nb-16+direccionB;
      end;
    end;
  end;
end;
function DireccionDeBitANumeroDeBit(db:Byte):Byte;
begin
  case PUERTO_USADO_P1_O_P2 of
  1:begin
      case db of
      direccionP1..direccionP1+7:DireccionDeBitANumeroDeBit:=db-direccionP1;
      direccionACC..direccionACC+7:DireccionDeBitANumeroDeBit:=db-direccionACC+8;
      direccionB..direccionB+7:DireccionDeBitANumeroDeBit:=db-direccionB+16;
      end;
    end;
  2:begin
      case db of
      direccionP2..direccionP2+7:DireccionDeBitANumeroDeBit:=db-direccionP2;
      direccionACC..direccionACC+7:DireccionDeBitANumeroDeBit:=db-direccionACC+8;
      direccionB..direccionB+7:DireccionDeBitANumeroDeBit:=db-direccionB+16;
      end;
    end;
  end;
end;
function ByteUnoEsDireccionBit(x:byte):Boolean;
begin
  if  (x=$C2) or (x=$D2) then Result :=True
  else Result:=False;
end;
function ByteUnoEsInmediato(x:byte):Boolean;
begin
  if   (x=$74) or (x=$78) or (x=$24) or (x=$34)
    or (x=$44) or (x=$54) or (x=$64) or (x=$94) then Result :=True
  else Result:=False;
end;
function instruccionAleatoria:vectorInstruccion;
var
  nB:byte;
  a:vectorInstruccion;
  indice:Integer;
begin
  indice:=Random(NUMERO_DE_INSTRUCCIONES_DE_TABLA);      //WFS
//  indice:=Random(10);
  a[0]:=iPermitidas[indice][0];
  a[1]:=iPermitidas[indice][1];
  a[2]:=indice;{El tercer byte usamos para almacenar el indice en la tabla}
  if (a[0]=$C2) or (a[0]=$D2) then
  begin {CLR BIT o SETB BIT}
    nB:=Random(CANTIDAD_DE_DIRECCIONES_DE_BITS);
    a[1]:=NumeroDeBitADireccionDeBit(nB);
  end;
  if   (a[0]=$74) or (a[0]=$78) or (a[0]=$24) or (a[0]=$34)
    or (a[0]=$44) or (a[0]=$54) or (a[0]=$64) or (a[0]=$94) then
  begin {MOV A,#data o MOV R0,#data}
    a[1]:=random(VALOR_INMEDIATO_MAXIMOMASUNO);//Valor inmediato
  end;
  instruccionAleatoria:=a;
(*
(	$24	,	$0	,	$0	), //	ADD	   	A,#data
(	$34	,	$0	,	$0	), //	ADDC   	A,#data
(	$44	,	$0	,	$0	), //	ORL	   	A,#data
(	$54	,	$0	,	$0	), //	ANL	   	A,#data
(	$64	,	$0	,	$0	), //	XRL	   	A,#data
(	$94	,	$0	,	$0	), //	SUBB   	A,#data
*)

end;
procedure cambiarValorInmediato(var x:Byte);
var
  n:integer;
  bTemp:Byte;
begin
  n:=random(8);
  bTemp:=1;
  x:=(x) xor (bTemp shl n);
end;
procedure MutarInstruccionPorIndice(var x:vectorInstruccion);
var
  nB,i,iant:byte;
  nAlea:Integer;
begin
  i:=x[2];
  iant:=i;
  nAlea:=Random(100);
  if nAlea<50 then
  begin
    if i>=NUMERO_DE_INSTRUCCIONES_DE_TABLA-1 then i:=0
    else Inc(i);
  end
  else
  begin
    if i=0 then i:=NUMERO_DE_INSTRUCCIONES_DE_TABLA-1
    else Dec(i);
  end;
  x[0]:=iPermitidas[i][0];
  x[2]:=i;{El tercer byte usamos para almacenar el indice en la tabla}
  if (ByteUnoEsInmediato(iPermitidas[iant][0])) and
     (ByteUnoEsInmediato(iPermitidas[i][0])) then begin end
  else
  begin
    x[1]:=random(VALOR_INMEDIATO_MAXIMOMASUNO);//Valor inmediato
  end;
  if (ByteUnoEsDireccionBit(iPermitidas[iant][0])) and
     (ByteUnoEsDireccionBit(iPermitidas[i][0])) then begin end
  else
  begin
    nB:=Random(CANTIDAD_DE_DIRECCIONES_DE_BITS);
    x[1]:=NumeroDeBitADireccionDeBit(nB);
  end;
end;
procedure generarProgramaAleatorio(var x:matrizPrograma);
var
  i:integer;
begin
  x:=vectorProgramaNulo;
  for i:= 0 to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 do
  begin
    x[i]:=instruccionAleatoria;
  end;
end;

procedure dividirVectorParaPartes(var x:vectorParaPartes;y:integer);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := x[i] div y;
  end;
end;
procedure dividirVectorParaPartesF(var x:vectorParaPartesF;y:Real);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := x[i]/y;
  end;
end;
procedure sumarVectoresParaPartes(var x,y:vectorParaPartes);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := x[i] + y[i];
  end;
end;
procedure sumarVectoresParaPartesF(var x,y:vectorParaPartesF);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := x[i] + y[i];
  end;
end;
procedure VectorParaPartesAleatorio(var x:vectorParaPartes);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := Random(10);
  end;
end;
procedure anularVectorParaPartes(var x:vectorParaPartes);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := 0;
  end;
end;
procedure anularVectorParaPartesF(var x:vectorParaPartesF);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := 0;
  end;
end;
function esVectorParaPartesFnulo(var x:vectorParaPartesF):Boolean;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    if x[i]<> 0 then
    begin
      Result:=False;
      Exit;
    end;
  end;
end;

procedure sumarConstanteAVectorParaPartesF(var x:vectorParaPartesF;constante:Real);
var
  i:integer;
begin
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    x[i] := x[i]+constante;
  end;
end;
function cadenaDeVectorParaPartes(var x:vectorParaPartes;EsRegistro:Boolean):string;
var
  i:integer;
  b:cadena20;
  z:string;
begin
  z:='';
  for i:=NUMERO_DE_PARTES_DE_SALIDA - 1 downto 0 do
  begin
    if EsRegistro then
    begin
      case x[i] of
      0:b:='    R0';
      1:b:='    R1';
      2:b:='   R20';
      else b:='      '
      end;
    end
    else
    begin
      b:=numCad(x[i],6);
    end;
    z:=z+b ;
  end;
  cadenaDeVectorParaPartes:=z;
end;
function cadenaDeVectorParaPartesF(var x:vectorParaPartesF):string;
var
  i:integer;
  b:cadena20;
  z:string;
begin
  z:='';
  for i:=NUMERO_DE_PARTES_DE_SALIDA - 1 downto 0 do
  begin
    b:=numFCad(x[i],6);
    z:=z+b ;
  end;
  cadenaDeVectorParaPartesF:=z;
end;
function sumarElementosVectorParaPartes(var x:vectorParaPartes):integer;
var
  i,a:integer;
begin
  a:=0;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    a:= a + x[i];
  end;
  sumarElementosVectorParaPartes:=a;
end;
function sumarElementosVectorParaPartesF(var x:vectorParaPartesF):Real;
var
  i:integer;
  a:Real;
begin
  a:=0;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    a:= a + x[i];
  end;
  sumarElementosVectorParaPartesF:=a;
end;
procedure convertirObjetivoW(var x:MatrizValoresSalidaW;var y:matrizValoresDePartesObjetivo);
var
  i,j:integer;
begin {y tiene numero de filas igual a NUMERO_DE_PARTES_DE_SALIDA}
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA - 1 do
  begin
    y[FIL_EST_ANT][i]:=x[i,COL_ENTRADA];
  end;
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA - 1 do
  begin
    for j:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
    begin
      y[j][i]:=(x[i,COL_SALIDA]shr(NUMERO_DE_BITS_POR_PARTE*j))and
                               tmascarasB[NUMERO_DE_BITS_POR_PARTE];
    end;
  end;

end;

procedure insertarInstruccion(ipos:integer;var x:vectorInstruccion;var y:matrizPrograma);
var
  i:integer;
begin
  if ipos > NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 then exit;
  if ipos = NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 then
  begin
    y[ipos] := x;
    exit;
  end;
  for i:=NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 -1 downto ipos do
  begin
    y[i+1] := y[i];
  end;
  y[ipos] := x;
end;
procedure llevarInstruccionAlFinal(ipos:integer;var y:matrizPrograma);
var
  i:integer;
  x:vectorInstruccion;
begin
  if ipos >= NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 then exit;
  x:=y[ipos];
  for i:=ipos to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1 -1 do
  begin
    y[i]:=y[i+1];
  end;
  y[NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA - 1] := x;
end;
function vpnMaximo(var x:vectorParaPartes):integer;
var
  i,a:integer;
begin
  a:=x[0];
  for i := 1 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    if(x[i] > a)then
    begin
      a:=x[i];
    end;
  end;
  vpnMaximo:=a;
end;
function comparacionParetoFconEPSILON(var x,y:vectorParaPartesF):resultadoPareto;
var
	mayores,menores,iguales,i:integer;
begin
	mayores := 0;
	menores := 0;
	iguales := 0;
	for i := 0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
	begin
		if(x[i] + EPSILON > y[i])then mayores:=mayores+1;
		if(x[i] + EPSILON < y[i])then menores:=menores+1;
		if(x[i] + EPSILON = y[i])then iguales:=iguales+1;
	end;
	if( iguales = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_igual; exit; end;
	if((mayores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_domina; exit; end;
	if((menores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_inferior; exit; end;
	Result := cp_indiferente;
end;
function comparacionParetoF(var x,y:vectorParaPartesF):resultadoPareto;
var
	mayores,menores,iguales,i:integer;
begin
	mayores := 0;
	menores := 0;
	iguales := 0;
	for i := 0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
	begin
		if(x[i] > y[i])then mayores:=mayores+1;
		if(x[i] < y[i])then menores:=menores+1;
		if(x[i] = y[i])then iguales:=iguales+1;
	end;
	if( iguales = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_igual; exit; end;
	if((mayores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_domina; exit; end;
	if((menores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin Result := cp_inferior; exit; end;
	Result := cp_indiferente;
end;
function comparacionPareto(var x,y:vectorParaPartes):resultadoPareto;
var
	mayores,menores,iguales,i:integer;
begin
	mayores := 0;
	menores := 0;
	iguales := 0;
	for i := 0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
	begin
		if(x[i] > y[i])then mayores:=mayores+1;
		if(x[i] < y[i])then menores:=menores+1;
		if(x[i] = y[i])then iguales:=iguales+1;
	end;
	if( iguales = NUMERO_DE_PARTES_DE_SALIDA)then
        begin comparacionPareto := cp_igual; exit; end;
	if((mayores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin comparacionPareto := cp_domina; exit; end;
	if((menores + iguales) = NUMERO_DE_PARTES_DE_SALIDA)then
        begin comparacionPareto := cp_inferior; exit; end;
	comparacionPareto := cp_indiferente;
end;

procedure realizarCrossoverIntercambiandoColas(var x1,x2:matrizPrograma);
var
  va,i:integer;
  vAux:matrizPrograma;
begin
    va:=random(NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA);
    for i:=va to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA-1 do //llevar cola de x1 a vAux
    begin
      vAux[i]:=x1[i];
    end;
    for i:=va to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA-1 do//llevar cola de x2 a x1
    begin
      x1[i]:=x2[i];
    end;
    for i:=va to NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA-1 do//llevar cola de vAux a x2
    begin
      x2[i]:=vAux[i];
    end;
end;
procedure realizarCrossoverIntercambiandoInstruccionPorIndice(i:integer;var x1,x2:matrizPrograma);
var
  vi:vectorInstruccion;
begin
  vi:= x1[i];
  x1[i]:= x2[i];
  x2[i]:= vi;
end;
procedure realizarCrossoverIntercambiandoInstruccion(var x1,x2:matrizPrograma);
var
  va:integer;
  vi:vectorInstruccion;
begin {Intercambio de instrucciones de una posición aleatoria}
  va:=random(NUMERO_DE_INSTRUCCIONES_EN_SECUENCIA);
  vi:= x1[va];
  x1[va]:= x2[va];
  x2[va]:= vi;
end;
function cye(n1,n2:integer):cadena20;
var
  c1,c2:cadena20;
begin
  str(n1,c1);
  str(n2,c2);
  cye:=' '+c1+' '+c2+' ';
end;

end.
