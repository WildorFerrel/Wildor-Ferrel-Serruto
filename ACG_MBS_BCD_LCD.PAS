unit ACG_MBS_BCD_LCD;
interface
uses
  Classes, sysUtils,math,StdCtrls, MMSystem,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,ACG_MBS_SEQUENCE_DINAMIC,
  ACG_MBS_LCD,
  mcsAVR,mcsAVRcpu;
const
  PUERTO_BCD_LCD:Npuerto = C;

procedure MonitorDeDiagramaDeTiempoDeLCDparaTM(i:Integer);
//procedure MonitorDeDiagramaDeTiempoDe7SEGparaTM(i:Integer);
//function calcularAdecuacionDTparaTM(fila:Integer;var rdt:rLCD):vectorParaPartesF;
function HallaDiferenciaEnFinDeDT(var maximo:Integer;var minPrimeraDiferencia:Integer):integer;
//procedure MonitorDeDiagramaDeTiempoDeLCD(i:Integer);
function NoUltimaInstruccionEnUnDT(var nIx:vectorValoresSalidaB):integer;
function NumeroInstruccionPrimeraDiferenciaEn_DT_SolDin:Integer;
function AdecuacionDeSecuenciaEn_BCD_LCD_CC(var mProg:Tseq; {BCD a LCD}
           var nI:vectorParaPartes;dimCC:TdimCC):vectorParaPartesF;
//procedure colocarValoresIniciales_LCD(var cpu:TmcsAVR;i:Integer);
//procedure PrimerasInstrucciones_ASM_en_LCD_INI(var Memo:TMemo);
procedure IniciarCC_BCD_LCD;
//procedure MostrarResultadosEn_LCD_INI_CC;

implementation
uses ACG_MAIN;
procedure IniciarCC_BCD_LCD;
begin
  NUMERO_MAXIMO_DE_EVALUACIONES:=15000000;//100000;//14000000;
  {No hay Registros de Entrada ni de Salida}
end;
procedure PrimerasInstrucciones_ASM_en_BCD_LCD(var Memo:TMemo);
begin
//  Memo.Lines.Add('    CALL DELAY');
  Memo.Lines.add('    LDI R20,0XFF');
  Memo.Lines.add('    OUT DDRC,R20');
  Memo.Lines.add('    LDI R20,0X00');
  Memo.Lines.add('    OUT PORTC,R20');
  Memo.Lines.add('    LDI R20,0X80');
  Memo.Lines.add('    OUT SREG,R20');
  Memo.Lines.add('    MOV R20,R0');{En R0 esta el numero a displayar}
  Memo.Lines.add('    MOV R1,R0');
end;
procedure colocarValoresIniciales_LCD(var cpu:TmcsAVR;i:Integer);
var
  k:Integer;
begin
  for k:=0 to CAPACIDAD_MEMORIA_DE_DATOS-1 do
  begin
    cpu.r[k]:=0;
  end;
  cpu.SREG:=$80;
  cpu.DDR[PUERTO_BCD_LCD]:=$FF;{Configurado como salidas}
  cpu.PORT[PUERTO_BCD_LCD]:=$00;{00 Es el valor inicial del puerto al energizar}
  cpu.r[0]:=byte(i);
  cpu.r[1]:=byte(i);
  cpu.r[20]:=byte(i);
end;
procedure MaximoMinimoEnFinDeDTconIndicesIzquierdos(var maximo,minimo,minPrimeraDiferencia:Integer;
          var IndicesIzquierdos:vectorParaPartesF;var iminPrimeraDiferencia:Integer);
var
  i,j,valor,pd:Integer;
begin
  minimo:=NoUltimaInstruccionEnUnDT(mregLCD[0].nI);
  minPrimeraDiferencia:=mregLCD[0].nPrimeraDiferenciaEnDT;
  iminPrimeraDiferencia:=mregLCD[0].iPrimeraDiferenciaEnDT;
  IndicesIzquierdos:=mregLCD[0].indicesIzquierdos;
  maximo:=minimo;
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    valor:=NoUltimaInstruccionEnUnDT(mregLCD[i].nI);
    if valor>maximo then maximo:=valor;
    if valor<minimo then minimo:=valor;
    pd:=mregLCD[i].nPrimeraDiferenciaEnDT;
    if pd<minPrimeraDiferencia then
    begin
      minPrimeraDiferencia:=pd;
      iminPrimeraDiferencia:=mregLCD[i].iPrimeraDiferenciaEnDT;;
    end;
    for j:=0 to 7 do
    begin
      if mregLCD[i].indicesIzquierdos[j] < IndicesIzquierdos[j] then
      begin
        IndicesIzquierdos[j]:=mregLCD[i].indicesIzquierdos[j];
      end;
    end;
  end;
