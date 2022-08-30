/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "PlatformInterfaceGenerator.h"
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonParseError>
#include <QDateTime>

PlatformInterfaceGenerator::PlatformInterfaceGenerator(QObject *parent) : QObject(parent) {}

PlatformInterfaceGenerator::~PlatformInterfaceGenerator() {}

QString PlatformInterfaceGenerator::lastError() const
{
    return lastError_;
}

bool PlatformInterfaceGenerator::generate(const QJsonValue &jsonObject, const QString &outputPath)
{
    lastError_ = "";
    QJsonObject platInterfaceData = jsonObject.toObject();

    QDir outputDir(outputPath);

    if (outputDir.exists() == false) {
        lastError_ = "Path to output folder (" + outputPath + ") does not exist.";
        qCCritical(lcControlViewCreator) << "Output folder path does not exist.";
        return false;
    }

    QFile outputFile(outputDir.filePath("PlatformInterface.qml"));

    if (outputFile.open(QFile::WriteOnly | QFile::Truncate) == false) {
        lastError_ = "Could not open " + outputFile.fileName() + " for writing";
        qCCritical(lcControlViewCreator) << "Could not open" << outputFile.fileName() + "for writing";
        return false;
    }

    QTextStream outputStream(&outputFile);
    outputStream.setCodec("UTF-8");
    int indentLevel = 0;

    // Generate license
    outputStream << generateLicense();

    // Generate imports
    outputStream << generateImports();

    // Generate Header Comment
    QDateTime localTime(QDateTime::currentDateTime());
    outputStream << generateCommentHeader("File auto-generated by PlatformInterfaceGenerator on " + SGUtilsCpp::formatDateTimeWithOffsetFromUtc(localTime));

    // Start of root item
    outputStream << "PlatformInterfaceBase {\n";
    indentLevel++;
    outputStream << insertTabs(indentLevel)
                 << "id: platformInterface\n"
                 << insertTabs(indentLevel) << "apiVersion: " << API_VERSION << "\n\n";
    outputStream << insertTabs(indentLevel) << "property alias notifications: notifications\n";
    outputStream << insertTabs(indentLevel) << "property alias commands: commands\n\n";

    // Notifications
    outputStream << generateCommentHeader("NOTIFICATIONS", indentLevel);
    outputStream << insertTabs(indentLevel) << "QtObject {\n";

    indentLevel++;
    outputStream << insertTabs(indentLevel) << "id: notifications\n";

    // Create QtObjects to handle notifications

    if (platInterfaceData.contains("notifications") == false) {
        lastError_ = "Missing notifications list in JSON.";
        qCCritical(lcControlViewCreator) << lastError_;
        return false;
    }

    QJsonValue notificationsList = platInterfaceData["notifications"];

    if (notificationsList.isArray() == false) {
        lastError_ = "'notifications' needs to be an array";
        qCCritical(lcControlViewCreator) << lastError_;
        return false;
    }

    QJsonArray notificationsListArray = notificationsList.toArray();
    for (QJsonValueRef vNotification : notificationsListArray) {
        QJsonObject notification = vNotification.toObject();
        outputStream << generateNotification(notification, indentLevel);

        if (lastError_.length() > 0) {
            return false;
        }
    }

    indentLevel--;
    outputStream << insertTabs(indentLevel) << "}\n\n";

    // Commands
    outputStream << generateCommentHeader("COMMANDS", indentLevel);
    outputStream << insertTabs(indentLevel) << "QtObject {\n";

    indentLevel++;
    outputStream << insertTabs(indentLevel) << "id: commands\n";

    if (platInterfaceData.contains("commands") == false) {
        lastError_ = "Missing commands list in JSON.";
        qCCritical(lcControlViewCreator) << lastError_;
        return false;
    }

    QJsonArray commandsList = platInterfaceData["commands"].toArray();

    if (notificationsList.isArray() == false) {
        lastError_ = "'commands' needs to be an array";
        qCCritical(lcControlViewCreator) << lastError_;
        return false;
    }

    for (int i = 0; i < commandsList.count(); ++i) {
        QJsonObject command = commandsList[i].toObject();
        outputStream << generateCommand(command, indentLevel);
        if (lastError_.length() > 0) {
            return false;
        }
    }

    indentLevel--;
    outputStream << insertTabs(indentLevel) + "}\n";
    indentLevel--;
    outputStream << "}\n";
    outputFile.close();

    if (indentLevel != 0) {
        lastError_ = "Final indent level is not 0. Check file for indentation errors";
        qCWarning(lcControlViewCreator) << lastError_;
        return true;
    }

    lastError_ = "";
    return true;
}

