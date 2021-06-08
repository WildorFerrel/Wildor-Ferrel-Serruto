unit ACG_MBS_SEQUENCE_DINAMIC;

interface
uses
  Classes, sysUtils,math,StdCtrls, MMSystem,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,ACG_MBS_LCD,ACG_MBS_KEYPAD;

type
  PTCromSeqDin = ^TCromSeqDin;
  TCromSeqDin = class
    rds: RDatosSeq;
    seq: Tseq;{Secuencia}
    constructor createWithS(vS:Integer);
    constructor createWithSeq(var vS:Tseq);
    constructor createWithSeqF(var vS:Tseq;vF:vectorParaPartesF);
    constructor createWithSeqRDS(var vS:Tseq;r:RDatosSeq);
    constructor createWithSeqProcede(var vS:Tseq;p:Integer);
    constructor createAleatoriamente;
    procedure copiarSecuencia(vS:Tseq);
    procedure copiarAdecuacion(vF:vectorParaPartesF);
    procedure colocarTamano(vS:Integer);
    procedure llenarAleatoriamente;
    procedure mostrar(var memo:TMemo);
    procedure mutar;
    procedure mutarInvirtiendo(i:Integer);
    procedure mutarInvirtiendoTodo;
    procedure mutarReemplazando(i:Integer);
    procedure mutarDuplicando(i:Integer);
    procedure mutarInsertando(i:Integer);
    procedure mutarAdicionando;
    procedure mutarEliminando(i:Integer);
    procedure mutarCambiandoEstado;
    procedure mostrarResultadosLCD;
    procedure mostrarResultadosLCDconTM(iIndividuo:Integer);
    procedure mostrarResultadosLCDconTM_QIGP(iIndividuo:Integer);
    procedure mostrarResultadosPKIP;
    procedure AdecuacionSeqConLCD;
    procedure AdecuacionSeqConKB;
    procedure AdecuacionSeqConTM(iIndividuo:Integer);
    procedure EliminarInstruccionesNOP;

  end;
type
  TPopSeqDin = Class
    PopList:TList;
    procedure iniciar;
    procedure llenarAleatoriamente;
    procedure mutarPoblacion;
    procedure eliminarItems;
    procedure eliminarItemsNuevo;
    procedure mostrar(var memo:TMemo);
    function contarCuanticos:Integer;
    procedure mostrarAdecuacion(var memo:TMemo);
    procedure ordenarPorTamano;
    procedure ordenarPorAdecuacion;
    procedure ordenarPorAdecuacionSumandoF;
    procedure funcionAdecuacionDeCadaProgramaDeLista;
    procedure conservarSoloUnaCantidad(n:Integer);
    function calcularCombinacionLineal:Real;

    function sumaLongitudes:string;

  end;
  TGASeqDin = class
  private
  protected
  public
    P1t,P2t,Qt,Dt,Dpaso5, PRt:TPopSeqDin;

    PRtnl,PRtni:vectorParaPartes;{Indices de los representantes}

    Q1t,Q2t:TPopSeqDin;{Listas de Padres}

    procedure iniciar;
    procedure finalizar;
    procedure iniciarAlgoritmo;
    procedure iniciarAlgoritmoMOCC;

    procedure iniciarParaCC;

    procedure hallarReprentantes;
    procedure hallarReprentantesSoloIndices;
    procedure hallarReprentantesSoloIndicesAleatorios;
    procedure hallarUnReprentante;
    procedure crossover;
    procedure mutacion;

    procedure realizarCrossoverIntercambiandoInstruccionEnQ1tQ2t(i:Integer);
    procedure realizarCrossoverIntercambiandoColasEnQ1tQ2t(i:Integer);
    procedure realizarCrossoverIntercambiandoBloquesEnQ1tQ2t(ii:Integer);
    procedure realizarCrossoverInsertandoBloquesEnQ1tQ2t(ii:Integer);
    procedure seleccionDePadres;
    procedure limpiarQ1tQ2t;
    procedure variacion;

    procedure EjecutarMientrasNoHaySolucion;
    function datos:string;

  end;
var {VARIABLES GLOBALES}
  GASeqDin:TGASeqDin;

procedure insertarListaSecuencia(var SRC, DES, D:TPopSeqDin);
procedure CopiarListaFuenteADestino(var SRC, DES:TPopSeqDin);
procedure CopiarListaFuenteADestinoBorrandoDestino(var SRC, DES:TPopSeqDin);
procedure crossoverSecuencias(var x,y:TCromSeqDin);
procedure copiarSecuenciaXigualY(var x,y:TCromSeqDin);
procedure realizarCrossover(var x1,x2:Tseq);

procedure NumeroDePrimeraDiferencia(i:Integer;var rdt:rLCD);

implementation
uses ACG_MAIN,ACG_MBS_QUANTIC_SEQUENCE;
procedure copiarSecuenciaXigualY(var x,y:TCromSeqDin);
begin
  x.rds:=y.rds;
  x.seq:=Copy(y.seq);
end;
procedure CopiarListaFuenteADestino(var SRC, DES:TPopSeqDin);
var
  tamanoSRC,tamanoDES,i,j:integer;
begin
  tamanoSRC := SRC.PopList.count;
  tamanoDES := DES.PopList.count;
  for i := 0 to tamanoSRC - 1 do
  begin
    DES.PopList.add(TCromSeqDin.createWithSeqRDS(
                     (TObject(SRC.PopList[i])as TCromSeqDin).seq,
                     (TObject(SRC.PopList[i])as TCromSeqDin).rds));
  end;
end;
procedure CopiarListaFuenteADestinoBorrandoDestino(var SRC, DES:TPopSeqDin);
var
  tamanoSRC,tamanoDES,i,j:integer;
begin
  DES.eliminarItems;
  DES.PopList.clear;
  DES.PopList.capacity:=DES.PopList.count;
  tamanoSRC := SRC.PopList.count;
  tamanoDES := DES.PopList.count;
  for i := 0 to tamanoSRC - 1 do
  begin
    DES.PopList.add(TCromSeqDin.createWithSeqRDS(
                        (TObject(SRC.PopList[i])as TCromSeqDin).seq,
                        (TObject(SRC.PopList[i])as TCromSeqDin).rds));
  end;
end;
procedure insertarListaSecuencia(var SRC, DES, D:TPopSeqDin);
var
  tamanoSRC,tamanoDES,i,j:integer;
  noDominado:boolean;
  cmpPar:resultadoPareto;
begin
  D.eliminarItems;
  D.PopList.clear;
  D.PopList.capacity:=D.PopList.count;
  tamanoSRC := SRC.PopList.count;
  tamanoDES := DES.PopList.count;
  for i := 0 to tamanoSRC - 1 do
  begin
    noDominado := true;
    j := 0;
    while(j < tamanoDES) do
    begin
      cmpPar := comparacionParetoF((TObject(SRC.PopList[i])as TCromSeqDin).rds.f,
                                   (TObject(DES.PopList[j])as TCromSeqDin).rds.f);
      if ( cmpPar = cp_domina)then
      begin
        D.PopList.add(TCromSeqDin.createWithSeqRDS(
                                (TObject(DES.PopList[j])as TCromSeqDin).seq,
                                (TObject(DES.PopList[j])as TCromSeqDin).rds));
        (TObject(DES.PopList[j])as TCromSeqDin).destroy;
        DES.PopList.delete(j);
        DES.PopList.capacity:=DES.PopList.count;
        j := j - 1;
        tamanoDES := tamanoDES - 1;
      end;
      if ( cmpPar = cp_inferior)or(cmpPar = cp_igual)then
      begin
        noDominado := false;
      end;
      j := j + 1;
    end;
    if (noDominado) then
    begin
      DES.PopList.add(TCromSeqDin.createWithSeqRDS(
                          (TObject(SRC.PopList[i])as TCromSeqDin).seq,
                          (TObject(SRC.PopList[i])as TCromSeqDin).rds));
    end;
  end;
end;
function ComparaTamanoCromoSeq(Item1, Item2: Pointer): Integer;
begin
  Result := TCromSeqDin(Item2).rds.s-TCromSeqDin(Item1).rds.s;
end;
function ComparaAdecuacionCromoSeqConSumafesc(Item1, Item2: Pointer): Integer;
begin
  Result := TCromSeqDin(Item2).rds.fsumaesc-TCromSeqDin(Item1).rds.fsumaesc;
end;
function ComparaAdecuacionCromoSeq(Item1, Item2: Pointer):Integer;// Integer;
begin
//  Result := floor(100*(sumarElementosVectorParaPartesF(TCromSeqDin(Item2).rds.f)))-
//            floor(100*(sumarElementosVectorParaPartesF(TCromSeqDin(Item1).rds.f)));
  Result := floor(10000*(sumarElementosVectorParaPartesF(TCromSeqDin(Item2).rds.f)))-
            floor(10000*(sumarElementosVectorParaPartesF(TCromSeqDin(Item1).rds.f)));
