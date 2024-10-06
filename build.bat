@echo off

pushd src
fpc -dRELEASE v-maker.pas
move v-maker.exe ..\
del *.o
del *.ppu
popd