QString PlatformInterfaceGenerator::generateLicense() const
{
    QString license = "/*\n";
    license += " * Copyright (c) 2018-" + QString::number(QDate::currentDate().year()) + " onsemi.\n";
    license += " *\n";
    license += " * All rights reserved. This software and/or documentation is licensed by onsemi under\n";
    license += " * limited terms and conditions. The terms and conditions pertaining to the software and/or\n";
    license += " * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard\n";
    license += " * Terms and Conditions of Sale, Section 8 Software”).\n";
    license += "*/\n";
    return license;
}

QString PlatformInterfaceGenerator::generateImports() const
{
    QString imports = "import QtQuick 2.12\n";
    imports += "import QtQuick.Controls 2.12\n";
    imports += "import tech.strata.common 1.0\n";
    imports += "import QtQml 2.12\n";
    imports += "\n\n";
    return imports;
}

QString PlatformInterfaceGenerator::generateCommand(const QJsonObject &command, int &indentLevel)
{
    if (command.contains("cmd") == false) {
        lastError_ = "Command did not contain 'cmd'";
        qCCritical(lcControlViewCreator) << lastError_;
        return QString();
    }
    const QString cmd = command["cmd"].toString();
    QString documentationText = '\n' + generateComment("@command " + cmd, indentLevel);
    QString commandBody = "";

    commandBody += insertTabs(indentLevel) + "property QtObject " + cmd + ": QtObject {\n";

    QStringList updateFunctionParams;
    QStringList updateFunctionKwRemoved;
    QStringList payloadProperties;

    if (command.contains("payload") && command["payload"].isNull() == false) {
        QJsonArray payload = command["payload"].toArray();
        for (QJsonValueRef payloadPropertyValue : payload) {
            QJsonObject payloadProperty = payloadPropertyValue.toObject();
            QJsonValue propertyNameValue = payloadProperty.value("name");
            QString propertyName = propertyNameValue.toString();
            updateFunctionParams.append(propertyName);
        }
        updateFunctionKwRemoved = updateFunctionParams;
        removeReservedKeywords(updateFunctionKwRemoved);

        for (QJsonValueRef payloadPropertyValue : payload) {
            QJsonObject payloadProperty = payloadPropertyValue.toObject();
            QJsonValue propNameValue = payloadProperty.value("name");
            QString propName = propNameValue.toString();
            QJsonValue propValue = payloadProperty.value("value");
            QJsonValue typeValue = payloadProperty.value("type");
            QString propType = typeValue.toString();

            payloadProperties.append(insertTabs(indentLevel + 2) + "\"" + propName + "\": " + propName);

            if (lastError_.length() > 0) {
                qCCritical(lcControlViewCreator) << lastError_;
                return "";
            }

            if (propType == TYPE_ARRAY_STATIC) {
                documentationText += generateComment("@property " + propName + ": list of size " + QString::number(propValue.toArray().count()), indentLevel);
            } else {
                documentationText += generateComment("@property " + propName + ": " + propType, indentLevel);
            }

            if (propType == TYPE_OBJECT_STATIC || propType == TYPE_ARRAY_STATIC) {
                commandBody += insertTabs(indentLevel + 1) + "property var " + propName + ": " + getPropertyValue(payloadProperty, propType, indentLevel + 1) + "\n";
            } else if (propType == TYPE_ARRAY_DYNAMIC || propType == TYPE_OBJECT_DYNAMIC) {
                commandBody += insertTabs(indentLevel + 1) + "property var " + propName + ": " + getPropertyValue(payloadProperty, propType, indentLevel) + "\n";
            } else {
                commandBody += insertTabs(indentLevel + 1) + "property " + propType + " " + propName + ": " + getPropertyValue(payloadProperty, propType, indentLevel) + "\n";
            }
        }

        commandBody += "\n" + insertTabs(indentLevel + 1) + "signal commandSent()\n";

        commandBody += "\n";
        commandBody += insertTabs(indentLevel + 1) + "function update(";
        commandBody += updateFunctionKwRemoved.join(", ");
        commandBody += ") {\n";
    } else {
        commandBody += insertTabs(indentLevel + 1) + "signal commandSent()\n\n";
        commandBody += insertTabs(indentLevel + 1) + "function update() {\n";
    }

    // Write update function definition
    if (updateFunctionParams.count() > 0) {
        commandBody += insertTabs(indentLevel + 2) + "this.set(" + updateFunctionKwRemoved.join(", ") + ")\n";
    }
    commandBody += insertTabs(indentLevel + 2) + "this.send()\n";
    commandBody += insertTabs(indentLevel + 1) + "}\n\n";

    // Create set function if necessary
    if (updateFunctionParams.count() > 0) {
        commandBody += insertTabs(indentLevel + 1) + "function set(" + updateFunctionKwRemoved.join(", ") + ") {\n";
        for (int i = 0; i < updateFunctionParams.count(); ++i) {
            commandBody += insertTabs(indentLevel + 2) + "this." + updateFunctionParams.at(i) + " = " + updateFunctionKwRemoved.at(i) + "\n";
        }
        commandBody += insertTabs(indentLevel + 1) + "}\n\n";
    }

    // Create send function
    commandBody += insertTabs(indentLevel + 1) + "function send() {\n";
    commandBody += insertTabs(indentLevel + 2) + "platformInterface.send({\n";
    commandBody += insertTabs(indentLevel + 3) + "\"cmd\": \"" + cmd + "\"";
    if (command.contains("payload") && command["payload"].isNull() == false) {
        commandBody += ",\n" + insertTabs(indentLevel + 3) + "\"payload\": {\n";
        commandBody += insertTabs(indentLevel) + payloadProperties.join(",\n" + insertTabs(indentLevel));
        commandBody += "\n" + insertTabs(indentLevel + 3) + "}";
    }
    commandBody += "\n" + insertTabs(indentLevel + 2) + "})\n";
    commandBody += insertTabs(indentLevel + 2) + "commandSent()\n";
    commandBody += insertTabs(indentLevel + 1) + "}\n";

    commandBody += insertTabs(indentLevel) + "}\n";
    return documentationText + commandBody;
}

