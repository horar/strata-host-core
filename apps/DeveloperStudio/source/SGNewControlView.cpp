/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGNewControlView.h"
#include "SGUtilsCpp.h"
#include "logging/LoggingQtCategories.h"

#include <QRegularExpression>

SGNewControlView::SGNewControlView(QObject *parent) : QObject(parent)
{
}

/***
 * This creates a new project in a folder of your choosing
 * @param projectName @param newProjectPath @param templatePath
 ***/
QUrl SGNewControlView::createNewProject(const QString &projectName, const QUrl &newProjectPath, const QString &templatePath) {
    QString newProjectPathStr = SGUtilsCpp::urlToLocalFile(newProjectPath);
    // Updating the new path to ensure that this file path always has a separator at the end
    if (!newProjectPathStr.endsWith(QDir::separator())) {
        newProjectPathStr += QDir::separator();
    }

    // Project name is added to end of new project path
    newProjectPathStr += projectName + QDir::separator();

    // Creates the new dir that will be the the new location path
    QDir newProjectDir(newProjectPathStr);
    if (!newProjectDir.isRoot()) {
        newProjectDir = QDir::root();
    }

    if (!newProjectDir.cd(newProjectPathStr)) {
        newProjectDir.mkpath(newProjectPathStr);
        newProjectDir.cd(newProjectPathStr);
    }

    rootPath_ = newProjectPathStr;
    projectName_ = projectName;

    // Copy files from templates selection
    QFileInfo templateSource(templatePath);
    QDir templateDir(templateSource.absoluteFilePath());
    copyFiles(templateDir, newProjectDir, false);
    return QUrl::fromLocalFile(qrcPath_);
}

/***
 * Recursively copies the file from the old Directory to the new Directory
 * @param oldDir @param newDir @param resolveConflict
 ***/
bool SGNewControlView::copyFiles(QDir &oldDir, QDir &newDir, bool resolveConflict) {
    foreach (QString oldFile, oldDir.entryList(QDir::Files)) {
        QFileInfo from(oldDir, oldFile);
        QFileInfo to(newDir, oldFile);

        // Attempt to remove file with the same name in destination directory (if exists)
        if (QFile::exists(to.absoluteFilePath()) && resolveConflict && !QFile::remove(to.absoluteFilePath())) {
            qCCritical(logCategoryControlViewCreator) << "The file" << to.absoluteFilePath() << "could not be removed";
            return false;
        }

        // Attempt to copy file from old directory to destination directory
        if (!QFile::copy(from.absoluteFilePath(), to.absoluteFilePath())) {
            qCCritical(logCategoryControlViewCreator) << "The files could not be copied from:" << from.absoluteFilePath() << "to:" << to.absoluteFilePath();
            return false;
        }

        // We need this because copying files from a qresource path yields a readonly file by default
        QFile::setPermissions(to.absoluteFilePath(), QFileDevice::WriteUser | QFileDevice::ReadUser);

        if (to.fileName() == "qml.qrc") {
            // Checks if is qml.qrc file, set qrcPath_
            qrcPath_ = rootPath_ + oldFile;
            qCDebug(logCategoryControlViewCreator) << "QRC path:" << qrcPath_;
        } else if (to.fileName() == "CMakeLists.txt") {
            // Checks if is CMakeLists.txt file, replace project name
            replaceProjectNameInCMakeListsFile(to.absoluteFilePath());
        }
    }

    // Loops through the next child directory
    foreach (QString copyDir, oldDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QFileInfo from(oldDir, copyDir);
        QFileInfo to(newDir, copyDir);

        // Make path to the new directory
        QDir root = QDir::root();
        if (!root.mkpath(to.absoluteFilePath())) {
            qCCritical(logCategoryControlViewCreator) << "Unable to add new directory";
            return false;
        }

        QFileInfo fromRes(from.absoluteFilePath());
        QDir fromDir(fromRes.absoluteFilePath());
        QDir toDir(to.absoluteFilePath());
        // Recursive call to traverse the whole directory
        if (!copyFiles(fromDir, toDir, resolveConflict)) {
            qCCritical(logCategoryControlViewCreator) << "The directory is unable to recursively add files and dirs to new directory" << oldDir.path();
            return false;
        }
    }

    return true;
}

/***
 * Edit template CMakeLists.txt file by replacing 'template' with project name
 * @param cmakeListsFilePath
 ***/
void SGNewControlView::replaceProjectNameInCMakeListsFile(const QString &cmakeListsFilePath) {
    QFile cmakeInFile(cmakeListsFilePath);
    if (!cmakeInFile.open(QIODevice::Text | QIODevice::ReadOnly)) {
        qCCritical(logCategoryControlViewCreator) << "Failed to edit CMakeLists template file with project name";
        return;
    }

    // This regular expression will be found in the input file (CMakeLists.txt file)
    QRegularExpression re("template");

    // Replace regular expressions with projectName_
    QString replacementText(projectName_);
    QString cmakeText = cmakeInFile.readAll();
    cmakeText.replace(re, replacementText);

    // Save new CMakeLists.txt file in same path
    QFile cmakeOutFile(cmakeListsFilePath);
    if (cmakeOutFile.open(QFile::WriteOnly | QFile::Truncate)) {
        QTextStream out(&cmakeOutFile);
        out << cmakeText;
    } else {
        qCCritical(logCategoryControlViewCreator) << "Failed to edit CMakeLists template file with project name";
    }

    cmakeInFile.close();
    cmakeOutFile.close();
}

/***
 * Check if projectPath + / + projectName exists and is not empty
 * @param projectName @param projectPath
 ***/
bool SGNewControlView::projectExists(const QString &projectName, const QUrl &projectPath) {
    QString projectPathStr = SGUtilsCpp::urlToLocalFile(projectPath);
    QString fullPath = projectPathStr + QDir::separator() + projectName;
    QDir projectDir(fullPath);
    return projectDir.exists() && !projectDir.isEmpty();
}
