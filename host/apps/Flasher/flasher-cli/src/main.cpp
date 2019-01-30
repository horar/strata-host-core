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
    if (argc < 2)
    {
		cout << "Usage: ./flasher <path_to_firmware.bin>" << endl;
		return 1;
	}

	char *firmware_file_path = argv[1];

    std::unique_ptr<Connector> connector(ConnectorFactory::getConnector("platform"));
#if MANUAL_OPEN_PORT
    if(!connector->open("/dev/cu.usbserial-DB00VFH8"))
    {
        return 1;
    }
#endif
    Flasher flasher(connector.get(), firmware_file_path);

    cout << "START: flash" << endl;

    if (false == flasher.initializeBootloader())
    {
        return 1;
    }

    bool result = flasher.flash(true);

    cout << "Flash: Return Status:   " << ( result ? "OK": "Failed" ) << endl;
    cout << "END: flash" << endl;

    return 0;
}
