#pragma once

#include <QByteArray>

// data for fake firmware/bootloader
namespace strata::FlasherTestConstants {

// default timeout for QTRY_COMPARE_WITH_TIMEOUT
constexpr int TEST_TIMEOUT = 1000;

constexpr int firmwareBufferSize = 1279; //represents 20 chunks of firmware (20 * mock_firmware_constants::CHUNK_SIZE/sizeof (int) - 1)
constexpr int bootloaderBufferSize = 639; //represents 10 chunks

} // namespace strata::FlasherTestConstants
