#ifndef SCIDATABASCONNECTOR
#define SCIDATABASCONNECTOR

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
    QSharedPointer<Spyglass::SGDatabase> database_;
    QSharedPointer<Spyglass::SGURLEndpoint> urlEndpoint_;
    QSharedPointer<Spyglass::SGReplicatorConfiguration> replicatorConfiguration_;
    QSharedPointer<Spyglass::SGReplicator> replicator_;
    bool running_;

    void setRunning(const bool running);
};

#endif //SCIDATABASCONNECTOR
