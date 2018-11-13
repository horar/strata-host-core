# Serial Console Interface

## Compilation
TODO

### macOS
Invoke in terminal side-by-side with 'SerialConsoleInterface' project root:

    [ -d build ] || mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release ../SerialConsoleInterface/
    cmake --build . --target SerialConsoleInterface

or Xcode driven build

    cmake -GXcode ../SerialConsoleInterface/
    cmake --build . --target SerialConsoleInterface --config Release

Optionally create simple app DMG with all dependant libraries

    macdeployqt SerialConsoleInterface.app/ -dmg -qmldir=../SerialConsoleInterface/

or on Xcode build

    macdeployqt Release\SerialConsoleInterface.app/ -dmg -qmldir=../SerialConsoleInterface/

Note: make sure to have a 'qmake' utility of your Qt5 installation in your PATH.
(or prefix above cmake and macdeployqt commands with e.g. 'PATH=/Users/..../Qt/5.11.1/clang_64/bin:$PATH cmake ...)
