# Strata Host Core

## Requirements

### Windows
    * Git Bash
    * CMake >= 3.19
    * Qt5 5.12.xx
    * Visual Studio Build Tools 2017
    * OpenSSL (can be installed through Qt installer)
### MacOS

    * Xcode and Command Line Tools
    * Git
    * Qt5 5.12.xx
    * CMake >= 3.19
    * OpenSSL

## Qt5 installation

Download and install Qt5 version is 5.12.xx

The following Qt5 components are required:

### Windows
* MSVC 2017 64-bit
* Qt Charts
* Qt WebEngin
* Qt Developer and Designer Tools -> OpenSSL Toolkit

### MacOS
* macOS 
* Qt Charts
* Qt WebEngin

## Build Instructions

Building through CLI:

### Windows 
make sure Qt directory is added into the path
- Search for Environment Variable
- Click Environment Variables
- Add the following to user variables Path (if not already added)
  `<QT installed directory>\5.12.xx\msvc2017_64\bin`
  `<QT installed directory>\Tools\OpenSSL\Win_x64\bin`
- Create a new user environment variable (if not already there)
    variable name: `Qt_DIR`
    variable value: `<QT installed directory>\5.12.xx\msvc2017_64\lib\cmake\Qt5`

Open `Command Prompt`, navigate to Strata Host Core directory and run `bootstrap-host.bat`

### MacOS
make sure Qt directory is added into the path
if not open Terminal and run the following command 
```
export PATH=$PATH:<QT installed directory>/5.12.xx/clang_64/bin
```
run `bootstrap-host.sh`
