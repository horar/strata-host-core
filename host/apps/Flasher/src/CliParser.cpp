#include "CliParser.h"
#include "Commands.h"
#include "logging/LoggingQtCategories.h"

namespace strata {

CliParser::CliParser(const QStringList &args) :
    args_(args),
    listOption_({QStringLiteral("l"), QStringLiteral("list")}, QStringLiteral("List of connected boards (serial devices).")),
    flashOption_({QStringLiteral("f"), QStringLiteral("flash")},
                 QStringLiteral("Flash firmware from <file> to board specified by 'device' option."), QStringLiteral("file")),
    deviceOption_({QStringLiteral("d"), QStringLiteral("device")}, QStringLiteral("Board number from 'list' option."), QStringLiteral("number"))
{
    parser_.setApplicationDescription(QStringLiteral("Flasher CLI"));
    parser_.addHelpOption();
    parser_.addVersionOption();
    parser_.addOption(listOption_);
    parser_.addOption(flashOption_);
    parser_.addOption(deviceOption_);
}

CommandShPtr CliParser::parse() {
    if (parser_.parse(args_) == false) {
        return std::make_unique<WrongCommand>(parser_.errorText());
    }

    if (parser_.isSet(QStringLiteral("h"))) {  // help option
        return std::make_unique<HelpCommand>(parser_.helpText());
    }

    if (parser_.isSet(QStringLiteral("v"))) {  // version option
        return std::make_unique<VersionCommand>(QCoreApplication::applicationName(),
            parser_.applicationDescription(), QCoreApplication::applicationVersion());
    }

    if (parser_.isSet(listOption_)) {
        return std::make_unique<ListCommand>();
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
            return std::make_unique<WrongCommand>(message);
        }
    }

    if (parser_.isSet(flashOption_)) {
        if (hasDeviceOption == false) {
            return std::make_unique<WrongCommand>(QStringLiteral("Flash firmware: No device specified by 'device' option."));
        }
        return std::make_unique<FlashCommand>(parser_.value(flashOption_), deviceNumber);
    }

    if (hasDeviceOption) {
        return std::make_unique<WrongCommand>(QStringLiteral("Option 'device' cannot be used without 'flash' option!"));
    }

    // Now we have only positional arguments (if any) or none arguments.
    QString message = QStringLiteral("Missing required options!\n") + parser_.helpText();
    return std::make_unique<WrongCommand>(message);
}

}  // namespace
