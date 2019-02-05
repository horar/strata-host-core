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


int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cout << "Usage: ./flasher <path_to_firmware.bin>" << std::endl;
		return 1;
	}

    const char* firmware_file_path = argv[1];

    std::unique_ptr<Connector> connector(ConnectorFactory::getConnector("platform"));

    Flasher flasher(connector.get(), firmware_file_path);

    std::cout << "START: flash" << std::endl;

    bool result = flasher.initializeBootloader() && flasher.flash(true);

    std::cout << "Flash: Return Status:   " << ( result ? "OK": "Failed" ) << std::endl;
    std::cout << "END: flash" << std::endl;

    return ( result ? 0 : 1 );
}