//  Result := floor(10*(sumarElementosVectorParaPartesF(TCromSeqDin(Item2).rds.f)))-
//            floor(10*(sumarElementosVectorParaPartesF(TCromSeqDin(Item1).rds.f)));
//  Result := floor(100000*(sumarElementosVectorParaPartesF(TCromSeqDin(Item2).rds.f)))-
//            floor(100000*(sumarElementosVectorParaPartesF(TCromSeqDin(Item1).rds.f)));
{Con 100 avanza la evolución}
//  Result := floor(100*(sumarElementosVectorParaPartesF(TCromSeqDin(Item2).rds.f)))-
//            floor(100*(sumarElementosVectorParaPartesF(TCromSeqDin(Item1).rds.f)));
{Con 10 avanza un poco mejor la evolución}
end;
function ComparaCromoSeqResInt64(Item1, Item2: Pointer): Int64;
begin
  Result := TCromSeqDin(Item2).rds.fsumaint64-TCromSeqDin(Item1).rds.fsumaint64;
end;
(*************************** TCromSeqDin **************************************)
procedure TCromSeqDin.EliminarInstruccionesNOP;
var
  j,n:Integer;
  a:Tseq;
begin
  SetLength(a,rds.s);
  n:=0;
  for j:=0 to rds.s-1 do
  begin
    if seq[j][0]=$0 then  {Es instruccion NOP}
    begin
    end
    else
    begin
      a[n]:=seq[j];
      inc(n);
    end;
  end;
  SetLength(a,n);
  SetLength(seq,n);
  seq:=Copy(a);
  rds.s:=n;
end;
procedure TCromSeqDin.mutar;
var
  n,i:Integer;
begin
  if (rds.s=0) then Exit;
  i:=random(rds.s);

  n:=Random(700);
  if n<100 then
  begin
    mutarEliminando(i);
    Exit;
  end;
  if n<200 then
  begin
    mutarInsertando(i);
    Exit;
  end;
  if n<300 then
  begin
    mutarInvirtiendo(i);
    Exit;
  end;
  if n<400 then
  begin
    mutarAdicionando;
    Exit;
  end;
  if n<500 then
  begin
    mutarReemplazando(i);
    Exit;
  end;
  if n<600 then
  begin
    mutarInvirtiendoTodo;
    Exit;
  end;
  if n<700 then
  begin
    mutarCambiandoEstado;
    Exit;
  end;
//  if n<800 then
//  begin
//    mutarDuplicando(i);
//    Exit;
//  end;

end;
procedure TCromSeqDin.mutarEliminando(i:Integer);
var
  j:Integer;
  a:Tseq;
begin
  if rds.s=1 then Exit;
  SetLength(a,rds.s-1);
  for j:=0 to rds.s-1 do
  begin
    if j<i then a[j]:=seq[j];
    if j>i then a[j-1]:=seq[j];
  end;
  SetLength(seq,rds.s-1);
  seq:=Copy(a);
  Dec(rds.s);
  rds.p:=1;
end;
procedure TCromSeqDin.mutarInsertando(i:Integer);
var
  j:Integer;
  a:Tseq;
begin
  SetLength(a,rds.s+1);
  for j:=0 to rds.s do
  begin
    if j<i then a[j]:=seq[j];
    if j=i then a[j]:=instruccionAleatoria;
    if j>i then a[j]:=seq[j-1];
  end;
  SetLength(seq,rds.s+1);
  seq:=Copy(a);
  Inc(rds.s);
  rds.p:=2;
end;
procedure TCromSeqDin.mutarInvirtiendo(i:Integer);
var
  a:vectorInstruccion;
  anterior,posterior:Integer;
begin
  posterior:=i;
  if i=0 then
  begin
    anterior:=rds.s-1;
  end
  else
  begin
    anterior:=i-1;
  end;
  a:= seq[posterior];
  seq[posterior]:=seq[anterior];
  seq[anterior]:=a;
  rds.p:=3;
end;
procedure TCromSeqDin.mutarAdicionando;
begin
  SetLength(seq,rds.s+1);
  rds.s:=rds.s+1;
  seq[rds.s-1]:=instruccionAleatoria;
  rds.p:=4;
end;
procedure cambiarValorInmediato(var x:byte);
var
  n:integer;
  bTemp:Byte;
begin
  n:=random(8);
  bTemp:=1;
  x:=(x) xor (bTemp shl n);
end;
procedure TCromSeqDin.mutarReemplazando(i:Integer);
var
  nalea:Integer;