QString PlatformInterfaceGenerator::generateNotification(const QJsonObject &notification, int &indentLevel)
{
    if (notification.contains("value") == false) {
        lastError_ = "Notification did not contain 'value'";
        qCCritical(lcControlViewCreator) << lastError_;
        return QString();
    }

    QString notificationId = notification["value"].toString();
    QString notificationBody = "";
    QString documentationBody = "";

    // Create documentation for notification
    documentationBody += '\n' + generateComment("@notification: " + notificationId, indentLevel);

    // Create the QtObject to handle this notification
    notificationBody += insertTabs(indentLevel) + "property QtObject " + notificationId + ": QtObject {\n";
    indentLevel++;

    QString childrenNotificationBody = "";
    QString childrenDocumentationBody = "";
    QString propertiesBody = "";

    QJsonArray payload = notification["payload"].toArray();

    // Add the properties to the notification
    for (QJsonValueRef payloadPropertyValue : payload) {
        if (payloadPropertyValue.isObject() == false) {
            lastError_ = "Payload elements are not objects";
            qCCritical(lcControlViewCreator) << lastError_;
            return QString();
        }

        QJsonObject payloadProperty = payloadPropertyValue.toObject();
        QJsonValue propNameValue = payloadProperty.value("name");
        QString propName = propNameValue.toString();
        QJsonValue propValue = payloadProperty.value("value");
        QJsonValue typeValue = payloadProperty.value("type");
        QString propType =  typeValue.toString();

        generateNotificationProperty(indentLevel, notificationId, propName, propType, propValue, childrenNotificationBody, childrenDocumentationBody);

        if (lastError_.length() > 0) {
            return "";
        }

        if (propType == TYPE_OBJECT_STATIC || propType == TYPE_ARRAY_STATIC) {
            continue;
        } else if (propType == TYPE_ARRAY_DYNAMIC || propType == TYPE_OBJECT_DYNAMIC) {
            propertiesBody += insertTabs(indentLevel) + "property var " + propName + ": " + getPropertyValue(payloadProperty, propType, indentLevel) + "\n";
        } else {
            propertiesBody += insertTabs(indentLevel) + "property " + propType + " " + propName + ": " + getPropertyValue(payloadProperty, propType, indentLevel) + "\n";
        }

        if (lastError_.length() > 0) {
            qCCritical(lcControlViewCreator) << lastError_;
            return "";
        }
    }

    propertiesBody += "\n" + insertTabs(indentLevel) + "signal notificationFinished()\n";

    notificationBody = childrenDocumentationBody + notificationBody + propertiesBody;
    notificationBody += childrenNotificationBody;

    indentLevel--;
    notificationBody += insertTabs(indentLevel) + "}\n";
    return documentationBody + notificationBody;
}

