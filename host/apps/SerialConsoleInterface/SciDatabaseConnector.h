#ifndef SCIDATABASCONNECTOR
#define SCIDATABASCONNECTOR

#include <couchbaselitecpp/SGCouchBaseLite.h>
#include <QObject>

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
    Spyglass::SGDatabase *database_{nullptr};
    Spyglass::SGURLEndpoint *urlEndpoint_{nullptr};
    Spyglass::SGReplicatorConfiguration *replicatorConfiguration_{nullptr};
    Spyglass::SGReplicator *replicator_{nullptr};
    Spyglass::SGBasicAuthenticator *autheticator_{nullptr};
    bool running_;

    void setRunning(bool running);
};

#endif //SCIDATABASCONNECTOR
