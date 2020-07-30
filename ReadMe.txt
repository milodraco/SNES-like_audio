audio4SNES
Designed by milodraco.

These batch files perform a couple of operations using some softwares to transform your audio files to sound 'SNES-like'.

Softwares used:
SPC700 Player, by degrade-factory: https://dgrfactory.jp/spcplay/index.html
SNESBRR, by DMV27: https://github.com/boldowa/snesbrr
Sound eXchange: http://sox.sourceforge.net/
XMSNES, by osoumen: https://github.com/osoumen/XMSNES

=========
|mod2wav| => Converts .mod or .xm files to SPC700 emulated .wav files.
=========    Ps: the size of the .mod file should be very small. If it's too large, try deleting some samples.
	     Ps2: to edit the SPC700 Player options, use the spcplay.exe. Just DO NOT change the speed, it has to be 100%.

=========
|wav2wav| => Applies some effects, filters, interpolation and transcode (wav-brr-wav) a stereo .wav file.
=========    Ps: the result is not an emulated audio, but it sounds like (actually, there are more high frequencies).

=========
|sfx2wav| => Use this if you are converting a mono audio file, great for sound effects.
=========

Usage: paste your input file in the folder and execute the desired .bat file. 