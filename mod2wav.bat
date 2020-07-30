@echo off

echo Converter from a mod file to a SNES emulated wav audio.
echo Algorithm (batch file) designed by milodraco.
echo.
echo Softwares used:
echo XMSNES, by osoumen: https://github.com/osoumen/XMSNES 
echo SPC700 Player, by degrade-factory: https://dgrfactory.jp/spcplay/index.html
echo Sound eXchange: http://sox.sourceforge.net/
echo.
echo Due to a SPC700 Player balance issue (panning to much to the left channel),
echo the balance's going to be adjusted.
echo.
set /p file=Please, enter the file name without extension (e.g mysong): 
set /p ext=Please, enter the file extension (mod/xm): 
set /p trim=Enter the track length in seconds (e.g 150.000000) or press ENTER: 
IF NOT "%trim%"=="" GOTO Jump
echo.
echo SPC players loop the audio when playing/converting, so you need to know the right
echo length of the song in seconds. If you don't know, please provide an audio file
echo with the correct length. You can use Audacity to open and convert the .mod.
echo.
set /p trimf=Please, enter the audio file name with extension (e.g mysong.wav): 
sox\sox --i -D %trimf% > trim.txt
set /p trim=<trim.txt

:Jump
set /p opt=Press ENTER to start or adv for advanced options: 
echo.

IF "%opt%"=="" set spc=n
IF "%opt%"=="" set db=-0.2
IF "%opt%"=="" set fade=0.001
IF "%opt%"=="" GOTO Start

set /p db=Please, enter the final normalising level in dB (e.g -1): 
set /p fade=Please, enter the fade out length in seconds (e.g 0.001): 
set /p spc=Keep the .spc file? (y/n): 
set /p png=Print the spectrum (y/n)?: 
echo.

:Start
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
sox\sox -S out.wav out2.wav trim 0 %trim% fade 0 -0 %fade%
echo.

echo Spliting stereo file into 2 mono tracks...
echo.
sox\sox -S --norm=%db% out2.wav -c 1 -D left.wav remix 1
echo.
sox\sox --norm=%db% out2.wav -c 1 -D right.wav remix 2
echo.
echo Merging into a stereo file...
echo.
sox\sox -S --no-clobber --norm=%db% -M left.wav right.wav -c 2 %file%-SNES.wav  stat stats spectrogram -t %file% -o %file%.png
echo.

pause
del out.wav | del left.wav | del right.wav | del out2.wav
IF "%png%"=="n" del %file%.png
IF "%spc%"=="n" del %file%.spc