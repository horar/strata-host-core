#ifndef SGNEWCONTROLVIEW_H

#include <QDir>

class SGNewControlView: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGNewControlView)

public:
    SGNewControlView(QObject *parent=nullptr);
    Q_INVOKABLE QUrl createNewProject(const QUrl &filepath, const QString &originPath);
    Q_INVOKABLE bool projectExists(QString projectPath);
    Q_INVOKABLE bool deleteProject(QString projectPath);

private:
    bool copyFiles(QDir &oldDir, QDir &newDir, bool resolve_conflict);

    QString qrcpath_ = "";
    QString rootpath_ = "";
};

#endif // SGNEWCONTROLVIEW_H