begin
  if   (seq[i][0]=$74) or (seq[i][0]=$78) or (seq[i][0]=$24) or (seq[i][0]=$34)
    or (seq[i][0]=$44) or (seq[i][0]=$54) or (seq[i][0]=$64) or (seq[i][0]=$94) then
  begin {MOV A,#data o MOV R0,#data}
    nalea:=Random(100);
    if nalea<70 then cambiarValorInmediato(seq[i][1])
    else seq[i]:=instruccionAleatoria;
  end
  else
  begin
    seq[i]:=instruccionAleatoria;
  end;
  rds.p:=5;
end;
procedure TCromSeqDin.mutarInvirtiendoTodo;
var
  r:Tseq;
  i,n1:Integer;
begin
  n1:=Length(seq);
  SetLength(r,n1);
  for i:=0 to n1-1 do
  begin
    r[n1-1-i]:=seq[i];
  end;
  seq:=Copy(r);
  rds.p:=6;
end;
procedure TCromSeqDin.mutarCambiandoEstado;
begin
  rds.aparece:=not(rds.aparece);
  rds.p:=7;
end;
procedure TCromSeqDin.mutarDuplicando(i:Integer);
var
  j:Integer;
  a:Tseq;
begin
  SetLength(a,rds.s+1);
  for j:=0 to rds.s do
  begin
//    if j<i then a[j]:=seq[j];
    if j<=i then a[j]:=seq[j];
    if j>i then a[j]:=seq[j-1];
  end;
//  if i=0 then
//  begin
//    a[i]:=instruccionAleatoria;
//  end
//  else
//  begin
//    a[i]:=seq[i-1];
//  end;
  SetLength(seq,rds.s+1);
  seq:=Copy(a);
  Inc(rds.s);
  rds.p:=8;
end;

procedure TCromSeqDin.colocarTamano(vS:Integer);
begin
  rds.s:=vS;
  SetLength(seq,rds.s);
end;

procedure TCromSeqDin.mostrar(var Memo:TMemo);
var
  j:Integer;
  linea:string;
begin
  Memo.Lines.Add('INSTRUCTION SEQUENCE: ');
  Memo.Lines.Add('   No  OpCODE  MNEMONIC');
  for j:=0 to rds.s-1 do
  begin
    linea:='  ';
    if j<10 then linea:=linea+' ';
    if j<100 then linea:=linea+' ';
    linea:=linea+IntToStr(j)+'  ';{Pone Numero de Fila}
    linea:=linea+vectorInstruccionAcadenaHEX(seq[j]);
    linea:=linea+'  '+intToStr(seq[j][2])+'  '+vectorInstruccionAcadenaASM(seq[j],0);

    Memo.Lines.Add(linea);
  end;
end;
procedure TCromSeqDin.copiarAdecuacion(vF:vectorParaPartesF);
begin
  rds.f:=vF;
  rds.fsuma:=Floor(sumarElementosVectorParaPartesF(rds.f));
  rds.fsumaesc:=Floor(1000*(sumarElementosVectorParaPartesF(rds.f)));
//  rds.fsumaint64:=Floor((1E12)*(sumarElementosVectorParaPartesF(rds.f)));
//  rds.fsumaint64:=Floor((1E9)*(sumarElementosVectorParaPartesF(rds.f)));
  rds.fsumaint64:=Floor((1E3)*(sumarElementosVectorParaPartesF(rds.f)));
end;
procedure TCromSeqDin.copiarSecuencia(vS:Tseq);
begin
  rds.s:=Length(vS);
  SetLength(seq,rds.s);
  seq:=Copy(vS);
end;
constructor TCromSeqDin.createAleatoriamente;
var
  tam:Integer;
begin
  rds.s:=Random(TAMANO_MAXIMO_DE_SECUENCIA_DIN-TAMANO_MINIMO_DE_SECUENCIA_DIN+1)+
                TAMANO_MINIMO_DE_SECUENCIA_DIN;
  SetLength(seq,rds.s);
  rds.p:=0;{Procedencia Multiobjetivo}
  rds.aparece:=True;{Al crearse debe aparecer en combinación}
  llenarAleatoriamente;
end;
constructor TCromSeqDin.createWithSeq(var vS:Tseq);
begin
  rds.s:=Length(vS);
  SetLength(seq,rds.s);
  seq:=Copy(vS);
end;
constructor TCromSeqDin.createWithSeqRDS(var vS:Tseq;r:RDatosSeq);
begin
  rds:=r;
  rds.s:=Length(vS);
  SetLength(seq,rds.s);
  seq:=Copy(vS);
end;
constructor TCromSeqDin.createWithSeqProcede(var vS:Tseq;p:Integer);
begin
  rds.p:=p;
  rds.aparece:=True;
  SetLength(seq,Length(vS));
  seq:=Copy(vS);
  rds.s:=Length(vS);
end;
constructor TCromSeqDin.createWithSeqF(var vS:Tseq;vF:vectorParaPartesF);
begin
  rds.s:=Length(vS);
  SetLength(seq,rds.s);
  seq:=Copy(vS);
  rds.f:=vF;
  rds.fsuma:=Floor(sumarElementosVectorParaPartesF(rds.f));
end;
constructor TCromSeqDin.createWithS(vS:Integer);
begin
  rds.s:=vS;
  SetLength(seq,rds.s);
end;
procedure TCromSeqDin.llenarAleatoriamente;
var
  i:Integer;
begin
  for i:=0 to rds.s-1 do
  begin
    seq[i]:=instruccionAleatoria;
  end;
end;
(*************************** ADECUACION CON KB ********************************)
procedure colocarValoresInicialesEnRegistros(i:Word	;var A,B,R:byte);
var
  k:Integer;
begin
  for k:=0 to 127 do { Anular el Area DI }
  begin
    microEje.pEMIC.AreaDI[k]:=0;
  end;
  with microEje.pEMIC do
  begin
    AreaSFR[direccionPSW]:=$00;
    AreaSFR[direccionSP]:=$07;
    AreaSFR[direccionP0]:=$FF;
    AreaSFR[direccionP1]:=$FF;{PARA INICIALIZACION}
//    AreaSFR[direccionP1]:=$00;{PARA MENSAJES DE TEXTO}
    AreaSFR[direccionP2]:=$FF;
    AreaSFR[direccionP3]:=$FF;
    APINS[0]:=$FF;{Pines de puertos desconectados}
    APINS[1]:=$FF; {PARA INICIALIZACION}
//    APINS[1]:=$00; {PARA MENSAJES DE TEXTO}
    APINS[2]:=$FF;
    APINS[3]:=$FF;
  end;
  //Colocar la entrada en los tres registros
  microEje.escribirConModoDirecto($00,         byte(i));{R0}
  microEje.escribirConModoDirecto($07,         byte(i));{R7} {2017}
  microEje.escribirConModoDirecto(direccionACC,byte(i));
  microEje.escribirConModoDirecto(direccionB,  byte(i));
  R:=byte(i);
  A:=byte(i);
  B:=byte(i);
end;
(******   Simulación del Teclado  ******)
procedure TCromSeqDin.mostrarResultadosPKIP;
var
  sCadtae,sCadEva,sCadtotal,sCadPor,sCadGen:cadena20;
begin
//    pormocc:=100*fsuma/(NUMERO_DE_PARTES_DE_SALIDA*NUMERO_DE_CADENAS_DE_SALIDA);
    pormocc:=100*rds.fsuma/fMoccMax;
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
    SecuenciaAMemo_PKIP_DIN_conOC(SDIAppForm.MemoResultados,SolDin);
    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
//    SDIAppForm.mostrarControlNivel1(sol.contSol.bif1);
//    SDIAppForm.mostrarControlNivel2(sol.contSol.bif2);
//    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
//    SDIAppForm.mostrarControlTransferencia(sol.pereSol.rec);
//    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
    MostrarLocalizacionDeBitsDin(SDIAppForm.MemoResultados,SolDin);
    SDIAppForm.MemoResultados.Lines.Add('==============================================================');
(*
    SDIAppForm.MemoTiempos.Lines.add(FormatDateTime('hh:mm:ss',Now)+ sCadGen+ sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' %');
*)
    {NGeneraciones NEvaluaciones Error Fsuma Porcentaje Tamano}
    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' '+inttostr(seqSize));

    SDIAppForm.MemoExper.Lines.add(IntToStr(nemocc)+'   '+FloatToStr(rds.fsuma)+'   '+IntToStr(rds.s));
    SDIAppForm.LabelAdecuacion.Caption:='f:'+FloatToStr(rds.fsuma);
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-rds.fsuma);
    SDIAppForm.LabelGeneraciones.update;

    fmocc:=rds.fsuma;
    sndPlaySound('beep_2seg.wav',SND_NODEFAULT Or SND_SYNC);
end;
procedure TCromSeqDin.AdecuacionSeqConKB;
var
  i,j,m,k:integer;
  cont:integer;
  nP,nI:vectorParaPartes;
  ff:vectorParaPartesF;
  sumafreal:Real;
  nTec:Byte;
  rint64,aint64,bint64:int64;
  numeroUltimaInstruccion:Integer;
begin
  inc(nemocc);
  valoresInicialesEnMatrizMVR_DIN(rds.s);
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    colocarValoresInicialesEnRegistros(0,regA,regB,regR);
    nTec:=mvpo[FIL_EST_ANT,i];
    for j:= 0 to rds.s-1 do
    begin
      seTransmitioSenalPorTeclado(nTec);
      realizarInstruccion(seq[j]);
      rint64:= (int64(microEje.pEMIC.AreaDI[$00]))and $0FF; //Lee R0
      aint64:= (int64(microEje.pEMIC.AreaSFR[direccionACC]))and $0FF;//Lee ACC
      bint64:= (int64(microEje.pEMIC.AreaSFR[direccionB]))and $0FF;//Lee B
      mvrDin[j][i]:= aint64 or (bint64 shl 8) or (rint64 shl 16);
      seTransmitioSenalPorTeclado(nTec);
    end;
  end;
  //Halla mejor parte
  anularVectorParaPartesF(ff);
  anularVectorParaPartes(nP);
  anularVectorParaPartes(nI);
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA-1 do{Recorre los bits del Identificador}
  begin
    for k:=0 to rds.s-1 do{Recorre la secuencia}
    begin
      for j:=0 to NUMERO_DE_PARTES_EN_MEMORIA-1 do{Recorre los registros A,B,R0}
      begin
        cont:=0;
        for m:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do{Recorre la Tabla de Identificadores}
        begin
          if mvpo[i][m]=byte((mvrDin[k][m]shr (j*NUMERO_DE_BITS_POR_PARTE))and
                        tmascaras64[NUMERO_DE_BITS_POR_PARTE]) then
          begin
            cont:=cont+1;
          end;
        end;
        if cont>ff[i] then
        begin
          ff[i]:=cont;
          nP[i]:=j;
          nI[i]:=k;
        end;
      end;
    end;
  end;
//  fsuma:=sumarElementosVectorParaPartesF(ff);
//  rds.f:=obtenerAdecuacionGAconInstruccionSalida(ff,nI);
  rds.fsuma:=Floor(sumarElementosVectorParaPartesF(ff));
//  sumafreal:=Floor(sumarElementosVectorParaPartesF(ff));

  numeroUltimaInstruccion:=vpnMaximo(nI);
  sumarConstanteAVectorParaPartesF(ff,(-0.001)*(numeroUltimaInstruccion));

  sumafreal:=sumarElementosVectorParaPartesF(ff);
  rds.fsumaesc:=Floor(sumafreal*1000);
  rds.f:=ff;

  if (rds.fsuma>fmocc)or ((rds.fsuma=fMoccMax)and(numeroUltimaInstruccion+1<seqSize)) then
  begin
    seqSize:=numeroUltimaInstruccion+1;

    SolDin.SeqSol:=Copy(seq);
//    sol.contSol:=mControl;
//    sol.pereSol:=mTransferencia;
    SolDin.rdsSol.f:=ff;
    SolDin.nPSol:=nP;
    SolDin.nISol:=nI;
    mostrarResultadosPKIP;
  end;
end;

(*************************** ADECUACION CON LCD *******************************)
procedure TCromSeqDin.mostrarResultadosLCD;
var
  sCadGen,sCadEva,sCadtotal,sCadPor,sCadTam:cadena20;
begin
    NumeroInstruccionPrimeraDiferenciaEn_DT_SolDin;
//    ActualizarFocoAtencion;
    pormocc:=100*rds.fsuma/fMoccMax;
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoResultados,SolDin);
//    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
//    SDIAppForm.mostrarControlTransferencia(SolDin.pereSol.rec);
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    SDIAppForm.mostrarDiagramaDeTiempo_DIN(SolDin.LCDSol.dt,SolDin.LCDSol.nI);
    SDIAppForm.MemoResultados.Lines.Add('========================================================================');

