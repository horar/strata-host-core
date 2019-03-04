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

#include <Flasher.h>
#include <serial_port.h>
#include <PlatformConnection.h>


int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        std::cout << "Usage: ./flasher <path_to_firmware.bin>" << std::endl;
		return 1;
	}

    const char* firmware_file_path = argv[1];

    std::vector<std::string> portsList;
    if (!getListOfSerialPorts(portsList)) {
        std::cerr << "Unable to populate list of serial ports" << std::endl;
        return 1;
    }

    if (portsList.empty()) {
        std::cerr << "No device connected on serial port." << std::endl;
        return 1;
    }

    std::string choosen_port;
    if (portsList.size() > 1) {
        std::cout << "Choose one port:" << std::endl;

        int idx = 1;
        for(const auto& item : portsList) {
            std::cout << idx << ") " << item << std::endl;
            idx++;
        }

        try {

            std::string input;
            std::cin >> input;

            int choosen_idx = std::stoi(input);
            choosen_port = portsList[choosen_idx];
        }
        catch(const std::exception& ex) {
            std::cout << "Error:" << ex.what() << std::endl;
            return 1;
        }

    }
    else {
        choosen_port = portsList.front();
    }

    std::unique_ptr<spyglass::PlatformConnection> connection(new spyglass::PlatformConnection(nullptr));

    if (!connection->open(choosen_port)) {
        std::cerr << "Cudn't open the serial port!" << std::endl;
        return 1;
    }

    connection->waitForMessages(100);


    Flasher flasher(connection.get(), firmware_file_path);

    std::cout << "START: flash" << std::endl;

    bool result = flasher.initializeBootloader() && flasher.flash(true);

    std::cout << "Flash: Return Status:   " << ( result ? "OK": "Failed" ) << std::endl;
    std::cout << "END: flash" << std::endl;

    return ( result ? 0 : 1 );
}
