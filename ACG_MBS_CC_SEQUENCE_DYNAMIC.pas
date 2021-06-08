unit ACG_MBS_CC_SEQUENCE_DYNAMIC;

interface
uses
  Classes, sysUtils,math,StdCtrls, MMSystem,
  mcsConstantesTiposRutinas,mcsConstantesRutinas,
  mcsRutinas,mcsTMicroEjecucion,
  mcsAVRcpu, mcsAVR,
  ACG_MBS_LCD,ACG_MBS_KEYPAD,ACG_MBS_BCD_LCD,ACG_MBS_CONV,
  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,
  ACG_MBS_SEQUENCE_DINAMIC;

type
  W_LIST = (P1T,P2T,QT,QR);
type
  aCCMOLGP = array of TGASeqDin;
var {VARIABLES GLOBALES}
  CCMOLGP:aCCMOLGP;

procedure iniciar_CC;
procedure finalizar_CC;
procedure seleccion_variacion_en_CC;
procedure hallarRepresentantes_CC;
procedure insertarOffsprings_CC;
procedure ordenarListas_CC;
procedure EjecutarProcesoEvolutivo_CC;

implementation
uses ACG_MAIN;
procedure copiarSegmentoFuenteADestino(var SRC,DES:Tseq;var tsrc:Integer);
var
  i,j,tdes:Integer;
begin
  tsrc:=Length(SRC);
  tdes:=Length(DES);
  SetLength(DES,tsrc+tdes);
  for i:=0 to tsrc-1 do
  begin
    DES[i+tdes]:=SRC[i];
  end;
end;

procedure limpiarTamanosSegmentos(var dimCC:TdimCC);
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    dimCC[i]:=0;
  end;
end;
procedure CombinarIndividuoConRepresentantesDeEspecies(lista:W_LIST;
            nEspecie,nIndividuo,nRepres:Integer;var mProg:Tseq;var dimCC:TdimCC);
var
  i,tam:Integer;
begin
  SetLength(mProg,0);
  limpiarTamanosSegmentos(dimCC);
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    if i=nEspecie then
    begin {Copiar Descendiente}
      case lista of
      QT:begin
          copiarSegmentoFuenteADestino(
            (TObject(CCMOLGP[i].Qt.PopList[nIndividuo])as TCromSeqDin).seq,mProg,tam);
         end;
      P1T:begin
          copiarSegmentoFuenteADestino(
            (TObject(CCMOLGP[i].P1t.PopList[nIndividuo])as TCromSeqDin).seq,mProg,tam);
         end;
      P2T:begin
          copiarSegmentoFuenteADestino(
            (TObject(CCMOLGP[i].P2t.PopList[nIndividuo])as TCromSeqDin).seq,mProg,tam);
         end;
      end;
    end
    else
    begin {Copiar Representante}
      case CCMOLGP[i].PRtnl[nRepres] of
        1:begin
          copiarSegmentoFuenteADestino(
            (TObject(CCMOLGP[i].P1t.PopList[CCMOLGP[i].PRtni[nRepres]])as
              TCromSeqDin).seq,mProg,tam);
        end;
        2:begin
          copiarSegmentoFuenteADestino(
            (TObject(CCMOLGP[i].P2t.PopList[CCMOLGP[i].PRtni[nRepres]])as
              TCromSeqDin).seq,mProg,tam);
        end;
      end;
    end;
    dimCC[i]:=tam;
  end;
end;
function AdecuacionDeSegmento(nEspecie:Integer;dimCC:TdimCC;nI:vectorParaPartes):Real;
var
  i:Integer;
  inferior,superior,cantidadnI,tamSegmento:Integer;
begin
  inferior:=0;
  {Hallar los numeros de la primera y de la ultima instruccion del segmento}
  if nEspecie>0 then
  begin
    for i:=0 to nEspecie-1 do
    begin
      inferior:=inferior+dimCC[i];
    end;
  end;
  superior:=inferior+dimCC[nEspecie];
  {Contar la cantidad de resultados de bits en el segmento}
  cantidadnI:=0;
  for i:=0 to NUMERO_DE_PARTES_DE_SALIDA - 1 do
  begin
    if (nI[i]>=inferior)and(nI[i]<superior) then
    begin
      Inc(cantidadnI);
    end;
  end;
  {Hallar el tamano del segmento}
  if nEspecie=NUMERO_DE_SEGMENTOS_EN_CC-1 then
  begin
    tamSegmento:=dimCC[nEspecie];
  end
  else
  begin
    tamSegmento:=dimCC[nEspecie];
  end;
  {Si no hay solucion la adecuacion depende de la cantidad de resultados de bits
   del segmento. En cambio, si ya hay solucion la adecuacion depende del tamano
   del segmento para optimizarlo}
  if haySolucion then
  begin
    Result:=-0.00001*(tamSegmento);
  end
  else
  begin
    Result:=0.00001*(cantidadnI);
  end;
end;
procedure EvaluarAdecuacionDeUnIndividuo(lista:W_LIST;nEspecie,nIndividuo:Integer);
var
  mProg:Tseq;
  k:Integer;
  fa,fmax:vectorParaPartesF;
  dimCC:TdimCC;
  nI:vectorParaPartes;
  adecuacion:Real;
  sumaF,sumaFmax:Real;
