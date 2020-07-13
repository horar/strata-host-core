#ifndef SGUSERSETTINGS_H
#define SGUSERSETTINGS_H

#include <QObject>
#include <QVector>
#include <QJsonObject>

class SGUserSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString classId READ classId WRITE setClassId NOTIFY classIdChanged)

private:
    QString classId_;

    /** SGUserSettings setBaseOutputPath
     * @brief SGUserSettings Sets the base output path of files.
     */
    void setBaseOutputPath();

    /** SGUserSettings makePath
     * @brief SGUserSettings Creates all directories included in a path if they do not exist.
     * @param path The path string.
     * @return Returns true if path was created, otherwise the path already exists.
     */
    bool makePath(const QString &path);

public:
    // The base output path for settings files.
    QString base_output_path_;

    // Getter function for retrieving the class id of the current control view
    QString classId();
	
    explicit SGUserSettings(QObject *parent = nullptr, const QString &classId = "");
    virtual ~SGUserSettings();
	
    /** SGUserSettings writeFile
     * @brief Writes a settings file in JSON format to the platform's directory
     * @param fileName The name of the settings file for that platform.
     * @param subdirectory The name of the subdirectory if it exists.
     * @param data The QJsonObject to write to the file.
     * @return Returns true if successful, otherwise returns false.
     */
    Q_INVOKABLE bool writeFile(const QString &fileName, const QJsonObject &data, const QString &subdirectory = "");

    /** SGUserSettings readFile
     * @brief SGUserSettings Reads a settings file.
     * @param fileName The name of the settings file.
     * @param subdirectory The name of the subdirectory if it exists.
     * @return Returns a string representation of the settings file.
     */
    Q_INVOKABLE QJsonObject readFile(const QString &fileName, const QString &subdirectory = "");

    /** SGUserSettings listFilesInDirectory
     * @brief SGUserSettings Lists the files in a given directory. Note** This will not list files in subdirectories of a given directory.
     * @param subdirectory The name of the subdirectory. This is optional if not using subdirectories.
     * @return Returns a QVector of strings containing all filenames in that directory.
     */
    Q_INVOKABLE QStringList listFilesInDirectory(const QString &subdirectory = "");

    /** SGUserSettings deleteFile
     * @brief SGUserSettings Deletes a settings file.
     * @param fileName The name of the file to delete.
     * @return Returns true if successful, otherwise returns false.
     */
    Q_INVOKABLE bool deleteFile(const QString &fileName, const QString &subdirectory = "");

    /** SGUserSettigns renameFile
     * @brief SGUserSettings Renames a settings file.
     * @param origFileName The original file name.
     * @param newFileName The new file name.
     * @param subdirectory The name of the subdirectory if it exists.
     * @return Returns true if successful, otherwise returns false.
     */
    Q_INVOKABLE bool renameFile(const QString &origFileName, const QString &newFileName, const QString &subdirectory = "");

    /** SGUserSettings getBaseOutputPath
     * @brief SGUserSettings Gets the absolute path for a platform's settings directory.
     * @return Returns the absolute path for the platform's settings directory.
     */
    Q_INVOKABLE QString getBaseOutputPath();

    void setClassId(const QString &id);
	
signals: 
    void classIdChanged();
};

#endif // SGUSERSETTINGS_H
