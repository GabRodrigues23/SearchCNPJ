unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, opensslsockets, fphttpclient, fpjson, jsonparser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    lbTitle: TLabel;
    lbCNPJ: TLabel;
    txtCNPJ: TEdit;
    btnSearch: TButton;
    memo: TMemo;
    procedure btnSearchClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
  CNPJ, URL, Response: string;
  HTTPClient: TFPHTTPClient;
  JSON: TJSONData;
begin
  try
    CNPJ := txtCNPJ.Text;

    URL := 'https://receitaws.com.br/v1/cnpj/' + CNPJ;
    try
      HTTPClient := TFPHTTPClient.Create(nil);

      Response := HTTPClient.Get(URL);
      JSON := GetJSON(Response);

      memo.Lines.Add('Razão Social: ' + JSON.FindPath('nome').AsString);
      memo.Lines.Add('Nome Fantasia: ' +  JSON.FindPath('fantasia').AsString);
      memo.Lines.Add('CNPJ: ' + JSON.FindPath('cnpj').AsString);

      if JSON.FindPath('ie') <> nil then
        memo.Lines.Add('Inscrição Estadual: ' + JSON.FindPath('ie').AsString)
      else
        memo.Lines.Add('Inscrição Estadual: [N/A]');


      memo.Lines.Add('Endereço: ' + JSON.FindPath('logradouro').AsString + ', '
                    + JSON.FindPath('numero').AsString + ' - '
                    + JSON.FindPath('bairro').AsString + ' - '
                    + JSON.FindPath('municipio').AsString + ' - '
                    + JSON.FindPath('uf').AsString);
    except
      on E: Exception do
        ShowMessage('Erro: ' + E.Message);
    end;
  finally
    HTTPClient.Free;
  end;


end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  client: TFPHTTPClient;
  response: String;
begin
  client := TFPHTTPClient.Create(nil);
  try
    response := client.Get('https://www.google.com');
    ShowMessage('Funcionou!');
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
  client.Free;
end;

end.
