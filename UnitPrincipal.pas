unit UnitPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, DB, StdCtrls, Buttons,
  IBCustomDataSet, IBQuery, ComCtrls;

type
  TFormPrincipal = class(TForm)
    PanelTopo: TPanel;
    PanelClient: TPanel;
    PanelBase: TPanel;
    DBGrid1: TDBGrid;
    DS: TDataSource;
    bbAtualizar: TBitBtn;
    bbImprimir: TBitBtn;
    QueryFilaImprimir: TIBQuery;
    QueryUpdateFilaImp: TIBQuery;
    TimerVerifica: TTimer;
    Label1: TLabel;
    dtpPeriodoIni: TDateTimePicker;
    dtpPeriodoFin: TDateTimePicker;
    rgStatus: TRadioGroup;
    bbCancelarImpressoes: TBitBtn;
    tbTempo: TTrackBar;
    Label2: TLabel;
    lblTempo: TLabel;
    procedure bbAtualizarClick(Sender: TObject);
    procedure bbImprimirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerVerificaTimer(Sender: TObject);
    procedure rgStatusClick(Sender: TObject);
    procedure dtpPeriodoFinChange(Sender: TObject);
    procedure dtpPeriodoIniChange(Sender: TObject);
    procedure bbCancelarImpressoesClick(Sender: TObject);
    procedure tbTempoChange(Sender: TObject);
  private
    { Private declarations }
    procedure AtualizarLista();
    procedure VerificaNovasSolicitacoes();
    procedure ImprimirProximoRelatorio();
    procedure ImprimirRelatorioPeloCodigoFila(codigoFilaImp:Integer);
    procedure PreenchePadroesForm;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

uses UnitConexao, UnitRelCredorPorProcurador, UnitHerancaRelatorio,
  UnitMenu, UnitRelCodBarrasCredor, UnitFilaImpressaoController;



{$R *.dfm}

{ TFormPrincipal }

procedure TFormPrincipal.AtualizarLista;
var
  sql:String;
begin
  Try
    FormMenu.CarregaAssembleia;
    FormMenu.CarregaConfigs;
    dmConexao.QueryFilaImp.Close;
    SQL:='';
    SQL:=SQL+' select FILAIMP.*, USUARIO.nm_usuario, ';
    SQL:=SQL+' cast(CASE ';
    SQL:=SQL+'   WHEN (CD_STATUS = 0) THEN ''Pendente'' ';
    SQL:=SQL+'   WHEN (CD_STATUS = 1) THEN ''Impresso'' ';
    SQL:=SQL+'   WHEN (CD_STATUS = 2) THEN ''Erro'' ';
    SQL:=SQL+'   WHEN (CD_STATUS = 3) THEN ''Imprimindo'' ';
    SQL:=SQL+' END AS VARCHAR(20)) "DS_STATUS" ';
    SQL:=SQL+' from FILAIMP ';
    SQL:=SQL+' LEFT JOIN USUARIO ON (USUARIO.cd_usuario = FILAIMP.cd_usuario) ';
    SQL:=SQL+' WHERE 1=1 ';
    SQL:=SQL+' AND FILAIMP.DT_SOLICITACAO BETWEEN '+QuotedStr(DataDB(dtpPeriodoIni.Date))+' AND '+QuotedStr(DataDB(dtpPeriodoFin.Date))+' ';
    if(rgStatus.ItemIndex<>4)then begin
      SQL:=SQL+' AND CD_STATUS = '+IntToStr(rgStatus.ItemIndex);
    end;
    SQL:=SQL+' ORDER BY FILAIMP.HR_SOLICITACAO DESC ';

    dmConexao.QueryFilaImp.SQL.Clear;
    dmConexao.QueryFilaImp.SQL.Add(SQL);

    dmConexao.QueryFilaImp.Open;
  Except
    on e : Exception do begin
      ShowMessage(e.Message);
    end;
  end;
end;

procedure TFormPrincipal.bbAtualizarClick(Sender: TObject);
begin
  Try
    bbAtualizar.Enabled := false;
    Self.AtualizarLista;
  Finally
    bbAtualizar.Enabled := true;
  end;
end;

procedure TFormPrincipal.bbImprimirClick(Sender: TObject);
begin
  Try
    bbImprimir.Enabled:=false;
    if(dmConexao.QueryFilaImpCD_FILAIMP.AsInteger>0)then begin
      Self.ImprimirRelatorioPeloCodigoFila(dmConexao.QueryFilaImpCD_FILAIMP.AsInteger);
    end;
  Finally
    bbImprimir.Enabled:=true;
  end;