void PlatformInterfaceGenerator::generateNotificationProperty(int indentLevel, const QString &parentId, const QString &id, const QString &type, const QJsonValue &value, QString &childrenNotificationBody, QString &childrenDocumentationBody)
{
    QString notificationBody = "";
    QString documentation = "";

    if (type == TYPE_ARRAY_STATIC || type == TYPE_OBJECT_STATIC) {
        QString properties = "";
        QString childNotificationBody = "";
        QString childDocumentationBody = "";
        QJsonArray valueArray = value.toArray();

        // Generate a property for each element in array
        notificationBody += insertTabs(indentLevel) + "property QtObject " + id + ": QtObject {\n";

        // Add object name
        if (type == TYPE_ARRAY_STATIC) {
            notificationBody += insertTabs(indentLevel + 1) + "objectName: \"array\"\n";
        } else {
            notificationBody += insertTabs(indentLevel + 1) + "objectName: \"object\"\n";
        }

        // This documentation text will be passed back to parent
        // This allows us to generate comments above each QtObject for their properties
        documentation += generateComment("@property " + id + ": " + type, indentLevel - 1);

        // Add the properties to the notification
        for (int i = 0; i < valueArray.count(); ++i) {
            QJsonValue element = valueArray[i];
            QJsonObject elementObject = element.toObject();
            QJsonValue elementValue = elementObject.value("value");
            QJsonValue elementTypeValue = elementObject.value("type");
            QString elementType = elementTypeValue.toString();
            QString childId;
            if (type == TYPE_ARRAY_STATIC) {
                childId = "index_" + QString::number(i);
            } else {
                QJsonValue elementNameValue = elementObject.value("name");
                QString elementName = elementNameValue.toString();
                childId = elementName;
            }

            generateNotificationProperty(indentLevel + 1, parentId + "_" + id, childId, elementType, elementValue, childNotificationBody, childDocumentationBody);

            if (i == 0) {
                childDocumentationBody = "\n" + childDocumentationBody;
            }

            if (elementType == TYPE_ARRAY_STATIC || elementType == TYPE_OBJECT_STATIC) {
                continue;
            } else if (elementType == TYPE_ARRAY_DYNAMIC || elementType == TYPE_OBJECT_DYNAMIC) {
                properties += insertTabs(indentLevel + 1) + "property var " + childId + ": " + getPropertyValue(elementObject, elementType, indentLevel) + "\n";
            } else {
                properties += insertTabs(indentLevel + 1) + "property " + elementType + " " + childId + ": " + getPropertyValue(elementObject, elementType, indentLevel) + "\n";
            }

            if (lastError_.length() > 0) {
                qCCritical(lcControlViewCreator) << lastError_;
                return;
            }
        }

        notificationBody = childDocumentationBody + notificationBody + properties + childNotificationBody;
        notificationBody += insertTabs(indentLevel) + "}\n";
    } else {
        documentation += generateComment("@property " + id + ": " + type, indentLevel - 1);
    }

    childrenNotificationBody += notificationBody;
    childrenDocumentationBody += documentation;
}

