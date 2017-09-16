@echo off
title AFTpinger
set Port=587
set SSL=False
set From="deneme@profen.com.tr"
set To="hasanemreari@gmail.com"
set Subject="Info: %date% - %time% File Transfer Report"
set Body="Auto Transfer File transfer esnasinda bağlantı sorunuyla karsilasti. Oturumunuz otomatik olarak kapatildi. Lutfen ilk transfer islemini manuel olarak yapin. Daha sonra programi tekrar baslatin."
set SMTPServer="mail.profen.com.tr"
set User="deneme@profen.com.tr"
set Pass="Deneme2017"
:Ping
::bir saniye aralıklarla ftp serverinin çalışıp çalışmadığını ping göndererek kontrol eder
::transfer esnasında bir an bile ping alamadığında bilgisayarın oturumunu kapatır
::burdaki amaç transfer esnasında kopukluk olduğunda gönderilen dosyaların bozulup yerel klasörde kalan orjinal dosyaların silinmesini engellemektir.
TIMEOUT /T 1 /NOBREAK
ping -n 1 ftp sunucu adresi     | find "TTL=" >nul
if errorlevel 1 (
    echo host not reachable-Error on the transfer progress
	::oturumu kapatmadan önce kullanıcıya mail atar
	goto Mail
) else (
	:: bir sıkıntı yoksa ping atmaya devam eder
    echo host reachable
	goto Ping 
)
:Mail

set "vbsfile=%temp%\email-bat.vbs"
del "%vbsfile%" 2>nul
set cdoSchema=http://schemas.microsoft.com/cdo/configuration
echo >>"%vbsfile%" Set objArgs       = WScript.Arguments
echo >>"%vbsfile%" Set objEmail      = CreateObject("CDO.Message")
echo >>"%vbsfile%" objEmail.From     = %From%
echo >>"%vbsfile%" objEmail.To       = %To%
echo >>"%vbsfile%" objEmail.Subject  = %Subject%
echo >>"%vbsfile%" objEmail.Textbody = %body%
if exist %fileattach% echo >>"%vbsfile%" objEmail.AddAttachment %fileattach%
echo >>"%vbsfile%" with objEmail.Configuration.Fields
echo >>"%vbsfile%"  .Item ("%cdoSchema%/smtpusessl")       = %SSL%
echo >>"%vbsfile%"  .Item ("%cdoSchema%/sendusing")        = 2 ' not local, smtp
echo >>"%vbsfile%"  .Item ("%cdoSchema%/smtpserver")       = %SMTPServer%
echo >>"%vbsfile%"  .Item ("%cdoSchema%/smtpserverport")   = %port%
echo >>"%vbsfile%"  .Item ("%cdoSchema%/smtpauthenticate") = 1 ' cdobasic
echo >>"%vbsfile%"  .Item ("%cdoSchema%/sendusername")     = %user%
echo >>"%vbsfile%"  .Item ("%cdoSchema%/sendpassword")     = %pass%
echo >>"%vbsfile%"  .Item ("%cdoSchema%/smtpconnectiontimeout") = 30
echo >>"%vbsfile%"  .Update
echo >>"%vbsfile%" end with
echo >>"%vbsfile%" objEmail.Send
cscript.exe /nologo "%vbsfile%"
echo email sent 
del "%vbsfile%" 2>nul
::outurumu kapatmak için gerekli kod parçasıdır
shutdown /l
goto :EOF
:Finish
