unit ACG_MBS_CONV;

interface
uses
  Classes, sysUtils,math,StdCtrls, MMSystem, Grids,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  mcsAVR,mcsAVRcpu,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC;

procedure mostrarResultadosEn_KB_SCAN_CC(fsuma:real);
procedure mostrarAlgunosResultadosEn_KB_SCAN_CC(fsuma:real);
procedure RelocalizarBitsDeSolucion(var Memo:TMemo; pSol,iSol:vectorParaPartes);
//procedure PrimerasInstruccionesEnProgramaASM(var Memo:TMemo);
//procedure obtenerProgramaASM(var sol:tipoSolucionDin;var sga:TStringGrid;var memo:TMemo);
//
//function seTransmitioSenalPorTeclado(nTecla:byte):Boolean;
//function valoresDePinesEnConexionConTecladoValidos(var cpu:TmcsAVR;
//           nTecla:byte):Boolean;
function AdecuacionDeSecuenciaEn_CONV_CC(var mProg:Tseq;
           var nI:vectorParaPartes;dimCC:TdimCC):vectorParaPartesF;
procedure IniciarCC_CONV;

implementation
uses ACG_MAIN;
procedure IniciarCC_CONV;
begin
//  NUMERO_MAXIMO_DE_EVALUACIONES:=4000000;//100000;//500000;//4000000;
  {No hay Registros de Entrada}
//  RegistroEntradaLOW:=R0;
//  nBitsRegistroEntradaLOW:=8;
  {Registros de Salida}
  if REGISTRO_DE_SALIDA_BYTE_BAJO = 'R0' then RegistroSalidaLOW:=R0;
  if REGISTRO_DE_SALIDA_BYTE_BAJO = 'R1' then RegistroSalidaLOW:=R1;
  if NUMERO_DE_PARTES_DE_SALIDA <= 8 then
  begin
    nBitsRegistroSalidaLOW:=NUMERO_DE_PARTES_DE_SALIDA;
  end
  else begin
    nBitsRegistroSalidaLOW:=8;
  end;

end;
procedure PrimerasInstruccionesEnProgramaASM(var Memo:TMemo);
begin
  Memo.Lines.add('    LDI R20,0X80');
  Memo.Lines.add('    OUT SREG,R20');
  Memo.Lines.add('    MOV R20,R0');
  if NUMERO_DE_PARTES_DE_ENTRADA<=8 then  // WFS 2020B
  begin
    Memo.Lines.add('    MOV R1,R0');
  end;
end;
procedure colocarValoresIniciales_KB(var cpu:TmcsAVR;i:Word);
var
  k:Integer;
begin
  for k:=0 to CAPACIDAD_MEMORIA_DE_DATOS-1 do
  begin
    cpu.r[k]:=0;
  end;
  cpu.SREG:=$80;
  if NUMERO_DE_PARTES_DE_ENTRADA <=8 then
  begin
    cpu.r[0]:=byte(i);
    cpu.r[1]:=byte(i);
    cpu.r[20]:=byte(i);
  end
  else
  begin // WFS 2020B
    cpu.r[0]:=i mod 256;
    cpu.r[1]:=i shr 8;
    cpu.r[20]:=cpu.r[0];
  end;
end;
function AdecuacionDeSecuenciaEn_CONV_CC(var mProg:Tseq;
           var nI:vectorParaPartes;dimCC:TdimCC):vectorParaPartesF;
var
  i,j,m,k, s:integer;
  cont:integer;
  nP:vectorParaPartes;
  ff:vectorParaPartesF;
  sumafreal,fsumaesc:Real;
//  valorEntrada:Byte;
  valorEntrada:Word; // WFS 2020B
  rint64,aint64,bint64:int64;
  numeroUltimaInstruccion:Integer;
  fsuma:real;
