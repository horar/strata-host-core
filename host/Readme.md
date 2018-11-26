# Host directory

## How to build applications

### Installing prerequisites in Linux (Ubuntu 18.04)

```
sudo apt-get update
sudo apt-get install build-essential cmake
```

### Installing prerequisites in Mac

* Install Xcode and Command Line Tools as described in http://railsapps.github.io/xcode-command-line-tools.html
* Install Homebrew, see http://brew.sh

```
brew install cmake
```

### Qt5 installation (for Linux and MacOS)

Download and install Qt5. Minimum required version is 5.11 and QtChart component installed as well

To set paths for build run command in console (for MacOS)
```
export Qt5_DIR=<QT installed directory>/5.11.2/clang_64/lib/cmake/Qt5
```

or for Linux:
```
export Qt5_DIR=<QT installed directory>/5.11.2/gcc_64/lib/cmake/Qt5
```


second option is to install QT trough brew.
```
brew install --force-bottle qt5
```

and the cmake finds this installation and uses it.


### Compilation for Linux and MacOS
Before you run compilation make sure you have updated git branch and git submodules as well. For git submodules update:
```
git submodule update --init --recursive
```

In 'host' folder run commands in console:

```
mkdir build
cd build
cmake ..
make
```


####Windows

We are currently cross compiling for windows from linux. Hence downloading mingw toolchain is essential. In linux terminal please follow these steps
```
sudo apt-get install mingw-w64
```

### Compilation for Windows
To start a build run cmd in a console: windows_build.sh in host folder
