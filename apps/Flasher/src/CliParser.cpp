/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "CliParser.h"

#include "commands/DeviceCommand.h"
#include "commands/FlasherCommand.h"
#include "commands/HelpCommand.h"
#include "commands/InfoCommand.h"
#include "commands/ListCommand.h"
#include "commands/VersionCommand.h"
#include "commands/WrongCommand.h"

#include "logging/LoggingQtCategories.h"

namespace strata::flashercli
{
CliParser::CliParser(const QStringList &args) : args_(args),
      listOption_({QStringLiteral("l"), QStringLiteral("list")},
                  QStringLiteral("List of connected boards (serial devices).")),
      flashFirmwareOption_({QStringLiteral("f"), QStringLiteral("flash")},
                           QStringLiteral("Flash firmware from <file> to board specified by 'device' option."),
                           QStringLiteral("file")),
      flashBootloaderOption_({QStringLiteral("flashbootloader")},
                             QStringLiteral("Flash bootloader from <file> to board specified by 'device' option."),
                             QStringLiteral("file")),
      backupFirmwareOption_({QStringLiteral("b"), QStringLiteral("backup")},
                            QStringLiteral("Backup firmware from board specified by 'device' option to <file>."),
                            QStringLiteral("file")),
      deviceInfoOption_({QStringLiteral("i"), QStringLiteral("info")},
                        QStringLiteral("Information about board specified by 'device' option.")),
      deviceOption_({QStringLiteral("d"), QStringLiteral("device")}, QStringLiteral("Board number from 'list' option."),
                    QStringLiteral("number"))
{
    parser_.setApplicationDescription(QStringLiteral("Flasher CLI"));
    parser_.addHelpOption();
    parser_.addVersionOption();
    parser_.addOption(listOption_);
    parser_.addOption(flashFirmwareOption_);
    parser_.addOption(flashBootloaderOption_);
    parser_.addOption(backupFirmwareOption_);
    parser_.addOption(deviceInfoOption_);
    parser_.addOption(deviceOption_);
}

CommandShPtr CliParser::parse()
{
    if (parser_.parse(args_) == false) {
        return std::make_unique<commands::WrongCommand>(parser_.errorText());
    }

    if (parser_.isSet(QStringLiteral("h"))) {  // help option
        return std::make_unique<commands::HelpCommand>(parser_.helpText());
    }

    if (parser_.isSet(QStringLiteral("v"))) {  // version option
        return std::make_unique<commands::VersionCommand>(QCoreApplication::applicationName(),
                                                          parser_.applicationDescription(),
                                                          QCoreApplication::applicationVersion());
    }

    if (parser_.isSet(listOption_)) {
        return std::make_unique<commands::ListCommand>();
    }

    bool hasDeviceOption = false;
    int deviceNumber = 0;
    if (parser_.isSet(deviceOption_)) {
        QString number = parser_.value(deviceOption_);
        bool ok;
        deviceNumber = number.toInt(&ok);
        if (ok) {
            hasDeviceOption = true;
        } else {
            QString message = QStringLiteral("'") + number + QStringLiteral("' is not a valid device number.");
            return std::make_unique<commands::WrongCommand>(message);
        }
    }

    if (parser_.isSet(flashFirmwareOption_)) {
        if (hasDeviceOption == false) {
            return std::make_unique<commands::WrongCommand>(QStringLiteral("Flash firmware: No device specified by 'device' option."));
        }
        return std::make_unique<commands::FlasherCommand>(parser_.value(flashFirmwareOption_), deviceNumber, commands::FlasherCommand::CmdType::FlashFirmware);
    }

    if (parser_.isSet(flashBootloaderOption_)) {
        if (hasDeviceOption == false) {
            return std::make_unique<commands::WrongCommand>(QStringLiteral("Flash bootloader: No device specified by 'device' option."));
        }
        return std::make_unique<commands::FlasherCommand>(parser_.value(flashBootloaderOption_), deviceNumber, commands::FlasherCommand::CmdType::FlashBootloader);
    }

    if (parser_.isSet(backupFirmwareOption_)) {
        if (hasDeviceOption == false) {
            return std::make_unique<commands::WrongCommand>(QStringLiteral("Backup firmware: No device specified by 'device' option."));
        }
        return std::make_unique<commands::FlasherCommand>(parser_.value(backupFirmwareOption_), deviceNumber, commands::FlasherCommand::CmdType::BackupFirmware);
    }

    if (parser_.isSet(deviceInfoOption_)) {
        if (hasDeviceOption == false) {
            return std::make_unique<commands::WrongCommand>(QStringLiteral("Board information: No device specified by 'device' option."));
        }
        return std::make_unique<commands::InfoCommand>(deviceNumber);
    }

    if (hasDeviceOption) {
        return std::make_unique<commands::WrongCommand>(QStringLiteral("Option 'device' cannot be used without 'flash', 'backup' or 'info' option!"));
    }

    // Now we have only positional arguments (if any) or none arguments.
    QString message = QStringLiteral("Missing required options!\n") + parser_.helpText();
    return std::make_unique<commands::WrongCommand>(message);
}

}  // namespace strata::flashercli