//    str(tamano,sCadtam);
//    str(fsuma:6:0,sCadtotal);
    str(rds.fsuma,sCadtotal);

    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);

    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' '+inttostr(seqSize));

//    SDIAppForm.MemoTiempos.Lines.add( sCadGen+ sCadEva+ sCadPor);
(*
    SDIAppForm.MemoTiempos.Lines.add(FormatDateTime('hh:mm:ss',Now)+ sCadGen+ sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' %'+
                      ' '+intToStr(SolDin.rdsSol.e)+
                      ' '+intToStr(SolDin.rdsSol.u)+
                      ' '+intToStr(SolDin.rdsSol.s)+
                      ' '+intToStr(SolDin.rdsSol.p));
*)
(*
                      ' L: '+intToStr(MOQIGP.P1t.PopList.Count)+
                      ' '+intToStr(MOQIGP.P2t.PopList.Count)+
                      ' '+intToStr(MOQIGP.Qt.PopList.Count));
*)
    SDIAppForm.MemoExper.Lines.add(IntToStr(nemocc)+'   '+FloatToStr(rds.fsuma)+'   '+IntToStr(rds.s));
//    SDIAppForm.MemoExper.Lines.add(sCadEva+'  '+sCadtotal);
    SDIAppForm.LabelAdecuacion.Caption:='f:'+sCadtotal;
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-rds.fsuma);
    SDIAppForm.LabelGeneraciones.update;
end;
procedure TCromSeqDin.mostrarResultadosLCDconTM(iIndividuo:Integer);
var
  sCadGen,sCadEva,sCadtotal,sCadPor,sCadTam:cadena20;
begin
//    NumeroInstruccionPrimeraDiferencia;
    pormocc:=100*rds.fsuma/fMoccMax;
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoResultados,SolDin);
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
//    mostrarMatrizDiagramasDeTiempo_DIN(SDIAppForm.MemoResultados,mregLCD);
//    SDIAppForm.mostrarDiagramaDeTiempo_DIN(SolDin.LCDSol.dt,SolDin.LCDSol.nI);
    SDIAppForm.MemoResultados.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6));
    SDIAppForm.MemoResultados.Lines.Add('========================================================================');
    str(rds.fsuma,sCadtotal);
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);

    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' '+inttostr(seqSize)+' '+//intToStr(SolDin.diferencia)+
                      numFCad(rds.p,6));

(*
    SDIAppForm.MemoTiempos.Lines.add(sCadGen+ sCadEva+ sCadPor+
               ' '+intToStr(SolDin.diferencia));
*)
(*
    SDIAppForm.MemoTiempos.Lines.add(FormatDateTime('hh:mm:ss',Now)+ sCadGen+ sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' % '+intToStr(SolDin.diferencia)+
                      ' '+intToStr(GASeqDin.P1t.PopList.Count)+
                      ' '+intToStr(GASeqDin.P2t.PopList.Count)+
                      ' '+intToStr(GASeqDin.Qt.PopList.Count));
*)
    SDIAppForm.MemoExper.Lines.add(IntToStr(nemocc)+'   '+FloatToStr(rds.fsuma)+'   '+IntToStr(rds.s));
    SDIAppForm.LabelAdecuacion.Caption:='f:'+sCadtotal;
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-rds.fsuma);
    SDIAppForm.LabelGeneraciones.update;
end;
procedure TCromSeqDin.mostrarResultadosLCDconTM_QIGP(iIndividuo:Integer);
var
  sCadGen,sCadEva,sCadtotal,sCadPor,sCadTam:cadena20;
begin
//    NumeroInstruccionPrimeraDiferencia;
    pormocc:=100*rds.fsuma/fMoccMax;
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoResultados,SolDin);
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    mostrarMatrizDiagramasDeTiempo_DIN(SDIAppForm.MemoResultados,mregLCD);
//    SDIAppForm.mostrarDiagramaDeTiempo_DIN(SolDin.LCDSol.dt,SolDin.LCDSol.nI);
    SDIAppForm.MemoResultados.Lines.Add('========================================================================');
    str(rds.fsuma,sCadtotal);
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);
    SDIAppForm.MemoTiempos.Lines.add(FormatDateTime('hh:mm:ss',Now)+ sCadGen+ sCadEva+
                      numFCad(fMoccMax-rds.fsuma,6)+ numFCad(rds.fsuma,6)+
                      sCadPor+' % '+intToStr(SolDin.diferencia)+
                      ' '+intToStr(SolDin.rdsSol.e)+
                      ' '+intToStr(SolDin.rdsSol.u)+
                      ' '+intToStr(SolDin.rdsSol.s)+
                      ' '+intToStr(SolDin.rdsSol.p)+

                      ' L: '+intToStr(MOQIGP.P1t.PopList.Count)+
                      ' '+intToStr(MOQIGP.P2t.PopList.Count)+
                      ' '+intToStr(MOQIGP.Qt.PopList.Count));

    SDIAppForm.MemoExper.Lines.add(IntToStr(nemocc)+'   '+FloatToStr(rds.fsuma)+'   '+IntToStr(rds.s));
    SDIAppForm.LabelAdecuacion.Caption:='f:'+sCadtotal;
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-rds.fsuma);
    SDIAppForm.LabelGeneraciones.update;
end;
procedure TCromSeqDin.AdecuacionSeqConLCD;
var
  i,j,numeroUltimaInstruccion,nuevoTamano:integer;
  nTec:Integer;
  sumafreal:Real;
begin
  inc(nemocc);
  inc(nesnuevo);

  for i:=0 to 0 do
  begin
    colocarValoresInicialesEnRegistros(0,regA,regB,regR);   (*CAMBIO 2016*)
    borrarRegistroLCD(regLCD);
    for j:= 0 to rds.s-1 do
    begin
      realizarInstruccion(seq[j]);
      MonitorDeDiagramaDeTiempoDeLCD(j);{2016}
    end;
  end;
  rds.f:=calcularAdecuacionDT(regLCD);

  rds.u:=NoUltimaInstruccionEnUnDT(regLCD.nI);
  rds.e:=regLCD.nPrimeraDiferenciaEnDT;

  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsuma:=Floor(sumafreal);
  sumarConstanteAVectorParaPartesF(rds.f,(-0.001)*(rds.u));

  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsumaesc:=Floor(sumafreal*1000);

  if (rds.fsuma>fmocc) or ((rds.fsuma=fMoccMax)and(rds.u+1<seqSize)) then
  begin
    seqSize:=rds.u+1;

    nesnuevo:=0;
    SolDin.SeqSol:=Copy(seq);
    SolDin.rdsSol:=rds;
//    SolDin.rdsSol.f:=rds.f;
    SolDin.LCDSol:=regLCD;
    mostrarResultadosLCD;
    fmocc:=rds.fsuma;
    sndPlaySound('beep_2seg.wav',SND_NODEFAULT Or SND_SYNC);
  end;
end;
procedure NumeroDePrimeraDiferencia(i:Integer;var rdt:rLCD);
var
  j:Integer;
begin
  rdt.nPrimeraDiferenciaEnDT:=NUMERO_GRANDE_SMALLINT;{Significa que al inicio todos son iguales}
  for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
  begin
    if (dtsObjetivo[i,j]<>rdt.dt[j]) then
    begin
      rdt.nPrimeraDiferenciaEnDT:=rdt.nI[j];
      Exit;
    end;
  end;

end;
procedure TCromSeqDin.AdecuacionSeqConTM(iIndividuo:Integer);
var
  i,j:integer;
  nTec:Integer;
  fcad:vectorParaPartesF;{Adecuacion de cadena}
  diferenciaEnFin,numeroUltimaInstruccion,numeroPrimeraDiferencia:Integer;
  sumafreal,Error:Real;
  nuevoTamano:Integer;
begin
  inc(nemocc);
  anularVectorParaPartesF(rds.f);
  SetLength(mregLCD,NUMERO_DE_CADENAS_DE_SALIDA);
  borrarMatrizRegistroLCD(mregLCD);
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    colocarValoresInicialesEnRegistros(vObjetivo[i,COL_ENTRADA],regA,regB,regR);
    borrarRegistroLCD(regLCD);
    for j:= 0 to rds.s-1 do
    begin
      realizarInstruccion(seq[j]);
      MonitorDeDiagramaDeTiempoDeLCDparaTM(j);{Resultado en regLCD}
