#include "SGNewControlView.h"

#include "SGUtilsCpp.h"

#include <QDebug>
#include <QString>
#include <QFileInfo>
#include <QUrl>

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
        if (QFile::exists(to.absoluteFilePath())) {
            // Overwrites the files while true
            if (resolveConflict) {
                if (!QFile::remove(to.absoluteFilePath())) {
                    qCritical() << "The file" << to.absoluteFilePath() << "could not be removed";
                    return false;
                }
            }
        }

        // Ensures we copy every file
        if (!QFile::copy(from.absoluteFilePath(), to.absoluteFilePath())) {
            qCritical() << "The files could not be copied from:" << from.absoluteFilePath() << "to:" << to.absoluteFilePath();
            return false;
        }

        // We need this because copying files from a qresource path yields a readonly file by default
        QFile::setPermissions(to.absoluteFilePath(), QFileDevice::WriteUser | QFileDevice::ReadUser);

        // Checks if is qrc file, rename qrc file
        if (to.fileName() == "qml.qrc") {
            const QString oldQrcPath = rootPath_ + oldFile;
            const QString newQrcPath = rootPath_ + "qml-views-" + projectName_ + ".qrc";

            // Rename qrc file to 'qml-views-<projectName>.qrc'
            QFile::rename(oldQrcPath, newQrcPath);

            qrcPath_ = newQrcPath;
            qDebug() << "qrc path" << qrcPath_;
        }

        // Checks if is CMakeLists.txt file, replace project name
        if (to.fileName() == "CMakeLists.txt") {
            replaceProjectNameInCMakeListsFile(to.absoluteFilePath());
        }
    }

    // Loops through the next child directory
    foreach (QString copyDir, oldDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QFileInfo from(oldDir, copyDir);
        QFileInfo to(newDir, copyDir);

        QFileInfo fromRes(from.absoluteFilePath());
        QDir fromDir(fromRes.absoluteFilePath());
        QDir toDir(to.absoluteFilePath());
        // Had to add this in so that we could make a path to the new directory
        QDir root = QDir::root();
        if (!root.mkpath(to.absoluteFilePath())) {
            qCritical() << "Unable to add new directory";
            return false;
        }
        // Recursive call to traverse the whole directory
        if (copyFiles(fromDir, toDir, resolveConflict) == false) {
            qCritical() << "The directory is unable to recursively add files and dirs to new directory" << oldDir.path();
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
        qCritical() << "Failed to edit CMakeLists template file with project name";
        return;
    }
    QString cmakeText = cmakeInFile.readAll();

    // These regular expressions will be found in the input file (CMakeLists.txt file)
    QRegularExpression re("template");

    // Replace regular expressions with projectName_
    QString replacementText(projectName_);
    cmakeText.replace(re, replacementText);

    // Save new CMakeLists.txt file in same path
    QFile cmakeOutFile(cmakeListsFilePath);
    if (cmakeOutFile.open(QFile::WriteOnly | QFile::Truncate)) {
        QTextStream out(&cmakeOutFile);
        out << cmakeText;
    } else {
        qCritical() << "Failed to edit CMakeLists template file with project name";
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
