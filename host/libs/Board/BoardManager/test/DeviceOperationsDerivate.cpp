#include "DeviceOperationsDerivate.h"
#include "QtTest.h"

using strata::device::Device;
using strata::device::DeviceOperations;

DeviceOperationsDerivate::DeviceOperationsDerivate(const strata::device::DevicePtr& device)
    : DeviceOperations(device)
{
}
