#include "DebugMenuGenerator.h"

#include <QFile>
#include <QDir>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QDebug>

DebugMenuGenerator::DebugMenuGenerator(QObject *parent) : QObject(parent)
{
    indentLevel = 0;
}

bool DebugMenuGenerator::generate(const QString &outputDirPath, QList<QVariantMap> &notifications, QList<QVariantMap> &commands)
{
    QDir outputDir(outputDirPath);
    QFile outputFile(outputDir.filePath("DebugMenu.qml"));
    outputFile.open(QFile::WriteOnly | QFile::Truncate);
    QTextStream outputStream(&outputFile);

    outputStream << generateImports();

    // Generate the base object and its main properties
    outputStream << writeLine("Rectangle {");

    indentLevel++;

    outputStream << writeLine("id: root");

    // Generate header
    outputStream << writeLine("Text {");
    indentLevel++;
    outputStream << writeLine("id: header");
    outputStream << writeLine("text: \"Debug Commands and Notifications\"");
    outputStream << writeLine("font.bold: true");
    outputStream << writeLine("font.pointSize: 18");
    outputStream << writeLine("anchors {");
    indentLevel++;
    outputStream << writeLine("top: parent.top");
    outputStream << writeLine("bottomMargin: 20");
    indentLevel--;
    outputStream << writeLine("}");
    outputStream << writeLine("width: parent.width");
    outputStream << writeLine("horizontalAlignment: Text.AlignHCenter");
    indentLevel--;
    outputStream << writeLine("}\n");

    // Generate the list model
    outputStream << generateListModel(notifications, commands);

    // Generate the two rows
    outputStream << writeLine("ColumnLayout {");
    indentLevel++;
    outputStream << writeLine("id: columnContainer");
    outputStream << writeLine("anchors {");
    indentLevel++;
    outputStream << writeLine("left: parent.left");
    outputStream << writeLine("right: parent.right");
    outputStream << writeLine("bottom: parent.bottom");
    outputStream << writeLine("top: header.bottom");
    outputStream << writeLine("margins: 5");
    indentLevel--;
    outputStream << writeLine("}\n");
    outputStream << writeLine("spacing: 10");
    outputStream << writeLine();

    // Generate column repeater
    outputStream << writeLine("Repeater {");
    indentLevel++;
    outputStream << writeLine("model: mainModel");

    // Repeater delegate for the commands / notifications list view
    outputStream << writeLine("delegate: ColumnLayout {");
    indentLevel++;
    outputStream << writeLine("id: notificationCommandColumn");
    outputStream << writeLine("Layout.fillHeight: true");
    outputStream << writeLine("Layout.fillWidth: true");
    outputStream << writeLine("property ListModel commandsModel: model.data");

    // Generate either "Notifications" or "Commands"
    outputStream << writeLine();
    outputStream << writeLine("Text {");
    indentLevel++;
    outputStream << writeLine("font.pointSize: 16");
    outputStream << writeLine("font.bold: true");
    outputStream << writeLine("text: (model.name === \"commands\" ? \"Commands\" : \"Notifications\")");
    indentLevel--;
    outputStream << writeLine("}");

    outputStream << generateMainListView();

    indentLevel--;
    outputStream << writeLine("}");
    indentLevel--;
    outputStream << writeLine("}");
    indentLevel--;
    outputStream << writeLine("}");

    outputStream << writeLine();

    outputStream << generateHelperFunctions();

    indentLevel--;
    outputStream << writeLine("}");

    outputFile.close();

    indentLevel = 0;
    return true;
}

bool DebugMenuGenerator::generate(const QString &inputJSONFile, const QString &outputDirPath)
{
    QFile file(inputJSONFile);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QByteArray jsonString = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(jsonString);

    QList<QVariantMap> notifications, commands;
    QJsonArray notificationJsonArray = doc["notifications"].toArray();
    QJsonArray commandJsonArray = doc["commands"].toArray();

    for (QJsonValue val : notificationJsonArray) {
        QVariantMap notif = QVariant::fromValue(val).toMap();
        notifications.append(notif);
    }

    for (QJsonValue val : commandJsonArray) {
        QVariantMap cmd = QVariant::fromValue(val).toMap();
        commands.append(cmd);
    }
    file.close();

    return generate(outputDirPath, notifications, commands);
}

QString DebugMenuGenerator::generateImports()
{
    QString imports = "import QtQuick 2.12\n";
    imports += "import QtQuick.Controls 2.12\n";
    imports += "import QtQuick.Layouts 1.12\n";
    imports += "import QtQuick.Window 2.12\n";
    imports += "import \"qrc:/js/constants.js\" as Constants\n\n";
    return imports;
}

QString DebugMenuGenerator::insertTabs(const int num, const int spaces)
{
    QString text = "";
    for (int tabs = 0; tabs < num; ++tabs) {
        for (int space = 0; space < spaces; ++space) {
            text += " ";
        }
    }
    return text;
}

