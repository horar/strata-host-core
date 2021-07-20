#pragma once

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QJsonValue>

class PlatformInterfaceGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError)
    Q_PROPERTY(QString TYPE_INT MEMBER TYPE_INT CONSTANT)
    Q_PROPERTY(QString TYPE_DOUBLE MEMBER TYPE_DOUBLE CONSTANT)
    Q_PROPERTY(QString TYPE_STRING MEMBER TYPE_STRING CONSTANT)
    Q_PROPERTY(QString TYPE_BOOL MEMBER TYPE_BOOL CONSTANT)
    Q_PROPERTY(QString TYPE_ARRAY_STATIC MEMBER TYPE_ARRAY_STATIC CONSTANT)
    Q_PROPERTY(QString TYPE_ARRAY_DYNAMIC MEMBER TYPE_ARRAY_DYNAMIC CONSTANT)
    Q_PROPERTY(QString TYPE_OBJECT_STATIC MEMBER TYPE_OBJECT_STATIC CONSTANT)
    Q_PROPERTY(QString TYPE_OBJECT_DYNAMIC MEMBER TYPE_OBJECT_DYNAMIC CONSTANT)

public:
    PlatformInterfaceGenerator(QObject *parent = nullptr);
    virtual ~PlatformInterfaceGenerator();

    static const int API_VERSION = 2;
    static QString lastError_;

    inline static const QString TYPE_INT = "int";
    inline static const QString TYPE_DOUBLE = "double";
    inline static const QString TYPE_STRING = "string";
    inline static const QString TYPE_BOOL = "bool";
    inline static const QString TYPE_ARRAY_STATIC = "array-static-sized";
    inline static const QString TYPE_ARRAY_DYNAMIC = "array-dynamic-sized";
    inline static const QString TYPE_OBJECT_STATIC = "object-known-properties";
    inline static const QString TYPE_OBJECT_DYNAMIC = "object-unknown-properties";

    static QString lastError();

    /**
     * @brief generate The main function that starts the generation of a PlatformInterface.qml file
     * @param pathToJson Path to the input JSON file
     * @param outputPath Path to the output directory
     * @return Returns True if successfully created the file, else False
     */
    Q_INVOKABLE static bool generate(const QJsonValue &jsonObject, const QString &outputPath);

    /**
     * @brief generateImports Generates the import section of the QML file
     * @return Returns the imports text
     */
    static QString generateImports();

    /**
     * @brief generateCommand Generates a command
     * @param command The Object for this command
     * @param indentLevel The level of indentation
     * @return Returns the command text
     */
    static QString generateCommand(const QJsonObject &command, int &indentLevel);

    /**
     * @brief generateNotification
     * @param notification The notification object
     * @param indentLevel The current indentation level
     * @return Returns the notification text
     */
    static QString generateNotification(const QJsonObject &notification, int &indentLevel);

    /**
     * @brief generateNotificationProperty
     * @param indentLevel The amount to indent
     * @param parentId The id of the parent
     * @param id The id of this object
     * @param type The type of this object
     * @param value The QJsonValue for this property
     * @param childrenNotificationBody The notification body for the children of this parent
     * @param childrenDocumentationBody The documentation body for the children of this parent
     * @return
     */
    static void generateNotificationProperty(int indentLevel, const QString &parentId, const QString &id, const QString &type, const QJsonValue &value, QString &childrenNotificationBody, QString &childrenDocumentationBody);

    /**
     * @brief generateComment Generates a single line comment
     * @param commentText The text inside the comment
     * @param indentLevel The amount of tabs to indent
     * @return Returns the comment text
     */
    static QString generateComment(const QString &commentText, int indentLevel = 0);

    /**
     * @brief generateCommentHeader Generates a header comment for a section
     * @param commentText The text inside the header comment
     * @param indentLevel The amount of tabs to indent
     * @return Returns the comment text
     */
    static QString generateCommentHeader(const QString &commentText, int indentLevel = 0);

private:

    /**
     * @brief insertTabs Helper function to insert tabs (as spaces)
     * @param num Number of tabs. Default is 1.
     * @param spaces Number of spaces per tab. Default is 4.
     * @return Returns the tabs as a string
     */
    static QString insertTabs(const int num = 1, const int spaces = 4);

    /**
     * @brief getPropertyValue Gets the string representation of the value passed in
     * @param object The QJsonObject to get the value from
     * @param propertyType The type of `value`
     * @param indentLevel The currentIndentLevel
     * @return Returns the string representation of the `value`
     */
    static QString getPropertyValue(const QJsonObject &object, const QString &propertyType, const int indentLevel);

    /**
     * @brief removeReservedKeywords Removes reserved keywords from a list of parameters
     * @param paramsList The list of parameters
     */
    static void removeReservedKeywords(QStringList &paramsList);

};
