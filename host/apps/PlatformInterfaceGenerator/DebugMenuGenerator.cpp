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
    imports += "import \"qrc:/js/constants.js\" as Constants\n";
    imports += "import tech.strata.sgwidgets 1.0\n\n";
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
    text += writeLine("let topLevelKeys = Object.keys(baseModel); // This contains \"commands\" / \"notifications\" arrays");

    text += writeLine();

    text += writeLine("mainModel.modelAboutToBeReset()");
    text += writeLine("mainModel.clear();");

    text += writeLine();

    text += writeLine("for (let i = 0; i < topLevelKeys.length; i++) {");
    indentLevel++;
    text += writeLine("const topLevelType = topLevelKeys[i];");
    text += writeLine("const arrayOfCommandsOrNotifications = baseModel[topLevelType];");

    text += writeLine("let listOfCommandsOrNotifications = {");
    indentLevel++;
    text += writeLine("\"name\": topLevelType, // \"commands\" / \"notifications\"");
    text += writeLine("\"data\": []");
    indentLevel--;
    text += writeLine("}");

    text += writeLine();

    text += writeLine("mainModel.append(listOfCommandsOrNotifications);");

    text += writeLine();

    text += writeLine("for (let j = 0; j < arrayOfCommandsOrNotifications.length; j++) {");
    indentLevel++;
    text += writeLine("let commandsModel = mainModel.get(i).data;");
    text += writeLine();
    text += writeLine("let cmd = arrayOfCommandsOrNotifications[j];");
    text += writeLine("let commandName;");
    text += writeLine("let commandType;");
    text += writeLine("let commandObject = {};");
    text += writeLine();
    text += writeLine("if (topLevelType === \"commands\") {");
    indentLevel++;
    text += writeLine("// If we are dealing with commands, then look for the \"cmd\" key");
    text += writeLine("commandName = cmd[\"cmd\"];");
    text += writeLine("commandType = \"cmd\";");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("commandName = cmd[\"value\"];");
    text += writeLine("commandType = \"value\";");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("commandObject[\"type\"] = commandType;");
    text += writeLine("commandObject[\"name\"] = commandName;");
    text += writeLine("commandObject[\"payload\"] = [];");
    text += writeLine();
    text += writeLine("commandsModel.append(commandObject);");
    text += writeLine();
    text += writeLine("const payload = cmd.hasOwnProperty(\"payload\") ? cmd[\"payload\"] : null;");
    text += writeLine("let payloadPropertiesArray = [];");
    text += writeLine();

    text += writeLine("if (payload) {");
    indentLevel++;
    text += writeLine("let payloadProperties = Object.keys(payload);");
    text += writeLine("let payloadModel = commandsModel.get(j).payload;");
    text += writeLine("for (let k = 0; k < payloadProperties.length; k++) {");
    indentLevel++;
    text += writeLine("const key = payloadProperties[k];");
    text += writeLine("const type = getType(payload[key]);");
    text += writeLine("let payloadPropObject = {};");
    text += writeLine("payloadPropObject[\"name\"] = key;");
    text += writeLine("payloadPropObject[\"type\"] = type;");
    text += writeLine("payloadPropObject[\"value\"] = \"\";");
    text += writeLine("payloadPropObject[\"array\"] = [];");
    text += writeLine("payloadPropObject[\"object\"] = [];");
    text += writeLine("payloadModel.append(payloadPropObject);");
    text += writeLine();
    text += writeLine("if (type === \"array\") {");
    indentLevel++;
    text += writeLine("generateArrayModel(payload[key], payloadModel.get(k).array);");
    indentLevel--;
    text += writeLine("} else if (type === \"object\") {");
    indentLevel++;
    text += writeLine("generateObjectModel(payload[key], payloadModel.get(k).object);");
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
    text += writeLine();
    text += writeLine("mainModel.modelReset()");
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

    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: payloadListModel");
    text += writeLine("delegate: ColumnLayout {");
    indentLevel++;
    text += writeLine("id: payloadContainer");
    text += writeLine();
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine();
    text += writeLine("property ListModel subArrayListModel: model.array");
    text += writeLine("property ListModel subObjectListModel: model.object");
    text += writeLine();
    text += writeLine("RowLayout {");
    indentLevel++;
    text += writeLine("Layout.preferredHeight: 35");
    text += writeLine();
    text += writeLine("Text {");
    indentLevel++;
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.preferredWidth: 200");
    text += writeLine("text: model.name");
    text += writeLine("font.bold: true");
    text += writeLine("verticalAlignment: Text.AlignVCenter");
    text += writeLine("elide: Text.ElideRight");
    text += writeLine();
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the textfield for the value of the payload property
    text += writeLine("TextField {");
    indentLevel++;
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.maximumWidth: 175");
    text += writeLine("placeholderText: generatePlaceholder(model.type, model.value)");
    text += writeLine("selectByMouse: true");
    text += writeLine("visible: model.type !== \"array\" && model.type !== \"object\" && model.type !== \"bool\"");
    text += writeLine("validator: RegExpValidator {");
    indentLevel++;
    text += writeLine("regExp: {");
    indentLevel++;
    text += writeLine("if (model.type === \"int\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+$/");
    indentLevel--;
    text += writeLine("} else if (model.type === \"double\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+\\.[0-9]+$/");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("return /^.*$/");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("onTextChanged: {");
    indentLevel++;
    text += writeLine("model.value = text");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the switch for boolean values
    text += generateSGSwitch("model");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the array repeater
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: payloadContainer.subArrayListModel");
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("sourceComponent: arrayStaticFieldComponent");
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    text += writeLine();

    // Generate the object repeater
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: payloadContainer.subObjectListModel");
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("sourceComponent: objectStaticFieldComponent");
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

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
    text += writeLine("payload[payloadProp.name] = createJsonObjectFromArrayProperty(payloadProp.array, []);");
    indentLevel--;
    text += writeLine("} else if (payloadProp.type === \"object\") {");
    indentLevel++;
    text += writeLine("payload[payloadProp.name] = createJsonObjectFromObjectProperty(payloadProp.object, {});");
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
    text += writeLine("let command = { \"cmd\": model.name, \"device_id\": controlViewCreatorRoot.debugPlatform.deviceId }");
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

    text += writeLine();
    text += writeLine("/********* COMPONENTS AND FUNCTIONS *********/");
    text += writeLine();

    text += generateArrayComponent();
    text += writeLine();

    text += generateObjectComponent();
    text += writeLine();

    // Generate the `generatePlaceholder` function
    text += writeLine("function generatePlaceholder(type, value) {");
    indentLevel++;
    text += writeLine("if (type === \"int\") { return \"0\"; }");
    text += writeLine("else if (type === \"string\") { return \"\\\"\\\"\"; }");
    text += writeLine("else if (type === \"double\") { return \"0.00\"; }");
    text += writeLine("else if (type === \"bool\") { return \"false\"; }");
    text += writeLine("return \"\"");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the `getType` function
    text += writeLine("function getType(value) {");
    indentLevel++;
    text += writeLine("if (Array.isArray(value)) {");
    indentLevel++;
    text += writeLine("return \"array\";");
    indentLevel--;
    text += writeLine("} else if (typeof value === \"object\") {");
    indentLevel++;
    text += writeLine("return \"object\";");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("return value;");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the `generateArrayModel` function
    text += writeLine("function generateArrayModel(arr, parentListModel) {");
    indentLevel++;
    text += writeLine("for (let i = 0; i < arr.length; i++) {");
    indentLevel++;
    text += writeLine("const type = getType(arr[i]);");
    text += writeLine("let obj = {\"type\": type, \"array\": [], \"object\": [], \"value\": \"\"};");
    text += writeLine();
    text += writeLine("parentListModel.append(obj);");
    text += writeLine();
    text += writeLine("if (type === \"array\") {");
    indentLevel++;
    text += writeLine("generateArrayModel(arr[i], parentListModel.get(i).array)");
    indentLevel--;
    text += writeLine("} else if (type === \"object\") {");
    indentLevel++;
    text += writeLine("generateObjectModel(arr[i], parentListModel.get(i).object)");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the `generateObjectModel` function
    text += writeLine("/**");
    text += writeLine("* This function takes an Object and transforms it into an array readable by our delegates");
    text += writeLine("**/");
    text += writeLine("function generateObjectModel(object, parentListModel) {");
    indentLevel++;
    text += writeLine("let keys = Object.keys(object);");
    text += writeLine("for (let i = 0; i < keys.length; i++) {");
    indentLevel++;
    text += writeLine("const key = keys[i];");
    text += writeLine("const type = getType(object[key]);");
    text += writeLine();
    text += writeLine("let obj = {\"key\": key, \"type\": type, \"array\": [], \"object\": [], \"value\": \"\" };");
    text += writeLine();
    text += writeLine("parentListModel.append(obj);");
    text += writeLine();
    text += writeLine("if (type === \"array\") {");
    indentLevel++;
    text += writeLine("generateArrayModel(object[key], parentListModel.get(i).array)");
    indentLevel--;
    text += writeLine("} else if (type === \"object\") {");
    indentLevel++;
    text += writeLine("generateObjectModel(object[key], parentListModel.get(i).object)");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the `createJsonObjectFromArrayProperty`
    text += writeLine("function createJsonObjectFromArrayProperty(arrayModel, outputArr) {");
    indentLevel++;
    text += writeLine("for (let m = 0; m < arrayModel.count; m++) {");
    indentLevel++;
    text += writeLine("let arrayElement = arrayModel.get(m);");
    text += writeLine();
    text += writeLine("if (arrayElement.type === \"object\") {");
    indentLevel++;
    text += writeLine("outputArr.push(createJsonObjectFromObjectProperty(arrayElement.object, {}))");
    indentLevel--;
    text += writeLine("} else if (arrayElement.type === \"array\") {");
    indentLevel++;
    text += writeLine("outputArr.push(createJsonObjectFromArrayProperty(arrayElement.array, []))");
    indentLevel--;
    text += writeLine("} else if (arrayElement.type === \"bool\") {");
    indentLevel++;
    text += writeLine("outputArr.push((arrayElement.value === \"true\"))");
    indentLevel--;
    text += writeLine("} else if (arrayElement.type === \"int\") {");
    indentLevel++;
    text += writeLine("outputArr.push(parseInt(arrayElement.value))");
    indentLevel--;
    text += writeLine("} else if (arrayElement.type === \"double\") {");
    indentLevel++;
    text += writeLine("outputArr.push(parseFloat(arrayElement.value))");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("outputArr.push(arrayElement.value)");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("return outputArr;");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the `createJsonObjectFromObjectProperty` function
    text += writeLine("function createJsonObjectFromObjectProperty(objectModel, outputObj) {");
    indentLevel++;
    text += writeLine("for (let i = 0; i < objectModel.count; i++) {");
    indentLevel++;
    text += writeLine("let objectProperty = objectModel.get(i);");
    text += writeLine();
    text += writeLine("// Recurse through array");
    text += writeLine("if (objectProperty.type === \"array\") {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = createJsonObjectFromArrayProperty(objectProperty.array, [])");
    indentLevel--;
    text += writeLine("} else if (objectProperty.type === \"object\") {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = createJsonObjectFromObjectProperty(objectProperty.object, {})");
    indentLevel--;
    text += writeLine("} else if (objectProperty.type === \"bool\") {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = (objectProperty.value === \"true\")");
    indentLevel--;
    text += writeLine("} else if (objectProperty.type === \"int\") {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = parseInt(objectProperty.value)");
    indentLevel--;
    text += writeLine("} else if (objectProperty.type === \"double\") {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = parseFloat(objectProperty.value)");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("outputObj[objectProperty.key] = objectProperty.value");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine("return outputObj;");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;

    return text;
}

