/**
******************************************************************************
* @file SerialPortConfiguration.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-04-12
* @brief serial port configuration parameters
******************************************************************************

* @copyright Copyright 2018 ON Semiconductor
*/

#ifndef SERIALPORTCONFIGURATION_H_
#define SERIALPORTCONFIGURATION_H_

#include "Connector.h"

// Serial Port Configuration
enum class SERIAL_PORT_CONFIGURATION {
    STOP_BIT = 1,
    DATA_BIT = 8,
    BAUD_RATE = 115200,
};

// Serial Port Flow Control
struct serial_port_settings{
    sp_rts rts_ = SP_RTS_OFF;
    sp_dtr dtr_ = SP_DTR_OFF;
    sp_parity parity_ = SP_PARITY_NONE;
    sp_cts cts_ = SP_CTS_IGNORE;
};

#endif
