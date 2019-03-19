@echo off
REM
REM Demo http server
REM
REM (c) 2019, Lubomir Carik
REM


echo Setting up environment for Python usage... 
set PATH="C:\Dev\Python\Python37";%PATH%

echo Starting server on 127.0.0.1:8000

python -m http.server 8000 --bind 127.0.0.1 --directory setup\pub\
echo ...done