end;

procedure TFormPrincipal.FormShow(Sender: TObject);
begin
  Self.AtualizarLista;
  Self.PreenchePadroesForm;
  TimerVerifica.Enabled:=true;
end;

procedure TFormPrincipal.VerificaNovasSolicitacoes;
begin
  if(GetQuantFilaImpParaImprimir(QueryFilaImprimir)>0)then begin
    Self.ImprimirProximoRelatorio();
  end;
end;

procedure TFormPrincipal.ImprimirProximoRelatorio;
var
  codigoProximoFilaImp:Integer;
begin
  codigoProximoFilaImp:=GetCodigoProximoRegistroFilaImp(QueryFilaImprimir);

  if(codigoProximoFilaImp>0)then begin
    ImprimirRelatorioPeloCodigoFila(codigoProximoFilaImp);
  end;
end;

procedure TFormPrincipal.TimerVerificaTimer(Sender: TObject);
begin
  Try
    TimerVerifica.Enabled:=False;
    Self.VerificaNovasSolicitacoes;
    PanelBase.Caption:='Ultima verificação: '+TimeToStr(Now);
  Finally
    TimerVerifica.Enabled:=True;
  end;
end;

procedure TFormPrincipal.ImprimirRelatorioPeloCodigoFila(codigoFilaImp: Integer);
var
  nomeFormularioRelatorio, msg:String;
begin
  Try
    if not(dmConexao.Transaction.InTransaction) then begin
       dmConexao.Transaction.StartTransaction;
    end;
    SetStatusFilaImpImprimindo(QueryUpdateFilaImp, codigoFilaImp);
    dmConexao.Transaction.CommitRetaining;

    if not(dmConexao.Transaction.InTransaction) then begin
       dmConexao.Transaction.StartTransaction;
    end;
    nomeFormularioRelatorio:=GetNomeFormularioFilaImp(QueryFilaImprimir,codigoFilaImp);
    AbrirRelatorioComParametrosCarregados(nomeFormularioRelatorio, codigoFilaImp);
    SetStatusFilaImpImpresso(QueryUpdateFilaImp, codigoFilaImp);

    dmConexao.Transaction.CommitRetaining;
  Except
    on E:Exception do begin
      dmConexao.Transaction.RollbackRetaining;
      msg:='Erro ao imprimir relatório da fila de impressão número '+IntToStr(codigoFilaImp)+': '+e.Message;
      FormMenu.SalvarNoLog(msg);

      if not(dmConexao.Transaction.InTransaction) then begin
         dmConexao.Transaction.StartTransaction;
      end;
      SetStatusFilaImpErro(QueryUpdateFilaImp, codigoFilaImp, msg);
      dmConexao.Transaction.CommitRetaining;
    end;
  end;
end;

procedure TFormPrincipal.PreenchePadroesForm;
begin
  dtpPeriodoIni.DateTime:=now;
  dtpPeriodoFin.DateTime:=now;
end;

procedure TFormPrincipal.rgStatusClick(Sender: TObject);
begin
  Self.AtualizarLista;
end;

procedure TFormPrincipal.dtpPeriodoFinChange(Sender: TObject);
begin
  Self.AtualizarLista;
end;

procedure TFormPrincipal.dtpPeriodoIniChange(Sender: TObject);
begin
  Self.AtualizarLista;
end;

procedure TFormPrincipal.bbCancelarImpressoesClick(Sender: TObject);
begin
  bbCancelarImpressoes.Enabled:=false;
  Try
    if not(dmConexao.Transaction.InTransaction) then begin
       dmConexao.Transaction.StartTransaction;
    end;
    CancelarTodasPendentes(QueryUpdateFilaImp);
    Self.AtualizarLista;
    dmConexao.Transaction.CommitRetaining;
  Except
    on E:Exception do begin
      dmConexao.Transaction.RollbackRetaining;
      FormMenu.SalvarNoLog('Erro ao cancelar impressões pendentes: '+e.Message);
    end;
  end;
  bbCancelarImpressoes.Enabled:=True;
end;

procedure TFormPrincipal.tbTempoChange(Sender: TObject);
begin
  lblTempo.Caption:=IntToStr(tbTempo.Position)+' Segundos';
  TimerVerifica.Enabled:=False;
  TimerVerifica.Interval:=tbTempo.Position*1000;
  TimerVerifica.Enabled:=True;
end;

end.
