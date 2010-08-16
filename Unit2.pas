unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ShellApi, MMSystem;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    ProgressBar: TProgressBar;
    BtnClose: TButton;
    Transfer: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure TransferClick(Sender: TObject);
  private
    { Private-Deklarationen}
  public
    { Public-Deklarationen}
  end;
var
  Form2: TForm2;
  Url: String;
  Value: Real;

implementation

uses Unit1;

{$R *.DFM}

procedure TForm2.FormShow(Sender: TObject);
begin
     TotalTime := GetTickCount - StartTime;
     Value := Round(((ExRight / (TotalTime / Ex)) - (ExWrong / (TotalTime / Ex))) * 1000000);

     if RanFlag = True then Value := Value * 1.5;
     if RoundFlag = True then Value := Value * 2;
     if NegFlag = True then Value := Value * 1.2;
     if Value < 0 then Value := 0;

     Label2.Caption := 'Sie haben ' + inttostr(ExRight) + ' von ' + inttostr(Ex) + ' Aufgaben richtig gelöst.' + Chr(13) + 'Das sind ' + inttostr(Round((ExRight/Ex)*100)) + '%.' + Chr(13) + 'Dafür haben Sie ' + FloattoStrF(TotalTime / 1000, ffFixed, 7, 2) + ' Sekunden gebraucht.' + Chr(13) + 'Insgesamt haben Sie ' + floattostr(Value) + ' Punkte.';

     Progressbar.Max := ExMax;
     Progressbar.Position := ExRight;

     if Round((ExRight / Ex) * 100) > 50 then
        if SoundFlag = True then sndPlaySound(SoundGoodResult, SND_LOOP)
     else
         if SoundFlag = True then sndPlaySound(SoundBadResult, SND_LOOP);
end;

procedure TForm2.BtnCloseClick(Sender: TObject);
begin
     sndPlaySound(nil,0);
     Form2.Close;
end;

procedure TForm2.TransferClick(Sender: TObject);
begin
     if Value > 0 then
        if InputQuery('Name', 'Wie heißen sie?', TransName) and InputQuery('Kommentar', 'Haben sie noch etwas zu sagen?!', TransComment) then
           if TransName = '' then
              Application.MessageBox ('Bitte geben Sie ihren Namen an!', 'Fehler', 0+16)
           else
               begin
                    Url := MainUrl + '?name=' +  TransName + '&value=' + FloattoStr(Value) + '&comment=' + TransComment;
                    ShellExecute(Form2.Handle,'open',PChar(Url),nil,nil,SW_SHOWNORMAL);
               end
        else
            Application.MessageBox ('Ihre Angaben sind nicht vollständig!', 'Fehler', 0+16)
     else
         Application.MessageBox ('Sie brauchen mindestens einen Punkt!', 'Nicht genügend Punkte', 0+16);
end;

end.