begin
  inc(nemocc);

  s:=Length(mProg);
  valoresInicialesEnMatrizMVR_DIN(s);
  for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    valorEntrada:=mvpo[FIL_EST_ANT,i];
    colocarValoresIniciales_KB(AVRcpu,valorEntrada);{Terminado}
    for j:= 0 to s-1 do
    begin
      AVRcpu.ejecutarInstruccion(mProg[j],CODIGO_NINGUNA_TECLA_PRESIONADA);
      rint64:= (int64(AVRcpu.r[20]))and $0FF; //Lee R0
      aint64:= (int64(AVRcpu.r[0]))and $0FF;//Lee ACC
      bint64:= (int64(AVRcpu.r[1]))and $0FF;//Lee B
      mvrDin[j][i]:= aint64 or (bint64 shl 8) or (rint64 shl 16);
//      if then
//      begin
//      end
//      else
//      begin
//        anularVectorParaPartes(nI);
//        anularVectorParaPartesF(Result);
//        Exit;
//      end;
    end;
  end;
  //Halla mejor parte
  anularVectorParaPartesF(ff);
  anularVectorParaPartes(nP);
  anularVectorParaPartes(nI);
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA-1 do{Recorre los bits del Identificador}
  begin
    for k:=0 to s-1 do{Recorre la secuencia}
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
  fsuma:=Floor(sumarElementosVectorParaPartesF(ff));

  numeroUltimaInstruccion:=vpnMaximo(nI);

  sumarConstanteAVectorParaPartesF(ff,(-0.001)*(numeroUltimaInstruccion));

  sumafreal:=sumarElementosVectorParaPartesF(ff);
  fsumaesc:=Floor(sumafreal*1000);
  Result:=ff;
  if (fsuma=fMoccMax) then
  begin
    haySolucion:=True;
  end;
  if (fsuma>fmocc)or ((fsuma=fMoccMax)and(numeroUltimaInstruccion+1<seqSize)) then
  begin
    seqSize:=numeroUltimaInstruccion+1;
    SolDin.SeqSol:=Copy(mProg);
    SolDin.dimCC:=dimCC;
    SolDin.rdsSol.f:=ff;
    SolDin.nPSol:=nP;
    SolDin.nISol:=nI;
    if CantidadProgramasGenerados=1 then
    begin
      sndPlaySound('beep_2seg.wav',SND_NODEFAULT Or SND_SYNC);
      mostrarResultadosEn_KB_SCAN_CC(fsuma);
    end
    else
    begin
      mostrarAlgunosResultadosEn_KB_SCAN_CC(fsuma);
    end;

  end;
end;

procedure ponerEnSG(var sga:TStringGrid;col:Integer;fil:Integer;s:string);
var
  sAux:string;
begin
  sAux:=sga.cells[col,fil];
  if sAux='' then
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      sga.cells[col,fil]:=s+':';
    end
    else
    begin
      sga.cells[col,fil]:=s;
    end;
  end
  else
  begin
    if (col=N_ETIQ_BIF1)or(col=N_ETIQ_BIF2)or(col=N_ETIQ_JMP2)or(col=N_ETIQ_JMP1) then
    begin
      sga.cells[col,fil]:=sAux+';'+s+':';
    end
    else
    begin
      sga.cells[col,fil]:=sAux+';'+s;
    end;
  end;
end;
procedure llenarSGconSolucion(var sga:TStringGrid;var pSol,iSol:vectorParaPartes);
var
  i,nRegSol:integer;
begin
  nRegSol:=DIR_REG_SOLUCION;//80;//$50;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA-1 do
  begin
    case pSol[i] of
    0,1,2,3,4,5,6,7:begin {A}
        ponerEnSG(sga,NSOL_A,iSol[i]+1,'MOV R'+IntToStr(nRegSol+i)+',R0');
      end;
    8,9,10,11,12,13,14,15:begin {B}
        ponerEnSG(sga,NSOL_B,iSol[i]+1,'MOV R'+IntToStr(nRegSol+i)+',R1');
      end;
    16,17,18,19,20,21,22,23:begin {R0}
        ponerEnSG(sga,NSOL_R,iSol[i]+1,'MOV R'+IntToStr(nRegSol+i)+',R20');
      end;
    end;
  end;
