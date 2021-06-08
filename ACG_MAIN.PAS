unit ACG_MAIN;

interface

uses Windows, sysUtils,   Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, Grids, DBGrids, DB, Math,  MMSystem,   DateUtils,
  System.TimeSpan, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZAbstractConnection, ZConnection, System.ImageList, System.Actions,
  Vcl.Samples.Spin,

  mcsRutinas, mcsConstantesTiposRutinas, mcsTMicroEjecucion,
  mcsAVR,mcsAVRcpu,

  ACG_MBS_TYPES,ACG_MBS_TYPES_DINAMIC,

  ACG_MBS_SEQUENCE_DINAMIC,
  ACG_MBS_CC_SEQUENCE_DYNAMIC,

  ACG_MBS_KEYPAD,ACG_MBS_LCD,ACG_MBS_BCD_LCD,ACG_MBS_CONV,

  OleServer, //ExcelXP,
  DBCtrls, //System.ImageList, System.Actions, ZAbstractConnection, ZConnection,
  //ZAbstractRODataset,  ZAbstractDataset,
  //ZAbstractTable, ZDataset,
  Vcl.Mask,

  ComObj,Variants;//, Vcl.Samples.Spin;

type
  TSDIAppForm = class(TForm)
    SaveDialog: TSaveDialog;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    Leerbasededatos1: TMenuItem;
    Guardarbasededatos1: TMenuItem;
    MemoResultados: TMemo;
    LabelGeneraciones: TLabel;
    LabelAdecuacion: TLabel;
    LabelArchivo: TLabel;
    LabelEvaluaciones: TLabel;
    TimerMOCC: TTimer;
    LabelPorcentaje: TLabel;
    MemoTiempos: TMemo;
    DataSourceEntrada: TDataSource;
    DBGridEntrada: TDBGrid;
    OpenDialog: TOpenDialog;
    OpenDialogXLS: TOpenDialog;
    ButtonReanudar: TButton;
    LabelTotal: TLabel;
    LabelError: TLabel;
    SGArmado: TStringGrid;
    memoHEX: TMemo;
    MemoExper: TMemo;
    MemoTamano: TMemo;
    PanelOpciones: TPanel;
    MemoSol: TMemo;
    ZConnection: TZConnection;
    ZQuery: TZQuery;
    Label2: TLabel;
    SGSpecies: TStringGrid;
    REprograma: TRichEdit;
    SGDATOS: TStringGrid;
    LabelProgramaGenerado: TLabel;
    ButtonLectura: TButton;
    ButtonMOCC: TButton;
    ButtonRun: TButton;
    seRUN1: TSpinEdit;
    LabelNumeroPrograma: TLabel;
    LabelNumPrograma: TLabel;
    ButtonParar: TButton;
    procedure TimerMOCCTimer(Sender: TObject);
    procedure ButtonMOCCClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonPararClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileNew1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure ButtonLecturaClick(Sender: TObject);
    procedure ButtonReanudarClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure button2Click(Sender: TObject);
    procedure ButtonRunClick(Sender: TObject);
    procedure ButtonProgramaHClick(Sender: TObject);
  private
    { Private declarations }
    procedure copiarFilaDeDatosARespuestas(nDato,nRes:integer);
    procedure ColocarNombresDeColumnas(var sg:TStringGrid);

  public
    { Public declarations }
//    procedure MatrizProgramaAMemo(var s:tipoSolucion);
    procedure mostrarParametros;
    procedure salvarArchivos;
    procedure salvarProgramaEstadisticaEnExcel(nPrograma:Integer);

    {Procedimientos para crear Archivo HEX}

    procedure ConvertirASMeHEX;
    procedure ConvertirSecuencia_LCD_DIN_a_ASM;

//    procedure MostrarLocalizacionDeBits(var s:tipoSolucion);
    procedure MostrarFitness(var s:tipoSolucion);
    procedure mostrarDiagramaDeTiempo(var x:vectorValoresSalidaSI;var y:vectorValoresSalidaB);

//    procedure Convertir_GA_PKIP_DIN_ASM;

    procedure LlenarEtiquetas_GA_DIN;
    procedure LlenarEtiquetas_CC;
    procedure LlenarAlgunasEtiquetasCC(i:Integer);
    procedure CargarDeExcelAMemo(nColumna:Integer;var Memo:TMemo);
    procedure ProcesarProgramaHumano;
    procedure salvarCaracteristicasPHenExcel;
  end;

var
  SDIAppForm: TSDIAppForm;

implementation

uses about; //, mcsFormProgramaControl, mcsEEHWFormTest;

{$R *.dfm}

procedure TSDIAppForm.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;
procedure TSDIAppForm.FileSave1Execute(Sender: TObject);
begin
  SaveDialog.Execute;
end;

procedure TSDIAppForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TSDIAppForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;
procedure TSDIAppForm.ColocarNombresDeColumnas(var sg:TStringGrid);
var
  i:integer;
  ncadena:shortstring;
begin
    for i:=0 to 19 do
    begin
      str(i+1,ncadena);
      sg.cells[i,0]:='Columna'+ncadena;
    end;
end;

procedure TSDIAppForm.copiarFilaDeDatosARespuestas(nDato,nRes:integer);
begin

end;

