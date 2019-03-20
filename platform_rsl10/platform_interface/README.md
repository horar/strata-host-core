# Platform Interface in C
- Platform interface written in C for RSL10 or any other board that
does not support mbed and has limited flash storage (program memory)

- Dependencies: Memory Pool
- It assumes that UART end character is '\n' (the new line feed)

## Development info
### Source code organisation
* CMakeLists.txt - CMake project root file
* README.md - this file
* test_example - project examples
* include - all *public* header files
* src - all *internal* source code



## How to use:
- Please look-up example.c under test_example directory.
- To change the command length, you can change the macro COMMAND_LENGTH_IN_BYTES
in platform_command_dispatcher.c file (planning to do that through cmake).
- platform_command_implementation.c contains the list of command handlers, where
you could add a handler for any command.
- Debug messages could turn on/off by setting the if condition in debug_macros.h 
to true/false (panning to do that as well through cmake)     


### Software requirements
- CMake 3.10+
- Git 2.7+

### Compilation
Clone the project from BitBucket server
```bash
   git clone https://bitbucket.org/onsemi-spyglass/spyglass.git
   cd platform_rsl10/
```
Create build folder, configure and generate Makefile project files
```bash
   mkdir build && cd build
   cmake ..
   make
```


 