#ifndef FLASHER_CONSTANTS_H_
#define FLASHER_CONSTANTS_H_

#include <chrono>

namespace strata {

// size of chunk in bytes
constexpr int CHUNK_SIZE = 256;

// emit progress signal every PROGRESS_STEP chunks
constexpr int PROGRESS_STEP = 5;

}

#endif // FLASHER_CONSTANTS_H_
