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
     * @brief generate Generate the DebugMenu.qml file
     * @param outputDirPath The directory to output
     * @param notifications The list of notifications
     * @param commands The list of commands
     * @return Return true if successful, false otherwise
     */
    Q_INVOKABLE bool generate(const QString &outputDirPath, QList<QVariantMap> &notifications, QList<QVariantMap> &commands);

    /**
     * @brief generate Generate the DebugMenu.qml from an inputJSON file path
     * @param inputJSONFile The path to the JSON file to read
     * @param outputDirPath The output directory path
     * @return Return true if successful, false otherwise
     */
    Q_INVOKABLE bool generate(const QString &inputJSONFile, const QString &outputDirPath);

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

private:
    int indentLevel = 0;

    QString writeLine(const QString &line = QString());
};

