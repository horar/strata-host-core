#pragma once

#include <QDir>

class SGNewControlView: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGNewControlView)

public:
    SGNewControlView(QObject *parent=nullptr);

    Q_INVOKABLE QUrl createNewProject(const QString &projectName, const QUrl &newProjectPath, const QString &templatePath, const QString &debugPath);

    Q_INVOKABLE bool projectExists(const QString &projectName, const QUrl &projectPath);

private:
    QString qrcPath_ = "";

    QString rootPath_ = "";

    QString projectName_ = "";

    bool copyFiles(QDir &oldDir, QDir &newDir, bool resolveConflict);

    void replaceProjectNameInCMakeListsFile(const QString &cmakeListsFilePath);
};