procedure TSDIAppForm.FormCreate(Sender: TObject);
begin
  Application.OnDeactivate := FormDeactivate;
  Application.OnActivate := FormActivate;

  SGSpecies.cells[0,0]:='P1t';
  SGSpecies.cells[1,0]:='P2t';
  SGSpecies.cells[2,0]:='Qt';
  SGSpecies.cells[3,0]:='Dt';
  SGSpecies.cells[4,0]:='Dpaso5';
  SGSpecies.cells[5,0]:='PRt';
  SGSpecies.cells[6,0]:='size';

  PanelOpciones.Width:=1361;
  PanelOpciones.Height:=665;

  AVRcpu:=TmcsAVR.Create;
  Randomize;
end;
procedure TSDIAppForm.FormDeactivate(Sender: TObject);
begin
  APLICACION_ACTIVADA:=False;
  //Caption:='desactivada';
end;

procedure TSDIAppForm.FormDestroy(Sender: TObject);
begin
  timerMOCC.enabled:=FALSE;
  AVRcpu.Destroy;
end;

procedure TSDIAppForm.FormActivate(Sender: TObject);
begin
  APLICACION_ACTIVADA:=True;
  //Caption:='activada';
end;

procedure TSDIAppForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  DialogValue: Integer;
begin
    DialogValue := MessageDlg('¿Desea cerrar la aplicación?', mtConfirmation,
      [mbYes, mbNo, mbCancel], 0);
    case DialogValue of
      id_Yes: CanClose := TRUE;
      id_Cancel: CanClose := FALSE;
      id_No: CanClose := FALSE;
    end;

end;
procedure TSDIAppForm.salvarProgramaEstadisticaEnExcel(nPrograma:Integer);
var
  i:Integer;
  ExcelFile : Variant;
  WorkBook : Variant;
  WorkSheet : Variant;
begin
  ExcelFile :=  CreateOleObject('Excel.Application');
  WorkBook := ExcelFile.WorkBooks.Open(nombreArchivoEntradaXLS);
  WorkSheet := WorkBook.WorkSheets.Item['Hoja2'];
  for i:=0 to MemoSol.Lines.Count -1 do
  begin {Colocar programa en hoja Excel}
    WorkSheet.Cells[i+2, nPrograma+1+2]:=MemoSol.Lines[i];
  end;
  {Cambiar de Hoja Excel}
  WorkSheet := Unassigned;
  WorkSheet := WorkBook.WorkSheets.Item['Hoja3'];
  for i:=1 to 12 do //13 do
  begin {Colocar estadisticas en Hoja3}
    WorkSheet.Cells[i+1, nPrograma+1+2]:=estadistica[i];
  end;
  WorkBook.Save;//(nombreArchivoEntradaXLS);
  //ExcelFile.Save;
  WorkSheet := Unassigned;
  WorkBook := Unassigned;

  ExcelFile.Quit;
  ExcelFile := Unassigned;
end;
procedure TSDIAppForm.salvarArchivos;
var
  TS: TTimeSpan;
begin
  MemoResultados.Lines.add('Stop at '+TimeToStr(Time));
  MemoResultados.Lines.add('Total Generations='+IntToStr(tmocc));
  MemoResultados.Lines.add('Total Evaluations='+IntToStr(nemocc));
  MemoResultados.Lines.SaveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.EVO'));
  MemoTiempos.Lines.SaveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.TIE'));
  MemoSol.Lines.saveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.ASM'));
  {Colocar programa en hoja Excel}
  TiempoFinal:=Time;
  estadistica[11]:=TimeToStr(TiempoInicio);
  estadistica[12]:=TimeToStr(TiempoFinal);
  TS := TTimeSpan.Subtract(TiempoFinal, TiempoInicio);
  estadistica[13]:= TS;
  salvarProgramaEstadisticaEnExcel(NumeroProgramaGenerado);
end;
(*************Procedimientos de visualización en ventana principal*************)
procedure TSDIAppForm.LlenarEtiquetas_GA_DIN;
var
  i:Integer;
begin
  LabelGeneraciones.Caption:=' Gen='+IntToStr(tmocc);
  LabelGeneraciones.update;

  LabelEvaluaciones.Caption:='nEva='+IntToStr(nemocc);
  LabelEvaluaciones.update;

  LabelTotal.Caption:='fmax = '+IntToStr(fMoccMax);
  LabelTotal.update;

  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    SGSpecies.cells[0,i+1]:=numCad(CCMOLGP[i].P1t.PopList.Count,6);
    SGSpecies.cells[1,i+1]:=numCad(CCMOLGP[i].P2t.PopList.Count,6);
    SGSpecies.cells[2,i+1]:=numCad(CCMOLGP[i].Qt.PopList.Count,6);
    SGSpecies.cells[3,i+1]:=numCad(CCMOLGP[i].Dt.PopList.Count,6);
    SGSpecies.cells[4,i+1]:=numCad(CCMOLGP[i].Dpaso5.PopList.Count,6);
    SGSpecies.cells[5,i+1]:=numCad(CCMOLGP[i].PRt.PopList.Count,6);
    SGSpecies.cells[6,i+1]:=numCad(SolDin.dimCC[i],6);
  end;
end;
procedure TSDIAppForm.LlenarAlgunasEtiquetasCC(i:Integer);
begin
  LabelGeneraciones.Caption:='Gen='+IntToStr(tmocc);
  LabelGeneraciones.update;

  LabelEvaluaciones.Caption:='Eva='+IntToStr(nemocc);
  LabelEvaluaciones.update;

  LabelNumeroPrograma.Caption:='Prog='+IntToStr(i);
  LabelNumeroPrograma.update;

//  LabelTotal.Caption:='fmax = '+IntToStr(fMoccMax);
//  LabelTotal.update;
end;
procedure TSDIAppForm.LlenarEtiquetas_CC;
var
  i:Integer;