//      MonitorDeDiagramaDeTiempoDe7SEGparaTM(j);{Resultado en regLCD}
    end;
    fcad:=calcularAdecuacionDTparaTM(i,regLCD);
    NumeroDePrimeraDiferencia(i,regLCD);{Primera Diferencia se pone en regLCD.nPrimeraDiferenciaEnDT}
    sumarVectoresParaPartesF(rds.f,fcad);
    mregLCD[i]:=regLCD;
  end;
  diferenciaEnFin:=HallaDiferenciaEnFinDeDT(numeroUltimaInstruccion,numeroPrimeraDiferencia);
  rds.e:=numeroPrimeraDiferencia;
  rds.u:=numeroUltimaInstruccion;

  sumarConstanteAVectorParaPartesF(rds.f,(-1)*diferenciaEnFin);
  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsuma:=Floor(sumafreal);
  if rds.fsuma<0 then rds.fsuma:=0;
  sumarConstanteAVectorParaPartesF(rds.f,(-0.001)*numeroUltimaInstruccion);
  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsumaesc:=Floor(sumafreal*1000);//1000);
  if (rds.fsuma>fmocc) or ((rds.fsuma=fMoccMax)and(rds.u+1<seqSize)) then
  begin
    seqSize:=rds.u+1;

    SetLength(SolDin.SeqSol,Length(seq));
    SolDin.SeqSol:=Copy(seq);
    SolDin.rdsSol:=rds;
    SolDin.LCDSol:=regLCD;
    SolDin.diferencia:=diferenciaEnFin;
    fmocc:=rds.fsuma;
    if CBII=TP_QIGP then
    begin
      mostrarResultadosLCDconTM_QIGP(iIndividuo);
    end
    else
    begin
      mostrarResultadosLCDconTM(iIndividuo);
    end;
    sndPlaySound('beep_2seg.wav',SND_NODEFAULT Or SND_SYNC);
  end;
end;
(******************** TPopSeqDin ************************)
function TPopSeqDin.sumaLongitudes:string;
var
  i:integer;
  a:integer;
begin
  a:=0;
  for i:= 0 to popList.count-1 do
  begin
    a:=a+length((TObject(popList[i])as TCromSeqDin).seq);
  end;
  result:=IntToStr(a);
end;
function TPopSeqDin.calcularCombinacionLineal:Real;
var
  i:integer;
  a:Real;
begin
  a:=0.0;
  for i:= 0 to popList.count-1 do
  begin
    a:=a+Real((TObject(popList[i])as TCromSeqDin).rds.fsuma);
  end;
  result:=a/popList.count;
end;
procedure TPopSeqDin.funcionAdecuacionDeCadaProgramaDeLista;
var
  i:integer;
begin
  for i:= 0 to popList.count-1 do
  begin
    case CBII of
    LCD_GP,LCD_QIGP:begin
        (TObject(popList[i])as TCromSeqDin).AdecuacionSeqConLCD;
      end;
    PKIP_GP, PKIP_QIGP:begin
        (TObject(popList[i])as TCromSeqDin).AdecuacionSeqConKB;
      end;
    TP_GP,TP_QIGP:begin
        (TObject(popList[i])as TCromSeqDin).AdecuacionSeqConTM(i);
      end;
    end;
  end;
end;
procedure TPopSeqDin.ordenarPorTamano;
begin
  PopList.Sort(@ComparaTamanoCromoSeq);
end;
procedure TPopSeqDin.conservarSoloUnaCantidad(n:Integer);
var
  m:Integer;
begin
  m:=PopList.Count;
//  if (n<0)or(n>=m) then Exit;
  while PopList.Count> n do
  begin
    (TObject(PopList[PopList.Count-1])as TCromSeqDin).destroy;
    PopList.Delete(PopList.Count-1);
    PopList.capacity:=PopList.count;
  end;
end;
procedure TPopSeqDin.ordenarPorAdecuacion;
begin
  if PopList.Count=0 then Exit;
//  PopList.Sort(@ComparaAdecuacionCromoSeq);
  PopList.Sort(@ComparaCromoSeqResInt64);
  if PopList.Count>POBLACION_MAXIMA then
  begin {Eliminar los ultimos}
    while PopList.Count> POBLACION_MAXIMA do
    begin
      (TObject(PopList[PopList.Count-1])as TCromSeqDin).destroy;
      PopList.Delete(PopList.Count-1);
    end;
  end;
end;
procedure TPopSeqDin.ordenarPorAdecuacionSumandoF;
begin
  if PopList.Count=0 then Exit;
  PopList.Sort(@ComparaCromoSeqResInt64);
  if PopList.Count>POBLACION_MAXIMA then
  begin {Eliminar los ultimos}
    while PopList.Count> POBLACION_MAXIMA do
    begin
      (TObject(PopList[PopList.Count-1])as TCromSeqDin).destroy;
      PopList.Delete(PopList.Count-1);
    end;
  end;
end;
procedure TPopSeqDin.iniciar;
begin
  PopList:=TList.create;
end;
procedure TPopSeqDin.llenarAleatoriamente;
var
  i:integer;
begin
  eliminarItems;
  PopList.clear;
  PopList.capacity:=PopList.count;
  for i:= 0 to TAMANO_POBLACION_DIN - 1 do
  begin
    PopList.add(TCromSeqDin.createAleatoriamente);
  end;
end;
procedure TPopSeqDin.eliminarItems;
var
  i:integer;
begin
  for i:= PopList.count-1 downto 0 do
  begin
    (TObject(PopList[i])as TCromSeqDin).destroy;
  end;
end;
procedure TPopSeqDin.eliminarItemsNuevo;
var
  i:integer;
begin
  for i:= PopList.count-1 downto 0 do
  begin
    (TObject(PopList[i])as TCromSeqDin).destroy;
  end;
  PopList.clear;
  PopList.capacity:=PopList.count;
end;
procedure TPopSeqDin.mutarPoblacion;
var
  i,tamano:integer;
  nAlea,probabilidadMutar:integer;
begin
  tamano:=PopList.count;
  for i:=0 to tamano-1 do
  begin 
    probabilidadMutar:=random(100);
    if probabilidadMutar<PROBABILIDAD_DE_MUTACION_DIN then
    begin
      ((TObject(PopList[i])as TCromSeqDin).mutar);
    end;
  end;
end;
function TPopSeqDin.contarCuanticos:Integer;
var
  i,a:integer;
begin
  a:=0;
  for i:=0 to PopList.count-1 do
  begin
    if (TObject(PopList[i])as TCromSeqDin).rds.p=0 then inc(a);
  end;
  result:=a;
end;
procedure TPopSeqDin.mostrar(var memo:TMemo);
var
  i:integer;
begin
  for i:=0 to PopList.count-1 do
  begin
    Memo.Lines.Add(IntToStr(i));
    (TObject(PopList[i])as TCromSeqDin).mostrar(memo);
  end;
end;
procedure TPopSeqDin.mostrarAdecuacion(var memo:TMemo);
var
  i:integer;
  cad:string;
begin
  cad:='';
  for i:=0 to PopList.count-1 do
  begin
    cad:=cad+IntToStr((TObject(PopList[i])as TCromSeqDin).rds.fsumaesc)+' ';
  end;
  Memo.Lines.Add(cad);
end;
(******************** TClassAlgoritmoEvolutivoPrograma ************************)
procedure TGASeqDin.iniciar;
begin
  P1t:=TPopSeqDin.create; P1t.iniciar;
  P2t:=TPopSeqDin.create; P2t.iniciar;
  Qt:=TPopSeqDin.create;  Qt.iniciar;
  Q1t:=TPopSeqDin.create; Q1t.iniciar;
  Q2t:=TPopSeqDin.create; Q2t.iniciar;
  Dt:=TPopSeqDin.create;  Dt.iniciar;
  Dpaso5:=TPopSeqDin.create;Dpaso5.iniciar;
  PRt:=TPopSeqDin.create;   PRt.iniciar;
  
end;
procedure TGASeqDin.finalizar;
begin
  P1t.PopList.Free;  P1t.destroy;
  P2t.PopList.Free;  P2t.destroy;
  Qt.PopList.Free;   Qt.destroy;
  Q1t.PopList.Free;  Q1t.destroy;
  Q2t.PopList.Free;  Q2t.destroy;
  Dt.PopList.Free;   Dt.destroy;
  Dpaso5.PopList.Free;  Dpaso5.destroy;
  PRt.PopList.Free;  PRt.destroy;
end;
procedure TGASeqDin.iniciarAlgoritmo;
begin
  fmocc:=0;
  tmocc:=0;
  nemocc:=0;
  pormocc:=0;

  P1t.llenarAleatoriamente;
  P2t.llenarAleatoriamente;

  P1t.funcionAdecuacionDeCadaProgramaDeLista;
  P2t.funcionAdecuacionDeCadaProgramaDeLista;

end;
procedure TGASeqDin.iniciarAlgoritmoMOCC;
begin
  P1t.llenarAleatoriamente;
  P2t.llenarAleatoriamente;

  fmocc:=0;
  tmocc:=0;
  nemocc:=0;
  pormocc:=0;

