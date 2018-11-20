/**
******************************************************************************
* @file main.cpp
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Test main APIs used by the flasher. This example shows how to encode struct and decode it to the original form.
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
#include <string.h>
#include "bootloader_protocol.h"
#include "util.h"
using namespace std;

int main(int argc, char *argv[]){

	cout << "Size of struct CommandHeader:" << sizeof(struct CommandHeader) << endl;
	cout << "Size of struct FirmwareMetadata:" << sizeof(struct FirmwareMetadata) << endl;
	cout << "Size of struct Flash:" << sizeof(struct Flash) << endl;
	cout << "Size of struct Binary:" << sizeof(struct Binary) << endl;
	cout << "Size of struct FirmwareInformationBlock:" << sizeof(struct FirmwareInformationBlock) << endl;
	char arr[5000];
	char encoded[5000];
	struct FirmwareInformationBlock fib;
	fib.command_header.cmd = 'A';
	fib.firmware_metadata.checksum = 0;
  fib.firmware_metadata.firmware_size = 1;
  fib.firmware_metadata.firmware_status = 2;

	memcpy(arr, &fib, sizeof(fib) );

	convertRawStringToHexString(arr,sizeof(fib), encoded );

	convertHexStringToRawString(encoded, sizeof(fib), arr);

	memcpy(&fib, arr, sizeof(fib) );

	cout << "command_header:" << fib.command_header.cmd << endl;
	cout << "checksum:" << fib.firmware_metadata.checksum << endl;
	cout << "firmware_size:" << fib.firmware_metadata.firmware_size << endl;
	cout << "firmware_status:" << fib.firmware_metadata.firmware_status << endl;

	cout << "--------------------------------" << endl;


	struct Flash flash;
	flash.command_header.cmd = 'B';
	memset(flash.binary.binary_data, 'A',sizeof(flash.binary.binary_data));
	flash.binary.binary_data[ sizeof(flash.binary.binary_data) -1 ] = '\0';
	flash.binary.sector_id = 1;
	flash.binary.bytes_count = 2;

	memcpy(arr, &flash, sizeof(flash) );

	convertRawStringToHexString(arr,sizeof(flash), encoded );

	convertHexStringToRawString(encoded, sizeof(flash), arr);

	memcpy(&flash, arr, sizeof(flash) );

	cout << "command_header:" << flash.command_header.cmd << endl;
	cout << "binary_data:" << flash.binary.binary_data << endl;
	cout << "sector_id:" << flash.binary.sector_id << endl;
	cout << "bytes_count:" << flash.binary.bytes_count << endl;

	return 0;
}
