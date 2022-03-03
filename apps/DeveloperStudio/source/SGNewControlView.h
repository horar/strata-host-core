/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QDir>

class SGNewControlView: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGNewControlView)

public:
    SGNewControlView(QObject *parent=nullptr);

    Q_INVOKABLE QUrl createNewProject(const QString &projectName, const QUrl &newProjectPath, const QString &templatePath);

    Q_INVOKABLE bool projectExists(const QString &projectName, const QUrl &projectPath);

private:
    QString qrcPath_ = "";

    QString rootPath_ = "";

    QString projectName_ = "";

    bool copyFiles(QDir &oldDir, QDir &newDir, bool resolveConflict);

    void replaceProjectNameInCMakeListsFile(const QString &cmakeListsFilePath);
};