begin
  LabelGeneraciones.Caption:=' Gen='+IntToStr(tmocc);
  LabelGeneraciones.update;

  LabelEvaluaciones.Caption:='nEva='+IntToStr(nemocc);
  LabelEvaluaciones.update;

  LabelNumeroPrograma.Caption:='Prog='+IntToStr(NumeroProgramaGenerado);
  LabelNumeroPrograma.update;

  LabelTotal.Caption:='fmax = '+IntToStr(fMoccMax);
  LabelTotal.update;
  for i:=0 to NUMERO_DE_SEGMENTOS_EN_CC-1 do
  begin
    SGSpecies.cells[0,i+1]:=numCad(CCMOLGP[i].P1t.PopList.Count,6);
    SGSpecies.cells[1,i+1]:=numCad(CCMOLGP[i].P2t.PopList.Count,6);
    SGSpecies.cells[2,i+1]:=numCad(CCMOLGP[i].Qt.PopList.Count,6);
    SGSpecies.cells[3,i+1]:=numCad(CCMOLGP[i].Dt.PopList.Count,6);
    SGSpecies.cells[4,i+1]:=numCad(CCMOLGP[i].Dpaso5.PopList.Count,6);
    SGSpecies.cells[5,i+1]:=numCad(CCMOLGP[i].PRt.PopList.Count,6);
    SGSpecies.cells[6,i+1]:=numCad(SolDin.dimCC[i],6);
  end;
end;
procedure TSDIAppForm.MostrarFitness(var s:tipoSolucion);
var
  i:Integer;
  linea:string;
begin
    MemoResultados.Lines.Add('------------------------------------------------------------------------');
    linea:='FITNESS: ';
    for i:=NUMERO_DE_PARTES_DE_SALIDA - 1 downto 0 do
    begin
      linea:=linea+'Pin'+intToStr(i)+'  ';
    end;
    MemoResultados.Lines.Add(linea);
    MemoResultados.Lines.Add('      '+cadenaDeVectorParaPartesF(s.fSol));
    MemoResultados.Lines.Add('------------------------------------------------------------------------');
end;

procedure TSDIAppForm.mostrarParametros;
var
  i:Integer;
  b:Byte;
  s:string;
begin
  MemoResultados.Lines.Add('USED INSTRUCTIONS:');
  for i:=0 to NUMERO_DE_INSTRUCCIONES_DE_TABLA-1 do
  begin
    s:=vectorInstruccionAVRaCadenaASM(iPermitidas[i]);
    MemoResultados.Lines.Add(IntToStr(iPermitidas[i][0])+' '+s);
  end;
  MemoResultados.Lines.Add('NUMERO_DE_INSTRUCCIONES_DE_TABLA: '+IntToStr(NUMERO_DE_INSTRUCCIONES_DE_TABLA));
  MemoResultados.Lines.Add('NUMERO_DE_INSTRUCCIONES_AVR: '+IntToStr(NUMERO_DE_INSTRUCCIONES_AVR));
  MemoResultados.Lines.Add('CANTIDAD_DE_TIPOS_TRANSFERENCIA: '+IntToStr(CANTIDAD_DE_TIPOS_TRANSFERENCIA));
  MemoResultados.Lines.Add('NUMERO_DE_REPRESENTANTES: '+IntToStr(NUMERO_DE_REPRESENTANTES));
  MemoResultados.Lines.Add('VALOR_INMEDIATO_MAXIMOMASUNO: '+IntToStr(VALOR_INMEDIATO_MAXIMOMASUNO));
  MemoResultados.Lines.Add('TAMANO_POBLACION_DIN: '+IntToStr(TAMANO_POBLACION_DIN));
  MemoResultados.Lines.Add('NUMERO_DE_REGISTROS: '+IntToStr(NUMERO_DE_REGISTROS));
  MemoResultados.Lines.Add('NUMERO_BYTES_POR_INSTRUCCION: '+IntToStr(NUMERO_BYTES_POR_INSTRUCCION));
  MemoResultados.Lines.Add('NUMERO_MAX_DE_CADENAS_DE_SALIDA: '+IntToStr(NUMERO_MAX_DE_CADENAS_DE_SALIDA));
  MemoResultados.Lines.Add('NUMERO_DE_CADENAS_DE_SALIDA: '+IntToStr(NUMERO_DE_CADENAS_DE_SALIDA));
  MemoResultados.Lines.Add('NUMERO_DE_BITS_POR_PARTE: '+IntToStr(NUMERO_DE_BITS_POR_PARTE));
  MemoResultados.Lines.Add('NUMERO_DE_PARTES_DE_SALIDA: '+IntToStr(NUMERO_DE_PARTES_DE_SALIDA));
  MemoResultados.Lines.Add('NUMERO_DE_PARTES_EN_MEMORIA: '+IntToStr(NUMERO_DE_PARTES_EN_MEMORIA));
end;
(***************Procedimientos de Botones de Ventana Principal*****************)
procedure TSDIAppForm.ButtonReanudarClick(Sender: TObject);
begin
  timerMOCC.enabled:=TRUE;
  ButtonParar.enabled:=TRUE;
  ButtonReanudar.enabled:=FALSE;
  SDIAppForm.MemoResultados.Lines.add('Restart at '+TimeToStr(Time));
  SDIAppForm.MemoResultados.Lines.add('Total Generations='+IntToStr(tmocc));
  SDIAppForm.MemoResultados.Lines.add('Total Evaluations='+IntToStr(nemocc));
  SDIAppForm.MemoResultados.Lines.add('Restart');