end;
function diferenciasEnCadaBitDeDT:vectorParaPartesF;
var
  i,j,suma:Integer;
  minVector,maxVector,difVector:vectorParaPartesF;
begin
  for i:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 do
  begin
    minVector[i] := mregLCD[0].nI[i];
    maxVector[i] := mregLCD[0].nI[i];
  end;
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 do
    begin
      if mregLCD[i].nI[j]<minVector[j] then
      begin
        minVector[j]:=mregLCD[i].nI[j];
      end;
      if mregLCD[i].nI[j]>maxVector[j] then
      begin
        maxVector[j]:=mregLCD[i].nI[j];
      end;
    end;
  end;
  for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA - 1 do
  begin
//    Result[j]:=(-0.01)*Abs(maxVector[j]-minVector[j]);
    Result[j]:=Abs(maxVector[j]-minVector[j]);
  end;
end;
procedure mostrarResultadosLCDconTM(var rds: RDatosSeq);
var
  sCadGen,sCadEva,sCadtotal,sCadPor,sCadTam:cadena20;
  scad:string;
  i,tam,nCiclos,nBytes:Integer;
  secuencia:Tseq;
begin
//    NumeroInstruccionPrimeraDiferencia;
    pormocc:=100*rds.fsuma/fMoccMax;
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoResultados,SolDin);
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    SDIAppForm.MemoSol.Clear;
    PrimerasInstrucciones_ASM_en_BCD_LCD(SDIAppForm.MemoSol);
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoSol,SolDin);
    SDIAppForm.MemoSol.Lines.add('    '+'RET');
    scad:='';
    for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
    begin
      scad:=scad+numCad(SolDin.dimCC[i],4);
    end;
    SDIAppForm.MemoResultados.Lines.add(scad);
    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
    SDIAppForm.MemoResultados.Lines.add('Diferencias: Max-Min');
    SDIAppForm.MemoResultados.Lines.add(cadenaDeVectorParaPartesDTF(vectorDifLCD));
    SDIAppForm.MemoResultados.Lines.Add('--------------------------------------------------------------');
    SDIAppForm.MemoResultados.Lines.Add('FITNESS:         '+cadenaDeVectorParaPartesF(SolDin.rdsSol.f));
    SDIAppForm.MemoResultados.Lines.Add('TOTAL FITNESS:'+
      numFCad(sumarElementosVectorParaPartesF(SolDin.rdsSol.f),6));
    SDIAppForm.MemoResultados.Lines.Add('========================================================================');
    str(rds.fsuma,sCadtotal);
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);
{}
    tam:=SDIAppForm.MemoSol.Lines.Count;
    MemoAseq(SDIAppForm.MemoSol,secuencia,SDIAppForm.memoHEX);
    tam:=Length(secuencia);
    calcularCiclosYbytesDeSecuencia(ISetAVR,secuencia,nCiclos,nBytes);
    {NGeneraciones NEvaluaciones Error Fsuma Porcentaje Tamano No Lineas nBytes nCiclos}
    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-SolDin.rdsSol.fsuma,6)+ numFCad(SolDin.rdsSol.fsuma,6)+
                      sCadPor+' '+numFCad(seqSize,6)+numFCad(tam,6)+
                      numFCad(nBytes,6)+numFCad(nCiclos,6));
    capturarEstadistica(sCadGen,sCadEva,
                      numFCad(fMoccMax-SolDin.rdsSol.fsuma,6),numFCad(SolDin.rdsSol.fsuma,6),
                      sCadPor,numFCad(seqSize,6),numFCad(tam,6),
                      numFCad(nBytes,6),numFCad(nCiclos,6),
                      IntToStr(fMoccMax));
    SDIAppForm.LabelAdecuacion.Caption:='f:'+sCadtotal;
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-rds.fsuma);
    SDIAppForm.LabelGeneraciones.update;
end;
function AdecuacionDeSecuenciaEn_BCD_LCD_CC(var mProg:Tseq; {BCD a LCD}
           var nI:vectorParaPartes;dimCC:TdimCC):vectorParaPartesF;
