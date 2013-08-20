@echo off
set filename=b64
copy bin\%filename%.lib ..\%filename%.lib
copy include\%filename%.inc ..\..\include\%filename%.inc