end;
procedure TGASeqDin.iniciarParaCC;
begin
  fmocc:=0;
  tmocc:=0;
  nemocc:=0;
  pormocc:=0;
  P1t.llenarAleatoriamente;
  P2t.llenarAleatoriamente;
end;
procedure TGASeqDin.hallarUnReprentante;
begin
  PRt.eliminarItems;
  PRt.PopList.clear;
  PRt.PopList.capacity:=PRt.PopList.count;
  PRt.PopList.add(TCromSeqDin.createWithSeq(
    (TObject(P1t.PopList[0])as TCromSeqDin).seq));
end;
procedure TGASeqDin.hallarReprentantes;
var
  i,n,falta:integer;
begin
  PRt.eliminarItems;
  PRt.PopList.clear;
  PRt.PopList.capacity:=PRt.PopList.count;

  if P1t.PopList.count+P2t.PopList.count > NUMERO_DE_REPRESENTANTES_DIN then
  begin
    n:=NUMERO_DE_REPRESENTANTES_DIN;
    if P1t.PopList.count<NUMERO_DE_REPRESENTANTES_DIN then n:=P1t.PopList.count;
    for i:= 0 to n-1 do// 0 to n-1 do
    begin
      PRt.PopList.add(TCromSeqDin.createWithSeq(
        (TObject(P1t.PopList[i])as TCromSeqDin).seq));
    end;
    falta:=NUMERO_DE_REPRESENTANTES_DIN - n;
    if falta<=0 then exit;
    n:=falta;
    if P2t.PopList.count<falta then n:=P2t.PopList.count;
    for i:= 0 to n-1 do //0 to n-1 do
    begin
      PRt.PopList.add(TCromSeqDin.createWithSeq(
        (TObject(P2t.PopList[i])as TCromSeqDin).seq));
    end;
  end
  else
  begin
    n:=P1t.PopList.count;
    for i:= 0 to n-1 do// 0 to n-1 do
    begin
      PRt.PopList.add(TCromSeqDin.createWithSeq(
        (TObject(P1t.PopList[i])as TCromSeqDin).seq));
    end;
    n:=P2t.PopList.count;
    for i:= 0 to n-1 do //0 to n-1 do
    begin
      PRt.PopList.add(TCromSeqDin.createWithSeq(
        (TObject(P2t.PopList[i])as TCromSeqDin).seq));
    end;
  end;
end;
procedure TGASeqDin.hallarReprentantesSoloIndices;
var
  i,n,falta:integer;
  nLista,nIndividuo,nIndice:Integer;
begin
  nIndice:=0;
  if P1t.PopList.count+P2t.PopList.count > NUMERO_DE_REPRESENTANTES_DIN then
  begin
    n:=NUMERO_DE_REPRESENTANTES_DIN;
    if P1t.PopList.count<NUMERO_DE_REPRESENTANTES_DIN then n:=P1t.PopList.count;
    for i:= 0 to n-1 do// 0 to n-1 do
    begin
      nLista:=1;
      nIndividuo:=i;
      PRtnl[nIndice]:=nLista;
      PRtni[nIndice]:=nIndividuo;
      nIndice:=nIndice+1;
    end;
    falta:=NUMERO_DE_REPRESENTANTES_DIN - n;
    if falta<=0 then exit;
    n:=falta;
    if P2t.PopList.count<falta then n:=P2t.PopList.count;
    for i:= 0 to n-1 do //0 to n-1 do
    begin
      nLista:=2;
      nIndividuo:=i;
      PRtnl[nIndice]:=nLista;
      PRtni[nIndice]:=nIndividuo;
      nIndice:=nIndice+1;
    end;
  end
  else
  begin
    n:=P1t.PopList.count;
    for i:= 0 to n-1 do// 0 to n-1 do
    begin
      nLista:=1;
      nIndividuo:=i;
      PRtnl[nIndice]:=nLista;
      PRtni[nIndice]:=nIndividuo;
      nIndice:=nIndice+1;
    end;
    n:=P2t.PopList.count;
    for i:= 0 to n-1 do //0 to n-1 do
    begin
      nLista:=2;
      nIndividuo:=i;
      PRtnl[nIndice]:=nLista;
      PRtni[nIndice]:=nIndividuo;
      nIndice:=nIndice+1;
    end;
  end;
end;
procedure TGASeqDin.hallarReprentantesSoloIndicesAleatorios;
var
  i,k,nParejas:integer;
  a,b,aa,bb:arregloEntero;
begin
//  nParejas := Ceil(NUMERO_DE_REPRESENTANTES_DIN div 2);
  nParejas := NUMERO_DE_REPRESENTANTES_DIN div 2;
  {Seleccionar padres}
  indicesDePadresEnSegmentos(P1t.PopList.Count,P2t.PopList.Count,nParejas,a,b,aa,bb);
  k:=0;
  for i:=0 to nParejas-1 do
  begin
    PRtni[k]:=a[i];
    PRtnl[k]:=aa[i];
    inc(k);
    PRtni[k]:=b[i];
    PRtnl[k]:=bb[i];
    inc(k);
  end;
end;
procedure realizarCrossoverIntercambiandoColas(var x1,x2:Tseq);
var
  n1,n2,n,t1,t2,i:Integer;
  p:Real;
  y:Tseq;
begin {Intercambio de instrucciones a partir de una posición aleatoria}
  p:=random(1000)/1000;
  t1:=Length(x1);
  t2:=Length(x2);
  n1:=Floor(p*(Length(x1)-1));
  n2:=Floor(p*(Length(x2)-1));
  n:=Min(n1,n2);
  if t1=t2 then
  begin
    y:=Copy(x1);
    for i:=n to t1-1 do
    begin
      x1[i]:=x2[i];
    end;
    for i:=n to t1-1 do
    begin
      x2[i]:=y[i];
    end;
    Exit;
  end;
  if t1>t2 then
  begin
    y:=Copy(x1);
    SetLength(x1,t2);
    for i:=n to t2-1 do
    begin
      x1[i]:=x2[i];
    end;
    SetLength(x2,t1);
    for i:=n to t1-1 do
    begin
      x2[i]:=y[i];
    end;
    Exit;
  end;
  if t2>t1 then
  begin
    y:=Copy(x2);
    SetLength(x2,t1);
    for i:=n to t1-1 do
    begin
      x2[i]:=x1[i];
    end;
    SetLength(x1,t2);
    for i:=n to t2-1 do
    begin
      x1[i]:=y[i];
    end;
    Exit;
  end;
end;
procedure realizarCrossoverIntercambiandoInstruccion(var x1,x2:Tseq);
var
  vi:vectorInstruccion;
  n1,n2:Integer;
  p:Real;
begin {Intercambio de instrucciones de la misma posición aleatoria}
  p:=random(1000)/1000;
  n1:=Floor(p*(Length(x1)-1));
  n2:=Floor(p*(Length(x2)-1));
  n1:=Min(n1,n2);
  n2:=n1;
  vi:= x1[n1];
  x1[n1]:= x2[n2];
  x2[n2]:= vi;
end;
procedure realizarCrossoverIntercambiandoInstruccionCP(var x1,x2:Tseq);
var
  vi:vectorInstruccion;
  n1,n2:Integer;
  p1,p2:Real;
begin {Intercambio de instrucciones de la misma posición aleatoria}
  p1:=random(1000)/1000;
  p2:=random(1000)/1000;
  n1:=Floor(p1*(Length(x1)-1));
  n2:=Floor(p2*(Length(x2)-1));
//  n1:=Min(n1,n2);
//  n2:=n1;
  vi:= x1[n1];
  x1[n1]:= x2[n2];
  x2[n2]:= vi;
end;
procedure realizarCrossover(var x1,x2:Tseq);
var
  n:Integer;
begin
  n:=Random(100);
  if n<PROBABILIDAD_INTERCAMBIO_DE_COLAS_EN_CROSSOVER then
  begin
    realizarCrossoverIntercambiandoColas(x1,x2);
    Exit;
  end;
  if n<100 then
  begin
    realizarCrossoverIntercambiandoInstruccionCP(x1,x2);
    Exit;
  end;
end;
procedure crossoverSecuencias(var x,y:TCromSeqDin);
begin
  realizarCrossover(x.seq,y.seq);
end;
procedure TGASeqDin.crossover;
var
  i,nParejas:integer;
  xa,xb:Tseq;
  a,b,aa,bb:arregloEntero;
