#include "PlatformInterfaceGenerator.h"
#include "SGUtilsCpp.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QMetaType>
#include <QVariantList>

QString PlatformInterfaceGenerator::lastError_ = QString();

PlatformInterfaceGenerator::PlatformInterfaceGenerator(QObject *parent) : QObject(parent) {}

PlatformInterfaceGenerator::~PlatformInterfaceGenerator() {}

QString PlatformInterfaceGenerator::lastError()
{
    return lastError_;
}

bool PlatformInterfaceGenerator::generate(const QString &pathToJson, const QString &outputPath)
{
    if (!QFile::exists(pathToJson)) {
        lastError_ = "Path to input file (" + pathToJson + ") does not exist.";
        qCritical() << "Input file path does not exist. Tried to read from" << pathToJson;
        return false;
    }

    QFile inputFile(pathToJson);
    inputFile.open(QIODevice::ReadOnly | QIODevice::Text);

    QString fileText = inputFile.readAll();
    inputFile.close();

    rapidjson::Document platInterfaceData;
    rapidjson::ParseResult result = platInterfaceData.Parse(fileText.toUtf8());

    if (!result) {
        lastError_ = "Failed to parse json. Offset : " + QString::number(result.Offset());
        qCritical() << lastError_;
        return false;
    }

    QDir outputDir(outputPath);

    if (!outputDir.exists()) {
        lastError_ = "Path to output folder (" + outputPath + ") does not exist.";
        qCritical() << "Output folder path does not exist.";
        return false;
    }

    QFile outputFile(outputDir.filePath("PlatformInterface.qml"));

    if (!outputFile.open(QFile::WriteOnly | QFile::Truncate)) {
        lastError_ = "Could not open " + outputFile.fileName() + " for writing";
        qCritical() << "Could not open" << outputFile.fileName() + "for writing";
        return false;
    }

    QTextStream outputStream(&outputFile);
    int indentLevel = 0;

    // Generate imports
    outputStream << generateImports();

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
    outputStream << insertTabs(indentLevel) << "id: notifications\n\n";

    // Create QtObjects to handle notifications

    rapidjson::Value& notificationsList = platInterfaceData["notifications"];

    if (!notificationsList.IsArray()) {
        lastError_ = "'notifications' needs to be an array";
        qCritical() << lastError_;
        return false;
    }

    for (rapidjson::Value &vNotification : notificationsList.GetArray()) {
        const rapidjson::Value::Object &notification = vNotification.GetObject();
        if (notification.HasMember("payload") && notification["payload"].IsNull()) {
            continue;
        }
        outputStream << generateNotification(notification, indentLevel);
    }

    indentLevel--;
    outputStream << insertTabs(indentLevel) << "}\n\n";

    // Commands
    outputStream << generateCommentHeader("COMMANDS", indentLevel);
    outputStream << insertTabs(indentLevel) << "QtObject {\n";

    indentLevel++;
    outputStream << insertTabs(indentLevel) << "id: commands\n";

    const rapidjson::GenericArray commandsList = platInterfaceData["commands"].GetArray();

    for (uint i = 0; i < commandsList.Size(); ++i) {
        rapidjson::Value::Object command = commandsList[i].GetObject();
        outputStream << generateCommand(command, indentLevel);
    }

    indentLevel--;
    outputStream << insertTabs(indentLevel) + "}\n";
    indentLevel--;
    outputStream << "}\n";
    outputFile.close();

    if (indentLevel != 0) {
        lastError_ = "Final indent level is not 0. Check file for indentation errors";
        qWarning() << lastError_;
        return true;
    }

    lastError_ = "";
    return true;
}

QString PlatformInterfaceGenerator::generateImports()
{
    QString imports = "import QtQuick 2.12\n";
    imports += "import QtQuick.Controls 2.12\n";
    imports += "import tech.strata.common 1.0\n";
    imports += "\n\n";
    return imports;
}

