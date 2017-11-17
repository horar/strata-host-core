Host Controller Service:

Compiling Linux:
Host controller uses GCC 5.40 with the C++11 standard to compile.
The host controller service also contains the Nimbus, our cloud wrapper for couchbase. Nimbus has a dependency on the
couchbase source code header files and litecore library. In order to build HCS then, the couchbase litecore submodule must
be properly downloaded and configured on the local machine. Run the spyglass/cloud/submodule_patches/configure_couchbase.sh
get couchbase installed, patched and compiled. You must run the shell script under 'sudo'.

After the shell completes you can run cmake by creating a '/build' folder in this directory. Then run 'cmake .. -DLINUX=1'

Cross-Compiling for Windows:
Cross compiling is done with x86_64-w64-mingw32-posix-g++. It builds a x64 binary exe and also relies on the couchbase DLLs
which are currently checked in as binary files.

To compile you can run cmake by creating a '/build' folder in this directory. Then run 'cmake .. -DWINDOWS=1 -DCMAKE_TOOLCHAIN_FILE=x86_64.cmake'

**Compiling on MAC**

1) LiteCore is already built and available in host/lib/macos/liblitecore

2) Make sure all the submodules are updated

3) If not, go to the spyglass home directory and type

```
git submodule update --init --recursive
```

4) Once all the submodules are updated, go to spyglass/host/HostContorllerService/build

5) To build, type the following

```
cmake .. -DMAC=1
make
```
