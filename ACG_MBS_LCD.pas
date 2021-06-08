unit ACG_MBS_LCD;
interface
uses
  Classes, sysUtils,math,StdCtrls, MMSystem,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,
  mcsAVR,mcsAVRcpu;
const
  PUERTO_LCD:Npuerto = C;

procedure MonitorDeDiagramaDeTiempoDeLCDparaTM(i:Integer);
function calcularAdecuacionDTparaTM(fila:Integer;var rdt:rLCD):vectorParaPartesF;
function HallaDiferenciaEnFinDeDT(var maximo:Integer;var minPrimeraDiferencia:Integer):integer;
procedure MonitorDeDiagramaDeTiempoDeLCD(i:Integer);
function NoUltimaInstruccionEnUnDT(var nIx:vectorValoresSalidaB):integer;
function NumeroInstruccionPrimeraDiferenciaEn_DT_SolDin:Integer;
function AdecuacionDeSecuenciaEn_LCD_INI_CC(var seq:Tseq;var dimCC:TdimCC):vectorParaPartesF;
procedure IniciarCC_LCD;
procedure MostrarResultadosEn_LCD_INI_CC;

implementation
uses ACG_MAIN;
procedure IniciarCC_LCD;
begin
  NUMERO_MAXIMO_DE_EVALUACIONES:=200000;//14000000;
  {No hay Registros de Entrada ni de Salida}
end;
procedure PrimerasInstrucciones_ASM_en_LCD_INI(var Memo:TMemo);
begin
  Memo.Lines.add('    LDI R20,0XFF');
  Memo.Lines.add('    OUT DDRC,R20');
  Memo.Lines.add('    LDI R20,0X00');
  Memo.Lines.add('    OUT PORTC,R20');
  Memo.Lines.add('    LDI R20,0X80');
  Memo.Lines.add('    OUT SREG,R20');
  Memo.Lines.add('    LDI R20,0');
  Memo.Lines.add('    MOV R0,R20');
  Memo.Lines.add('    MOV R1,R20');
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
  cpu.DDR[PUERTO_LCD]:=$FF;{Configurado como salidas}
  cpu.PORT[PUERTO_LCD]:=$00;{00 Es el valor inicial del puerto al energizar}
  cpu.r[0]:=byte(i);
  cpu.r[1]:=byte(i);
  cpu.r[20]:=byte(i);
end;
function AdecuacionDeSecuenciaEn_LCD_INI_CC(var seq:Tseq;var dimCC:TdimCC):vectorParaPartesF;
var
  i,j,numeroUltimaInstruccion,nuevoTamano:integer;
  nTec:Integer;
  sumafreal:Real;
  rds:RDatosSeq;
begin
  inc(nemocc);
  inc(nesnuevo);
  rds.s:=Length(seq);

  for i:=0 to 0 do
  begin
    colocarValoresIniciales_LCD(AVRcpu,0);{Terminado}
    borrarRegistroLCD(regLCD);
    for j:= 0 to rds.s-1 do
    begin
      AVRcpu.ejecutarInstruccion(seq[j],0);
      MonitorDeDiagramaDeTiempoDeLCD(j);{2016}
    end;
  end;
  rds.f:=calcularAdecuacionDT(regLCD);

  rds.u:=NoUltimaInstruccionEnUnDT(regLCD.nI);
  rds.e:=regLCD.nPrimeraDiferenciaEnDT;

  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsuma:=Floor(sumafreal);
  sumarConstanteAVectorParaPartesF(rds.f,(-0.001)*(rds.u));
  Result:=rds.f;
  sumafreal:=sumarElementosVectorParaPartesF(rds.f);
  rds.fsumaesc:=Floor(sumafreal*1000);

  if (rds.fsuma>fmocc) or ((rds.fsuma=fMoccMax)and(rds.u+1<seqSize)) then
  begin
    seqSize:=rds.u+1;

    nesnuevo:=0;
    SolDin.SeqSol:=Copy(seq);
    SolDin.dimCC:=dimCC;
    SolDin.rdsSol:=rds;
    SolDin.LCDSol:=regLCD;
    MostrarResultadosEn_LCD_INI_CC;
    fmocc:=rds.fsuma;
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
procedure MonitorDeDiagramaDeTiempoDeLCD(i:Integer);
var
  P1actual:Byte;
