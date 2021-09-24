/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QtGlobal>

namespace strata::loggers
{
/*!
 * \brief register2cbLogger
 * \param qtLogCallback pointer to a function used by app Qt logger callback
 */
void cbLoggerSetup(QtMessageHandler qtLogCallback);

}  // namespace strata::loggers
