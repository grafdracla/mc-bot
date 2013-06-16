unit uOpenSSL;

interface

function  Seq_Init():boolean;
procedure Seq_Final();

procedure Seq_InportPublicKey();
procedure Seq_GenerateKey();

implementation

uses
  System.SysUtils,

  libeay32;

var
  // ServerId, fHash: string;
  rsa: pRSA;

function GetError(ErrMsg:pBIO):string;
var
  buff: array [0..1023] of AnsiChar;
begin
  BIO_reset(ErrMsg);
  BIO_read(ErrMsg, @buff, 1024);
  result := string(buff);
end;

procedure GenirateRSA();
var
  i, fEssLen:Integer;
  rsa: pRSA;
  ErrMsg: pBIO;
  ss, ess:array[0..15] of byte;
begin
  rsa := nil;
  ErrMsg := nil;

  //     PrivateKeyOut := nil;
  //     PublicKeyOut := nil;
  try
    // Gen key
    rsa := RSA_generate_key(1024, RSA_F4, nil, ErrMsg);
    if rsa = nil then
      raise Exception.Create( GetError(ErrMsg) );

    // Shared sicret
    for i := 0 to Length(ss)-1 do
      ss[i] := Random(256);

    // Key size
    {fSharedKeyLength := RSA_size(rsa);
    SetLength( fSharedKey, fSharedKeyLength );}

    // Set key to buff
    fEssLen := RSA_public_encrypt(SizeOf(ss), @ss, @ess, rsa, RSA_PKCS1_PADDING);
    if fEssLen < 0 then
      raise Exception.Create( 'Error encrypt' );

{
    PrivateKeyOut := BIO_new( BIO_s_file() );

    BIO_write_filename(PrivateKeyOut, 'd:\private.key');
    PublicKeyOut := BIO_new(BIO_s_file());
    BIO_write_filename(PublicKeyOut, 'd:\public.key');

    PEM_write_bio_RSAPrivateKey(PrivateKeyOut, rsa, enc, nil, 0, nil, PChar(fPassword));
    PEM_write_bio_RSAPublicKey(PublicKeyOut, rsa);}
  finally
    if rsa <> nil then RSA_free(rsa);
    {if PrivateKeyOut <> nil then BIO_free_all(PrivateKeyOut);
    if PublicKeyOut <> nil then BIO_free_all(PublicKeyOut);}
  end;
end;

function Seq_Init():boolean;
begin
  Seq_Final();

  result := true;
end;

procedure Seq_Final();
begin
  if rsa <> nil then
    RSA_free(rsa);

  rsa := nil;
end;

procedure Seq_InportPublicKey();
//var
//  keyfile: pBIO;
begin
//  keyfile := BIO_new(BIO_s_mem());

  //@@@
//  pKey := nil;
//  PEM_read_bio_RSAPublicKey(keyfile, nil, nil, );
end;

procedure Seq_GenerateKey();
var
  ErrMsg: pBIO;
begin
  ErrMsg := nil;

  rsa := RSA_generate_key(1024, RSA_F4, nil, ErrMsg);
  if rsa = nil then
     raise Exception.Create( GetError(ErrMsg) );
end;

initialization
  OpenSSL_add_all_algorithms;
  OpenSSL_add_all_ciphers;
  OpenSSL_add_all_digests;
  ERR_load_crypto_strings;

finalization
  EVP_cleanup;

end.
