@echo off
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
IF "%opt%"=="" GOTO Start

set /p ext=Please, enter the output format (wav/ogg): 
set /p db=Please, enter the final normalising level in dB (e.g -1): 
set /p bit=Please, enter the number of bits (8/16): 
set /p lpf=Please, enter the frequency of LPF in Hz (e.g 6000): 
set /p png=Print the spectrum (y/n)?: 

:Start
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