begin
  sumaFmax:=0;
  anularVectorParaPartesF(fmax);
  for k:= 0 to NUMERO_DE_REPRESENTANTES_DIN-1 do
  begin
    CombinarIndividuoConRepresentantesDeEspecies(lista,nEspecie,nIndividuo,k,mProg,dimCC);
    case CBII of
    PKIP_CC:begin
      fa:=AdecuacionDeSecuenciaEn_KB_SCAN_CC(mProg,nI,dimCC);
      if not esVectorParaPartesFnulo(fa) then
      begin
        adecuacion:=AdecuacionDeSegmento(nEspecie,dimCC,nI);
        sumarConstanteAVectorParaPartesF(fa,adecuacion);
      end;
    end;
    CONV_CC:begin
      fa:=AdecuacionDeSecuenciaEn_CONV_CC(mProg,nI,dimCC);
      if not esVectorParaPartesFnulo(fa) then
      begin
        adecuacion:=AdecuacionDeSegmento(nEspecie,dimCC,nI);
        sumarConstanteAVectorParaPartesF(fa,adecuacion);
      end;
    end;
    LCD_CC:begin
      fa:=AdecuacionDeSecuenciaEn_LCD_INI_CC(mProg,dimCC);//,nI,dimCC);
    end;
    BCD_LCD_CC:begin
      fa:=AdecuacionDeSecuenciaEn_BCD_LCD_CC(mProg,nI,dimCC);
    end;
    end;
    sumaF:=sumarElementosVectorParaPartesF(fa);
    if sumaF>sumaFmax then
    begin
      fmax:=fa;
      sumaFmax:=sumaF;
    end;
  end;
  case lista of
  QT:begin
       (TObject(CCMOLGP[nEspecie].Qt.PopList[nIndividuo])as
         TCromSeqDin).copiarAdecuacion(fmax);
     end;
  P1T:begin
       (TObject(CCMOLGP[nEspecie].P1t.PopList[nIndividuo])as
         TCromSeqDin).copiarAdecuacion(fmax);
     end;
  P2T:begin
       (TObject(CCMOLGP[nEspecie].P2t.PopList[nIndividuo])as
         TCromSeqDin).copiarAdecuacion(fmax);
     end;
  end;
end;
procedure EvaluarAdecuacionDeTodaLaLista(lista:W_LIST);
var
  i,j:integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    case lista of
    QT:begin
        for j:= 0 to CCMOLGP[i].Qt.PopList.count-1 do
        begin
          EvaluarAdecuacionDeUnIndividuo(lista,i,j);
        end;
       end;
    P1T:begin
        for j:= 0 to CCMOLGP[i].P1t.PopList.count-1 do
        begin
          EvaluarAdecuacionDeUnIndividuo(lista,i,j);
        end;
       end;
    P2T:begin
        for j:= 0 to CCMOLGP[i].P2t.PopList.count-1 do
        begin
          EvaluarAdecuacionDeUnIndividuo(lista,i,j);
        end;
       end;
    end;
  end;
end;

procedure ordenarListas_CC;
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    CCMOLGP[i].P1t.ordenarPorAdecuacionSumandoF;
    CCMOLGP[i].P2t.ordenarPorAdecuacionSumandoF;
  end;
end;
procedure insertarOffsprings_CC;
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    insertarListaSecuencia(CCMOLGP[i].Qt,CCMOLGP[i].P1t,CCMOLGP[i].Dt);
    insertarListaSecuencia(CCMOLGP[i].Dt,CCMOLGP[i].P2t,CCMOLGP[i].Dpaso5);
  end;
end;
procedure hallarRepresentantes_CC;
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    CCMOLGP[i].hallarReprentantesSoloIndices;
  end;
end;
procedure iniciar_CC;
var
  i:Integer;
begin
  haySolucion:=False;
  SetLength(CCMOLGP,NUMERO_DE_SEGMENTOS_EN_CC);
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    CCMOLGP[i]:=TGASeqDin.Create;
    CCMOLGP[i].iniciar;
    CCMOLGP[i].iniciarParaCC;
  end;
  hallarRepresentantes_CC;
  EvaluarAdecuacionDeTodaLaLista(P1T);
  EvaluarAdecuacionDeTodaLaLista(P2T);
  ordenarListas_CC;
end;
procedure finalizar_CC;
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    CCMOLGP[i].finalizar;
  end;
  CCMOLGP := nil;
end;
procedure seleccion_variacion_en_CC;
var
  i:Integer;
begin
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    CCMOLGP[i].seleccionDePadres;
    CCMOLGP[i].variacion;
  end;
end;
function MostrarDatos_CC:string;
var
  i:Integer;
begin
  Result:='';
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    Result:=result+'('+CCMOLGP[i].datos+') ';
  end;
end;
procedure EjecutarProcesoEvolutivo_CC;
begin
  seleccion_variacion_en_CC;
  hallarRepresentantes_CC;
  EvaluarAdecuacionDeTodaLaLista(P1T);
  EvaluarAdecuacionDeTodaLaLista(P2T);
  EvaluarAdecuacionDeTodaLaLista(QT);
  insertarOffsprings_CC;
  ordenarListas_CC;
end;

end.
