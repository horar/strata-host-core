/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "logging/LoggingQtCategories.h"

#include "ComponentUpdateInfo.h"
#include <QDir>
#include <QFileInfo>
#include <QDomDocument>
#include <QJsonObject>
#include <QProcess>
#include <QCoreApplication>
#include <QVersionNumber>

void ComponentUpdateInfo::requestUpdateInfo(const QByteArray &clientId) {
    QString updateMetadata;
    QString error = acquireUpdateMetadata(updateMetadata);
    if (error.isEmpty()) {
        if (updateMetadata.isEmpty()) {
            handleUpdateInfoResponse(clientId, QJsonArray(), QString());    // no updates available
            return;
        } else {
            QJsonArray updateInfo;
            error = acquireUpdateInfo(updateMetadata, updateInfo);
            if (error.isEmpty()) {
                handleUpdateInfoResponse(clientId, updateInfo, QString());
                return;
            }
        }
    }

    handleUpdateInfoResponse(clientId, QJsonArray(), error);
}

void ComponentUpdateInfo::handleUpdateInfoResponse(const QByteArray &clientId, QJsonArray componentList, const QString &errorString) {
    emit requestUpdateInfoFinished(clientId, componentList, errorString);
}

QString ComponentUpdateInfo::acquireUpdateInfo(const QString &updateMetadata, QJsonArray &updateInfo) const {
    QMap<QString, QString> componentMap;
    QString error = getCurrentVersionOfComponents(componentMap);
    if (error.isEmpty() == false) {
        return error;
    }

    QString errorMsg;
    int errorColumn = 0;
    QDomDocument xmlDocument("MaintenanceToolOutput");
    if (xmlDocument.setContent(updateMetadata, false, &errorMsg, &errorColumn) == false) {
        qCCritical(lcHcs) << "Could not parse updateMetadata: " << errorMsg << ", errorColumn: " << errorColumn;
        return "Unable to check for updates. Error parsing update metadata: " + errorMsg;
    }
    return parseUpdateMetadata(xmlDocument, componentMap, updateInfo);
}

QString ComponentUpdateInfo::getCurrentVersionOfComponents(QMap<QString, QString>& componentMap) const {
    // Retrieve current version info from 'components.xml' file
    const QDir applicationDir(QCoreApplication::applicationDirPath());
    const QString absPathComponentsXmlFile = applicationDir.filePath("components.xml");

    if ((QFileInfo::exists(absPathComponentsXmlFile) == false) || (QFileInfo(absPathComponentsXmlFile).isFile() == false)) {
        qCCritical(lcHcs) << "File components.xml not found at " << absPathComponentsXmlFile;
        return "Unable to check for updates. File components.xml not found at " + absPathComponentsXmlFile;
    }
    // Load 'components.xml' file
    QFile file(absPathComponentsXmlFile);
    if (file.open(QIODevice::ReadOnly) == false) {
        return "Unable to check for updates. Unable to open " + absPathComponentsXmlFile;
    }

    QString errorMsg;
    int errorColumn = 0;
    QDomDocument xmlDocument("components");
    if (xmlDocument.setContent(&file, false, &errorMsg, &errorColumn) == false) {
        file.close();
        qCCritical(lcHcs) << "Could not parse components.xml: " << errorMsg << ", errorColumn: " << errorColumn;
        return "Unable to check for updates. Error parsing components.xml: " + errorMsg;
    }
    file.close();

    QDomElement componentInfoRoot = xmlDocument.documentElement();
    QDomNode componentInfoNode = componentInfoRoot.firstChild();
    while (componentInfoNode.isNull() == false) {
        QDomElement componentInfoElement = componentInfoNode.toElement(); // try to convert the node to an element.
        if (componentInfoElement.isNull() == false) {
            if (componentInfoElement.tagName() == "Package") {
                QString packageName; bool packageNameFound = false;
                QString packageVersion; bool packageVersionFound = false;
                QDomNode packageInfoNode = componentInfoElement.firstChild();
                while (packageInfoNode.isNull() == false) {
                    QDomElement packageInfoElement = packageInfoNode.toElement(); // try to convert the node to an element.
                    if (packageInfoElement.isNull() == false) {
                        if ((packageInfoElement.tagName() == "Title") && (packageNameFound == false)) {
                            packageName = packageInfoElement.text();
                            if (packageName.isEmpty() == false) {
                                packageNameFound = true;
                            }
                        } else if (packageInfoElement.tagName() == "Version" && (packageVersionFound == false)) {
                            packageVersion = packageInfoElement.text();
                            if (packageVersion.isEmpty() == false) {
                                packageVersionFound = true;
                            }
                        }
                    }
                    packageInfoNode = packageInfoNode.nextSibling();
                }
                if ((packageNameFound == true) && (packageVersionFound == true)) {
                    if (packageName == "OpenSSL Libraries") {
                        preprocessOpenSSLVersion(packageVersion);
                    }
                    componentMap.insert(packageName, packageVersion);
                    qCInfo(lcHcs) << "Found mandatory elements (Title / Version) in components.xml: " << packageName << ", " << packageVersion;
                } else {
                    qCWarning(lcHcs) << "Missing mandatory elements (Title / Version) in components.xml";
                }
            }
        }
        componentInfoNode = componentInfoNode.nextSibling();
    }
    if (componentMap.isEmpty()) {
        return "Unable to check for updates. Error acquiring components from components.xml file.";
    } else {
        return QString();
    }
}

