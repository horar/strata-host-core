Microsoft Visual C++ 2017 x64 Redistributable

File vc_redist.x64.exe is created during cmake build of SDS when not using --no-compiler-runtime in windeployqt
Will be copied into this folder upon its creation and later executed using run_vc_redist.bat
This is necessary as QTIFW does not allows to capture exit codes (and we need to know when to restart PC)