QString PlatformInterfaceGenerator::generateCommand(const rapidjson::Value::Object &command, int &indentLevel)
{
    const QString cmd = command["cmd"].GetString();
    QString documentationText = generateComment("@command " + cmd, indentLevel);
    QString commandBody = "";

    commandBody += insertTabs(indentLevel) + "property var " + cmd + ": ({\n";
    commandBody += insertTabs(indentLevel + 1) + "\"cmd\": \"" + cmd + "\",\n";

    QStringList updateFunctionParams;
    QStringList updateFunctionKwRemoved;

    if (command.HasMember("payload") && !command["payload"].IsNull()) {
        rapidjson::Value::Object payload = command["payload"].GetObject();
        for (auto &prop : payload) {
            updateFunctionParams.append(QString(prop.name.GetString()));
        }
        updateFunctionKwRemoved = updateFunctionParams;
        removeReservedKeywords(updateFunctionKwRemoved);

        commandBody += insertTabs(indentLevel + 1) + "\"payload\": {\n";
        QStringList payloadProperties;

        for (auto &prop : payload) {
            rapidjson::Value &propValue = prop.value;
            QString propType = getType(propValue);
            QString key = prop.name.GetString();

            payloadProperties.append(insertTabs(indentLevel + 2) + "\"" + key + "\": " + getPropertyValue(propValue, propType));
            if (propType == "var" && propValue.IsArray()) {
                documentationText += generateComment("@property " + key + ": list of size " + QString::number(propValue.GetArray().Size()), indentLevel);
            } else {
                documentationText += generateComment("@property " + key + ": " + propType, indentLevel);
            }
        }

        commandBody += payloadProperties.join(",\n");
        commandBody += "\n";
        commandBody += insertTabs(indentLevel + 1) + "},\n";
        commandBody += insertTabs(indentLevel + 1) + "update: function (";
        commandBody += updateFunctionKwRemoved.join(",");
        commandBody += ") {\n";
    } else {
        commandBody += insertTabs(indentLevel + 1) + "update: function () {\n";
    }

    // Write update function definition
    if (updateFunctionParams.count() > 0) {
        commandBody += insertTabs(indentLevel + 2) + "this.set(" + updateFunctionKwRemoved.join(",") + ")\n";
    }
    commandBody += insertTabs(indentLevel + 2) + "this.send(this)\n";
    commandBody += insertTabs(indentLevel + 1) + "},\n";

    // Create set function if necessary
    if (updateFunctionParams.count() > 0) {
        commandBody += insertTabs(indentLevel + 1) + "set: function (" + updateFunctionKwRemoved.join(",") + ") {\n";
        for (int i = 0; i < updateFunctionParams.count(); ++i) {
            commandBody += insertTabs(indentLevel + 2) + "this.payload." + updateFunctionParams.at(i) + " = " + updateFunctionKwRemoved.at(i) + "\n";
        }
        commandBody += insertTabs(indentLevel + 1) + "},\n";
    }

    // Create send function
    commandBody += insertTabs(indentLevel + 1) + "send: function () { platformInterface.send(this) }\n";
    commandBody += insertTabs(indentLevel) + "})\n\n";

    return documentationText + commandBody;
}

QString PlatformInterfaceGenerator::generateNotification(const rapidjson::Value::Object &notification, int &indentLevel)
{
    if (!notification.HasMember("value")) {
        lastError_ = "Notification did not contain 'value'";
        qCritical() << lastError_;
        return QString();
    }

    QString notificationId = notification["value"].GetString();
    QString notificationBody = "";
    QString documentationBody = "";

    // Create documentation for notification
    documentationBody += generateComment("@notification: " + notificationId, indentLevel);

    // Create the QtObject to handle this notification
    notificationBody += insertTabs(indentLevel) + "property QtObject " + notificationId + ": QtObject {\n";
    indentLevel++;

    QString childrenNotificationBody = "";
    QString childrenDocumentationBody = "";
    QString propertiesBody = "";

    rapidjson::Value::Object payload = notification["payload"].GetObject();

    // Add the properties to the notification
    for (auto &prop : payload) {
        rapidjson::Value &propValue = prop.value;
        QString payloadProperty = prop.name.GetString();

        generateNotificationProperty(indentLevel, notificationId, payloadProperty, propValue, childrenNotificationBody, childrenDocumentationBody);

        QString propType = getType(propValue);

        if (propValue.IsArray() && propValue.GetArray().Size() > 0) {
            continue;
        }

        propertiesBody += insertTabs(indentLevel) + "property " + propType + " " + payloadProperty + ": " + getPropertyValue(propValue, propType) + "\n";
    }

    notificationBody = childrenDocumentationBody + notificationBody + propertiesBody;
    notificationBody += childrenNotificationBody;

    indentLevel--;
    notificationBody += insertTabs(indentLevel) + "}\n\n";
    return documentationBody + notificationBody;
}