QString ComponentUpdateInfo::parseUpdateMetadata(const QDomDocument &xmlDocument, const QMap<QString, QString>& componentMap, QJsonArray &updateInfo) const {
    QDomElement updateInfoRoot = xmlDocument.documentElement();
    QDomNode updateInfoNode = updateInfoRoot.firstChild();
    while (updateInfoNode.isNull() == false) {
        QDomElement updateInfoElement = updateInfoNode.toElement(); // try to convert the node to an element.
        if (updateInfoElement.isNull() == false) {
            if (updateInfoElement.tagName() == "update") {
                if (updateInfoElement.hasAttribute("name") && updateInfoElement.hasAttribute("version") && updateInfoElement.hasAttribute("size")) {
                    QString updateName = updateInfoElement.attribute("name");
                    QString updateVersion = updateInfoElement.attribute("version");
                    QString updateSize = parseUpdateSize(updateInfoElement.attribute("size"));

                    if (updateName == "OpenSSL Libraries") {
                        preprocessOpenSSLVersion(updateVersion);
                    }

                    QJsonObject payload;
                    payload.insert("name", updateName);
                    payload.insert("latest_version", updateVersion);
                    payload.insert("update_size", updateSize);
                    if (componentMap.contains(updateName)) {
                        payload.insert("current_version", componentMap[updateName]);
                    } else {
                        qCWarning(lcHcs) << "Missing component " << updateName << " in installed componentns: " << componentMap;
                        // this might be valid, it might be forcing installation of new component which was not installed
                        payload.insert("current_version", "N/A");
                    }
                    updateInfo.push_back(payload);
                    qCInfo(lcHcs) << "Inserted Update Info: " << payload;
                } else {
                    qCWarning(lcHcs) << "Missing mandatory attributes (name / version / size) in update metadata";
                }
            } else {
                qCWarning(lcHcs) << "Unknown element in update metadata: " << updateInfoElement.tagName();
            }
        }
        updateInfoNode = updateInfoNode.nextSibling();
    }
    return QString();
}

QString ComponentUpdateInfo::parseUpdateSize(const QString& updateSize) const
{
    bool succesfullyParsed;
    float num = updateSize.toFloat(&succesfullyParsed);
    if(succesfullyParsed == false) {
        return QString("N/A");
    }

    QStringList unitList = { "Bytes", "KB", "MB", "GB", "TB" };
    QStringListIterator iter(unitList);
    QString currentUnit(iter.next());
    bool displayFraction = false;

    while((num >= 1024.0) && iter.hasNext())
    {
        currentUnit = iter.next();
        num /= 1024.0;
        if(num > 10.0)
            displayFraction = false;
        else
            displayFraction = true;
    }
    return QString().setNum(num, 'f', displayFraction ? 2 : 0) + " " + currentUnit;
}

void ComponentUpdateInfo::preprocessOpenSSLVersion(QString& opensslVersion) const {
    // for example: 1.1.1.11-1 (which must be changed to 1.1.1k-1)
    // any other version string (with digits != 4) should remain unchanged
    int suffixIndex = 0;
    QVersionNumber parsedVersion = QVersionNumber::fromString(opensslVersion, &suffixIndex);
    QVector<int> versionNumbers = parsedVersion.segments();
    if (versionNumbers.size() == 4) {
        QString suffix;
        if (suffixIndex >= 0) {
            suffix = opensslVersion.mid(suffixIndex);
        }

        if ((versionNumbers[3] >= 'a' && versionNumbers[3] <= 'z')) {
            QString optionalVersion(static_cast<char>(versionNumbers[3]));
            opensslVersion = QString::number(versionNumbers[0]) + QStringLiteral(".") +
                             QString::number(versionNumbers[1]) + QStringLiteral(".") +
                             QString::number(versionNumbers[2]) + optionalVersion + suffix;
        }
    }
}

