/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>

namespace strata::platform::validation {

Q_NAMESPACE

enum class Status : short {
    Plain,
    Info,
    Warning,
    Error,
    Success
};
Q_ENUM_NS(Status)

}  // namespace