begin
  Qt.eliminarItems;
  Qt.PopList.clear;
  Qt.PopList.capacity:=Qt.PopList.count;
  nParejas := ceil((0.75 *P1t.PopList.Count  +
                    0.25 *P2t.PopList.Count )*PROBABILIDAD_EN_SELECCION_DE_PADRES);
  if (nParejas>NUMERO_DE_PAREJAS_MAXIMO)and APLICACION_ACTIVADA then
    nParejas:=NUMERO_DE_PAREJAS_MAXIMO;

  {Seleccionar padres}
  indicesDePadresEnSegmentos(P1t.PopList.Count,P2t.PopList.Count,nParejas,a,b,aa,bb);

  for i:=0 to nParejas-1 do
  begin
    if aa[i]=1 then
    begin
      SetLength(xa,Length((TObject(P1t.PopList[a[i]])as TCromSeqDin).seq));
      xa:=Copy((TObject(P1t.PopList[a[i]])as TCromSeqDin).seq);
    end
    else
    begin
      SetLength(xa,Length((TObject(P2t.PopList[a[i]])as TCromSeqDin).seq));
      xa:=Copy((TObject(P2t.PopList[a[i]])as TCromSeqDin).seq);
    end;
    if bb[i]=1 then
    begin
      SetLength(xb,Length((TObject(P1t.PopList[b[i]])as TCromSeqDin).seq));
      xb:=Copy((TObject(P1t.PopList[b[i]])as TCromSeqDin).seq);
    end
    else
    begin
      SetLength(xb,Length((TObject(P2t.PopList[b[i]])as TCromSeqDin).seq));
      xb:=Copy((TObject(P2t.PopList[b[i]])as TCromSeqDin).seq);
    end;
    realizarCrossover(xa,xb);
    Qt.PopList.add(TCromSeqDin.createWithSeq(xa));
    Qt.PopList.add(TCromSeqDin.createWithSeq(xb));
  end;
end;
procedure TGASeqDin.mutacion;//Mutacion en Qt
begin
  Qt.mutarPoblacion;
end;
procedure TGASeqDin.limpiarQ1tQ2t;
begin
  Q1t.eliminarItems;
  Q1t.PopList.clear;
  Q1t.PopList.capacity:=Q1t.PopList.count;
  Q2t.eliminarItems;
  Q2t.PopList.clear;
  Q2t.PopList.capacity:=Q2t.PopList.count;
end;
procedure TGASeqDin.seleccionDePadres;
var
  i,nParejas:integer;
  a,b,aa,bb:arregloEntero;
begin
  limpiarQ1tQ2t;

//  Q1t.eliminarItems;
//  Q1t.PopList.clear;
//  Q1t.PopList.capacity:=Q1t.PopList.count;
//  Q2t.eliminarItems;
//  Q2t.PopList.clear;
//  Q2t.PopList.capacity:=Q2t.PopList.count;

  nParejas := ceil((0.75 *P1t.PopList.Count  +
                    0.25 *P2t.PopList.Count )*PROBABILIDAD_EN_SELECCION_DE_PADRES);
  if (nParejas>NUMERO_DE_PAREJAS_MAXIMO)and APLICACION_ACTIVADA then
    nParejas:=NUMERO_DE_PAREJAS_MAXIMO;
  {Seleccionar padres}
  indicesDePadresEnSegmentos(P1t.PopList.Count,P2t.PopList.Count,nParejas,a,b,aa,bb);

  for i:=0 to nParejas-1 do
  begin
    if aa[i]=1 then
    begin
      Q1t.PopList.add(TCromSeqDin.createWithSeqRDS(
        (TObject(P1t.PopList[a[i]])as TCromSeqDin).seq,
        (TObject(P1t.PopList[a[i]])as TCromSeqDin).rds));
    end
    else
    begin
      Q1t.PopList.add(TCromSeqDin.createWithSeqRDS(
        (TObject(P2t.PopList[a[i]])as TCromSeqDin).seq,
        (TObject(P2t.PopList[a[i]])as TCromSeqDin).rds));
    end;
    if bb[i]=1 then
    begin
      Q2t.PopList.add(TCromSeqDin.createWithSeqRDS(
        (TObject(P1t.PopList[b[i]])as TCromSeqDin).seq,
        (TObject(P1t.PopList[b[i]])as TCromSeqDin).rds));
    end
    else
    begin
      Q2t.PopList.add(TCromSeqDin.createWithSeqRDS(
        (TObject(P2t.PopList[b[i]])as TCromSeqDin).seq,
        (TObject(P2t.PopList[b[i]])as TCromSeqDin).rds));
    end;
  end;
end;
procedure TGASeqDin.realizarCrossoverIntercambiandoInstruccionEnQ1tQ2t(i:Integer);
var
  x1,x2:RDatosSeq;
  r1,r2:Tseq;
  n1,n2,n:Integer;
  vi:vectorInstruccion;
begin
  x1:=(TObject(Q1t.PopList[i])as TCromSeqDin).rds;
  x2:=(TObject(Q2t.PopList[i])as TCromSeqDin).rds;
  r1:=Copy((TObject(Q1t.PopList[i])as TCromSeqDin).seq);
  r2:=Copy((TObject(Q2t.PopList[i])as TCromSeqDin).seq);
  if (x1.s=0)or(x1.e>=x1.s) then Exit;
  if (x2.s=0)or(x2.e>=x2.s) then Exit;
  n1:=random(x1.s);
  n2:=random(x2.s);

  vi:=r1[n1];
  r1[n1]:= r2[n2];
  r2[n2]:= vi;
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(r1,10));
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(r2,10));
end;

procedure TGASeqDin.realizarCrossoverIntercambiandoColasEnQ1tQ2t(i:Integer);
var
  x1,x2:RDatosSeq;
  r1,r2,y:Tseq;
  n1,n2,n,t1,t2:Integer;
  vi:vectorInstruccion;
begin
  x1:=(TObject(Q1t.PopList[i])as TCromSeqDin).rds;
  x2:=(TObject(Q2t.PopList[i])as TCromSeqDin).rds;
  r1:=Copy((TObject(Q1t.PopList[i])as TCromSeqDin).seq);
  r2:=Copy((TObject(Q2t.PopList[i])as TCromSeqDin).seq);
  if (x1.s=0)or(x1.e>=x1.s) then Exit;
  if (x2.s=0)or(x2.e>=x2.s) then Exit;
  n1:=random(x1.s);
  n2:=random(x2.s);

  n:=Min(n1,n2);
  t1:=Length(r1);
  t2:=Length(r2);
  if t1=t2 then
  begin
    SetLength(y,t1);
    y:=Copy(r1);
    for i:=n to t1-1 do
    begin
      r1[i]:=r2[i];
    end;
    for i:=n to t1-1 do
    begin
      r2[i]:=y[i];
    end;
  end
  else
  begin
    if t1>t2 then
    begin
      SetLength(y,t1);
      y:=Copy(r1);
      SetLength(r1,t2);
      for i:=n to t2-1 do
      begin
        r1[i]:=r2[i];
      end;
      SetLength(r2,t1);
      for i:=n to t1-1 do
      begin
        r2[i]:=y[i];
      end;
    end
    else
    begin {t2>t1}
      SetLength(y,t2);
      y:=Copy(r2);
      SetLength(r2,t1);
      for i:=n to t1-1 do
      begin
        r2[i]:=r1[i];
      end;
      SetLength(r1,t2);
      for i:=n to t2-1 do
      begin
        r1[i]:=y[i];
      end;
    end;
  end;
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(r1,11));
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(r2,11));
end;
procedure TGASeqDin.realizarCrossoverIntercambiandoBloquesEnQ1tQ2t(ii:Integer);
var
  x1,x2:RDatosSeq;
  r1,r2,y1,y2:Tseq;
  n1,n2,n,t1,t2:Integer;
  tb1,tb2,nt1,nt2,i1,i2,i:Integer;
  vi:vectorInstruccion;
begin

  x1:=(TObject(Q1t.PopList[ii])as TCromSeqDin).rds;
  x2:=(TObject(Q2t.PopList[ii])as TCromSeqDin).rds;
  r1:=Copy((TObject(Q1t.PopList[ii])as TCromSeqDin).seq);
  r2:=Copy((TObject(Q2t.PopList[ii])as TCromSeqDin).seq);

(* Para probar se uso esta parte
  x1:=(TObject(P1t.PopList[ii])as TCromSeqDin).rds;
  x2:=(TObject(P2t.PopList[ii])as TCromSeqDin).rds;
  r1:=Copy((TObject(P1t.PopList[ii])as TCromSeqDin).seq);
  r2:=Copy((TObject(P2t.PopList[ii])as TCromSeqDin).seq);
*)

  if (x1.s=0) then Exit;
  if (x2.s=0) then Exit;
  n1:=random(x1.s);{Posición de Inicio de Bloque en x1}
  n2:=random(x2.s);{Posición de Inicio de Bloque en x2}
