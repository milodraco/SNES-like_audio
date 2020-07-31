@echo off
echo SNES-like Audio
echo Designed by milodraco
echo.
echo 1. wav2wav: Applies some effects, filters, interpolation and transcode (wav-brr-wav) a 
echo stereo .wav file.
echo.
echo 2. monoSFX: Use this if you are converting a mono audio file, great for sound effects.
echo.
echo 3. mod2wav: Converts .mod or .xm files to SPC700 emulated .wav files.
echo.

set /p n=Please, enter your choice: 
IF "%n%"=="1" GOTO wav2wav
IF "%n%"=="2" GOTO monoSFX
IF "%n%"=="3" GOTO mod2wav
echo Invalid number. | echo. | pause | exit

:wav2wav
cls
echo Converter from a stereo wave file to a downsampled, transcoded,
echo interpolated and filtered 32000 Hz SNES-like stereo .wav audio.
echo Algorithm (batch file) designed by milodraco.
echo.
echo Softwares used:
echo SNESBRR, by DMV27: https://github.com/boldowa/snesbrr
echo Sound eXchange: http://sox.sourceforge.net/
echo.
set /p file=Please, enter the file name without extension (e.g mysong): 
set /p opt=Press ENTER to start or adv for advanced options: 

IF "%opt%"=="" set db=-0.2
IF "%opt%"=="" set lpf=8000
IF "%opt%"=="" GOTO Start

set /p db=Please, enter the final normalising level in dB (e.g -1): 
set /p lpf=Please, enter the frequency of LPF in Hz (e.g 8000): 
set /p png=Print the spectrum (y/n)?: 

:Start
echo.
echo Spliting stereo file into 2 mono tracks...
echo.
sox\sox -S %file%.wav -c 1 -r 32k -D left1.wav remix 1
echo.
sox\sox %file%.wav -c 1 -r 32k -D right1.wav remix 2
echo.

echo Transcoding and adding interpolation...
echo.
snesbrr\snesbrr -t -g left1.wav left2.wav
echo.
snesbrr\snesbrr -t -g right1.wav right2.wav
echo.

echo Merging into a stereo file...
echo.
sox\sox -S --no-clobber --norm=%db% -M left2.wav right2.wav -c 2 %file%-SNES.wav lowpass %lpf% speed 1.01 stat stats spectrogram -t %file% -o %file%.png
echo.

echo FINISHED!
echo.

pause
del left1.wav | del left2.wav | del right1.wav | del right2.wav
IF "%png%"=="n" del %file%.png
exit

:monoSFX
cls
echo Converter from a mono wave file to a downsampled, transcoded,
echo interpolated and filtered 32000 Hz SNES-like mono .ogg audio.
echo Algorithm (batch file) designed by milodraco.
echo.
echo Softwares used:
echo SNESBRR, by DMV27: https://github.com/boldowa/snesbrr
echo Sound eXchange: http://sox.sourceforge.net/
echo.
set /p file=Please, enter the file name without extension (e.g mysong): 
set /p opt=Press ENTER to start or adv for advanced options: 

IF "%opt%"=="" set db=-0.2
IF "%opt%"=="" set lpf=6000
IF "%opt%"=="" set bit=8
IF "%opt%"=="" set ext=ogg
IF "%opt%"=="" GOTO Start2

set /p ext=Please, enter the output format (wav/ogg): 
set /p db=Please, enter the final normalising level in dB (e.g -1): 
set /p bit=Please, enter the number of bits (8/16): 
set /p lpf=Please, enter the frequency of LPF in Hz (e.g 6000): 
set /p png=Print the spectrum (y/n)?: 

:Start2
echo.
echo Downsampling...
echo.
sox\sox -S %file%.wav -c 1 -b %bit% -r 32k -D out.wav
echo.

echo Transcoding and adding interpolation...
echo.
snesbrr\snesbrr -t -g out.wav out2.wav
echo.

echo Applying some filters...
echo.
sox\sox -S --no-clobber --norm=%db% out2.wav %file%-SFX.%ext% lowpass %lpf% stat stats spectrogram -t %file% -o %file%.png
echo.

echo FINISHED!
echo.

pause
del out.wav | del out2.wav
IF "%png%"=="n" del %file%.png
exit

:mod2wav
cls
echo Converter from a mod file to a SNES emulated wav audio.
echo Algorithm (batch file) designed by milodraco.
echo.
echo Softwares used:
echo XMSNES, by osoumen: https://github.com/osoumen/XMSNES 
echo SPC700 Player, by degrade-factory: https://dgrfactory.jp/spcplay/index.html
echo Sound eXchange: http://sox.sourceforge.net/
echo OpenMPT123, by manx and Saga Musix: https://lib.openmpt.org/
echo.
echo Ps1: due to a SPC700 Player balance issue (panning to much to the left channel),
echo the balance's going to be adjusted.
echo.
echo Ps2: due to a SPC700 Player limitation, the maximum length should be 180 seconds.
echo The audio will fade out after that.
echo.

set /p file=Please, enter the file name without extension (e.g mysong): 
set /p ext=Please, enter the file extension (mod/xm): 
set /p opt=Press ENTER to start or adv for advanced options: 
echo.

IF "%opt%"=="" set spc=n
IF "%opt%"=="" set db=-0.2
IF "%opt%"=="" set fade=0.00001
IF "%opt%"=="" GOTO Start3

set /p db=Please, enter the final normalising level in dB (e.g -1): 
set /p fade=Please, enter the fade in/out length in seconds (e.g 0.00001): 
set /p spc=Keep the .spc file? (y/n): 
set /p png=Print the spectrum (y/n)?: 
echo.

:Start3
echo. Getting the track length...
echo.
powershell ((libopenmpt\openmpt123\amd64\openmpt123 --info %file%.%ext%) -replace 'Duration...: ', '') -replace ':', '' > info.txt
for /F "skip=8 delims=" %%i in (info.txt) do set "trim=%%i"&goto nextline
:nextline
echo.
echo Converting to SPC...
echo.
move %file%.%ext% xm2snes\
cd xm2snes
xm2snes -d -b %file%.%ext%
move %file%.%ext% ..\
move %file%.spc ..\
echo.

cd..
echo Emulating the SPC700 and converting to WAV...
echo.
echo Starting SPC700 Player
start spcplay\spcplay
timeout /t 2 /nobreak
spcplay\spccmd -cw %file%.spc out.wav
echo.
echo Closing SPC700 Player...
echo.
powershell stop-process -name spcplay

echo Trimming the file...
echo.
sox\sox -S out.wav out2.wav silence 1 0.001 0.1%
echo.

echo Spliting stereo file into 2 mono tracks...
echo.
sox\sox -S --norm=%db% out2.wav -c 1 -D left.wav remix 1
echo.
sox\sox --norm=%db% out2.wav -c 1 -D right.wav remix 2
echo.
echo Merging into a stereo file...
echo.
sox\sox -S --no-clobber --norm=%db% -M left.wav right.wav -c 2 %file%-SNES.wav trim 0 %trim% fade %fade% -0 %fade% stat stats spectrogram -t %file% -o %file%.png
echo.

echo FINISHED!
echo.

pause
del out.wav | del left.wav | del right.wav | del out2.wav | del %file%.%ext%.wav | del info.txt
IF "%png%"=="n" del %file%.png
IF "%spc%"=="n" del %file%.spc
exit