#pragma once

#include <couchbaselitecpp/SGCouchBaseLite.h>
#include <QObject>
#include <QSharedPointer>

#include <string>

class SciDatabaseConnector: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciDatabaseConnector)

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit SciDatabaseConnector(QObject *parent=nullptr);
    ~SciDatabaseConnector();

    bool open(const QString &dbName);
    bool initReplicator(const QString &replUrl, const QStringList &channels=QStringList());

    Q_INVOKABLE QString getDocument(
            const QString &docId,
            const QString &rootElementName=QString());

    bool running() const;

signals:
    void runningChanged();

private:
    QSharedPointer<Strata::SGDatabase> database_;
    QSharedPointer<Strata::SGURLEndpoint> urlEndpoint_;
    QSharedPointer<Strata::SGReplicatorConfiguration> replicatorConfiguration_;
    QSharedPointer<Strata::SGReplicator> replicator_;
    bool running_;

    void setRunning(const bool running);
};
