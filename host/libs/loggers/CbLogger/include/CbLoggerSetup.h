#pragma once

#include <QtGlobal>


/*!
 * \brief register2cbLogger
 * \param qtLogCallback pointer to a function used by app Qt logger callback
 */
void cbLoggerSetup(QtMessageHandler qtLogCallback);
