program FIlaImpressaoGladius;

uses
  Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FormPrincipal},
  UnitConexao in '..\votacao\Sistema\UnitConexao.pas' {dmConexao: TDataModule},
  UnitHerancaRelatorio in '..\votacao\Sistema\Herancas\UnitHerancaRelatorio.pas' {FormHerancaRelatorio},
  UnitRelCredorPorProcurador in '..\votacao\Sistema\Relatorios\UnitRelCredorPorProcurador.pas' {FormRelatorioCredorPorProcurador},
  UnitMenu in '..\votacao\Sistema\UnitMenu.pas' {FormMenu},
  UnitRelCodBarrasCredor in '..\votacao\Sistema\Relatorios\UnitRelCodBarrasCredor.pas' {FormRelatorioCodBarrasCredor},
  UnitFilaImpressaoController in 'UnitFilaImpressaoController.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmConexao, dmConexao);
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.CreateForm(TFormMenu, FormMenu);
  Application.Run;
end.