end;
////
//// delay in milliseconds, uses the system time, also uses
//// Application.ProcessMessages, which allows access to other events
//// during the delay, the Win32 API function Sleep() does not
////
//procedure Delay(msecs: integer);
//var
//  FirstTickCount: longint;
//begin
//  FirstTickCount := GetTickCount;
//   repeat
//     Application.ProcessMessages;
//   until ((GetTickCount-FirstTickCount) >= Longint(msecs));
//end;
procedure TSDIAppForm.salvarCaracteristicasPHenExcel;
var
  i:Integer;
  ExcelFile : Variant;
  WorkBook : Variant;
  WorkSheet : Variant;
begin
  ExcelFile :=  CreateOleObject('Excel.Application');
  WorkBook := ExcelFile.WorkBooks.Open(nombreArchivoEntradaXLS);
  WorkSheet := WorkBook.WorkSheets.Item['Hoja3'];
  for i:=1 to 10 do
  begin {Colocar estadisticas en Hoja3}
    WorkSheet.Cells[i+1, 2]:=estadistica[i];
  end;
  WorkBook.Save;//(nombreArchivoEntradaXLS);
  //ExcelFile.Save;
  WorkSheet := Unassigned;
  WorkBook := Unassigned;

  ExcelFile.Quit;
  ExcelFile := Unassigned;
end;
procedure TSDIAppForm.ButtonRunClick(Sender: TObject);
var
  i:Integer;
  secuencia:Tseq;
  tamano1,nBytes1,nCiclos1,tamano2,nBytes2,nCiclos2:Integer;
  nProg1,nProg2:Integer;
  TS: TTimeSpan;
begin
  PanelOpciones.Visible:=False;
//  NumeroProgramaGenerado:=seNumeroEvolucion.Value;

  timerMOCC.enabled:=False;
  ButtonRun.enabled:=FALSE;
  ButtonParar.enabled:=FALSE;
  ButtonLectura.enabled:=FALSE;
  ButtonMOCC.enabled:=FALSE;
//  MostrarParametros;
  MemoResultados.Visible:=False;
  MemoTiempos.Visible:=False;
  MemoSol.Visible:=False;
  memoHEX.Visible:=False;
  SGSpecies.Visible:=False;

  case CBII of
  PKIP_CC,CONV_CC:begin
      convertirObjetivoW(vObjetivo,mvpo);
      fMoccMax:=NUMERO_DE_PARTES_DE_SALIDA*NUMERO_DE_CADENAS_DE_SALIDA;
    end;
  LCD_CC:begin
      ArreglarDiagramaDeTiempo;
      fMoccMax:=NUMERO_DE_PARTES_DE_SALIDA*(NUMERO_DE_CADENAS_DE_SALIDA+1)*
                    (NUMERO_DE_CADENAS_DE_SALIDA) div 2;
    end;
  BCD_LCD_CC:begin
      fMoccMax:=(NUMERO_DE_PARTES_DE_SALIDA*(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA+1)*
                    (NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA) div 2)*
                    NUMERO_DE_CADENAS_DE_SALIDA;
    end;
  end;


  nProg1:=NumeroProgramaGenerado;
  nProg2:=NumeroProgramaGenerado+seRUN1.Value-1;
  CantidadProgramasGenerados:=nProg2-nProg1+1;
  for i:=nProg1 to nProg2 do
  begin
    TiempoInicio:=Time;
    MemoTiempos.Clear;
    MemoResultados.Clear;
    iniciar_CC;
    LlenarAlgunasEtiquetasCC(i);
    repeat
      tmocc:=tmocc+1;
      EjecutarProcesoEvolutivo_CC;
      LlenarAlgunasEtiquetasCC(i);
    until (nemocc>NUMERO_MAXIMO_DE_EVALUACIONES);
    TiempoFinal:=Time;
    estadistica[11]:=TimeToStr(TiempoInicio);
    estadistica[12]:=TimeToStr(TiempoFinal);
    TS := TTimeSpan.Subtract(TiempoFinal, TiempoInicio);
    estadistica[13]:= TS;
    salvarProgramaEstadisticaEnExcel(i);
    finalizar_CC;
  end;
  MemoResultados.Visible:=True;
  MemoTiempos.Visible:=True;
  MemoSol.Visible:=True;
  memoHEX.Visible:=True;
  SGSpecies.Visible:=True;
  ProcesarProgramaHumano;
  salvarCaracteristicasPHenExcel;
end;

{************* PROCEDIMIENTOS PARA CREAR ARCHIVO HEX **************************}
procedure TSDIAppForm.ConvertirASMeHEX;
var
  sFila,antes,despues:string;
  i:Word;
  contBytes,contCR,contInst:LongInt;
