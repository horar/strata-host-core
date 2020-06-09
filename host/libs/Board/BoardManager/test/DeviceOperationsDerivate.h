#pragma once

#include <Device/DeviceOperations.h>

class DeviceOperationsDerivate : public strata::device::DeviceOperations
{
    Q_OBJECT
public:
    DeviceOperationsDerivate(const strata::device::DevicePtr& device);

    bool mockIsExecutingCommand() {return operation_ != strata::device::DeviceOperation::None;}
    strata::device::DeviceOperation mockGetOperation() {return operation_;}
};
