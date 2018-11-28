# Flasher Readme file

### Installing

Inside spyglass,

```
cd host/Flasher
mkdir build
cd build

```

####Linux and MAC

```
cmake ..

```

####Windows

We are currently cross compiling for windows from linux. Hence downloading mingw toolchain is essential. In linux terminal please follow these steps
```
sudo apt-get install mingw-w64

```

####Windows

We are currently cross compiling for windows from linux. To get the makefile for windows with cross compiling toolchain follow this step

```
cmake .. -DCROSSCOMPILE=1 -DCMAKE_TOOLCHAIN_FILE=../../hcs2/cmake/x86_64.cmake

```
The flasher-cli executable file requires the following dll files:
libgcc_s_seh-1.dll
libserialport-0.dll
libzmq.dll
libwinpthread-1.dll
libstdc++-6.dll

These files are located in ./spyglass/deployment/dependencies/hcs

####Building on all machines

```
make

```

####Test
./build/flasher-cli/flasher-cli <binary-file-path.bin>