QString DebugMenuGenerator::generateArrayComponent()
{
    QString text = "";

    text += writeLine("Component {");
    indentLevel++;
    text += writeLine("id: arrayStaticFieldComponent");
    text += writeLine();
    text += writeLine("ColumnLayout {");
    indentLevel++;
    text += writeLine("id: arrayColumnLayout");
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine();
    text += writeLine("property var modelData");
    text += writeLine("property ListModel subArrayListModel: modelData.array");
    text += writeLine("property ListModel subObjectListModel: modelData.object");
    text += writeLine();
    text += writeLine("property int modelIndex: index");
    text += writeLine();
    text += writeLine("RowLayout {");
    indentLevel++;
    text += writeLine("Layout.preferredHeight: 30");
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("spacing: 5");
    text += writeLine();
    text += writeLine("Text {");
    indentLevel++;
    text += writeLine("text: \"[Index \" + modelIndex  + \"] Element type: \" + modelData.type");
    text += writeLine("Layout.alignment: Qt.AlignVCenter");
    text += writeLine("Layout.preferredWidth: 200");
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("verticalAlignment: Text.AlignVCenter");
    text += writeLine("elide: Text.ElideRight");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("TextField {");
    indentLevel++;
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.maximumWidth: 175");
    text += writeLine("placeholderText: generatePlaceholder(modelData.type, modelData.value)");
    text += writeLine("selectByMouse: true");
    text += writeLine("visible: modelData.type !== \"array\" && modelData.type !== \"object\" && modelData.type !== \"bool\"");
    text += writeLine("validator: RegExpValidator {");
    indentLevel++;
    text += writeLine("regExp: {");
    indentLevel++;
    text += writeLine("if (modelData.type === \"int\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+$/");
    indentLevel--;
    text += writeLine("} else if (modelData.type === \"double\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+\\.[0-9]+$/");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("return /^.*$/");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("onTextChanged: {");
    indentLevel++;
    text += writeLine("modelData.value = text");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    text += generateSGSwitch("modelData");

    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: arrayColumnLayout.subArrayListModel");
    text += writeLine();
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("sourceComponent: arrayStaticFieldComponent");
    text += writeLine();
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    text += writeLine();
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: arrayColumnLayout.subObjectListModel");
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("sourceComponent: objectStaticFieldComponent");
    text += writeLine();
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    return text;
}

