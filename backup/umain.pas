unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, httpsend, ssl_openssl, fpjson, jsonparser;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    lbTitle: TLabel;
    lbCNPJ: TLabel;
    txtCNPJ: TEdit;
    btnSearch: TButton;
    memo: TMemo;
    procedure btnSearchClick(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

function GetSafeJSONValue(JSON: TJSONData; const Path, Default: string): string;
var
  Node: TJSONData;
begin
  Node := JSON.FindPath(Path);
  if Assigned(Node) then
    Result := Node.AsString
  else
    Result := Default;
end;

function ClearCNPJ(const CNPJ: string): string;
begin
  Result := trim(CNPJ);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '', [rfReplaceAll]);
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
  CNPJ, URL, Response: string;
  HTTP: THTTPSend;
  ResponseStream: TStringStream;
  JSON: TJSONdata;
begin
  JSON := nil;
  ResponseStream := nil;
  HTTP := nil;

  try
    CNPJ := ClearCNPJ(txtCNPJ.Text);

    URL := 'https://receitaws.com.br/v1/cnpj/' + CNPJ;

    HTTP := THTTPSend.Create;
    ResponseStream := TStringStream.Create('', TEncoding.UTF8);

    Memo.Lines.Clear;

    try
      if HTTP.HTTPMethod('GET', URL) then
        begin
          if (HTTP.ResultCode >= 200) and (HTTP.ResultCode <= 300) then
            begin
              ResponseStream.LoadFromStream(HTTP.Document);
              Response := ResponseStream.DataString;

              JSON := GetJSON(Response);

              if JSON.FindPath('status') <> nil then
                begin
                  if JSON.FindPath('status').AsString = 'ERROR' then
                  begin
                    raise Exception.Create('400');
                  end;
                end;

              memo.Lines.Add('Razao Social: ' + JSON.FindPath('nome').AsString);
              memo.Lines.Add('Nome Fantasia: ' + JSON.FindPath('fantasia').AsString);
              memo.Lines.Add('CNPJ: ' + JSON.FindPath('cnpj').AsString);
              memo.Lines.Add('Inscricao Estadual: ' + GetSafeJSONValue(JSON, 'ie', 'n/a'));
              memo.Lines.Add('Porte: ' + JSON.FindPath('porte').AsString);
              memo.Lines.Add('Data Inscricao: ' + JSON.FindPath('data_situacao').AsString);
              memo.Lines.Add('Endereco: ' + JSON.FindPath('logradouro').AsString +
                ', ' + JSON.FindPath('numero').AsString +
                ' - ' + JSON.FindPath('bairro').AsString);
              memo.Lines.Add('Cidade/UF: ' + Json.FindPath('municipio').AsString +
                '/' + Json.FindPath('uf').AsString);
            end
          else
            raise Exception.Create('Erro HTTP: ' + IntToStr(HTTP.ResultCode));
        end
      else
        raise Exception.Create('Erro ao conectar na API' + LineEnding + 'Código de resposta HTTP: ' + IntToStr(HTTP.ResultCode));

    except
      on e: Exception do
        begin
          if Pos('429', e.Message) > 0 then
            ShowMessage('Muitas requisições. Aguarde e tente novamente.')
          else if Pos('400', e.Message) > 0 then
            ShowMessage('Requisição inválida. Verifique o CNPJ informado.')
          else if Pos('500', e.Message) > 0 then
            ShowMessage('Erro interno no servidor. Tente novamente mais tarde')
          else
            ShowMessage('Erro desconhecido: ' + e.Message);
        end
    end;
  finally
    if Assigned(JSON) then JSON.Free;
    if Assigned(ResponseStream) then ResponseStream.Free;
    if Assigned(HTTP) then HTTP.Free;
  end;
end;

end.