QString DebugMenuGenerator::generateListModel(QList<QVariantMap> &notifications, QList<QVariantMap> &commands)
{
    QString text = "";
    text += writeLine("ListModel {");
    indentLevel++;
    text += writeLine("id: mainModel");
    text += writeLine();

    // Generate the baseModel object
    text += writeLine("property var baseModel: ({");
    indentLevel++;
    text += writeLine("\"commands\": [");
    indentLevel++;
    text += generateCommands(commands);
    indentLevel--;
    text += writeLine("],");

    text += writeLine("\"notifications\": [");
    indentLevel++;
    text += generateNotifications(notifications);
    indentLevel--;
    text += writeLine("]");

    indentLevel--;
    text += writeLine("})\n");

    // Populate the ListModel on Component.onCompleted
    text += writeLine("Component.onCompleted: {");
    indentLevel++;
    text += writeLine("let keys = Object.keys(baseModel);");
    text += writeLine("for (let j = 0; j < keys.length; j++) {");
    indentLevel++;
    text += writeLine("let name = keys[j];");
    text += writeLine("let data = [];");
    text += writeLine("let commands = baseModel[name];");

    text += writeLine("for (let i = 0; i < commands.length; i++) {");
    indentLevel++;
    text += writeLine("let commandType = (name === \"commands\" ? \"cmd\" : \"value\");");
    text += writeLine("let commandName = commands[i][commandType];");
    text += writeLine("let payloadPropertyArr = [];");
    text += writeLine();

    text += writeLine("if (commands[i].hasOwnProperty(\"payload\") && commands[i][\"payload\"]) {");
    indentLevel++;
    text += writeLine("let payload = commands[i][\"payload\"];");
    text += writeLine("let payloadKeys = Object.keys(payload);");
    text += writeLine();

    text += writeLine("for (let key of payloadKeys) {");
    indentLevel++;
    text += writeLine("let type = getType(payload[key])");
    text += writeLine("let arr = [];");

    text += writeLine("if (type === \"array\") {");
    indentLevel++;
    text += writeLine("for (let subType of payload[key]) {");
    indentLevel++;
    text += writeLine("arr.push({ \"type\": getType(subType) })");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    text += writeLine("payloadPropertyArr.push({ \"name\": key, \"type\": type, \"array\": arr, \"value\": \"\"})");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    text += writeLine();

    text += writeLine("data.push({ \"name\": commandName, \"type\": commandType, \"payload\": payloadPropertyArr })");
    indentLevel--;
    text += writeLine("}");

    text += writeLine("let type = {");
    indentLevel++;
    text += writeLine("\"name\": name,");
    text += writeLine("\"data\": data");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("append(type)");

    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    return text;
}

QString DebugMenuGenerator::generateNotifications(QList<QVariantMap> &notifications)
{
    QString text = "";
    for (QVariantMap notification : notifications) {
        QJsonDocument doc = QJsonDocument::fromVariant(notification);
        text += writeLine(doc.toJson(QJsonDocument::Compact) + ",");
    }
    return text;
}

QString DebugMenuGenerator::generateCommands(QList<QVariantMap> &commands)
{
    QString text = "";
    for (QVariantMap command : commands) {
        QJsonDocument doc = QJsonDocument::fromVariant(command);
        text += writeLine(doc.toJson(QJsonDocument::Compact) + ",");
    }
    return text;
}