void PlatformInterfaceGenerator::generateNotificationProperty(int indentLevel, const QString &parentId, const QString &id, const rapidjson::Value &value, QString &childrenNotificationBody, QString &childrenDocumentationBody)
{
    QString propType = getType(value);
    QString notificationBody = "";
    QString documentation = "";

    if (propType.isNull()) {
        lastError_ = "Property for " + id + " is null";
        qCritical() << lastError_;
        return;
    }

    if (propType == "var" && value.IsArray() && value.GetArray().Size() > 0) {
        QString properties = "";
        QString childNotificationBody = "";
        QString childDocumentationBody = "";
        const rapidjson::GenericArray valueArray = value.GetArray();

        // Generate a property for each element in array
        notificationBody += insertTabs(indentLevel) + "property QtObject " + id + ": QtObject {\n";

        // This documentation text will be passed back to parent
        // This allows us to generate comments above each QtObject for their properties
        documentation += generateComment("@property " + id + ": " + propType, indentLevel - 1);

        // Add the properties to the notification
        for (uint i = 0; i < valueArray.Size(); ++i) {
            const rapidjson::Value &element = valueArray[i];
            QString childId = id + "_" + QString::number(i);

            generateNotificationProperty(indentLevel + 1, parentId + "_" + id, childId, element, childNotificationBody, childDocumentationBody);

            if (i == 0) {
                childDocumentationBody = "\n" + childDocumentationBody;
            }

            QString childType = getType(element);

            if (element.IsArray() && element.GetArray().Size() > 0) {
                continue;
            }

            properties += insertTabs(indentLevel + 1) + "property " + childType + " " + childId + ": " + getPropertyValue(element, childType) + "\n";
        }

        notificationBody = childDocumentationBody + notificationBody + properties + childNotificationBody;
        notificationBody += insertTabs(indentLevel) + "}\n";
    } else {
        documentation += generateComment("@property " + id + ": " + propType, indentLevel - 1);
    }

    childrenNotificationBody += notificationBody;
    childrenDocumentationBody += documentation;
}

QString PlatformInterfaceGenerator::generateComment(const QString &commentText, int indentLevel)
{
    return insertTabs(indentLevel) + "// " + commentText + "\n";
}

QString PlatformInterfaceGenerator::generateCommentHeader(const QString &commentText, int indentLevel)
{
    QString comment = insertTabs(indentLevel) + "/******************************************************************\n";
    comment += insertTabs(indentLevel) + "  * " + commentText + "\n";
    comment += insertTabs(indentLevel) + "******************************************************************/\n\n";
    return comment;
}

QString PlatformInterfaceGenerator::insertTabs(const int num, const int spaces)
{
    QString text = "";
    for (int tabs = 0; tabs < num; ++tabs) {
        for (int space = 0; space < spaces; ++space) {
            text += " ";
        }
    }
    return text;
}

QString PlatformInterfaceGenerator::getType(const rapidjson::Value &value)
{
    if (value.IsArray()) {
        return "var";
    } else if (value.IsObject()) {
        return "var";
    } else if (value.IsString()) {
        return "string";
    } else if (value.IsBool()) {
        return "bool";
    } else if (value.IsDouble()) {
        return "double";
    } else if (value.IsInt()) {
        return "int";
    } else {
        return QString();
    }
}

QString PlatformInterfaceGenerator::getPropertyValue(const rapidjson::Value &value, const QString &propertyType)
{
    if (propertyType == "var" && value.IsArray()) {
        QString returnText = "[";
        const rapidjson::GenericArray arr = value.GetArray();

        for (uint i = 0; i < arr.Size(); ++i) {
            returnText += getPropertyValue(arr[i], getType(arr[i]));
            if (i != arr.Size() - 1)
                returnText += ", ";
        }
        returnText += "]";
        return returnText;
    } else if (propertyType == "bool") {
        return value.GetBool() ? "true" : "false";
    } else if (propertyType == "string") {
        return "\"" + QString(value.GetString()) + "\"";
    } else if (propertyType == "int") {
        return QString::number(value.GetInt());
    } else if (propertyType == "double") {
        QString tmp = QString::number(value.GetDouble());
        if (!tmp.contains('.')) {
            tmp.append(".0");
        }
        return tmp;
    } else {
        return "";
    }
}

void PlatformInterfaceGenerator::removeReservedKeywords(QStringList &paramsList)
{
    for (QString param : paramsList) {
        if (param == "function") {
            param = "func";
        }
    }
}
