Version 1
~~~~~~~~~

Dependency :

Linux:
	1) libevent, zeromq, libserialport

Windows 64:
	1) x86_64-w64-mingw32 (toolchain)
	2) libevent, zeromq, libserialport (configured explicitly
					    for Windows)
 example : 
	./configure -host=x86_64-w64-mingw32 --prefix=new_dir
	
	3) refer wiki where to place the libraries after configure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Cross-Platform communication demo

Features not supported:
	1) Mutiple Connect and Dis-Connect

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Test bed:
	Linux : tested
	Windows 64 : tested
	Windows 32 : not tested
	OS-X : not tested

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
serial_zmq.cpp : HostControllerService type demo functionality
zmq_client.cpp : HostControllerClient type demo functionality

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
To create executable for Linux :
cmake -DLINUX=1 ..

To cross-compile for Windows from Linux:
cmake -DCMAKE_TOOLCHAIN_FILE=x86_64.cmake -DWINDOWS=1 ..

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Executable path:
	Debug/demo_hcs || Debug/demo_hcs.exe
	Debug/demo_hcc || Debug/demo_hcc.exe
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