QString DebugMenuGenerator::generateMainListView()
{
    QString text = "";
    text += writeLine("ListView {");
    indentLevel++;
    text += writeLine("id: mainListView");
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.leftMargin: 5");
    text += writeLine("Layout.bottomMargin: 10");
    text += writeLine("clip: true");
    text += writeLine("spacing: 10");
    text += writeLine("model: commandsModel");

    // Delegate
    text += writeLine("delegate: ColumnLayout {");
    indentLevel++;
    text += writeLine("width: parent.width\n");
    text += writeLine("property ListModel payloadListModel: model.payload");
    text += writeLine("spacing: 5");

    text += writeLine();

    // Generate horizontal line
    text += writeLine("Rectangle {");
    indentLevel++;
    text += writeLine("Layout.preferredHeight: 1");
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.rightMargin: 2");
    text += writeLine("Layout.leftMargin: 2");
    text += writeLine("Layout.alignment: Qt.AlignHCenter");
    text += writeLine("color: \"black\"");
    indentLevel--;
    text += writeLine("}\n");

    // Generate the command / notification name Text element
    text += writeLine("Text {");
    indentLevel++;
    text += writeLine("font.pointSize: 14");
    text += writeLine("font.bold: true");
    text += writeLine("text: model.name");
    indentLevel--;
    text += writeLine("}\n");

    // Repeater for command / notification properties
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: payloadListModel");
    text += writeLine("delegate: RowLayout {");
    indentLevel++;
    text += writeLine("Layout.preferredHeight: 35\n");
    text += writeLine("Text {");
    indentLevel++;
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("text: model.name");
    text += writeLine("font.bold: true");
    text += writeLine("verticalAlignment: Text.AlignVCenter");
    indentLevel--;
    text += writeLine("}\n");

    text += writeLine("TextField {");
    indentLevel++;
    text += writeLine("id: payloadValueTextField");
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.preferredWidth: 200");
    text += writeLine("text: placeholderText");
    text += writeLine("placeholderText: generatePlaceholder(model.type, model.array)\n");
    text += writeLine("selectByMouse: true");
    text += writeLine("Component.onCompleted: {");
    indentLevel++;
    text += writeLine("model.value = text");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("onTextEdited: {");
    indentLevel++;
    text += writeLine("model.value = text");
    indentLevel--;
    text += writeLine("}");

    indentLevel--;
    text += writeLine("}");

    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    // Generate the send command / notification button
    text += writeLine("Button {");
    indentLevel++;
    text += writeLine("text: \"Send \" + (model.type === \"cmd\" ? \"Command\" : \"Notification\")");

    // Generate the onClicked functionality for sending the command / notification
    text += writeLine("onClicked: {");
    indentLevel++;
    text += writeLine("let payloadArr = model.payload;");
    text += writeLine("let payload = null;");
    text += writeLine("if (payloadArr.count > 0) {");
    indentLevel++;
    text += writeLine("payload = {}");
    text += writeLine("for (let i = 0; i < payloadArr.count; i++) {");
    indentLevel++;
    text += writeLine("let payloadProp = payloadArr.get(i);");
    text += writeLine("if (payloadProp.type === \"array\") {");
    indentLevel++;
    text += writeLine("if (payloadProp.value === \"\") {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = [];");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = JSON.parse(payloadProp.value)");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("} else if (payloadProp.type === \"bool\") {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = (payloadProp.value === \"true\");");
    indentLevel--;
    text += writeLine("} else if (payloadProp.type === \"int\") {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = parseInt(payloadProp.value);");
    indentLevel--;
    text += writeLine("} else if (payloadProp.type === \"double\") {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = parseFloat(payloadProp.value);");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = payloadProp.value");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    text += writeLine("if (model.type === \"value\") {");
    indentLevel++;

    text += writeLine("let notification = {");
    indentLevel++;
    text += writeLine("\"notification\": {");
    indentLevel++;
    text += writeLine("\"value\": model.name,");
    text += writeLine("\"payload\": payload");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    text += writeLine("let wrapper = { \"device_id\": Constants.NULL_DEVICE_ID, \"message\": JSON.stringify(notification) }");
    text += writeLine("coreInterface.notification(JSON.stringify(wrapper))");

    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("let command = { \"cmd\": model.name, \"device_id\": Constants.NULL_DEVICE_ID }");
    text += writeLine("if (payload) {");
    indentLevel++;
    text += writeLine("command[\"payload\"] = payload;");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("coreInterface.sendCommand(JSON.stringify(command))");
    indentLevel--;
    text += writeLine("}");

    indentLevel--;
    text += writeLine("}");

    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    return text;
}

QString DebugMenuGenerator::generateHelperFunctions()
{
    QString text = "";

    // Generate the `generatePlaceholder()` function
    text += writeLine("function generatePlaceholder(type, value) {");
    indentLevel++;
    text += writeLine("if (type === \"array\") {");
    indentLevel++;
    text += writeLine("let placeholder = \"[\"");
    text += writeLine("for (let i = 0; i < value.count; i++) {");
    indentLevel++;
    text += writeLine("let subType = getType(value.get(i).type);");
    text += writeLine("let arr = []");
    text += writeLine("if (subType === \"array\") {");
    indentLevel++;
    text += writeLine("arr = value.get(i)");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("placeholder += generatePlaceholder(subType, arr) + (i !== value.count - 1 ? \",\" : \"\")");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("placeholder += \"]\"");
    text += writeLine("return placeholder");
    indentLevel--;
    text += writeLine("}");

    text += writeLine("else if (type === \"int\") { return \"0\"; }");
    text += writeLine("else if (type === \"string\") { return \"\\\"\\\"\"; }");
    text += writeLine("else if (type === \"double\") { return \"0.00\"; }");
    text += writeLine("else if (type === \"bool\") { return \"false\"; }");
    text += writeLine("return \"\"");
    indentLevel--;
    text += writeLine("}\n");

    // Generate the `getType()` function
    text += writeLine("function getType(value) {");
    indentLevel++;
    text += writeLine("if (Array.isArray(value)) {");
    indentLevel++;
    text += writeLine("return \"array\"");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("return value");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    return text;
}

QString DebugMenuGenerator::writeLine(const QString &line)
{
    if (line.isNull()) {
        return "\n";
    } else {
        return insertTabs(indentLevel) + line + "\n";
    }
}