QString ComponentUpdateInfo::acquireUpdateMetadata(QString &updateMetadata) const {
    // Search for Strata Maintenance Tool in application directory, if found perform check for updates
    const QDir applicationDir(QCoreApplication::applicationDirPath());  // hcs is not an .app, so no need for special handling in case of MacOS
    QString absPathMaintenanceTool;
    QString error = locateMaintenanceTool(applicationDir, absPathMaintenanceTool);

    if (error.isEmpty()) {
        return launchMaintenanceTool(absPathMaintenanceTool, applicationDir, updateMetadata);
    }

    return error;
}

// TODO: this function is duplicated in SDS/HCS, should be unified in future
QString ComponentUpdateInfo::locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool) const {
#if defined(Q_OS_WIN)
    const QString maintenanceToolFilename = "Strata Maintenance Tool.exe";
#elif defined(Q_OS_MACOS)
    const QString maintenanceToolFilename = "Strata Maintenance Tool.app/Contents/MacOS/Strata Maintenance Tool";
#elif defined(Q_OS_LINUX)
    const QString maintenanceToolFilename = "Strata Maintenance Tool";
#endif
    absPathMaintenanceTool = applicationDir.filePath(maintenanceToolFilename);

    if (applicationDir.exists(maintenanceToolFilename) == false) {
        qCCritical(lcHcs) << maintenanceToolFilename << "not found in" << applicationDir.absolutePath();
        return QString("Unable to check for updates. Strata Maintenance Tool not found.");
    }

    return QString();
}

#define MAINTENANCE_TOOL_START_TIMEOUT 2000 // msecs
#define MAINTENANCE_TOOL_FINISH_TIMEOUT 5000 // msecs
QString ComponentUpdateInfo::launchMaintenanceTool(const QString &absPathMaintenanceTool, const QDir &applicationDir, QString &updateMetadata) const {
    qCInfo(lcHcs) << "Launching Strata Maintenance Tool";
    QStringList arguments;
    arguments << "--checkupdates" <<  "--verbose";

    QProcess maintenanceToolProcess;
    maintenanceToolProcess.setProgram(absPathMaintenanceTool);
    maintenanceToolProcess.setArguments(arguments);
    maintenanceToolProcess.setWorkingDirectory(applicationDir.absolutePath());
    maintenanceToolProcess.start();

    // Wait until the update tool is finished
    if ((maintenanceToolProcess.waitForStarted(MAINTENANCE_TOOL_START_TIMEOUT) == false) ||
        (maintenanceToolProcess.waitForFinished(MAINTENANCE_TOOL_FINISH_TIMEOUT) == false) ||
        (maintenanceToolProcess.exitStatus() != QProcess::NormalExit) ||
        (maintenanceToolProcess.exitCode() != EXIT_SUCCESS)) {
        // Note that when no updates are available, the exit code will be 1
        QString errorOutput = maintenanceToolProcess.readAllStandardError();
        qCCritical(lcHcs) << "Error code returned when checking for updates (" +
                QString::number(maintenanceToolProcess.error()) + "): " +
                maintenanceToolProcess.errorString() + ", error output: " + errorOutput;
        return "Unable to check for updates. Loading of Strata Maintanance Tool failed with error code " + QString::number(maintenanceToolProcess.error()) + ".";
    }

    // Read the output
    QByteArray maintenanceToolOutput = maintenanceToolProcess.readAllStandardOutput();
    if (maintenanceToolOutput.isEmpty()) {
        qCCritical(lcHcs) << "Error acquiring maintenance tool output: no standard output, error output: " +
                                      maintenanceToolProcess.readAllStandardError();
        return "Unable to check for updates. Error acquiring Strata Maintanance Tool output.";
    }

    QString updateData = maintenanceToolOutput;
    QString updatesBeginStr("<updates>");
    QString updatesEndStr("</updates>");
    int beginIdx = updateData.indexOf(updatesBeginStr);
    int endIdx = updateData.indexOf(updatesEndStr);

    if ((beginIdx == -1) || (endIdx == -1) || (endIdx < beginIdx)) {
        if (updateData.contains("There are currently no updates available.")) {
            qCInfo(lcHcs) << "No updates available";
            return QString();
        } else {
            qCCritical(lcHcs) << "Error parsing maintenance tool output:" << updateData;
            return "Unable to check for updates. Error parsing Strata Maintanance Tool output.";
        }
    }

    // extract only desired part in case we acquire more information
    updateMetadata = updateData.mid(beginIdx, (endIdx - beginIdx) + updatesEndStr.size());
    qCInfo(lcHcs) << "Updates available:" << updateMetadata;
    return QString();
}

