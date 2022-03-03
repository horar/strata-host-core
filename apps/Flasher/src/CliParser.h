/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <memory>

#include <QCommandLineParser>
#include <QStringList>

#include "commands/Command.h"

namespace strata::flashercli
{
typedef std::unique_ptr<commands::Command> CommandShPtr;

class CliParser
{
public:
    /*!
     * CliParser constructor.
     * \param args command line arguments
     */
    CliParser(const QStringList &args);

    /*!
     * Parse command line arguments.
     * \return Right 'Commands' object according to given command line arguments
     */
    CommandShPtr parse();

private:
    const QStringList args_;
    const QCommandLineOption listOption_;
    const QCommandLineOption flashFirmwareOption_;
    const QCommandLineOption flashBootloaderOption_;
    const QCommandLineOption backupFirmwareOption_;
    const QCommandLineOption deviceInfoOption_;
    const QCommandLineOption deviceOption_;
    QCommandLineParser parser_;
};

}  // namespace strata::flashercli
