Spyglass platform applications located in/platform/applications
require MBed Operating System libraries and its dependencies.

How to set up your MBed OS enviroment is explained in README file located in /platform/tools/MbedOSBuilder


#This process must be executed before building any platform application!


HOW TO BUILD:
=============

Inside spyglass directory, create a new directory called "build" and from there run
Mac, Linux: cmake .. -Dproject_name="water-heater"
Windows: cmake .. -G"MinGW Makefiles" -Dproject_name="water-heater"

#if you have problems with integrating MbedOS to your enviroment use:

cmake .. .. -Dproject_name="water-heater" -DMBED_OS_CHECKOUT=True


Where water-heater is the project name located in the platform/applications directory
and for now we support build of this project only.

USP-PD-100W comming soon.