var
  rds: RDatosSeq;
  i,j:integer;
  nTec:Integer;
  fcad :vectorParaPartesF;{Adecuacion de cadena}
  IndicesIzquierdos,diferenciasPorBitDeDT_F:vectorParaPartesF;
  diferenciaEnFin,numeroUltimaInstruccion,numeroPrimeraDiferencia:Integer;
  sumafreal,Error,difMax:Real;
  nuevoTamano,minimoEnFin:Integer;
begin
  inc(nemocc);

  rds.s:=Length(mProg);

  anularVectorParaPartesF(rds.f);
  SetLength(mregLCD,NUMERO_DE_CADENAS_DE_SALIDA);
  borrarMatrizRegistroLCD(mregLCD);
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    colocarValoresIniciales_LCD(AVRcpu,vObjetivo[i,COL_ENTRADA]);
    borrarRegistroLCD(regLCD);
    for j:= 0 to rds.s-1 do
    begin
      AVRcpu.ejecutarInstruccion(mProg[j],0);
      MonitorDeDiagramaDeTiempoDeLCDparaTM(j);{Resultado en regLCD}
    end;
    fcad:=calcularAdecuacionDTparaTM(i,regLCD);
    NumeroDePrimeraDiferencia(i,regLCD);{Primera Diferencia se pone en regLCD.nPrimeraDiferenciaEnDT}
    sumarVectoresParaPartesF(rds.f,fcad);
    mregLCD[i]:=regLCD;
  end;
  MaximoMinimoEnFinDeDTconIndicesIzquierdos(numeroUltimaInstruccion,minimoEnFin,
    numeroPrimeraDiferencia,IndicesIzquierdos,rds.ie);
  rds.e:=numeroPrimeraDiferencia;
  rds.iei:=IndicesIzquierdos;
  rds.u:=numeroUltimaInstruccion;
  rds.m:=minimoEnFin;
  diferenciaEnFin:=numeroUltimaInstruccion-minimoEnFin;
  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsuma:=Floor(sumafreal);
  if rds.fsuma<0 then rds.fsuma:=0;
  anularVectorParaPartesDTF(diferenciasPorBitDeDT_F); //NUEVO
  diferenciasPorBitDeDT_F:=diferenciasEnCadaBitDeDT;   //NUEVO
  difMax:=vpnMaximoDTF(diferenciasPorBitDeDT_F);     //NUEVO
  vectorDifLCD:=diferenciasPorBitDeDT_F;
  sumarConstanteAVectorParaPartesF(rds.f,(-0.01)*difMax);

  sumarConstanteAVectorParaPartesF(rds.f,(-0.01)*numeroUltimaInstruccion);

//   sumarConstanteAVectorParaPartesF(rds.f,rds.ie); Con esta linea tambien funciona

  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsumaesc:=Floor(sumafreal*1000);//1000);
  Result:=rds.f;
  if (rds.fsuma>fmocc) or ((rds.fsuma=fMoccMax)and(rds.u+1<seqSize)) then
  begin
    seqSize:=rds.u+1;

    SetLength(SolDin.SeqSol,Length(mProg));
    SolDin.dimCC:=dimCC;
    SolDin.SeqSol:=Copy(mProg);
    SolDin.rdsSol:=rds;
    SolDin.LCDSol:=regLCD;
    SolDin.diferencia:=diferenciaEnFin;
    fmocc:=rds.fsuma;
    mostrarResultadosLCDconTM(rds);
    sndPlaySound('beep_2seg.wav',SND_NODEFAULT Or SND_SYNC);
  end;
end;
function NumeroInstruccionPrimeraDiferenciaEn_DT_SolDin:Integer;
var
  j:Integer;
begin
  Result:=-1;
  SolDin.LCDSol.nPrimeraDiferenciaEnDT:=-1;{Significa que al inicio todos son iguales}
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    if (vObjetivo[j,COL_SALIDA]<>SolDin.LCDSol.dt[j]) then
    begin
      SolDin.LCDSol.nPrimeraDiferenciaEnDT:=SolDin.LCDSol.nI[j];
      Result:=SolDin.LCDSol.nI[j];
      Exit;
    end;
  end;
end;
function NoUltimaInstruccionEnUnDT(var nIx:vectorValoresSalidaB):integer;
var
  i,valor:Integer;
begin
  for i:=NUMERO_DE_CADENAS_DE_SALIDA-1 downto 0 do
  begin
    valor:=nIx[i];
    if valor>0 then
    begin
      Result:=valor;
      Exit;
    end;
  end;
  Result:=0;
