#include "SGNewControlView.h"

#include "SGUtilsCpp.h"

SGNewControlView::SGNewControlView(QObject *parent) : QObject(parent)
{

}

/***
 * This creates a new project in a folder of your choosing
 * @param filepath @param originPath
 ***/
QUrl SGNewControlView::createNewProject(const QUrl &filepath, const QString &originPath){
    // This is the current path of the origin directory in resources
    QResource orgSrc(originPath);
    qrcpath_ = "";

    QString path = SGUtilsCpp::urlToLocalFile(filepath);
    // Updating the new path to ensure that this file path always has a seperator at the end

    if(!path.endsWith(QDir::separator())){
        path = path + QDir::separator();
    }

    // Creates the new dir that will be the the new location path
    QDir dir(path);
    if(!dir.isRoot()){
        dir = QDir::root();
    }

    if(!dir.cd(path)){
        dir.mkpath(path);
        dir.cd(path);
    }

    rootpath_ = path;
    // Copy files from templates selection
    QDir oldDir(orgSrc.absoluteFilePath());
    copyFiles(oldDir,dir,false);
    return QUrl::fromLocalFile(qrcpath_);
}

/***
 * Recursively copies the file from the old Directory to the new Directory
 * @param oldDir @param newDir @param resolve_conflict
 ***/
bool SGNewControlView::copyFiles(QDir &oldDir, QDir &newDir, bool resolve_conflict){
    foreach (QString oldFile, oldDir.entryList(QDir::Files)){
        QFileInfo from(oldDir,oldFile);
        QFileInfo to(newDir,oldFile);
        if(QFile::exists(to.absoluteFilePath())){
            //Overwrites the files while true
            if(resolve_conflict){
                if(!QFile::remove(to.absoluteFilePath())){
                    qCritical()<<"The file could "+ to.absoluteFilePath() +" not be removed";
                    return false;
                }
            }
        }
        // Ensures we copy every file
        if(!QFile::copy(from.absoluteFilePath(), to.absoluteFilePath())){
            qCritical()<<"The files could not be copied" << "from: " + from.absoluteFilePath() + "to: " + to.absoluteFilePath();
            return false;
        }

        // We need this because copying files from a qresource path yields a readonly file by default
        QFile::setPermissions(to.absoluteFilePath(), QFileDevice::WriteUser | QFileDevice::ReadUser);

        // Checks if is qrc file
        if(to.absoluteFilePath().endsWith(".qrc")){
            qrcpath_ = rootpath_ + oldFile;
            qDebug() << "qrc path" << qrcpath_;
        }
    }

    // Loops through the next child directory
    foreach (QString copyDir, oldDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)){
        QFileInfo from(oldDir,copyDir);
        QFileInfo to(newDir,copyDir);

        QResource fromRes(from.absoluteFilePath());
        QDir fromDir(fromRes.absoluteFilePath());
        QDir toDir(to.absoluteFilePath());
        // Had to add this in so that we could make a path to the new directory
        QDir root = QDir::root();
        if(!root.mkpath(to.absoluteFilePath())){
            qCritical() << "Unable to add new directory";
            return false;
        }
        // Recursive call to traverse the whole directory
        if(copyFiles(fromDir, toDir, resolve_conflict) == false){
            qCritical()<<"The directory is unable to recursively add files and dirs to new directory" << oldDir.path();
            return false;
        }
    }

    return true;
}
