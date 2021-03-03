#include <thread>

#include "DatabaseManager.h"
#include "DatabaseAccess.h"
#include "CouchbaseDocument.h"
#include "TokenManager.h"

#include <QDebug>
#include <QCoreApplication>

const QString path = "";
const QString url = "ws://sync-gateway:4984/french_cuisine";

int main(int argc, char *argv[]) {

    QCoreApplication app(argc, argv);

    TokenManager tm;
    const QString cookie = tm.getTokenID();
    const QString cookie_name = "SyncGatewaySession";

    auto db = std::make_unique<CouchbaseDatabase>("french_cuisine", path.toStdString());

    if (db->open()) {
        qDebug() << "Opened bucket";
    } else {
        qDebug() << "Failed to open bucket";
        return -1;
    }

    db->startSessionReplicator(url.toStdString(), cookie.toStdString(), cookie_name.toStdString());

    // Wait until replication is finished
    unsigned int retries = 0;
    const unsigned int REPLICATOR_RETRY_MAX = 50;
    const std::chrono::milliseconds REPLICATOR_RETRY_INTERVAL = std::chrono::milliseconds(200);
    while (db->getReplicatorStatus() != "Stopped" && db->getReplicatorStatus() != "Idle") {
        ++retries;
        std::this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (db->getReplicatorError() != 0 || retries >= REPLICATOR_RETRY_MAX) {
            qDebug() << "Error with execution of replicator. Verify endpoint URL" << url << "is valid.";
            return -1;
        }
    }

    return 0;
}
