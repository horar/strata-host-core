#pragma once

#include <QObject>
#include <QList>
#include <QVariantMap>

class DebugMenuGenerator : public QObject
{
    Q_OBJECT
public:
    explicit DebugMenuGenerator(QObject *parent = nullptr);

    /**
     * @brief generateWithData Generate the DebugMenu.qml file when a list of commands and notifications is already supplied
     * @param outputDirPath The directory to output
     * @param notifications The list of notifications
     * @param commands The list of commands
     */
    void generate(const QString &outputDirPath, QList<QVariantMap> &notifications, QList<QVariantMap> &commands);

    /**
     * @brief generate Generate the DebugMenu.qml from an inputJSON file path
     * @param inputJSONFile The path to the JSON file to read
     * @param outputDirPath The output directory path
     */
    Q_INVOKABLE void generate(const QJsonValue &inputJSON, const QString &outputDirPath);

    /**
     * @brief generateImports Generates the imports needed for the debug menu
     * @return Returns the imports string
     */
    QString generateImports();

    /**
     * @brief insertTabs Insert tabs as spaces
     * @param num Number of tabs
     * @param spaces Number of spaces for each tab
     * @return Returns the tab string
     */
    QString insertTabs(const int num, const int spaces = 4);

    /**
     * @brief generateListModel Generates the QML ListModel text
     * @param notifications The list of notifications
     * @param commands The list of commands
     * @return Returns the ListModel text
     */
    QString generateListModel(QList<QVariantMap> &notifications, QList<QVariantMap> &commands);

    /**
     * @brief generateNotifications Generates the list of notifications
     * @param notifications The list of notifications to create
     * @return Returns the notifications text
     */
    QString generateNotifications(QList<QVariantMap> &notifications);

    /**
     * @brief generateCommands Generates the list of commands
     * @param commands The list of commands to create
     * @return Returns the commands text
     */
    QString generateCommands(QList<QVariantMap> &commands);

    /**
     * @brief generateMainListView Generates the main listview used for both commands and notifications
     * @return Returns the ListView string
     */
    QString generateMainListView();

    /**
     * @brief generateHelperFunctions Generates the helper functions such as generatePlaceholder and getType
     * @return Returns the helper functions strings
     */
    QString generateHelperFunctions();

    /**
     * @brief generateArrayComponent Generates the reusable Array component that handles the repeater for sub arrays
     * @return Returns the array component string
     */
    QString generateArrayComponent();

    /**
     * @brief generateObjectComponent Generates the reusable Object component that handles the repeater for sub objects
     * @return Returns the object component string
     */
    QString generateObjectComponent();

    /**
     * @brief generateSGSwitch Generates the SGSwitch
     * @param modelName Either "model" or "modelData"
     * @return Returns the SGSwitch string
     */
    QString generateSGSwitch(const QString &modelName);

private:
    int indentLevel_ = 0;

    QString writeLine(const QString &line = QString());
};