begin
  MiError.create;
  MiError.anular;
  microAyu:=TmcsEje.create;
  microAyu.iniciarEje(1);

  microAyu.ensamblarArchivo(ChangeFileExt(nombreArchivoEntradaXLS,'.ASM'));
  MemoTamano.Lines.Add(IntToStr(microAyu.pDE.contadorDeBytes));
  microAyu.crearArchivoHEX(ChangeFileExt(nombreArchivoEntradaXLS,'.HEX'));
  memoHEX.Lines.LoadFromFile(ChangeFileExt(nombreArchivoEntradaXLS,'.HEX'));

  contBytes:=microAyu.pDE.contadorDeBytes;
  contCR:=microAyu.pDE.contadorDeCiclosDeReloj;
  contInst:=microAyu.pDE.contadorDeInstrucciones;

  microAyu.Free;

  microAyu:=TmcsEje.create;
  microAyu.iniciarEje(1);
  {2018 Ensamblar el programa escrito por humano}

  microAyu.ensamblarArchivo(ExtractFilePath(nombreArchivoEntradaXLS)+
    'A_WRITTEN_BY_HUMAN.ASM');

  MemoTiempos.Lines.add(inttostr(contBytes)+' '+inttostr(contCR)+' '+inttostr(contInst)+' '+
    inttostr(microAyu.pDE.contadorDeBytes)+' '+
    inttostr(microAyu.pDE.contadorDeCiclosDeReloj)+' '+
    inttostr(microAyu.pDE.contadorDeInstrucciones));
  capturarEstadistica(inttostr(contBytes),inttostr(contCR),inttostr(contInst),
    inttostr(microAyu.pDE.contadorDeBytes),
    inttostr(microAyu.pDE.contadorDeCiclosDeReloj),
    inttostr(microAyu.pDE.contadorDeInstrucciones),
    inttostr(0),inttostr(0),inttostr(0),inttostr(0));
  microAyu.Free;

end;

procedure TSDIAppForm.mostrarDiagramaDeTiempo(var x:vectorValoresSalidaSI;
                                              var y:vectorValoresSalidaB);
var
  j:integer;
  linea:cadena100;