end;
function HallaDiferenciaEnFinDeDT(var maximo:Integer;var minPrimeraDiferencia:Integer):integer;
var
  minimo,i,valor,pd:Integer;
begin
  minimo:=NoUltimaInstruccionEnUnDT(mregLCD[0].nI);
  minPrimeraDiferencia:=mregLCD[0].nPrimeraDiferenciaEnDT;
  maximo:=minimo;
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    valor:=NoUltimaInstruccionEnUnDT(mregLCD[i].nI);
    if valor>maximo then maximo:=valor;
    if valor<minimo then minimo:=valor;
    pd:=mregLCD[i].nPrimeraDiferenciaEnDT;
    if pd<minPrimeraDiferencia then minPrimeraDiferencia:=pd;
  end;
  Result:=maximo-minimo;
end;
procedure MonitorDeDiagramaDeTiempoDeLCDparaTM(i:Integer);
var
  P1actual:Byte;
begin
  if (regLCD.nIntervalo >= NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1) then Exit;
  {En la anterior línea es vital el -1: NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1}
  if (regLCD.nTiempo=0) then
  begin {Es tiempo 0 (Primera instruccion)}{esta en el Intervalo 0}
    P1actual:=(AVRcpu.PORT[PUERTO_BCD_LCD])and($FE);//($FC);
    regLCD.dt[0]:=P1actual;
  end
  else
  begin
    P1actual:=(AVRcpu.PORT[PUERTO_BCD_LCD])and($FE);//($FC);
    if (P1actual = regLCD.P1anterior) then
    begin

    end
    else
    begin {P1actual <> regLCD.P1anterior}
      inc(regLCD.nIntervalo);
      regLCD.dt[regLCD.nIntervalo]:=P1actual;
      regLCD.nI[regLCD.nIntervalo]:=i;{2016}
      regLCD.nInstruccionUltimoCambio:=i;{2017}
    end;
  end;
  Inc(regLCD.nTiempo);
  regLCD.nUltimaInstDeDT:=i;
  regLCD.P1anterior:=P1actual;
end;
procedure MonitorDeDiagramaDeTiempoDe7SEGparaTM(i:Integer);
var
  P1actual:Byte;
begin
  if (regLCD.nIntervalo >= NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1) then Exit;
  {En la anterior línea es vital el -1: NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1}
  if (regLCD.nTiempo=0) then
  begin {Es tiempo 0 (Primera instruccion)}{esta en el Intervalo 0}
    P1actual:=(microEje.pEMIC.AreaSFR[direccionP1]);//and($FC);
    regLCD.dt[0]:=P1actual;
  end
  else
  begin
    P1actual:=(microEje.pEMIC.AreaSFR[direccionP1]);//and($FC);
    if (P1actual = regLCD.P1anterior) then
    begin

    end
    else
    begin {P1actual <> regLCD.P1anterior}
      inc(regLCD.nIntervalo);
      regLCD.dt[regLCD.nIntervalo]:=P1actual;
      regLCD.nI[regLCD.nIntervalo]:=i;{2016}

      regLCD.nInstruccionUltimoCambio:=i;{2017}
    end;
  end;
  Inc(regLCD.nTiempo);
  regLCD.nUltimaInstDeDT:=i;
  regLCD.P1anterior:=P1actual;
end;
procedure mostrarDiagramaDeTiempo_DIN(var memo:TMemo; x:vectorValoresSalidaSI;
                                              var y:vectorValoresSalidaB);
var
  j:integer;
  linea:cadena100;
begin
  Memo.Lines.add('Target Time Diagram:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(vObjetivo[j,COL_SALIDA],4);
  end;
  Memo.Lines.add(linea);
  Memo.Lines.add('Time Diagram:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(x[j],4);
  end;
  Memo.Lines.add(linea);
  Memo.Lines.add('Instruction Number:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(y[j],4);
  end;
  Memo.Lines.add(linea);
  Memo.Lines.Add('------------------------------------------------------------------------');
  Memo.Lines.add('Instruction number of the first mismatch in TD: '+
                            IntToStr(solDin.LCDSol.nPrimeraDiferenciaEnDT));
  Memo.Lines.add('Number of the last instruction in TD: '+
                            IntToStr(solDin.LCDSol.nUltimaInstDeDT));
  Memo.Lines.add('Number of the last interval in TD: '+
                            IntToStr(solDin.LCDSol.nIntervalo));
end;
end.

