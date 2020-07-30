@echo off
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
