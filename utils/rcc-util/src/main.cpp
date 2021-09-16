/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <QCommandLineParser>
#include <QDebug>
#include <QDirIterator>
#include <QResource>
#include <QSettings>

#include "Timestamp.h"
#include "Version.h"

int main(int argc, char* argv[])
{

    QCoreApplication::setOrganizationName(QStringLiteral("ON Semiconductor"));
    QCoreApplication::setApplicationName(QStringLiteral("rcc-util"));
    QCoreApplication::setApplicationVersion(AppInfo::version.data());
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QCoreApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription(
        QCoreApplication::translate("main", "Strata RCC files utility\nBuild on %1 at %2")
            .arg(Timestamp::buildTimestamp.data(), Timestamp::buildOnHost.data()));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOptions(
        {{{QStringLiteral("p"), QStringLiteral("prefix")},
          QCoreApplication::translate("main",
                                      "Filter resources prefix <prefix> (default: ':/')."),
          QCoreApplication::translate("main", "prefix")},
         {{QStringLiteral("d"), QStringLiteral("dump")},
          QCoreApplication::translate("main",
                                      "Dump <file> content if found instead of package listing."),
          QCoreApplication::translate("main", "file")},
         {{QStringLiteral("e"), QStringLiteral("extract")},
          QCoreApplication::translate("main", "Extract RCCs content to <dir> instead of package listing (experimental)."),
          QCoreApplication::translate("main", "dir")}});
    parser.addPositionalArgument(QStringLiteral("RCCs"),
                                 QCoreApplication::translate("main", "RCCs to list, at least one"),
                                 QStringLiteral("[RCCs...]"));

    parser.process(app);

    const QString filterResourcesPrefix{parser.isSet(QStringLiteral("prefix"))
                                            ? parser.value(QStringLiteral("prefix"))
                                            : QStringLiteral(":/")};

    QDebug info = qInfo();
    info.noquote();

    if (parser.isSet(QStringLiteral("extract"))) {
        QDir currentDir{QDir::currentPath()};
        if (const bool folderCreated = currentDir.mkpath(parser.value(QStringLiteral("extract"))); folderCreated == false) {
            info << QCoreApplication::translate("main", "Failed to create target extract folder");
            return EXIT_FAILURE;
        }
    }

    if (const QStringList args = parser.positionalArguments(); !args.isEmpty()) {
        for (const auto& rccName : args) {
            info << QCoreApplication::translate("main", "Loading '%1' ->").arg(rccName);
            if (const auto resourceLoaded = QResource::registerResource(rccName); resourceLoaded == false) {
                info << QCoreApplication::translate("main", "FAILED\n");
                continue;
            }
            info << QCoreApplication::translate("main", "OK; files:\n %1\n").arg(QString(78, '-'));

            QDirIterator it(filterResourcesPrefix, QDirIterator::Subdirectories);
            while (it.hasNext()) {
                if (parser.isSet(QStringLiteral("dump"))) {
                    const QFileInfo fileInfo{it.next()};
                    if (fileInfo.isFile() && fileInfo.filePath() == QString(":%1").arg(parser.value(
                                                                        QStringLiteral("dump")))) {
                        QFile file(fileInfo.filePath());
                        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                            info << QCoreApplication::translate(
                                        "main", "opening FAILED (code: %1; \"%2\")\n")
                                        .arg(file.error())
                                        .arg(file.errorString());
                            break;
                        }

                        while (!file.atEnd()) {
                            info << file.readLine();
                        }
                        break;
                    }
                } else if (parser.isSet(QStringLiteral("extract"))) {
                    it.next();
                    const QString resourceFile{it.filePath()};
                    const QString localFile{QString{resourceFile}.remove(0, 2)};

                    if (it.fileInfo().isDir()) {
                        QDir workingDir{QDir::currentPath()};

                        if (const bool pathCreated =
                                workingDir.mkpath(QString("%1/%2")
                                                      .arg(parser.value(QStringLiteral("extract")))
                                                      .arg(localFile));
                            pathCreated == false) {
                            info << QCoreApplication::translate(
                                "main", "Failed to create target working folder");
                            return EXIT_FAILURE;
                        } else {
                            info << QCoreApplication::translate(
                                        "main", "creating folder '%1' -> %2/%3/%4 ... %5\n")
                                        .arg(resourceFile)
                                        .arg(workingDir.path())
                                        .arg(parser.value(QStringLiteral("extract")))
                                        .arg(localFile)
                                        .arg(pathCreated);
                        }

                        it.next();
                        continue;
                    }

                    info << QCoreApplication::translate("main", "copying '%1' -> %2 ... %3\n")
                                .arg(resourceFile)
                                .arg(localFile)
                                .arg(QFile::copy(resourceFile,
                                                 QString("%1/%2/%3")
                                                     .arg(QDir::currentPath())
                                                     .arg(parser.value(QStringLiteral("extract")))
                                                     .arg(localFile)));
                } else {
                    info << it.next() << '\n';
                }
            }
            info << QString(78, '-');
        }
    } else {
        parser.showHelp(EXIT_FAILURE);
    }
}
