/**
******************************************************************************
* @file SerialPortConfiguration.h
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-04-12
* @brief serial port configuration parameters
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/

#ifndef SERIALPORTCONFIGURATION_H_
#define SERIALPORTCONFIGURATION_H_

#include "Connector.h"

struct serialport_settings{
    int stop_bit_ = 1;
    int data_bit_ = 8;
    int baudrate_ = 115200;
    sp_rts RTS_setting_ = SP_RTS_OFF;
    sp_dtr DTR_setting_ = SP_DTR_OFF;
    sp_parity parity_setting_ = SP_PARITY_NONE;
    sp_cts cts_setting_ = SP_CTS_IGNORE;
};

#endif
