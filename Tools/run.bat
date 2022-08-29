@echo off

set file=%1
tasm/zi %file%
tlink/v %file%
%file% >nul
del %file%.obj
del %file%.map

@echo on