object frmFirstStart: TfrmFirstStart
  Left = 0
  Top = 0
  HelpType = htKeyword
  HelpKeyword = 'Chatter '#8212' %s'#8230
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 264
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblFirstStartInfo: TLabel
    Left = 8
    Top = 8
    Width = 155
    Height = 19
    HelpType = htKeyword
    HelpKeyword = 'Chatter: %s'#8230
    Caption = 'Chatter: STEPINFO'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 421
    Top = 231
    Width = 9
    Height = 25
    Shape = bsLeftLine
  end
  object lblStepInfo: TLabel
    Left = 11
    Top = 236
    Width = 118
    Height = 13
    HelpType = htKeyword
    HelpKeyword = 'Step: %d/%d'
    AutoSize = False
    Caption = 'step_id_progress'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object pnlStep3: TPanel
    Left = 8
    Top = 33
    Width = 507
    Height = 192
    HelpType = htKeyword
    HelpKeyword = 'History settings'
    TabOrder = 5
    object cbSaveHistory: TCheckBox
      Left = 42
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Save history'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = cbSaveHistoryClick
    end
    object cbSaveChannels: TCheckBox
      Left = 42
      Top = 92
      Width = 191
      Height = 17
      Caption = 'Save history for public channels'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cbSaveOnlyAdded: TCheckBox
      Left = 42
      Top = 47
      Width = 175
      Height = 17
      Caption = 'Don'#39't add new contacts'
      TabOrder = 2
    end
  end
  object pnlStep1: TPanel
    Left = 8
    Top = 33
    Width = 507
    Height = 192
    HelpType = htKeyword
    HelpKeyword = 'Locating Path of Exile install directory'
    TabOrder = 0
    object lblPathAutodetect: TLabel
      Left = 15
      Top = 115
      Width = 86
      Height = 13
      Caption = 'lblPathAutodetect'
      Visible = False
    end
    object tGamePath: TEdit
      Left = 15
      Top = 78
      Width = 389
      Height = 31
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object bBrowsePath: TButton
      Left = 410
      Top = 78
      Width = 75
      Height = 31
      Caption = #8230
      TabOrder = 1
      OnClick = bBrowsePathClick
    end
  end
  object pnlStep2: TPanel
    Left = 8
    Top = 33
    Width = 507
    Height = 192
    HelpType = htKeyword
    HelpKeyword = 'Sound configuration'
    TabOrder = 4
    object rbInternalSound: TRadioButton
      Left = 42
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Build-in sound'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbInternalSoundClick
    end
    object rbCustomSound: TRadioButton
      Left = 42
      Top = 55
      Width = 113
      Height = 17
      Caption = 'Custom sound'
      TabOrder = 1
      OnClick = rbInternalSoundClick
    end
    object cbPlayWhenPoEOpen: TCheckBox
      Left = 42
      Top = 114
      Width = 231
      Height = 17
      Caption = 'Also play sound while game in foreground'
      TabOrder = 2
    end
    object cbAlertGuildChat: TCheckBox
      Left = 42
      Top = 137
      Width = 175
      Height = 17
      Caption = 'Also alert guild chat messages'
      TabOrder = 3
    end
    object tCustomSound: TEdit
      Left = 56
      Top = 78
      Width = 217
      Height = 21
      TabOrder = 4
    end
    object bBrowseCustom: TButton
      Left = 279
      Top = 76
      Width = 75
      Height = 25
      Caption = #8230
      TabOrder = 5
      OnClick = bBrowseCustomClick
    end
  end
  object bBack: TButton
    Left = 256
    Top = 231
    Width = 75
    Height = 25
    Caption = #171' Back'
    TabOrder = 1
    OnClick = bBackClick
  end
  object bNext: TButton
    Left = 337
    Top = 231
    Width = 75
    Height = 25
    Caption = 'Next '#187
    TabOrder = 2
    OnClick = bNextClick
  end
  object bExit: TButton
    Left = 432
    Top = 231
    Width = 75
    Height = 25
    TabOrder = 3
    OnClick = bExitClick
  end
  object bSave: TButton
    Left = 337
    Top = 231
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 6
    Visible = False
    OnClick = bSaveClick
  end
  object cbStep: TComboBox
    Left = 80
    Top = 6
    Width = 435
    Height = 24
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 7
    Visible = False
    OnChange = cbStepChange
  end
  object ood: TOpenDialog
    Filter = 'Wave file (*.wav)|*.wav'
    Left = 320
    Top = 48
  end
  object od: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 352
    Top = 48
  end
end