//  tb1:=random(x1.s-n1);{Tamaño de Bloque en x1}
//  tb2:=random(x2.s-n2);{Tamaño de Bloque en x2}
  tb1:=1+(random(x1.s-n1) mod 3);{Tamaño de Bloque en x1}
  tb2:=1+(random(x2.s-n2) mod 3);{Tamaño de Bloque en x2}

//  if (tb1=0) then tb1:=1; Se probó no es necesario
//  if (tb2=0) then tb2:=1;

  t1:=Length(r1);
  t2:=Length(r2);
  nt1:=t1+tb2-tb1;
  nt2:=t2+tb1-tb2;

  {Formamos y1}
  SetLength(y1,nt1);
  for i:=0 to n1-1 do
  begin
    y1[i]:=r1[i];
  end;
  i2:=n2;
  for i:=n1 to n1+tb2-1 do {Copia bloque de r2 a y1}
  begin
    y1[i]:=r2[i2];
    inc(i2);
  end;
  i1:=n1+tb1;
  for i:=n1+tb2 to nt1-1 do
  begin
    y1[i]:=r1[i1];
    inc(i1);
  end;
  {Formamos y2}
  SetLength(y2,nt2);
  for i:=0 to n2-1 do
  begin
    y2[i]:=r2[i];
  end;
  i1:=n1;
  for i:=n2 to n2+tb1-1 do {Copia bloque de r1 a y2}
  begin
    y2[i]:=r1[i1];
    inc(i1);
  end;
  i2:=n2+tb2;
  for i:=n2+tb1 to nt2-1 do
  begin
    y2[i]:=r2[i2];
    inc(i2);
  end;
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(y1,12));
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(y2,12));
end;
procedure TGASeqDin.realizarCrossoverInsertandoBloquesEnQ1tQ2t(ii:Integer);
var
  x1,x2:RDatosSeq;
  r1,r2,y1,y2:Tseq;
  n1,n2,n,t1,t2:Integer;
  tb1,tb2,nt1,nt2,i1,i2,i:Integer;
  vi:vectorInstruccion;
begin

  x1:=(TObject(Q1t.PopList[ii])as TCromSeqDin).rds;
  x2:=(TObject(Q2t.PopList[ii])as TCromSeqDin).rds;
  r1:=Copy((TObject(Q1t.PopList[ii])as TCromSeqDin).seq);
  r2:=Copy((TObject(Q2t.PopList[ii])as TCromSeqDin).seq);

(* Para probar se uso esta parte
  x1:=(TObject(P1t.PopList[ii])as TCromSeqDin).rds;
  x2:=(TObject(P2t.PopList[ii])as TCromSeqDin).rds;
  r1:=Copy((TObject(P1t.PopList[ii])as TCromSeqDin).seq);
  r2:=Copy((TObject(P2t.PopList[ii])as TCromSeqDin).seq);
*)

  if (x1.s=0) then Exit;
  if (x2.s=0) then Exit;
  n1:=random(x1.s);{Posición de Inicio de Bloque en x1}
  n2:=random(x2.s);{Posición de Inicio de Bloque en x2}
//  tb1:=random(x1.s-n1);{Tamaño de Bloque en x1}
//  tb2:=random(x2.s-n2);{Tamaño de Bloque en x2}
  tb1:=1+(random(x1.s-n1) mod 3);{Tamaño de Bloque en x1}
  tb2:=1+(random(x2.s-n2) mod 3);{Tamaño de Bloque en x2}

//  if (tb1=0) then tb1:=1; Se probó no es necesario
//  if (tb2=0) then tb2:=1;

  t1:=Length(r1);
  t2:=Length(r2);
  nt1:=t1+tb2;
  nt2:=t2+tb1;

  {Formamos y1}
  SetLength(y1,nt1);
  for i:=0 to n1-1 do
  begin
    y1[i]:=r1[i];
  end;
  i2:=n2;
  for i:=n1 to n1+tb2-1 do {Copia bloque de r2 a y1}
  begin
    y1[i]:=r2[i2];
    inc(i2);
  end;
  i1:=n1;//n1+tb1;
  for i:=n1+tb2 to nt1-1 do
  begin
    y1[i]:=r1[i1];
    inc(i1);
  end;
  {Formamos y2}
  SetLength(y2,nt2);
  for i:=0 to n2-1 do
  begin
    y2[i]:=r2[i];
  end;
  i1:=n1;
  for i:=n2 to n2+tb1-1 do {Copia bloque de r1 a y2}
  begin
    y2[i]:=r1[i1];
    inc(i1);
  end;
  i2:=n2;//n2+tb2;
  for i:=n2+tb1 to nt2-1 do
  begin
    y2[i]:=r2[i2];
    inc(i2);
  end;
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(y1,13));
  Qt.PopList.add(TCromSeqDin.createWithSeqProcede(y2,13));
end;

//procedure TGASeqDin.variacion;
//var
//  i:integer;
//  prob1,prob2:Real;
//begin
//  Qt.eliminarItems;
//  Qt.PopList.clear;
//  Qt.PopList.capacity:=Qt.PopList.count;
//  for i:=0 to Q1t.PopList.Count-1 do
//  begin
//    prob1:=Random;
//    if prob1<PROBABILIDAD_DE_CRUZAMIENTO then
//    begin
//      prob2:=Random;
//      if prob2<0.7 then
//      begin
//        realizarCrossoverIntercambiandoInstruccionEnQ1tQ2t(i);
//      end
//      else
//      begin
//        realizarCrossoverIntercambiandoColasEnQ1tQ2t(i);
//      end;
//    end
//    else
//    begin
//      (TObject(Q1t.PopList[i])as TCromSeqDin).mutar;
//      (TObject(Q2t.PopList[i])as TCromSeqDin).mutar;
//      Qt.PopList.add(TCromSeqDin.createWithSeqProcede(
//        (TObject(Q1t.PopList[i])as TCromSeqDin).seq,
//        (TObject(Q1t.PopList[i])as TCromSeqDin).rds.p));
//      Qt.PopList.add(TCromSeqDin.createWithSeqProcede(
//        (TObject(Q2t.PopList[i])as TCromSeqDin).seq,
//        (TObject(Q2t.PopList[i])as TCromSeqDin).rds.p));
//    end;
//  end;
//end;
procedure TGASeqDin.variacion;
var
  i:integer;
  prob1,prob2:Real;
begin
  Qt.eliminarItems;
  Qt.PopList.clear;
  Qt.PopList.capacity:=Qt.PopList.count;
  for i:=0 to Q1t.PopList.Count-1 do
  begin
    prob1:=Random;
    if prob1<PROBABILIDAD_DE_CRUZAMIENTO then
    begin {Cruzamiento}
      prob2:=Random;
      if prob2<0.7 then
      begin
        realizarCrossoverIntercambiandoInstruccionEnQ1tQ2t(i);
      end
      else
      begin
        if prob2<0.85 then//0.8 then
        begin
          realizarCrossoverIntercambiandoColasEnQ1tQ2t(i);
        end
        else
        begin
          if prob2<0.95 then//0.95 then
          begin
            realizarCrossoverIntercambiandoBloquesEnQ1tQ2t(i);{2019-A}
          end
          else
          begin
            realizarCrossoverInsertandoBloquesEnQ1tQ2t(i);{2019-A}
          end;
        end;
      end;
    end
    else
    begin {Mutación}
      (TObject(Q1t.PopList[i])as TCromSeqDin).mutar;
      (TObject(Q2t.PopList[i])as TCromSeqDin).mutar;
      Qt.PopList.add(TCromSeqDin.createWithSeqProcede(
        (TObject(Q1t.PopList[i])as TCromSeqDin).seq,
        (TObject(Q1t.PopList[i])as TCromSeqDin).rds.p));
      Qt.PopList.add(TCromSeqDin.createWithSeqProcede(
        (TObject(Q2t.PopList[i])as TCromSeqDin).seq,
        (TObject(Q2t.PopList[i])as TCromSeqDin).rds.p));
    end;
  end;
end;

function TGASeqDin.datos:string;
begin
  Result:='P1t:'+inttostr(P1t.PopList.Count)+' '+P1t.sumaLongitudes+' | '+
          'P2t:'+inttostr(P2t.PopList.Count)+' '+P2t.sumaLongitudes;
end;

procedure TGASeqDin.EjecutarMientrasNoHaySolucion;
begin
  seleccionDePadres;
  variacion;

  Qt.funcionAdecuacionDeCadaProgramaDeLista;

  insertarListaSecuencia(Qt,P1t,Dt);
  insertarListaSecuencia(Dt,P2t,Dpaso5);

  P1t.ordenarPorAdecuacion;
  P2t.ordenarPorAdecuacion;

end;
end.