begin
  if regLCD.nIntervalo >= NUMERO_DE_CADENAS_DE_SALIDA-1 then Exit;
  if regLCD.nTiempo=0 then
  begin {Es tiempo 0 (Primera instruccion)}{esta en el Intervalo 0}
    P1actual:=(AVRcpu.PORT[PUERTO_LCD])and($FE);//and($FC);
    regLCD.dt[0]:=P1actual;
  end
  else
  begin
    P1actual:=(AVRcpu.PORT[PUERTO_LCD])and($FE);//and($FC);
    if P1actual = regLCD.P1anterior then
    begin

    end
    else
    begin {Es diferente y se debe registrar}
      inc(regLCD.nIntervalo);
      P1actual:=(AVRcpu.PORT[PUERTO_LCD])and($FE);//and($FC);
      regLCD.dt[regLCD.nIntervalo]:=P1actual;
      regLCD.nI[regLCD.nIntervalo]:=i;{2016}
    end;
  end;
  Inc(regLCD.nTiempo);
  regLCD.nUltimaInstDeDT:=i;
  regLCD.P1anterior:=P1actual;
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
function calcularAdecuacionDTparaTM(fila:Integer;var rdt:rLCD):vectorParaPartesF;
var
  i,j:Integer;
  f:vectorParaPartesF;
  a,g,b:Byte;
  bb:SmallInt;
begin
  anularVectorParaPartesF(f);
  for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
  begin
    a:=dtsObjetivo[fila,j];
    bb:=rdt.dt[j];
    if bb>=0 then {Si bb=-1 no se cuenta}
    begin
      b:=Byte(bb);
      for i:=0 to 7 do
      begin
        g:=byte((not(((a shr i)and 1)xor((b shr i)and 1)))and 1);
        if g=1 then
        begin
          f[i]:=f[i]+(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-j);
//          f[i]:=f[i]+2*(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-j);
//          f[i]:=f[i]+1.0;
        end;
      end;
    end;
  end;
  Result:=f;
end;
procedure MonitorDeDiagramaDeTiempoDeLCDparaTM(i:Integer);
var
  P1actual:Byte;
begin
  if (regLCD.nIntervalo >= NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1) then Exit;
  {En la anterior línea es vital el -1: NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1}
  if (regLCD.nTiempo=0) then
  begin {Es tiempo 0 (Primera instruccion)}{esta en el Intervalo 0}
    P1actual:=(microEje.pEMIC.AreaSFR[direccionP1])and($FC);
    regLCD.dt[0]:=P1actual;
  end
  else
  begin
    P1actual:=(microEje.pEMIC.AreaSFR[direccionP1])and($FC);
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
procedure MostrarResultadosEn_LCD_INI_CC;
var
  sCadGen,sCadEva,sCadtotal,sCadPor,sCadTam:cadena20;
  i,tam,nCiclos,nBytes:Integer;
  secuencia:Tseq;
begin
    NumeroInstruccionPrimeraDiferenciaEn_DT_SolDin;
    pormocc:=100*SolDin.rdsSol.fsuma/fMoccMax;
    SDIAppForm.MemoResultados.Lines.Add('EVALUATION: '+IntToStr(nemocc));
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    SDIAppForm.MemoSol.Clear;
    PrimerasInstrucciones_ASM_en_LCD_INI(SDIAppForm.MemoSol);
    MatrizProgramaAMemo_DIN_conOC(SDIAppForm.MemoSol,SolDin);
    SDIAppForm.MemoSol.Lines.add('    '+'RET');
    SDIAppForm.MemoResultados.Lines.Add('------------------------------------------------------------------------');
    mostrarDiagramaDeTiempo_DIN(SDIAppForm.MemoResultados,SolDin.LCDSol.dt,SolDin.LCDSol.nI);
    SDIAppForm.MemoResultados.Lines.Add('========================================================================');
    str(SolDin.rdsSol.fsuma,sCadtotal);
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
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-SolDin.rdsSol.fsuma);
    SDIAppForm.LabelGeneraciones.update;
end;
end.

