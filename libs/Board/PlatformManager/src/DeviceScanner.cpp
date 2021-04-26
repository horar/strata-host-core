#include <DeviceScanner.h>
#include "logging/LoggingQtCategories.h"

namespace strata::device::scanner {

DeviceScanner::DeviceScanner(const Device::Type scannerType) :
    scannerType_(scannerType)
{ }

DeviceScanner::~DeviceScanner() { }


Device::Type DeviceScanner::scannerType() const
{
    return scannerType_;
}

}  // namespace
