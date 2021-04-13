#ifndef CLI_PARSER_H
#define CLI_PARSER_H

#include <memory>

#include <QStringList>
#include <QCommandLineParser>

#include "Commands.h"

namespace strata {

typedef std::unique_ptr<Command> CommandShPtr;

class CliParser {
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

}  // namespace

#endif