QString PlatformInterfaceGenerator::generateComment(const QString &commentText, int indentLevel) const
{
    return insertTabs(indentLevel) + "// " + commentText + "\n";
}

QString PlatformInterfaceGenerator::generateCommentHeader(const QString &commentText, int indentLevel) const
{
    QString comment = insertTabs(indentLevel) + "/******************************************************************\n";
    comment += insertTabs(indentLevel) + "  * " + commentText + "\n";
    comment += insertTabs(indentLevel) + "******************************************************************/\n\n";
    return comment;
}

QString PlatformInterfaceGenerator::insertTabs(const int num, const int spaces) const
{
    QString text = "";
    for (int tabs = 0; tabs < num; ++tabs) {
        for (int space = 0; space < spaces; ++space) {
            text += " ";
        }
    }
    return text;
}

QString PlatformInterfaceGenerator::getPropertyValue(const QJsonObject &object, const QString &propertyType, const int indentLevel)
{
    if (propertyType == TYPE_BOOL) {
        if (object.value("value").toBool() == 1) {
            return "true";
        } else {
            return "false";
        }
    } else if (propertyType == TYPE_STRING) {
        return "\"" + object.value("value").toString() + "\"";
    } else if (propertyType == TYPE_INT) {
        return QString::number(object.value("value").toInt());
    } else if (propertyType == TYPE_DOUBLE) {
        return QString::number(object.value("value").toDouble());
    } else if (propertyType == TYPE_ARRAY_STATIC) {
        QString returnText = "[";
        QJsonValue arrayValue = object.value("value");
        QJsonArray arr = arrayValue.toArray();

        for (int i = 0; i < arr.count(); ++i) {
            QJsonObject child = arr[i].toObject();
            QString type = child.value("type").toString();
            returnText += getPropertyValue(child, type, indentLevel);
            if (i != arr.count() - 1) {
                returnText += ", ";
            }
        }
        returnText += "]";
        return returnText;
    } else if (propertyType == TYPE_OBJECT_STATIC) {
        QString returnText = "{\n";
        QJsonValue objectValue = object.value("value");
        QJsonArray obj = objectValue.toArray();

        for (int i = 0; i < obj.count(); ++i) {
            QJsonObject child = obj[i].toObject();
            QString type = child.value("type").toString();
            QString name = child.value("name").toString();
            returnText += insertTabs(indentLevel + 1) + "\"" + name + "\": " + getPropertyValue(child, type, indentLevel + 1);
            if (i != obj.count() - 1) {
                returnText += ",";
            }
            returnText += "\n";
        }
        returnText += insertTabs(indentLevel) + "}";
        return returnText;
    } else if (propertyType == TYPE_ARRAY_DYNAMIC) {
        return "[]";
    } else if (propertyType == TYPE_OBJECT_DYNAMIC) {
        return "({})";
    } else {
        lastError_ = "Unable to get value for unknown type " + propertyType;
        qCCritical(lcControlViewCreator) << lastError_;
        return "";
    }
}

void PlatformInterfaceGenerator::removeReservedKeywords(QStringList &paramsList) const
{
    for (QString param : paramsList) {
        if (param == "function") {
            param = "func";
        }
    }
}