end;
procedure SecuenciaAStringGrid(var sol: tipoSolucionDin;var SG:TStringGrid);
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
  t:=vpnMaximo(sol.nISol);
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
    ponerEnSG(SG,NPROG,fila,linea);
    Inc(fila);
  end;
  SG.rowCount:=fila+1;
end;

procedure obtenerProgramaASM(var sol:tipoSolucionDin;var sga:TStringGrid;var memo:TMemo);
var
  i:Integer;
begin
    {Borrar SG y Rich}
    for i := 0 to sga.RowCount - 1 do sga.Rows[i].Clear;
    Memo.Clear;
    {Generar Programa ASM}
    SecuenciaAStringGrid(Sol,sga);
    llenarSGconSolucion(sga,Sol.nPSol,Sol.nISol);
    PrimerasInstruccionesEnProgramaASM(Memo);
    stringGridAmemo_PKIP_DIN(sga,Memo);
    RelocalizarBitsDeSolucion(Memo,Sol.nPSol,Sol.nISol);
    {Salvar ASM}
//    Memo.Lines.saveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.ASM'));
end;
procedure RelocalizarBitsDeSolucion(var Memo:TMemo; pSol,iSol:vectorParaPartes);
var
  i,j,nRegSol,nAux:integer;
begin
  nRegSol:=DIR_REG_SOLUCION;//80;//$50;
  {2018 Para Máquina de Estados SALIDA de 9 bits: 4 bits en B y 5 bits en A}
  if RegistroSalidaLOW=R0 then
  begin
//    Memo.Lines.add('; Bit relocation.');
    Memo.Lines.add('    '+'CLR R0');
    for i:=0 to nBitsRegistroSalidaLOW - 1 do
    begin {Bits menos significativos en A}
      nAux:=pSol[i] mod 8;
      Memo.Lines.add('    '+'BST R'+IntToStr(DIR_REG_SOLUCION+i)+','
                               +IntToStr(nAux));
      Memo.Lines.add('    '+'BLD R0'+','+IntToStr(i));
    end;
    if nBitsRegistroSalidaLOW < NUMERO_DE_PARTES_DE_SALIDA then
    begin
      Memo.Lines.add('    '+'CLR R1');
      for i:=nBitsRegistroSalidaLOW to NUMERO_DE_PARTES_DE_SALIDA-1 do
      begin {Bits mas significativos en B}
        nAux:=pSol[i] mod 8;
        Memo.Lines.add('    '+'BST R'+IntToStr(DIR_REG_SOLUCION+i)+','
                                 +IntToStr(nAux));
        Memo.Lines.add('    '+'BLD R1'+','+IntToStr(i-nBitsRegistroSalidaLOW));
      end;
    end;
  end
  else
  begin
//    Memo.Lines.add('; Bit relocation.');
    Memo.Lines.add('    '+'CLR R1');
    for i:=0 to nBitsRegistroSalidaLOW - 1 do
    begin {Bits menos significativos en B}
      nAux:=pSol[i] mod 8;
      Memo.Lines.add('    '+'BST R'+IntToStr(DIR_REG_SOLUCION+i)+','
                               +IntToStr(nAux));
      Memo.Lines.add('    '+'BLD R1'+','+IntToStr(i));
    end;
    if nBitsRegistroSalidaLOW < NUMERO_DE_PARTES_DE_SALIDA then
    begin
      Memo.Lines.add('    '+'CLR R0');
      for i:=nBitsRegistroSalidaLOW to NUMERO_DE_PARTES_DE_SALIDA-1 do
      begin {Bits mas significativos en A}
        nAux:=pSol[i] mod 8;
        Memo.Lines.add('    '+'BST R'+IntToStr(DIR_REG_SOLUCION+i)+','
                                 +IntToStr(nAux));
        Memo.Lines.add('    '+'BLD R0'+','+IntToStr(i-nBitsRegistroSalidaLOW));
      end;
    end;
  end;
  Memo.Lines.add('    '+'RET');
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
procedure mostrarResultadosEn_KB_SCAN_CC(fsuma:real);
var
  sCadtae,sCadEva,sCadtotal,sCadPor,sCadGen:cadena20;
  scad:string;
  i,tam,nCiclos,nBytes:Integer;
  secuencia:Tseq;
