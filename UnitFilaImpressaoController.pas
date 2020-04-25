unit UnitFilaImpressaoController;

interface

uses DB, UnitConexao, IBQuery, Classes, UnitRelCredorPorProcurador, UnitRelCodBarrasCredor,
     Forms, UnitHerancaRelatorio, SysUtils;

CONST
 STATUS_FILAIMP_PENDENTE = 0;
 STATUS_FILAIMP_IMPRESSO = 1;
 STATUS_FILAIMP_ERRO = 2;
 STATUS_FILAIMP_IMPRIMINDO = 3;

function GetCodigoProximoRegistroFilaImp(Query:TIBQuery):Integer;
function GetQuantFilaImpParaImprimir(Query:TIBQuery):Integer;
function GetNomeFormularioFilaImp(Query:TIBQuery;codigoFilaImp:Integer):String;

procedure SetStatusFilaImpImprimindo(Query:TIBQuery;codigoFilaImp:Integer);
procedure SetStatusFilaImpImpresso(Query:TIBQuery;codigoFilaImp:Integer);
procedure SetStatusFilaImpErro(Query:TIBQuery;codigoFilaImp:Integer; msgErro:String);

procedure CancelarTodasPendentes(Query:TIBQuery);

procedure AbrirRelatorioComParametrosCarregados(formName: string;cdFilaImp:Integer);

function DataDB(data:TDateTime):string;


implementation

function GetCodigoProximoRegistroFilaImp(Query:TIBQuery): Integer;
var sql:String;
    codigoRetornar:Integer;
begin
  Try
    codigoRetornar:=0;
    sql:= ' SELECT FIRST 1 CD_FILAIMP FROM FILAIMP FI WHERE coalesce(FI.cd_status,0) in (:STATUS_PENDENTE) ORDER BY FI.CD_FILAIMP ASC ';
    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('STATUS_PENDENTE').AsInteger:= STATUS_FILAIMP_PENDENTE;
    Query.Open;

    if(Query.FieldByName('CD_FILAIMP').AsInteger>0)then begin
      codigoRetornar:=Query.FieldByName('CD_FILAIMP').AsInteger;
    end;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' GetCodigoProximoRegistroFilaImp SQL ('+sql+') ');
    end;
  end;
  Result:=codigoRetornar;
end;

function GetQuantFilaImpParaImprimir(Query:TIBQuery):Integer;
var sql:String;
begin
  Try
    sql:= ' SELECT COUNT(*) as QT FROM FILAIMP FI WHERE coalesce(FI.cd_status,0) in (:STATUS_PENDENTE) ';
    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('STATUS_PENDENTE').AsInteger:= STATUS_FILAIMP_PENDENTE;
    Query.Open;
    Result:=Query.FieldByName('QT').AsInteger;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' GetQuantFilaImpParaImprimir SQL ('+sql+') ');
    end;
  end;  
end;

function GetNomeFormularioFilaImp(Query:TIBQuery;codigoFilaImp:Integer):String;
var sql:String;
begin
  Try
    sql:= ' SELECT NM_FORMULARIO FROM FILAIMP FI WHERE FI.CD_FILAIMP = :CD_FILAIMP ';
    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('CD_FILAIMP').AsInteger:= codigoFilaImp;
    Query.Open;
    Result:=Query.FieldByName('NM_FORMULARIO').AsString;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' GetNomeFormularioFilaImp SQL ('+sql+') ');
    end;
  end;
end;

procedure SetStatusFilaImpImprimindo(Query:TIBQuery;codigoFilaImp:Integer);
var sql:String;
begin
  Try
    sql:= '';
    sql:= sql+ ' UPDATE FILAIMP FI SET CD_STATUS = :CD_STATUS ';
    sql:= sql+ ' WHERE FI.CD_FILAIMP = :CD_FILAIMP ';

    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('CD_FILAIMP').AsInteger:= codigoFilaImp;
    Query.Params.ParamByName('CD_STATUS').AsInteger:= STATUS_FILAIMP_IMPRIMINDO;
    Query.ExecSQL;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' SetStatusFilaImpImprimindo SQL ('+sql+') ');
    end;
  end;
