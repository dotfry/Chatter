object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Path of Exile: Chatter...'
  ClientHeight = 239
  ClientWidth = 577
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000000000000000000000000000000000000000000000000
    000000000000141414FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FF000000FF000000FF000000FF000000FF4F4F4F80000000000000
    0000000000FF000000FF000000FF191919FF909090FF868686FF050505FF0000
    00FF000000FF000000FF000000FF000000FF000000FF000000FF4F4F4F802828
    2880000000FF000000FFDFDFDFFFFFFFFFFFD2D2D2FFBEBEBEFFFFFFFFFFB1B1
    B1FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF1111
    11FF000000FF636363FFFFFFFFFF9A9A9AFF000000FF000000FF292929FFFFFF
    FFFF727272FF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFFFFFFFFFFFFFFFFF000000FF000000FF000000FF000000FFFFFF
    FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFFFFFFFFFFFFFFFFF000000FF000000FF000000FF000000FFFFFF
    FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFFFFFFFFFFFFFFFFF000000FF000000FF000000FF000000FFFFFF
    FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFFFFFFFFFFFFFFFFF959595FF000000FF000000FF9A9A9AFFFFFF
    FFFFFFFFFFFF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFFFFFFFFFFFFFFFFFF4F4F4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FFFF696969FF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FFADADADFFFFFFFFFF666666FF5C5C5CFFC0C0C0FFAAAAAAFF1B1B
    1BFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FF040404FFFFFFFFFFF7F7F7FF000000FF000000FF000000FF0000
    00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
    00FF000000FF000000FF9B9B9BFFFFFFFFFF7C7C7CFF000000FF000000FF0000
    00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF3E3E
    3EFF000000FF000000FF000000FFBDBDBDFFFFFFFFFF858585FF000000FF0000
    00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FFB8B8
    B80C000000FF000000FF000000FF000000FF5E5E5EFFFFFFFFFFFFFFFFFF3D3D
    3DFF000000FF000000FF000000FF000000FF000000FF000000FF141414FF0000
    0000535353BF000000FF000000FF000000FF000000FF000000FF5D5D5DFFF4F4
    F4FF111111FF000000FF000000FF000000FF000000FF000000FF000000000000
    000000000000B8B8B80C3E3E3EFF000000FF000000FF000000FF000000FF0000
    00FF000000FF000000FF000000FF111111FF282828800000000000000000C001
    0000800000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000008000000080010000E0030000}
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    577
    239)
  PixelsPerInch = 96
  TextHeight = 13
  object tDetailedInfo: TMemo
    Left = 8
    Top = 39
    Width = 401
    Height = 192
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object lbContacts: TListBox
    Left = 415
    Top = 8
    Width = 156
    Height = 223
    Anchors = [akTop, akRight, akBottom]
    ItemHeight = 13
    PopupMenu = pmContacts
    TabOrder = 1
    OnClick = lbContactsClick
  end
  object bSettings: TBitBtn
    Left = 8
    Top = 8
    Width = 25
    Height = 25
    TabOrder = 2
    TabStop = False
    OnClick = bSettingsClick
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000A449A3A449A3
      A449A3A449A3D6BBA5A45528A45528D6BBA5A449A3A449A3A449A3A449A3A449
      A3A449A3A449A3A449A3A449A3DEC9BAA45528A45528A45528FFEACEFFEACEA4
      5528A45528A45528DEC9BAA449A3A449A3A449A3A449A3A449A3A449A3A45528
      FFEACEFFEACEBC6531FFEACEFFEACEBC6531FFEACEFFEACEA45528A449A3A449
      A3A449A3A449A3A449A3A449A3A45528FFEACEFFEACEFFEACEFFFFFFFFFFFFFF
      EACEFFEACEFFEACEA45528A449A3A449A3A449A3A449A3A449A3D6BBA5A45528
      A45528FFEACEFFFFFFA45528A45528FFFFFFFFEACEBC6531A45528C69A79A449
      A3A449A3A449A3A449A3A45528FFFFFFFFEACEFFFFFFA45528FFFFFFFFFFFFA4
      5528FFFFFFFFEACEFFEACEA45528284B82284B82BECDD3A449A3A45528FFFFFF
      FFEACEFFFFFFA45528FFFFFFFFFFFFA45528FFFFFFFFEACEFFFFFFA455284DBE
      FF4DBEFF284B82A449A3D6BBA5A45528BC6531FFFFFFFFFFFFA45528A45528FF
      FFFFFFFFFFBC6531A4552857B9EA4DBEFF4DBEFF284B82A449A3A449A3A45528
      FFFFFFFFEACEFFFFFFFFFFFFFFFFFFFFFFFFFFEACEFFEACEA45528EAFBFF4DBE
      FF284B82284B82A8BBC9A449A3A45528FFFFFFFFFFFFBC6531FFEACEFFEACEBC
      6531FFEACEFFFFFFA455282D6BA3EAFBFF4DBEFF8ECCFF284B82A449A3E2C2AF
      A45528A45528A45528FFFFFFFFFFFFA45528A45528A45528B7D6EB2D6BA3EAFB
      FF4DBEFFEAFBFF284B82A449A3A449A3A449A3A449A3C69A79A45528A4552828
      EFE7FFFFFF2D6BA32D6BA3EAFBFF28EDFA284B82284B82A8BBC9A449A3A449A3
      A449A3A449A3A449A3355B9FEAFBFF4DBEFF28EDFAEAFBFFEAFBFF28EDFA4DBE
      FF8ECCFF284B82A449A3A449A3A449A3A449A3A449A3A449A3355B9FFFFFFFEA
      FBFF284B824DBEFF4DBEFF284B824DBEFFEAFBFF284B82A449A3A449A3A449A3
      A449A3A449A3A449A3B2CBD8355B9F355B9F284B82EAFBFFEAFBFF284B82355B
      9F355B9FB2CBD8A449A3A449A3A449A3A449A3A449A3A449A3A449A3A449A3A4
      49A398AFC5355B9F355B9F98B2CAA449A3A449A3A449A3A449A3}
  end
  object bSound: TBitBtn
    Left = 39
    Top = 8
    Width = 25
    Height = 25
    TabOrder = 3
    TabStop = False
    OnClick = bSoundClick
  end
  object cbDebug: TCheckBox
    Left = 181
    Top = 16
    Width = 51
    Height = 17
    Caption = 'debug'
    TabOrder = 4
  end
  object bAbout: TBitBtn
    Left = 101
    Top = 8
    Width = 25
    Height = 25
    TabOrder = 5
    TabStop = False
    OnClick = bAboutClick
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF5F
      31275D3027FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FF8E6E25DEC58089523D5D3127FF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF907025F5
      E9BCDDC47F5E3127FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FF8F6F258D6D25FF00FFFF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF6D
      3529623328938872FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FF967526F6ECC0C5A568744230876A5FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF997827F7
      EDC2F6ECBFC4A4679E6F4D694438FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF947326F6EBBFC3A3669F734F866A
      5FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB490897E38309D6B64FF00FFFF
      00FFFF00FF6E3429F6EABFC3A365673428FF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFAB8361F8EECA7E3830FF00FFFF00FFFF00FF70362AF6ECBFC4A4676132
      27FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFAB8361F8EECACFB27B7E38307C
      382F78372DCAAC6EF7ECC1C6A6686A3328FF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFB6967CE7DAB8F8EECACFB27BCFB27BCEB177F8EEC6F7ECC3AD937B8A6B
      5FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB08B6EE7DAB8F8EECAF8
      EECAF8EECAF8EFC7CCB79696763CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFBB9C86AF8A6AAB8361AB8361A98360B8997FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
  end
  object pnlImportProgress: TPanel
    Left = 54
    Top = 88
    Width = 483
    Height = 81
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 6
    Visible = False
    object lblImportProgress: TLabel
      Left = 16
      Top = 8
      Width = 81
      Height = 13
      HelpType = htKeyword
      HelpKeyword = 'Import progress: (%d / %d)'
      Caption = 'Import progress:'
    end
    object pbImport: TProgressBar
      Left = 16
      Top = 24
      Width = 449
      Height = 17
      TabOrder = 0
    end
    object bStopImport: TButton
      Left = 390
      Top = 47
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = bStopImportClick
    end
  end
  object bClear: TBitBtn
    Left = 70
    Top = 8
    Width = 25
    Height = 25
    TabOrder = 7
    TabStop = False
    OnClick = bClearClick
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000FF00FFFF00FF
      FF00FFE3D9D0DCD2CAD2C8C0CCC3BCCBC1BACBC1BACCC2BBCCC3BCD1C7BFD3C9
      C1D9CFC7E5DBD3FF00FFFF00FFFF00FFE4D9D1AAA39C4F413F4D3E3C493C3A47
      3B38908884A49D97A59D98A9A19CAAA29DB5ADA7C3BAB3FF00FFFF00FFFF00FF
      BAB2AC5E4E4BF6F6F6A99B9B857575736868262525C3BCB5FF00FFFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFC5BDB7635450F6F6F6F6F6F6F6F6F6A99B9B85
      7575736868262525C3BCB6FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFAA9190
      FFFFFFF6F6F6F6F6F6F6F6F6F6F6F6A99B9B857575736868262525C4BCB7FF00
      FFFF00FFFF00FFFF00FFFF00FFAD9393FFFFFFFCFAFAFCFAFAF6F6F6F6F6F6F6
      F6F6A99B9B85757573686832302E9692A1FF00FFFF00FFFF00FFFF00FFFF00FF
      AC9393FFFFFFFCFAFAFCFAFAF6F6F6F6F6F6F6F6F6A99B9B333C8A3F49930002
      3BB6B3C6FF00FFFF00FFFF00FFFF00FFFF00FFAC9393FFFFFFFCFAFAFCFAFAF6
      F6F6F6F6F64354B75A68B5515DA83F499300023BB8B5C8FF00FFFF00FFFF00FF
      FF00FFFF00FFAC9393FFFFFFFCFAFAFCFAFA4F5FC1AEBBFAAEBAFC5A67B4515D
      A83F499300023BB8B6C9FF00FFFF00FFFF00FFFF00FFFF00FFAC9393FFFFFF58
      69C7B1BBF9B0BEFAAEBBFAAEBAFC5A67B4515DA83F499300023BFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FF6571BDF2F3FFBDC6FDB1BBF9B0BEFAAEBBFAAEBA
      FC5B68B55966B400023BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF6B
      75B8F3F5FFBDC6FCB1BBF9B0BEFAAEBBFAB5BEFC3337759BA1D2FF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF6B75B9F3F5FFBDC6FDB7C2FCC3CB
      FF353A7B9CA3D3FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FF6E78BCF5F5FFF5F6FF363B84A1A7D6FF00FFFF00FFFF00FFFF00FF
      FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF737CBF717ABB9FA6
      DFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
      00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
  end
  object tmrMain: TTimer
    Enabled = False
    OnTimer = tmrMainTimer
    Left = 304
    Top = 8
  end
  object il: TImageList
    DrawingStyle = dsTransparent
    Masked = False
    Left = 272
    Top = 8
    Bitmap = {
      494C0101020008001C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300554D4900554D4900A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A30000519300156BA700A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A300554D4900AFA8A2005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A3000051930035BAFF00005F9E00A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300554D4900AFA8A200AFA8A2005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A3000051930035BAFF0035BAFF00005F9E00A449A300A449A300A449
      A300A449A300AA7E5400A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300554D4900AFA8A200AFA8A200AFA8A2005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300005193003FC1FF0035BAFF0035BAFF00005F9E00A449A300A449A300A449
      A300A449A300A449A300BA947000A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A3003C3734003C3734003E39
      3600C1BAB600C1BAB600AFA8A200AFA8A2005D565100A449A30000127C009492
      A000A449A3009492A00000127C00A449A300A449A30001700500017005000A60
      5A005CD1FF005CD1FF003FC1FF0035BAFF00005F9E00A449A300A449A300AF7F
      5300A449A300A449A300A449A300BA9470000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000062595400B2ABA600B2ABA6006259
      5400C1BAB600C1BAB600C1BAB600AFA8A2005D565100A449A300BAB7C6000012
      7C007F87BD0000127C00BAB7C600A449A30011A0250065E28B0065E28B000989
      11006DDDFF005CD1FF005CD1FF0035BAFF00005F9E00A449A300A449A300A449
      A300BF967100A449A300A449A300BA9470000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000062595400DFDCD900B2ABA6006259
      5400D6D0CD00C1BAB600C1BAB600C1BAB6005D565100A449A300A449A3008088
      BD000029E8008088BD00A449A300A449A30011A02500ADFCC90065E28B000989
      110080EBFF006DDDFF005CD1FF005CD1FF00005F9E00A449A300A449A300A449
      A300A9744200A449A300A449A300A27042000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006259540000000000DFDCD9006259
      5400D6D0CD00D6D0CD00D6D0CD00C1BAB6005D565100A449A3009392A0000012
      7C00A3AADD0000127C009392A000A449A30011A0250000000000ADFCC9000989
      110080EBFF0080EBFF006EDDFF005CD1FF00005F9E00A449A300A449A300A449
      A300AB754200A449A300A449A300A77242000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000006259540000000000000000006259
      5400F2EFEE00D6D0CD00D6D0CD00D6D0CD005D565100A449A30000127C00BAB8
      C700A449A300BAB8C70000127C00A449A30011A0250000000000000000000C84
      1000CFFEFF0080EBFF0080EBFF0069D7FF00005F9E00A449A300A449A300A449
      A300C49B7300A449A300A449A300BF9671000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A30062595400625954006259
      5400F2EFEE00F2EFEE00D6D0CD00D6D0CD005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A30011A0250011A025000D71
      6A00CFFEFF00CFFEFF0080EBFF0080EBFF00005F9E00A449A300A449A300BF88
      5600A449A300A449A300C8A37F00A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A30071676000F2EFEE00F2EFEE00D6D0CD005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A3000280C800CFFEFF00CFFEFF0080EBFF00005F9E00A449A300A449A300A449
      A300A449A300A449A300C49A7300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A30071676000F2EFEE00F2EFEE005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A3000280C800CFFEFF00CFFEFF00005F9E00A449A300A449A300A449
      A300A449A300BF895700A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A30071676000F2EFEE005D565100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A3000280C800CFFEFF000063A100A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A300A449A3007167600071676000A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A3000280C800328ABE00A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A300A449A300A449A300A449A300A449
      A300A449A300A449A300A449A300A449A3000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000040004000000000006000600000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object pmContacts: TPopupMenu
    Left = 240
    Top = 8
    object pmWhisper: TMenuItem
      Caption = 'Copy name'
      OnClick = pmWhisperClick
    end
    object pmDelete: TMenuItem
      Caption = 'Delete'
      OnClick = pmDeleteClick
    end
  end
end
