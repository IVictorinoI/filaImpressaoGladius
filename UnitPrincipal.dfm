object FormPrincipal: TFormPrincipal
  Left = 192
  Top = 125
  Width = 928
  Height = 480
  Caption = 'Fila de impress'#227'o Gladius'
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 21
  object PanelTopo: TPanel
    Left = 0
    Top = 0
    Width = 912
    Height = 105
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 18
      Width = 56
      Height = 21
      Caption = 'Periodo:'
    end
    object Label2: TLabel
      Left = 18
      Top = 48
      Width = 49
      Height = 21
      Caption = 'Tempo:'
    end
    object lblTempo: TLabel
      Left = 272
      Top = 48
      Width = 82
      Height = 21
      Caption = '2 Segundos'
    end
    object dtpPeriodoIni: TDateTimePicker
      Left = 72
      Top = 16
      Width = 129
      Height = 29
      Date = 42684.000236805560000000
      Time = 42684.000236805560000000
      TabOrder = 0
      OnChange = dtpPeriodoIniChange
    end
    object dtpPeriodoFin: TDateTimePicker
      Left = 216
      Top = 16
      Width = 129
      Height = 29
      Date = 42684.000331828710000000
      Time = 42684.000331828710000000
      TabOrder = 1
      OnChange = dtpPeriodoFinChange
    end
    object rgStatus: TRadioGroup
      Left = 360
      Top = 8
      Width = 521
      Height = 65
      Caption = 'Status'
      Columns = 5
      ItemIndex = 0
      Items.Strings = (
        'Pendente'
        'Impresso'
        'Erro'
        'Imprimindo'
        'Todos')
      TabOrder = 2
      OnClick = rgStatusClick
    end
    object tbTempo: TTrackBar
      Left = 66
      Top = 48
      Width = 201
      Height = 45
      Min = 1
      Position = 2
      SelEnd = 1
      SelStart = 10
      TabOrder = 3
      OnChange = tbTempoChange
    end
  end
  object PanelClient: TPanel
    Left = 0
    Top = 105
    Width = 912
    Height = 287
    Align = alClient
    TabOrder = 1
    object DBGrid1: TDBGrid
      Left = 1
      Top = 1
      Width = 910
      Height = 285
      Align = alClient
      DataSource = DS
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      TitleFont.Charset = ANSI_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -16
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object PanelBase: TPanel
    Left = 0
    Top = 392
    Width = 912
    Height = 49
    Align = alBottom
    TabOrder = 2
    object bbAtualizar: TBitBtn
      Left = 8
      Top = 8
      Width = 81
      Height = 33
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = bbAtualizarClick
    end
    object bbImprimir: TBitBtn
      Left = 96
      Top = 8
      Width = 81
      Height = 33
      Caption = 'Imprimir'
      TabOrder = 1
      OnClick = bbImprimirClick
    end
    object bbCancelarImpressoes: TBitBtn
      Left = 712
      Top = 8
      Width = 193
      Height = 33
      Caption = 'Cancelar todas pendentes'
      TabOrder = 2
      OnClick = bbCancelarImpressoesClick
    end
  end
  object DS: TDataSource
    DataSet = dmConexao.QueryFilaImp
    Left = 40
    Top = 97
  end
  object QueryFilaImprimir: TIBQuery
    Database = dmConexao.DB
    Transaction = dmConexao.Transaction
    BufferChunks = 1000
    CachedUpdates = False
    Left = 200
    Top = 112
  end
  object QueryUpdateFilaImp: TIBQuery
    Database = dmConexao.DB
    Transaction = dmConexao.Transaction
    BufferChunks = 1000
    CachedUpdates = False
    Left = 240
    Top = 112
  end
  object TimerVerifica: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = TimerVerificaTimer
    Left = 352
    Top = 241
  end
end