end;

procedure SetStatusFilaImpImpresso(Query:TIBQuery;codigoFilaImp:Integer);
var sql:String;
begin
  Try
    sql:= '';
    sql:= sql+ ' UPDATE FILAIMP FI SET CD_STATUS = :CD_STATUS ';
    sql:= sql+ ' WHERE FI.CD_FILAIMP = :CD_FILAIMP ';

    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('CD_FILAIMP').AsInteger:= codigoFilaImp;
    Query.Params.ParamByName('CD_STATUS').AsInteger:= STATUS_FILAIMP_IMPRESSO;
    Query.ExecSQL;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' SetStatusFilaImpImpresso SQL ('+sql+') ');
    end;
  end;
end;

procedure SetStatusFilaImpErro(Query:TIBQuery;codigoFilaImp:Integer; msgErro:String);
var sql:String;
begin
  Try
    sql:= '';
    sql:= sql+ ' UPDATE FILAIMP FI SET CD_STATUS = :CD_STATUS, DS_MSGERRO = :DS_MSGERRO ';
    sql:= sql+ ' WHERE FI.CD_FILAIMP = :CD_FILAIMP ';

    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('CD_FILAIMP').AsInteger:= codigoFilaImp;
    Query.Params.ParamByName('CD_STATUS').AsInteger:= STATUS_FILAIMP_ERRO;
    Query.Params.ParamByName('DS_MSGERRO').AsString:= Copy(msgErro,1,300);
    Query.ExecSQL;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' SetStatusFilaImpErro SQL ('+sql+') ');
    end;
  end;
end;

procedure CancelarTodasPendentes(Query:TIBQuery);
var sql:String;
begin
  Try
    sql:= '';
    sql:= sql+ ' UPDATE FILAIMP FI SET CD_STATUS = :CD_STATUS ';
    sql:= sql+ ' WHERE FI.CD_STATUS = :CD_STATUS_PENDENTE ';

    Query.close;
    Query.SQL.Clear;
    Query.SQL.Add(sql);
    Query.Params.ParamByName('CD_STATUS_PENDENTE').AsInteger:= STATUS_FILAIMP_PENDENTE;
    Query.Params.ParamByName('CD_STATUS').AsInteger:= STATUS_FILAIMP_ERRO;
    Query.ExecSQL;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' CancelarTodasPendentes SQL ('+sql+') ');
    end;
  end;
end;

procedure AbrirRelatorioComParametrosCarregados(formName: string;cdFilaImp:Integer);
var
  FrmClass : TFormClass;
  Frm : TForm;
begin
  Try
    {Finalidade : Criar o Formulário pelo Nome}
    try
      FrmClass := TFormClass(FindClass('T'+formName));
      Frm      := FrmClass.Create(Application);
      (frm as TFormHerancaRelatorio).CarregarParametrosDaFilaDeImpressao(cdFilaImp);
      (frm as TFormHerancaRelatorio).cbVisualiza.ItemIndex:=4;
      (frm as TFormHerancaRelatorio).Show;
      (frm as TFormHerancaRelatorio).sbExecRelatorio.Click;
    finally
      Frm.Free;
    end;
  Except
    on e:Exception do begin
      Raise exception.Create('Erro '+e.Message+' AbrirRelatorioComParametrosCarregados SQL ('+''+') ');
    end;
  end;
end;

function DataDB(data:TDateTime):string;
begin
  Result:=FormatDateTime('yyyy-mm-dd', data );;
end;

initialization
   RegisterClass(TFormRelatorioCredorPorProcurador);
   RegisterClass(TFormRelatorioCodBarrasCredor);
end.