begin
    pormocc:=100*fsuma/fMoccMax;
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);
    MostrarLocalizacionDeBitsDin(SDIAppForm.memoResultados,SolDin);
    obtenerProgramaASM(SolDin,SDIAppForm.SGArmado,SDIAppForm.MemoSol);
    tam:=SDIAppForm.MemoSol.Lines.Count;
    MemoAseq(SDIAppForm.MemoSol,secuencia,SDIAppForm.memoHEX);
    tam:=Length(secuencia);
    calcularCiclosYbytesDeSecuencia(ISetAVR,secuencia,nCiclos,nBytes);
    {NGeneraciones NEvaluaciones Error Fsuma Porcentaje Tamano No Lineas nBytes nCiclos}
    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
                      numFCad(fMoccMax-fsuma,6)+ numFCad(fsuma,6)+
                      sCadPor+' '+numFCad(seqSize,6)+numFCad(tam,6)+
                      numFCad(nBytes,6)+numFCad(nCiclos,6));
    capturarEstadistica(sCadGen,sCadEva,
                      numFCad(fMoccMax-fsuma,6),numFCad(fsuma,6),
                      sCadPor,numFCad(seqSize,6),numFCad(tam,6),
                      numFCad(nBytes,6),numFCad(nCiclos,6),
                      IntToStr(fMoccMax));
    SDIAppForm.LabelAdecuacion.Caption:='f:'+FloatToStr(fsuma);
    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-fsuma);
    SDIAppForm.LabelGeneraciones.update;
    fmocc:=fsuma;
end;
procedure mostrarAlgunosResultadosEn_KB_SCAN_CC(fsuma:real);
var
  sCadtae,sCadEva,sCadtotal,sCadPor,sCadGen:cadena20;
  scad:string;
  i,tam,nCiclos,nBytes:Integer;
  secuencia:Tseq;
begin
    pormocc:=100*fsuma/fMoccMax;
    str(nemocc:11,sCadEva);
    str(pormocc:6:1,sCadPor);
    str(tmocc:9,sCadGen);
//    MostrarLocalizacionDeBitsDin(SDIAppForm.memoResultados,SolDin);
    obtenerProgramaASM(SolDin,SDIAppForm.SGArmado,SDIAppForm.MemoSol);
    tam:=SDIAppForm.MemoSol.Lines.Count;
    MemoAseq(SDIAppForm.MemoSol,secuencia,SDIAppForm.memoHEX);
    tam:=Length(secuencia);
    calcularCiclosYbytesDeSecuencia(ISetAVR,secuencia,nCiclos,nBytes);
    {NGeneraciones NEvaluaciones Error Fsuma Porcentaje Tamano No Lineas nBytes nCiclos}
//    SDIAppForm.MemoTiempos.Lines.add(sCadGen+sCadEva+
//                      numFCad(fMoccMax-fsuma,6)+ numFCad(fsuma,6)+
//                      sCadPor+' '+numFCad(seqSize,6)+numFCad(tam,6)+
//                      numFCad(nBytes,6)+numFCad(nCiclos,6));
    capturarEstadistica(sCadGen,sCadEva,
                      numFCad(fMoccMax-fsuma,6),numFCad(fsuma,6),
                      sCadPor,numFCad(seqSize,6),numFCad(tam,6),
                      numFCad(nBytes,6),numFCad(nCiclos,6),
                      IntToStr(fMoccMax));
//    SDIAppForm.LabelAdecuacion.Caption:='f:'+FloatToStr(fsuma);
//    SDIAppForm.LabelPorcentaje.Caption:=sCadPor+'%';
//    SDIAppForm.LabelError.Caption:=FloatToStr(fMoccMax-fsuma);
//    SDIAppForm.LabelGeneraciones.update;

    fmocc:=fsuma;
end;
end.

