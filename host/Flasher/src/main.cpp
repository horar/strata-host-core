/**
******************************************************************************
* @file main.cpp
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Test Falsher Api.
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*
* @internal
*
* @endinternal
*
* @ingroup driver
*/

#include <string>
#include <iostream>
#include <unistd.h>
#include <thread>// std::this_thread::sleep_for
#include "Connector.h"
#include "Flasher.h"
using namespace std;

#define MANUAL_OPEN_PORT 0
int main(int argc, char *argv[]){

	if(argc < 2){
		cout << "Usage: ./flasher path_to_firmware.bin" << endl;
		return 1;
	}

	char *firmware_file_path = argv[1];


#if MANUAL_OPEN_PORT
	SerialConnector *serialConnector = new SerialConnector();
	int res = serialConnector->open("/dev/cu.usbserial-DB00VFH8");
	if(!res){
		return 0;
	}
	Flasher flasher(serialConnector);
#else
	Flasher flasher;
#endif

	//TODO: Listen on port changes instead of wait
	// Wait till port is open
	// std::this_thread::sleep_for (std::chrono::milliseconds(2000));

	cout << "START: flash" <<endl;
	int r = flasher.flash(firmware_file_path);
	cout << "r:" << r << endl;
	cout << "END: flash" <<endl;

#if MANUAL_OPEN_PORT
	delete serialConnector;
#endif
	return 0;
}
