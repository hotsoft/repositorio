unit acNetUtils;

interface

uses idHTTP, SysUtils, System.Classes, IdSSL, IdIOHandler, IdSSLOpenSSL;

function getRemoteXmlContent(pUrl: string; http: TIdHTTP = nil): String; overload
function getRemoteXmlContent(const pUrl: string; http: TIdHTTP; var erro: string; aRetornoStream: TStringStream): boolean; overload
function getHTTPInstance: TidHTTP;
procedure downloadFile(url, filename: string);

implementation

function getHTTPInstance: TidHTTP;
var
  http: TIdHTTP;
  LHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  http := TIdHTTP.Create(nil);
  LHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(http);
  LHandler.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]; //Não alterar, usado no hibrido
  LHandler.SSLOptions.Method := sslvTLSv1_2;
  LHandler.PassThrough := False;
  http.IOHandler := LHandler;
  http.AllowCookies := True;
  http.HandleRedirects := True;
  http.ProtocolVersion := pv1_1;
  http.HTTPOptions := http.HTTPOptions + [hoKeepOrigProtocol];
  http.Request.Connection := 'keep-alive';
  result := http;
end;

function getRemoteXmlContent(pUrl: string; http: TIdHTTP = nil): String;
var
  criouHTTP: boolean;
  IOHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  criouHttp := false;
  if http = nil then
  begin
    criouHTTP := true;
    http := getHTTPINstance;

    if pUrl.ToLower.Contains('https') then
    begin
      IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(http);
      IOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      IOHandler.SSLOptions.Method := sslvTLSv1_2;
      IOHandler.PassThrough := False;
      http.IOHandler := IOHandler;
    end;
  end;

  try
    try
      result := http.Get(pUrl);
    except
      result := '';
    end;
  finally
    if criouHTTP and (http <> nil) then
      FreeAndNil(http);
  end;
end;

function getRemoteXmlContent(const pUrl: string; http: TIdHTTP; var erro: string; aRetornoStream: TStringStream): boolean;
var
  criouHTTP: boolean;
begin
  criouHTTP := False;

  erro := EmptyStr;
  try
    if http = nil then
    begin
      criouHTTP := true;
      http := getHTTPINstance;
    end;

    try
      http.ConnectTimeout := 30000;
      http.ReadTimeOut := 30000;
      http.Get(pUrl, aRetornoStream);
    except
      on E: EIdHTTPProtocolException do
        erro := E.ErrorMessage;
    end;

    Result := erro.IsEmpty;
  finally
    if criouHTTP and (http <> nil) then
      FreeAndNil(http);
  end;
end;


procedure downloadFile(url, filename: string);

var

  http: TIdHTTP;

  ms: TMemoryStream;

begin

  http := getHTTPInstance;
  ms := TMemoryStream.Create;
  try
    http.Get(url, ms);
    ms.SaveToFile(filename);
  finally
    FreeAndNil(http);
  end;
end;


end.