begin
  MemoResultados.Lines.add('Target Time Diagram:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(vObjetivo[j,COL_SALIDA],4);
  end;
  MemoResultados.Lines.add(linea);
  MemoResultados.Lines.add('Time Diagram:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(x[j],4);
  end;
  MemoResultados.Lines.add(linea);
  MemoResultados.Lines.add('Instruction Number:');
  linea:='';
  for j:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
  begin
    linea:=linea+numCad(y[j],4);
  end;
  MemoResultados.Lines.add(linea);
  MemoResultados.Lines.Add('------------------------------------------------------------------------');
  MemoResultados.Lines.add('Instruction number of the first mismatch in TD: '+
                            IntToStr(sol.LCDSol.nPrimeraDiferenciaEnDT));
  MemoResultados.Lines.add('Number of the last instruction in TD: '+
                            IntToStr(sol.LCDSol.nUltimaInstDeDT));
  MemoResultados.Lines.add('Number of intervals in TD: '+
                            IntToStr(sol.LCDSol.nIntervalo));
end;

procedure TSDIAppForm.Button1Click(Sender: TObject);
var
  sec:Tseq;
begin
  MemoResultados.Lines.Add('ENSAMBLADO Y DESENSAMBLADO:');
  RichEditAseq(REprograma,sec,MemoResultados);
end;

procedure TSDIAppForm.button2Click(Sender: TObject);
var
   ExcelFile : Variant;
   WorkBook : Variant;
   WorkSheet : Variant;
   varvalue:string;
begin
// Open Excel OLE
ExcelFile :=  CreateOleObject('Excel.Application');
WorkBook := ExcelFile.WorkBooks.Open('D:\2020-A\tesis\2020-A-Program\MBS_KB_SCAN_CC_AVR-MEGA-025\AVR_IS_PUERTO_A.xlsx');
WorkSheet := WorkBook.WorkSheets.Item['HOJA_1'];

VarValue := WorkSheet.Cells[1, 1].Value;
MemoResultados.Lines.Add(varvalue);

WorkSheet := Unassigned;
WorkBook := Unassigned;
ExcelFile.Quit;
ExcelFile := Unassigned;

// Handle WoorkBook
//if not VarIsNull(ExcelFile) then
//begin
//    WorkBook := ExcelFile.WorkBooks.Open('AVR_IS_PUERTO_A.xlsx');
//    if not VarIsNull(WorkBook) then
//    begin
//    // Handle Sheet
//        WorkSheet := WorkBook.WorkSheets.Item['HOJA_1'];
//    end;
//end;
end;
procedure TSDIAppForm.ButtonLecturaClick(Sender: TObject);
var
  i,j,fila,columna,valent,valsal,valentMax,valsalMax:Integer;
  nfilas,nColumnas,nEntrada,nSalida,nSalidaFin:Integer;
  cad:string;
  ExcelFile : Variant;
  WorkBook : Variant;
  WorkSheet : Variant;

begin
  if OpenDialogXLS.Execute then
  begin
    if OpenDialogXLS.FileName='' then
    begin
      Exit;
    end;
  end
  else
  begin
    Exit;
  end;
  ButtonLectura.Enabled:=False;
  ButtonMOCC.Enabled:=True;
  ButtonRun.Enabled:=True;
  nombreArchivoEntradaXLS:=OpenDialogXLS.FileName;
  LabelArchivo.Caption:=nombreArchivoEntradaXLS;

  ExcelFile :=  CreateOleObject('Excel.Application');
//  WorkBook := ExcelFile.WorkBooks.Open(GetCurrentDir+'\'+nombreArchivoEntradaXLS);
  WorkBook := ExcelFile.WorkBooks.Open(nombreArchivoEntradaXLS);
  WorkSheet := WorkBook.WorkSheets.Item['Hoja1'];
  nfilas:=0;
  repeat {Determina la cantidad de filas del archivo excel}
    Inc(nfilas);
    cad:= WorkSheet.Cells[nfilas, 1].Value;
  until cad='';
  nfilas:=nfilas-1; {Cantidad de filas del archivo excel}
  nColumnas:=0; nEntrada:=0; nSalida:=0; nSalidaFin:=0;
  repeat {Determina la cantidad de columnas del archivo excel}
    Inc(nColumnas);
    cad:= WorkSheet.Cells[1, nColumnas].Value;
    if cad='ENTRADA' then
    begin {Determina la columna de ENTRADA}
      nEntrada:=nColumnas;
    end;
    if cad='SALIDA' then
    begin {Determina la columna de SALIDA}
      nSalida:=nColumnas;
    end;
    if cad='SALIDAFIN' then
    begin {Determina la columna de SALIDA}
      nSalidaFin:=nColumnas;
    end;
  until cad='';
  nColumnas:=nColumnas-1; {Cantidad de filas del archivo excel}
  if (nEntrada=0)or(nSalida=0) then Exit;
  TipoProgramaGenerado:=WorkSheet.Cells[1, 1].Value;{Lee tipo de programa}
  LabelProgramaGenerado.Caption:=TipoProgramaGenerado;
  if TipoProgramaGenerado='KBP' then CBII:=PKIP_CC;
  if TipoProgramaGenerado='LCD' then CBII:=LCD_CC;
  if TipoProgramaGenerado='NLCD' then CBII:=BCD_LCD_CC;
  if TipoProgramaGenerado='CONV' then CBII:=CONV_CC;

  case CBII of
  PKIP_CC,LCD_CC,CONV_CC:begin {Lee ENTRADA y SALIDA}
      valentMax:=0; valsalMax:=0;
      for i:=3 to nfilas do
      begin {Lee Tabla de Entrada-Salida}
        valent:=WorkSheet.Cells[i, nEntrada].Value;
        valsal:=WorkSheet.Cells[i, nSalida].Value;
        vObjetivo[i-3,COL_ENTRADA]:=valent;
        vObjetivo[i-3,COL_SALIDA]:=valsal;
        if valent> valentMax then valentMax:=valent;
        if valsal> valsalMax then valsalMax:=valsal;
      end;
      NUMERO_DE_CADENAS_DE_SALIDA:=nfilas-2;
      NUMERO_DE_BITS_POR_PARTE:=1;
      {Visualización}
      SGDATOS.cells[0,0]:='ENTRADA';
      SGDATOS.cells[1,0]:='SALIDA';
      SGDATOS.RowCount:=nfilas;
      for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
      begin {Visualizar vObjetivo en SGDATOS}
        SGDATOS.cells[0,i+2]:=IntToStr(vObjetivo[i,COL_ENTRADA]);
        SGDATOS.cells[1,i+2]:=IntToStr(vObjetivo[i,COL_SALIDA]);
      end;
    end;
  BCD_LCD_CC:begin {Lee ENTRADA y desde SALIDA hasta SALIDAFIN}
      NUMERO_DE_CADENAS_DE_SALIDA:=nfilas-2;
      NUMERO_DE_BITS_POR_PARTE:=1;
      NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA:=nSalidaFin-nSalida+1;
      SetLength(dtsObjetivo,NUMERO_DE_CADENAS_DE_SALIDA);
      fila:=0;
      for i:=3 to nfilas do
      begin
        vObjetivo[i-3,COL_ENTRADA]:=WorkSheet.Cells[i, nEntrada].Value;
        vObjetivo[i-3,COL_SALIDA]:=WorkSheet.Cells[i, nSalida].Value;
        columna:=0;
        for j:=nSalida to nSalidaFin do
        begin
          valsal:=WorkSheet.Cells[i, j].Value;
          if valsal> valsalMax then valsalMax:=valsal;
          dtsObjetivo[fila,columna]:=valsal;
          Inc(columna);
        end;
        Inc(fila);
      end;
      {Visualización}
      SGDATOS.RowCount:=nfilas;
      SGDATOS.ColCount:=NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA+1;
      SGDATOS.cells[0,0]:='ENTRADA';
      SGDATOS.cells[1,0]:='SALIDA';
      for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
      begin
        SGDATOS.cells[j+1,0]:=WorkSheet.Cells[1, j+nSalida].Value;
      end;
      for i:=0 to NUMERO_DE_CADENAS_DE_SALIDA-1 do
      begin
        SGDATOS.cells[0,i+2]:=IntToStr(vObjetivo[i,COL_ENTRADA]);
        for j:=0 to NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA-1 do
        begin
          SGDATOS.cells[j+1,i+2]:=IntToStr(dtsObjetivo[i,j]);
        end;
      end;
    end;
  end;

  case CBII of
  PKIP_CC:begin
      NUMERO_DE_PARTES_DE_SALIDA:=Ceil(Log2(valsalMax+1));
    end;
  CONV_CC:begin
      NUMERO_DE_PARTES_DE_SALIDA:=Ceil(Log2(valsalMax+1));
      NUMERO_DE_PARTES_DE_ENTRADA:=Ceil(Log2(valentMax));
    end;
  LCD_CC:begin
      NUMERO_DE_PARTES_DE_SALIDA:=8;
    end;
  BCD_LCD_CC:begin
      NUMERO_DE_PARTES_DE_SALIDA:=8;
    end;
  end;

  {Traslado de Botón Iniciar}
  case CBII of
  PKIP_CC:begin
      IniciarCC_KB;
    end;
  CONV_CC:begin
      IniciarCC_CONV;
    end;
  LCD_CC:begin
      IniciarCC_LCD;
    end;
  BCD_LCD_CC:begin
      IniciarCC_BCD_LCD;
    end;
  end;

  {Determina Columna Libre en Hoja3 para colocar resultado}
  WorkSheet := Unassigned;
  WorkSheet := WorkBook.WorkSheets.Item['Hoja3'];
  nColumnas:=3;{Despues del incremento comienza en 4}
  repeat {Busca columna libre en la fila 2}
    Inc(nColumnas);
    cad:= WorkSheet.Cells[2,nColumnas].Value;
  until cad='';
  NumeroProgramaGenerado:=nColumnas-3;{En la hoja ya estan numerados}
  {Leer Instrucciones}
  WorkSheet := Unassigned;
  WorkSheet := WorkBook.WorkSheets.Item['Hoja4'];
  leerInstruccionesAVRdeXLSabierto(WorkSheet);
  {Leer Parametros}
  WorkSheet := Unassigned;
  WorkSheet := WorkBook.WorkSheets.Item['Hoja5'];
  leerParametrosAVRdeXLSabierto(WorkSheet);

  WorkSheet := Unassigned;
  WorkBook := Unassigned;
  ExcelFile.Quit;
  ExcelFile := Unassigned;

  mostrarTablaInstrucciones(ISetAVR,MemoResultados);
  mostrarParametros;

end;
procedure TSDIAppForm.ButtonMOCCClick(Sender: TObject);
begin
  TiempoInicio:=Time;
  PanelOpciones.Visible:=False;
  ButtonParar.enabled:=TRUE;
  ButtonLectura.enabled:=FALSE;
  ButtonMOCC.enabled:=FALSE;
//  NumeroProgramaGenerado:=seNumeroEvolucion.Value;
  LabelNumPrograma.Caption:=IntToStr(NumeroProgramaGenerado);
  CantidadProgramasGenerados:=1;
  case CBII of
  PKIP_CC,CONV_CC:begin
      convertirObjetivoW(vObjetivo,mvpo);
      fMoccMax:=NUMERO_DE_PARTES_DE_SALIDA*NUMERO_DE_CADENAS_DE_SALIDA;
    end;
  LCD_CC:begin
      ArreglarDiagramaDeTiempo;
      fMoccMax:=NUMERO_DE_PARTES_DE_SALIDA*(NUMERO_DE_CADENAS_DE_SALIDA+1)*
                    (NUMERO_DE_CADENAS_DE_SALIDA) div 2;
//      fMoccMax:=2*NUMERO_DE_PARTES_DE_SALIDA*(NUMERO_DE_CADENAS_DE_SALIDA+1)*
//                    (NUMERO_DE_CADENAS_DE_SALIDA) div 2;
    end;
  BCD_LCD_CC:begin
      fMoccMax:=(NUMERO_DE_PARTES_DE_SALIDA*(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA+1)*
                    (NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA) div 2)*
                    NUMERO_DE_CADENAS_DE_SALIDA;
//      fMoccMax:=(NUMERO_DE_PARTES_DE_SALIDA*2*(NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA+1)*
//                    (NUMERO_DE_VALORES_EN_CADENA_DE_SALIDA) div 2)*
//                    NUMERO_DE_CADENAS_DE_SALIDA;
    end;
  end;
  iniciar_CC;
  timerMOCC.enabled:=TRUE;
end;
procedure TSDIAppForm.ConvertirSecuencia_LCD_DIN_a_ASM;
var
  i:Integer;
  nig,nie,nec:Integer;
begin
    {Borrar SG y Rich}
//    for i := 0 to SGArmado.RowCount - 1 do SGArmado.Rows[i].Clear;
    MemoSol.Clear;

    {Generar Programa ASM}
//    MatrizProgramaAStringGrid(Sol.progSol);
//    llenarConRecuperacion(Sol.pereSol.rec);
//    implementarControlNivel1(Sol.contSol.bif1);
//    implementarControlNivel2(Sol.contSol.bif1,Sol.contSol.bif2);
//    llenarSGconSolucion(Sol.nPSol,Sol.nISol);

    nig:=0; nie:=0; nec:=0;
    {nig-Cuenta instrucciones generadas. nie-cuenta instr. evolucionadas}
    PrimerasInstruccionesEnRich_LCD(MemoSol,nig,nec);
    MatrizProgramaAMemo_DIN(MemoSol,SolDin,nie);
//    stringGridARich(nig,nie,nec);
//    completarRichConSolucion(Sol.nPSol,Sol.nISol,nig,nec);
//    UltimasInstruccionesEnRich_LCD(nig,nec);
    {Salvar tamano: comentarios_etiquetas, instr genera, inst evolucionadas}
    MemoTamano.Lines.Add(intToStr(nec)+'  '+intToStr(nig)+'  '+intToStr(nie));
    MemoTamano.Lines.Add(intToStr(nig)+'  '+intToStr(nie)+'  '+intToStr(nec));
    MemoTamano.Lines.Add(intToStr(nec+nig)+'  '+intToStr(nig+nie)+'  '+intToStr(nie+nec));
    MemoTamano.Lines.Add(intToStr(nec+nig+nie)+'  '+intToStr(nig+nie+nec)+'  '+intToStr(nie+nec+nig));
    {Salvar ASM}
    MemoSol.Lines.saveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.ASM'));
    MemoTamano.Lines.saveToFile(ChangeFileExt(nombreArchivoEntradaXLS,'.SIZ'));
end;
procedure TSDIAppForm.TimerMOCCTimer(Sender: TObject);
begin
  tmocc:=tmocc+1;

  EjecutarProcesoEvolutivo_CC;
  case CBII of
  PKIP_CC,CONV_CC:begin
      LlenarEtiquetas_CC;
      end;
  LCD_CC:begin
      LlenarEtiquetas_GA_DIN;
      end;
  BCD_LCD_CC:begin
      LlenarEtiquetas_GA_DIN;
      end;
  end;

  if (nemocc>=NUMERO_MAXIMO_DE_EVALUACIONES) then
  begin
    timerMOCC.enabled:=FALSE;
    LabelError.Color:=clBlue;
    SGSpecies.Font.Color:=clBlue;
    SDIAppForm.salvarArchivos;
    //ProcesarProgramaHumano;
    //salvarCaracteristicasPHenExcel;
    ButtonParar.enabled:=FALSE;
    finalizar_CC;
  end;
end;
procedure TSDIAppForm.ButtonPararClick(Sender: TObject);
var
  DialogValue: Integer;
begin
  DialogValue :=id_No;
  DialogValue := MessageDlg('¿Desea parar y salvar?', mtConfirmation,
    [mbYes, mbNo], 0);
  if DialogValue <> id_Yes then exit;
  timerMOCC.enabled:=FALSE;

  salvarArchivos;
  //ProcesarProgramaHumano;

  ButtonParar.enabled:=FALSE;
  ButtonReanudar.enabled:=TRUE;

  //finalizar_CC;
end;

procedure TSDIAppForm.CargarDeExcelAMemo(nColumna:Integer;var Memo:TMemo);
var
  i,j,fila,columna,valent,valsal,valentMax,valsalMax:Integer;
  nfilas,nColumnas,nEntrada,nSalida:Integer;
  cad:string;
  ExcelFile : Variant;
  WorkBook : Variant;
  WorkSheet : Variant;
  nFilasVaciasSeguidas,filaAnteriorVacia,filaActualVacia:Integer;
begin
  MemoSol.Clear;
  ExcelFile :=  CreateOleObject('Excel.Application');
//  WorkBook := ExcelFile.WorkBooks.Open(GetCurrentDir+'\'+nombreArchivoEntradaXLS);
  WorkBook := ExcelFile.WorkBooks.Open(nombreArchivoEntradaXLS);
  WorkSheet := WorkBook.WorkSheets.Item['Hoja2'];
  nfilas:=1;  nFilasVaciasSeguidas:=0; filaAnteriorVacia:=0; filaActualVacia:=0;
  repeat {Determina la cantidad de filas del archivo excel}
    Inc(nfilas);
    cad:= WorkSheet.Cells[nfilas, nColumna].Value;
    if cad='' then
    begin
      filaActualVacia:=1;
    end
    else
    begin
      filaActualVacia:=0;
      nFilasVaciasSeguidas:=0;
    end;
    if (filaAnteriorVacia=1)and(filaActualVacia=1) then
    begin
      inc(nFilasVaciasSeguidas);
    end;
    Memo.Lines.Add(cad);
    filaAnteriorVacia:=filaActualVacia;
  until (nFilasVaciasSeguidas>5)or(nfilas>1000);
  WorkSheet := Unassigned;
  WorkBook := Unassigned;
  ExcelFile.Quit;
  ExcelFile := Unassigned;
end;

procedure TSDIAppForm.ProcesarProgramaHumano;
var
  secuencia:Tseq;
  tamano1,nBytes1,nCiclos1,tamano2,nBytes2,nCiclos2:Integer;
begin
//  CargarDeExcelAMemo(2,MemoSol);

  {Procesar Programa Humano. Se usa un archivo ASM para determinar la cantidad
   de bytes y otro archivo ASM para determinar la cantidad de ciclos}
  CargarDeExcelAMemo(2,MemoSol);

//  MemoSol.Clear;
//  MemoSol.Lines.LoadFromFile(ExtractFilePath(nombreArchivoEntradaXLS)+
//                             ArchivoDeProgramaHumanoBytes);
  MemoAseq(MemoSol,secuencia,memoHEX);
  tamano1:=Length(secuencia);
  {Calcula Numero de bytes}
  calcularCiclosYbytesDeSecuencia(ISetAVR,secuencia,nCiclos1,nBytes1);

  CargarDeExcelAMemo(3,MemoSol);

//  MemoSol.Clear;
//  MemoSol.Lines.LoadFromFile(ExtractFilePath(nombreArchivoEntradaXLS)+
//                             ArchivoDeProgramaHumanoCiclos);
  MemoAseq(MemoSol,secuencia,memoHEX);
  tamano2:=Length(secuencia);
  {Calcula Numero de ciclos}
  calcularCiclosYbytesDeSecuencia(ISetAVR,secuencia,nCiclos2,nBytes2);

  MemoTiempos.Clear;
  MemoTiempos.Lines.add(numFCad(0,6)+numFCad(0,6)+numFCad(0,6)+
                    numFCad(0,6)+ numFCad(0,6)+numFCad(0,6)+
                    numFCad(tamano1,6)+numFCad(nBytes1,6)+numFCad(nCiclos2,6));
  capturarEstadistica('','','','','','',
                    numFCad(tamano1,6),numFCad(nBytes1,6),numFCad(nCiclos2,6),
                    '');
  MemoTiempos.Lines.SaveToFile(ExtractFilePath(nombreArchivoEntradaXLS)+
                               ArchivoDeSalidaHumano+'.TIE');
end;
procedure TSDIAppForm.ButtonProgramaHClick(Sender: TObject);
begin
  ProcesarProgramaHumano;
end;

end.
