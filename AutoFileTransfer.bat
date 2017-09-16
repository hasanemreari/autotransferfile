
@echo off
title AutoTransferFile
:: Yerel dosya transferi için kaynak, hedef bilgileri
set source= C:\Users\hasan\Desktop\y\* 
set destination= C:\Users\hasan\Desktop\x
set source2= C:\Users\hasan\Desktop\b\*
set destination2= C:\Users\hasan\Desktop\a
::Mail bilgileri için kullanılan değişkenler
set Port=587
set SSL=False
set From="e mailin kimden gittiği"
set To="e mailin kime gittiği"
set Subject="Başlık"
set SMTPServer="mail server"
set User="mail adresi ID"
set Pass="mail adresi şifresi"
::Programın hangi durumda olduğunu ve sayıcıların tanımlamaları
set /a status = 1
set /a countermove=0
set /a counterftp=0
:Start
::yarım saatlik zamanlayıcı
TIMEOUT /T 1 /nobreak
:Move
::ftp serverına ping gönderilir
ping -n 1 sunucu IP adresi     | find "TTL=" >nul
if errorlevel 1 (
	::ulaşılamadıysa burdan noservermove kısmına gidilir
    echo host not reachable
	goto NoServerMove
) else (
    echo host reachable
	::ulaşıldıysa burdan devam edilir ve yerelde taşıma işlemi gerçekleştirilir
	if exist  %source% (move %source% %destination%) else (echo "File does not exist")
	if exist  %source2% (move %source2% %destination2%) else (echo "File does not exist")
	::taşınan dosyaları sayar
	for /f %%a in ('2^>nul dir "C:\Users\hasan\Desktop\x" /a-d/b/-o/-p/s^|find /v /c ""') do set /a transferedfiles=%%a
	for /f %%a in ('2^>nul dir "C:\Users\hasan\Desktop\a" /a-d/b/-o/-p/s^|find /v /c ""') do set /a transferedfiles2=%%a
	set /a countermove=0
)

::///////////////////////////////////////////////////////////////////////////////////////
:: 2 buçuk saatlik zamanlayıcı
TIMEOUT /T 1 /nobreak
:FTP
::ftp serverına ping gönderilir
ping -n 1   sunucu IP adresi   | find "TTL=" >nul
if errorlevel 1 (
	::ulaşılamadıysa burdan noserverFTP kısmına gidilir
    echo host not reachable
	goto NoServerFTP
	
) else (
    echo host reachable
	start C:\Users\hasan\Desktop\AFTpinger.bat
	echo open sunucu IP adresi >ftp.txt
	::kullanıcı adı
	echo deneme>>ftp.txt
	::parola
	echo deneme>>ftp.txt
	:: cd=change directory		hedef sunucudaki hedef klasör belirlenir
	echo cd deneme1 >>ftp.txt
	:: lcd= local change directory yereldeki kaynak klasörü belirlenir
	echo lcd C:\Users\hasan\Desktop\x>>ftp.txt
	::mput komutuyla kaynak klasöründeki dosyalar hedef klasörüne kopyalanır
	echo mput *.*>>ftp.txt
	echo cd .. >>ftp.txt
	echo cd deneme2 >>ftp.txt
	echo lcd C:\Users\hasan\Desktop\a>>ftp.txt
	echo mput *.*>>ftp.txt
	::ftp bağlantısından çıkış yapılır
	echo quit>>ftp.txt
	
	ftp -i -s:ftp.txt  2>error.txt
	del ftp.txt	
	taskkill /f /fi "Windowtitle eq AFTpinger" /im cmd.exe
	::start C:\Users\hasan\Desktop\killer.bat
	set /a counterftp=0
)
		
::///////////////////////////////////////////////////////////////////////////////////////////
	::toplam dosya sayısı hesaplanır
	set /a total = %transferedfiles%+%transferedfiles2%
	set Body=" FTP'den ipdr sunucusuna %total% dosya basariyla transfer edildi."
	::her iki dosyada da silme işlemi gerçekleştirilir
	del /Q C:\Users\hasan\Desktop\x\*.*
	del /Q C:\Users\hasan\Desktop\a\*.*	
	echo File deleted
	
	goto Mail

:NoServerMove
::connection failed
:: 15 minutes
TIMEOUT /T 10 /nobreak
::when the ping isn't response, give a break and try again
set /a countermove=countermove+1
echo %countermove%
::eğer 4 kere bağlantı gönderilemezse kullanıcıya mail gönderilir
if %countermove%==4 (
	set Body="FTP sunucusuna erisilemedi. Bu sebeple dosya transferi baslayamadi. Lutfen sunucunun acık ve agın erisilebilir oldugunu kontrol edin."
	set /a status=3
	goto Mail
	)
goto Move
:NoServerFTP
::connection failed
:: 15 minutes
TIMEOUT /T 10 /nobreak
::when the ping isn't response, give a break and try again
set /a counterftp=counterftp+1
echo %counterftp%
if %counterftp%==4 (
	set Body="FTP sunucusuna erisilemedi. Bu sebeple dosya transferi baslayamadi. Lutfen sunucunun acık ve agın erisilebilir oldugunu kontrol edin."
	set /a status=3
	goto Mail
	)
goto FTP
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

if %status%==1 (
    echo Completed
	goto Start
) 
if %status%==3 (
	set /a countermove=0
	set /a counterftp=0
	set /a status=1
	echo Ping Failure
	goto Move
)

:Finish
