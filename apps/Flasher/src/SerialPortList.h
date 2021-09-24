/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef SERIAL_PORT_LIST_H
#define SERIAL_PORT_LIST_H

#include <QString>
#include <QList>

namespace strata {

class SerialPortList {
public:
    /*!
     * SerialPortList constructor.
     */
    SerialPortList();

    /*!
     * Get name of serial port.
     * \param index index of serial port (starting from 0)
     * \return name of serial port if index is valid, otherwise empty string
     */
    QString name(int index) const;

    /*!
     * Get list of available serial ports.
     * \return list of names of all available serial ports
     */
    QList<QString> list() const;

    /*!
     * Get count of available serial ports.
     * \return count of available serial ports
     */
    int count() const;

private:
    QList<QString> portNames_;
};

}  // namespace

#endif
