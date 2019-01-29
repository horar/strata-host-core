/**
******************************************************************************
* @file main.cpp
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Falsher Command Line Interface.
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

#include <Connector.h>
#include <Flasher.h>

using namespace std;

#define MANUAL_OPEN_PORT 0
int main(int argc, char *argv[])
{
	if(argc < 2){
		cout << "Usage: ./flasher <path_to_firmware.bin>" << endl;
		return 1;
	}

	char *firmware_file_path = argv[1];

#if MANUAL_OPEN_PORT
    Connector* connector = ConnectorFactory::getConnector("platform");
    if(!connector->open("/dev/cu.usbserial-DB00VFH8")) {
        return 1;
	}
    Flasher flasher(connector);
#else
    Connector* connector(ConnectorFactory::getConnector("platform"));
    Flasher flasher(connector, firmware_file_path);
#endif

    cout << "START: flash" <<endl;
    cout << "Flash: Return Status:   " << ( flasher.flash(true) ? "true": "false" ) << endl;
    cout << "END: flash" <<endl;

    delete connector;
    return 0;
}
