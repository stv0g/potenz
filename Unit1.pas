unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, StdCtrls, Math, CommCtrl, ShellApi, MMSystem, ExtCtrls;

type
  TForm1 = class(TForm)
    StatusBar: TStatusBar;
    MnuMain: TMainMenu;
    MnuArt: TMenuItem;
    MnuPotenzeinerPotenz: TMenuItem;
    MnuGleicheBasis: TMenuItem;
    MnuGleicherExponent: TMenuItem;
    MnuHelp: TMenuItem;
    MnuBeenden: TMenuItem;
    MnuOptionen: TMenuItem;
    MnuNeuebung: TMenuItem;
    MnuAuswerten: TMenuItem;
    TxtSolBas: TEdit;
    TxtSolExp: TEdit;
    LblExOp2Bas: TLabel;
    LblExOp2Exp: TLabel;
    BtnSubmit: TButton;
    LblEqual: TLabel;
    LblExOp1Bas: TLabel;
    LblExOp1Exp: TLabel;
    LblExOp1ExpExp: TLabel;
    LblOp: TLabel;
    LblBrackets: TLabel;
    BtnNextEx: TButton;
    NegativeExponenten1: TMenuItem;
    Zahlenbereich1: TMenuItem;
    Aufgaben1: TMenuItem;
    ProgressBarExRight: TProgressBar;
    Zufaellig1: TMenuItem;
    Round1: TMenuItem;
    StatusBarInstruction: TStatusBar;
    ProgressBarEx: TProgressBar;
    Ueber1: TMenuItem;
    InternetRanking1: TMenuItem;
    Hilfe1: TMenuItem;
    Timer: TTimer;
    Sounds1: TMenuItem;
    Zeitanzeigen1: TMenuItem;
    BtnCalc: TButton;
    LblWelcome: TLabel;
    procedure MnuGleicherExponentClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnSubmitClick(Sender: TObject);
    procedure MnuPotenzeinerPotenzClick(Sender: TObject);
    procedure MnuGleicheBasisClick(Sender: TObject);
    procedure BtnNextExClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure NegativeExponenten1Click(Sender: TObject);
    procedure Aufgaben1Click(Sender: TObject);
    procedure Zahlenbereich1Click(Sender: TObject);
    procedure MnuBeendenClick(Sender: TObject);
    procedure Zufaellig1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MnuAuswertenClick(Sender: TObject);
    procedure InternetRanking1Click(Sender: TObject);
    procedure Round1Click(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Hilfe1Click(Sender: TObject);
    procedure Ueber1Click(Sender: TObject);
    procedure Sounds1Click(Sender: TObject);
    procedure Zeitanzeigen1Click(Sender: TObject);
    procedure BtnCalcClick(Sender: TObject);

  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
  end;

  procedure GleicheBasis;
  procedure GleicherExponent;
  procedure PotenzeinerPotenz;
  procedure ExRandom;
  procedure UpdateCounter;
  procedure ResetDisplay;
  procedure Reset;
  function SolRound(value: double; dcpoint: integer): double;

var
  Form1: TForm1;
  ExType: Integer;
  {0= Keine Übung
  1= Gleicher Exponent
  2= Gleiche Basis
  3= Potenz einer Potenz}
  Flag: Boolean; // Richtig oder Falsch?
  RanFlag: Boolean; // Zufallsübung?
  TimeFlag: Boolean; // Zeit anzeigen?
  RoundFlag: Boolean; // ganzzahlige Ergebnisse oder Runden?
  NegFlag: Boolean;
  SoundFlag: Boolean;
  Op: Integer;
  {0= /(geteilt)
  1= x (mal)}
  SolBas: Integer; // zum Errechnen ganzzahliger Lösungen
  Sol: Real; // Lösungen
  Op1: Integer; // Operant 1
  Op2: Integer; // Operant 2
  Op3: String;
  Constants: Array[1..6] of String;
  RangeMax, RangeMin: Integer; // Zahlenbereich
  ExMax: Integer; // Wieviele Aufgaben?
  Ex: Integer; // Aktuelle Aufgabe
  ExRight: Integer; // richtige Aufgaben
  ExWrong: Integer; // falsche Aufgaben
  TransName: String; // Name für Online Ranking
  TransComment: String; // Kommentar für Online Ranking
  r: TRect;
  s: TRect;
  StartTime, TotalTime: Cardinal; // für den Timer

const
     MainUrl = 'http://steffenvogel.de/stff/Programmieren/Delphi/Potenz/Ranking/index.php';
     SoundRight = 'Right.wav';
     SoundWrong = 'Wrong.wav';
     SoundBadResult = 'BadResult.wav';
     SoundGoodResult = 'GoodResult.wav';

implementation

uses Unit2, Unit3;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
   randomize;
   RoundFlag := False;
   TimeFlag := True;
   NegFlag := True;
   SoundFlag := True;
   Flag := False;
   RangeMax := 20;
   RangeMin := -20;
   ExMax := 20;

   Constants[1] := 'a';
   Constants[2] := 'b';
   Constants[3] := 'c';
   Constants[4] := 'x';
   Constants[5] := 'y';
   Constants[6] := 'z';

   ExType := 0;
   //RanFlag := True; // eventuell auskommentieren

   if ExType <> 0 then
      begin
           StartTime := GetTickCount;
      end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
     StatusBar.Perform(SB_GETRECT, 1, integer(@R));
     ProgressBarEx.Parent := StatusBar;
     ProgressBarEx.BoundsRect := r;

     StatusBar.Perform(SB_GETRECT, 3, integer(@S));
     ProgressBarExRight.Parent := StatusBar;
     ProgressBarExRight.BoundsRect := s;

     Form1.BtnNextExClick(Sender);
end;

function SolRound(value: double; dcpoint: integer): double;
var Multi: Double;
begin
  Multi:= IntPower(10, dcpoint);
  Value:= Round(Value * Multi);
  Result:= Value / Multi;
end;

procedure UpdateCounter;
begin
     if ExType <> 0 then
        begin
             try
                Form1.StatusBar.Panels[0].Text := inttostr(Ex) + '/' + inttostr(ExMax) + ' (' + inttostr(Round((Ex / ExMax)*100)) + '%)';
                Form1.ProgressbarEx.Max := ExMax;
                Form1.ProgressbarEx.Position := Ex;

                Form1.StatusBar.Panels[2].Text := inttostr(ExRight) + '/' + inttostr(Ex) + ' (' + inttostr(Round((ExRight / Ex)*100)) + '%)';
                Form1.ProgressbarExRight.Max := Ex;
                Form1.ProgressbarExRight.Position := ExRight;
             except
                   //on EZeroDivide do
                   //   begin
                           Form1.StatusBar.Panels[2].Text := inttostr(ExRight) + '/' + inttostr(Ex) + ' (0%)';
                           Form1.StatusBar.Panels[0].Text := inttostr(Ex) + '/' + inttostr(ExMax) + ' (0%)';
                   //   end;
             end;
        end;
end;

procedure ResetDisplay;
begin
     Form1.LblExOp1Bas.Visible := False;
     Form1.LblExOp1Exp.Visible := False;
     Form1.LblExOp1ExpExp.Visible := False;
     Form1.LblExOp2Bas.Visible := False;
     Form1.LblExOp2Exp.Visible := False;
     Form1.LblBrackets.Visible := False;
     Form1.LblEqual.Visible := False;
     Form1.LblOp.Visible := False;

     Form1.TxtSolBas.Font.Color := clBlack;
     Form1.TxtSolExp.Font.Color := clBlack;

     Form1.BtnSubmit.Visible := False;
     Form1.BtnNextEx.Visible := False;
     Form1.BtnCalc.Visible := False;

     Form1.TxtSolBas.Visible := False;
     Form1.TxtSolExp.Visible := False;

     Form1.LblWelcome.Visible := False;

     Form1.TxtSolBas.ReadOnly := False;
     Form1.TxtSolExp.ReadOnly := False;

     Form1.LblExOp1Exp.Caption := '';
     Form1.LblExOp2Exp.Caption := '';
     Form1.LblExOp1Bas.Caption := '';
     Form1.LblExOp2Bas.Caption := '';
     Form1.StatusBarInstruction.Panels[0].Text := '';
     Form1.StatusBarInstruction.Panels[1].Text := '';
     Form1.StatusBar.Panels[0].Text := '';
     Form1.StatusBar.Panels[2].Text := '';
     Form1.TxtSolBas.Text := '';
     Form1.TxtSolExp.Text := '';

     Flag := False;

     Form1.ProgressbarExRight.Max := 100;
     Form1.ProgressbarExRight.Position := 0;

     Form1.ProgressbarEx.Max := 100;
     Form1.ProgressbarEx.Position := 0;
end;

procedure Reset;
begin
     ResetDisplay;
     Form1.LblWelcome.Visible := True;
     RanFlag := False;
     Form1.StatusBarInstruction.Panels[0].Text := 'Wählen Sie bitte eine Übung aus!';
     ExType := 0;
     Ex := 0;
     ExRight := 0;
     StartTime := 0;
     TotalTime := 0;
end;

procedure GleicherExponent;
begin
     ResetDisplay;

     Op := Random(2);
     Op1 := Random(RangeMax-RangeMin)+RangeMin;
     Op2 := Random(RangeMax-RangeMin)+RangeMin;
     Op3 := constants[Random(5) + 1];

     if (Op1 = 0) or (Op2 = 0) then GleicherExponent;

     if NegFlag = False then
        begin
             Op1 := Abs(Op1);
             Op2 := Abs(Op2);
        end;

     if Op = 1 then
        begin
             Form1.LblOp.Caption := '*';
             Sol := Op1 * Op2;
        end
     else
         begin
              Form1.LblOp.Caption := ':';
              if RoundFlag = True then
                 begin
                      Sol := SolRound((Op1 / Op2), 2)
                 end
              else
                  begin
                       SolBas := Round(Op1 / Op2);
                       Op1 := SolBas * Op2;
                       Form1.LblExOp1Bas.Caption := inttostr(Op1);
                       Sol := Op1 / Op2;
                  end;
         end;

     if (Op1 = 0) or (Op2 = 0) then GleicherExponent;

     Form1.LblExOp2Bas.Caption := inttostr(Op2);
     Form1.LblExOp1Bas.Caption := inttostr(Op1);
     Form1.LblExOp1Exp.Caption := Op3;
     Form1.LblExOp2Exp.Caption := Form1.LblExOp1Exp.Caption;
     Form1.StatusBarInstruction.Panels[0].Text := 'Rechnen Sie bitte die Basis aus!';
     Form1.LblExOp1Bas.Visible := True;
     Form1.LblExOp1Exp.Visible := True;
     Form1.LblBrackets.Visible := False;
     Form1.LblExOp2Bas.Visible := True;
     Form1.LblExOp2Exp.Visible := True;
     Form1.BtnSubmit.Visible := True;
     Form1.TxtSolBas.Visible := True;
     Form1.TxtSolExp.Visible := True;
     Form1.LblEqual.Visible := True;
     Form1.LblOp.Visible := True;
     Form1.TxtSolBas.SetFocus;
     Form1.BtnNextEx.Visible := True;
     Form1.BtnSubmit.Enabled := True;
     Form1.BtnCalc.Visible := True;
     Form1.BtnNextEx.Enabled := False;
     Form1.TxtSolBas.SetFocus;

     UpdateCounter;
end;

procedure GleicheBasis;
begin
     ResetDisplay;
     
     Op := Random(2);
     Op1 := Random(RangeMax - RangeMin) + RangeMin;
     Op2 := Random(RangeMax - RangeMin) + RangeMin;
     Op3 := Constants[Random(5) + 1];

     if (Op1 = 0) or (Op2 = 0) then GleicheBasis;

     if NegFlag = False then
        begin
             Op1 := Abs(Op1);
             Op2 := Abs(Op2);
        end;

     if Op = 1 then
        begin
             Form1.LblOp.Caption := '*';
             Sol := Op1 + Op2;
        end
     else
         begin
              if Op1 = Op2 then GleicheBasis;
              Form1.LblOp.Caption := ':';
              Sol := Op1 - Op2;
         end;
         
     Form1.LblExOp1Exp.Caption := inttostr(Op1);
     Form1.LblExOp2Exp.Caption := inttostr(Op2);
     Form1.LblExOp1Bas.Caption := Op3;
     Form1.LblExOp2Bas.Caption := Form1.LblExOp1Bas.Caption;
     Form1.StatusBarInstruction.Panels[0].Text := 'Rechnen Sie bitte den Exponenten aus!';
     Form1.LblExOp1Bas.Visible := True;
     Form1.LblExOp1Exp.Visible := True;
     Form1.LblExOp2Bas.Visible := True;
     Form1.LblExOp2Exp.Visible := True;
     Form1.BtnSubmit.Visible := True;
     Form1.TxtSolBas.Visible := True;
     Form1.TxtSolExp.Visible := True;
     Form1.LblEqual.Visible := True;
     Form1.LblOp.Visible := True;
     Form1.TxtSolExp.SetFocus;
     Form1.BtnNextEx.Visible := True;
     Form1.BtnSubmit.Enabled := True;
     Form1.BtnNextEx.Enabled := False;
     Form1.BtnCalc.Visible := True;
     Form1.TxtSolBas.SetFocus;

     UpdateCounter;
end;

procedure PotenzeinerPotenz;
begin
     ResetDisplay;
     
     Op1 := Random(RangeMax-RangeMin)+RangeMin;
     Op2 := Random(RangeMax-RangeMin)+RangeMin;
     Op3 := constants[Random(5) + 1];

     if (Op1 = 0) or (Op2 = 0) then PotenzeinerPotenz;

     if NegFlag = False then
        begin
             Op1 := Abs(Op1);
             Op2 := Abs(Op2);
        end;

     Form1.LblExOp1Exp.Caption := inttostr(Op1);
     Form1.LblExOp1ExpExp.Caption := inttostr(Op2);
     Sol := Op1 * Op2;

     Form1.LblExOp1Bas.Caption := Op3;
     Form1.StatusBarInstruction.Panels[0].Text := 'Rechnen Sie bitte den Exponenten aus!';
     Form1.LblExOp1Bas.Visible := True;
     Form1.LblExOp1Exp.Visible := True;
     Form1.LblExOp1ExpExp.Visible := True;
     Form1.LblBrackets.Visible := True;
     Form1.LblOp.Visible := False;
     Form1.BtnSubmit.Visible := True;
     Form1.TxtSolBas.Visible := True;
     Form1.TxtSolExp.Visible := True;
     Form1.LblEqual.Visible := True;
     Form1.TxtSolExp.SetFocus;
     Form1.BtnNextEx.Visible := True;
     Form1.BtnSubmit.Enabled := True;
     Form1.BtnNextEx.Enabled := False;
     Form1.BtnCalc.Visible := True;
     Form1.TxtSolBas.SetFocus;

     UpdateCounter;
end;

procedure ExRandom;
begin
     ExType := Random(3) + 1;
     case ExType of
          1: GleicherExponent;
          2: GleicheBasis;
          3: PotenzeinerPotenz;
     end;
end;

procedure TForm1.MnuGleicherExponentClick(Sender: TObject);
begin
     Reset;

     ExType := 1;
     GleicherExponent;

     StartTime := GetTickCount;
end;

procedure TForm1.MnuGleicheBasisClick(Sender: TObject);
begin
     Reset;

     ExType := 2;
     GleicheBasis;

     StartTime := GetTickCount;
end;

procedure TForm1.MnuPotenzeinerPotenzClick(Sender: TObject);
begin
     Reset;

     ExType := 3;
     PotenzeinerPotenz;

     StartTime := GetTickCount;
end;

procedure TForm1.Zufaellig1Click(Sender: TObject);
begin
     Reset;

     RanFlag := True;
     ExRandom;

     StartTime := GetTickCount;
end;

procedure TForm1.BtnSubmitClick(Sender: TObject);
begin
     try
        case ExType of
             0: // Keine Übung ausgewählt
                StatusBarInstruction.Panels[0].Text := 'Wählen Sie bitte eine Übung aus!';

             1: // Gleicher Exponent
                if (Sol = SolRound(strtofloat(TxtSolBas.Text), 2)) and (LblExOp1Exp.Caption = TxtSolExp.Text) then
                   Flag := True
                else
                    begin
                         Flag := False;
                         if (Sol = SolRound(strtofloat(TxtSolBas.Text), 2)) and (LblExOp1Exp.Caption <> TxtSolExp.Text) then
                            TxtSolExp.Font.Color := clRed
                         else if (Sol <> SolRound(strtofloat(TxtSolBas.Text), 2)) and (LblExOp1Exp.Caption = TxtSolExp.Text) then
                                 TxtSolBas.Font.Color := clRed
                         else
                             begin
                                  TxtSolBas.Font.Color := clRed;
                                  TxtSolExp.Font.Color := clRed;
                             end;
                         StatusBarInstruction.Panels[0].Text := 'Falsch! ' + FloattoStr(Sol) + ' hoch ' + Op3 + '  wäre richtig gewesen!';
                    end;

             2: // Gleiche Basis
                if (Sol = strtofloat(TxtSolExp.Text)) and (Op3 = TxtSolBas.Text) then
                   Flag := True
                else
                    begin
                         Flag := False;
                         if (Sol = SolRound(strtofloat(TxtSolExp.Text), 2)) and (LblExOp1Bas.Caption <> TxtSolBas.Text) then
                            TxtSolBas.Font.Color := clRed
                         else if (Sol <> SolRound(strtofloat(TxtSolExp.Text), 2)) and (LblExOp1Bas.Caption = TxtSolBas.Text) then
                                 TxtSolExp.Font.Color := clRed
                         else
                             begin
                                  TxtSolBas.Font.Color := clRed;
                                  TxtSolExp.Font.Color := clRed;
                             end;
                         StatusBarInstruction.Panels[0].Text := 'Falsch! ' + Op3 + ' hoch ' + floattostr(Sol) + ' wäre richtig gewesen!';
                    end;

             3: // Potenz einer Potenz
                if (Sol = strtofloat(TxtSolExp.Text)) and (Op3 = TxtSolBas.Text) then
                   Flag := True
                else
                    begin
                         Flag := False;
                         if (Sol = SolRound(strtofloat(TxtSolExp.Text), 2)) and (LblExOp1Bas.Caption <> TxtSolBas.Text) then
                            TxtSolBas.Font.Color := clRed
                         else if (Sol <> SolRound(strtofloat(TxtSolExp.Text), 2)) and (LblExOp1Bas.Caption = TxtSolBas.Text) then
                                 TxtSolExp.Font.Color := clRed
                         else
                             begin
                                  TxtSolBas.Font.Color := clRed;
                                  TxtSolExp.Font.Color := clRed;
                             end;
                         StatusBarInstruction.Panels[0].Text := 'Falsch! ' + Op3 + ' hoch ' + floattostr(Sol) + ' wäre richtig gewesen!';
                    end;
        end;

        if Flag = True then
           begin
                StatusBarInstruction.Panels[0].Text := 'Richtig!';
                BtnNextEx.Enabled := True;
                BtnSubmit.Visible := True;
                BtnSubmit.Enabled := False;
                BtnNextEx.SetFocus;
                inc(ExRight);
                if RanFlag = True then ExType := 4;
                if SoundFlag = True then sndPlaySound(SoundRight, SND_ASYNC);
           end
        else
            begin
                 BtnNextEx.Enabled := True;
                 BtnSubmit.Visible := True;
                 BtnSubmit.Enabled := False;
                 BtnNextEx.SetFocus;
                 Flag := True;
                 inc(ExWrong);
                 if SoundFlag = True then sndPlaySound(SoundWrong, SND_ASYNC);
            end;
        inc(Ex);
        TxtSolBas.ReadOnly := True;
        TxtSolExp.ReadOnly := True;
     except
           on EConvertError do
              StatusBarInstruction.Panels[0].Text := 'Das ist keine Zahl!';
     end;
end;


procedure TForm1.BtnNextExClick(Sender: TObject);
begin
     if Ex < ExMax then
        begin
             if RanFlag = True then
                ExRandom
             else
                 begin
                      case ExType of
                           0: StatusBarInstruction.Panels[0].Text := 'Wählen Sie bitte eine Übung aus!';
                           1: GleicherExponent;
                           2: GleicheBasis;
                           3: PotenzeinerPotenz;
                      end;
                 end;
        end
     else
         begin
              UpdateCounter;
              TimeFlag := False;
              TimerTimer(Sender);
              Form2.ShowModal;
              TimeFlag := True;
              Reset;
         end;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
     case Key of
          #13:
              if ExType <> 0 then
                 if Flag = True then
                    begin
                         Key := #0;
                         Form1.BtnNextExClick(Sender)
                    end
                 else
                     begin
                          Key := #0;
                          Form1.BtnSubmitClick(Sender);
                     end;
     end;
end;

procedure TForm1.NegativeExponenten1Click(Sender: TObject);
begin
     if NegFlag = True then
        begin
             NegativeExponenten1.Checked := False;
             NegFlag := False;
        end
     else
         begin
              NegativeExponenten1.Checked := True;
              NegFlag := True;
         end;
end;

procedure TForm1.Aufgaben1Click(Sender: TObject);
begin
     try
        ExMax := strtoint(InputBox ('Anzahl der Aufgaben', 'Wie viele Aufgaben wollen Sie gestellt bekommen?', inttostr(ExMax)));
     except
           Application.MessageBox ('Das ist keine Zahl!', 'Fehler', 0+16);
     end;
     if ExType <> 0 then UpdateCounter;
end;

procedure TForm1.Zahlenbereich1Click(Sender: TObject);
begin
     try
        RangeMin := strtoint(InputBox ('Zahlenbereich', 'Wie groß soll die kleinste Zahl sein?', inttostr(RangeMin)));
        RangeMax := strtoint(InputBox ('Zahlenbereich', 'Wie groß soll die größte Zahl sein?', inttostr(RangeMax)));
     except
           Application.MessageBox ('Das ist keine Zahl!', 'Fehler', 0+16);
     end;
end;

procedure TForm1.MnuBeendenClick(Sender: TObject);
begin
     Close;
end;

procedure TForm1.MnuAuswertenClick(Sender: TObject);
begin
     if (ExType <> 0) and (Ex >= 1) then
        begin
             Timer.Enabled := False;
             Form2.ShowModal;
             Timer.Enabled := True;
             Reset;
        end
     else
         Application.MessageBox ('Bitte rechnen Sie zuerst eine Aufgabe!', 'Fehler', 0+48);

end;

procedure TForm1.InternetRanking1Click(Sender: TObject);
begin
     ShellExecute(Form2.Handle,'open',PChar(MainUrl),nil,nil,SW_SHOWNORMAL);
end;

procedure TForm1.Round1Click(Sender: TObject);
begin
     if RoundFlag = True then
        begin
             RoundFlag := False;
             Round1.Checked := False;
        end
     else
         begin
              RoundFlag := True;
              Round1.Checked := True;
         end;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
     if (TimeFlag = True) and (ExType <> 0) then
        begin
             TotalTime := GetTickCount - StartTime;
             StatusBarInstruction.Panels[1].Text :=  FloattoStrF(TotalTime / 1000, ffFixed, 7, 2) + ' sec';
        end
     else
         StatusBarInstruction.Panels[1].Text := '';
end;

procedure TForm1.Hilfe1Click(Sender: TObject);
begin
     Application.HelpCommand(HELP_FINDER, 0);
end;

procedure TForm1.Ueber1Click(Sender: TObject);
begin
     Form3.ShowModal;
end;

procedure TForm1.Sounds1Click(Sender: TObject);
begin
     if SoundFlag = True then
        begin
             SoundFlag := False;
             Sounds1.Checked := False;
        end
     else
         begin
              SoundFlag := True;
              Sounds1.Checked := True;
         end;
end;

procedure TForm1.Zeitanzeigen1Click(Sender: TObject);
begin
     if TimeFlag = True then
        begin
             TimeFlag := False;
             Zeitanzeigen1.Checked := False;
        end
     else
         begin
              TimeFlag := True;
              Zeitanzeigen1.Checked := True;
         end;
end;

procedure TForm1.BtnCalcClick(Sender: TObject);
begin
     ShellExecute(Handle, 'open', 'calc.exe', '', nil, SW_SHOW);
end;

end.