QString DebugMenuGenerator::generateObjectComponent()
{
    QString text = "";

    text += writeLine("Component {");
    indentLevel++;
    text += writeLine("id: objectStaticFieldComponent");
    text += writeLine();
    text += writeLine("ColumnLayout {");
    indentLevel++;
    text += writeLine("id: objColumnLayout");
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine();
    text += writeLine("property var modelData");
    text += writeLine("property ListModel subArrayListModel: modelData.array");
    text += writeLine("property ListModel subObjectListModel: modelData.object");
    text += writeLine();
    text += writeLine("property int modelIndex");
    text += writeLine();
    text += writeLine("RowLayout {");
    indentLevel++;
    text += writeLine("Layout.preferredHeight: 30");
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("spacing: 5");
    text += writeLine();
    text += writeLine("Text {");
    indentLevel++;
    text += writeLine("text: modelData.key");
    text += writeLine("Layout.alignment: Qt.AlignVCenter");
    text += writeLine("Layout.preferredWidth: 200");
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("verticalAlignment: Text.AlignVCenter");
    text += writeLine("font.bold: true");
    text += writeLine("elide: Text.ElideRight");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the textfield for editing strings, ints, and doubles
    text += writeLine("TextField {");
    indentLevel++;
    text += writeLine("Layout.fillHeight: true");
    text += writeLine("Layout.fillWidth: true");
    text += writeLine("Layout.maximumWidth: 175");
    text += writeLine("placeholderText: generatePlaceholder(modelData.type, modelData.value)");
    text += writeLine("selectByMouse: true");
    text += writeLine("visible: modelData.type !== \"array\" && modelData.type !== \"object\" && modelData.type !== \"bool\"");
    text += writeLine("validator: RegExpValidator {");
    indentLevel++;
    text += writeLine("regExp: {");
    indentLevel++;
    text += writeLine("if (modelData.type === \"int\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+$/");
    indentLevel--;
    text += writeLine("} else if (modelData.type === \"double\") {");
    indentLevel++;
    text += writeLine("return /^[0-9]+\\.[0-9]+$/");
    indentLevel--;
    text += writeLine("} else {");
    indentLevel++;
    text += writeLine("return /^.*$/");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();
    text += writeLine("onTextChanged: {");
    indentLevel++;
    text += writeLine("modelData.value = text");
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the switch for booleans
    text += generateSGSwitch("modelData");

    indentLevel--;
    text += writeLine("}");
    text += writeLine();

    // Generate the repeater for nested array
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: objColumnLayout.subArrayListModel");
    text += writeLine();
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("sourceComponent: arrayStaticFieldComponent");
    text += writeLine();
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    text += writeLine();

    // Generate the repeater for nested objects
    text += writeLine("Repeater {");
    indentLevel++;
    text += writeLine("model: objColumnLayout.subObjectListModel");
    text += writeLine("delegate: Component {");
    indentLevel++;
    text += writeLine("Loader {");
    indentLevel++;
    text += writeLine("Layout.leftMargin: 10");
    text += writeLine("sourceComponent: objectStaticFieldComponent");
    text += writeLine();
    text += writeLine("onStatusChanged: {");
    indentLevel++;
    text += writeLine("if (status === Loader.Ready) {");
    indentLevel++;
    text += writeLine("item.modelData = Qt.binding(() => model)");
    text += writeLine("item.modelIndex = index");
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
    indentLevel--;
    text += writeLine("}");
    indentLevel--;
    text += writeLine("}");

    return text;
}

QString DebugMenuGenerator::generateSGSwitch(const QString &modelName)
{
    QString text = "";
    text += writeLine("SGSwitch {");
    indentLevel++;
    text += writeLine("Layout.preferredWidth: 70");
    text += writeLine("checkedLabel: \"True\"");
    text += writeLine("uncheckedLabel: \"False\"");
    text += writeLine("visible: " + modelName + ".type === \"bool\"");
    text += writeLine();
    text += writeLine("onToggled: {");
    indentLevel++;
    text += writeLine(modelName + ".value = (checked ? \"true\" : \"false\")");
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

