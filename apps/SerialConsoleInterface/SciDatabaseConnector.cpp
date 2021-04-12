#include "SciDatabaseConnector.h"
#include "logging/LoggingQtCategories.h"

#include <QDebug>
#include <QStandardPaths>
#include <couchbaselitecpp/SGFleece.h>

SciDatabaseConnector::SciDatabaseConnector(QObject *parent)
    : QObject(parent),
      running_(false)
{
}

SciDatabaseConnector::~SciDatabaseConnector()
{
    if (replicator_) {
        replicator_->stop();
    }
}

bool SciDatabaseConnector::open(const QString &dbName)
{
    if (database_.isNull() == false) {
        return false;
    }

    database_ = QSharedPointer<Strata::SGDatabase>(
                new Strata::SGDatabase(
                    dbName.toStdString(),
                    QStandardPaths::writableLocation(QStandardPaths::AppDataLocation).toStdString()));

    Strata::SGDatabaseReturnStatus ret = database_->open();
    if (ret != Strata::SGDatabaseReturnStatus::kNoError) {
        qCCritical(logCategorySci) << "Failed to open database error" << static_cast<int>(ret);
        return false;
    }

    return true;
}

bool SciDatabaseConnector::initReplicator(const QString &replUrl, const QStringList &channels)
{
    if (urlEndpoint_ != nullptr) {
        return false;
    }

    urlEndpoint_ = QSharedPointer<Strata::SGURLEndpoint>(
                new Strata::SGURLEndpoint(replUrl.toStdString()));

    if (urlEndpoint_->init() == false) {
        qCCritical(logCategorySci) << "Replicator endpoint URL is failed";
        return false;
    }

    replicatorConfiguration_ = QSharedPointer<Strata::SGReplicatorConfiguration>(
                new Strata::SGReplicatorConfiguration(database_.data(), urlEndpoint_.data()));

    replicatorConfiguration_->setReplicatorType(Strata::SGReplicatorConfiguration::ReplicatorType::kPull);

    if (channels.isEmpty() == false) {
        std::vector<std::string> myChannels;
        for (const auto &channel : channels) {
            myChannels.push_back(channel.toStdString());
        }

        replicatorConfiguration_->setChannels(myChannels);
    }

    replicator_ = QSharedPointer<Strata::SGReplicator>(
                new Strata::SGReplicator(replicatorConfiguration_.data()));

    const auto result = replicator_->start();
    if (result != Strata::SGReplicatorReturnStatus::kNoError) {
        qCCritical(logCategorySci) << "Replicator start failed" << static_cast<int>(result);

        replicator_.reset();
        replicatorConfiguration_.reset();
        urlEndpoint_.reset();

        return false;
    }

    setRunning(true);
    return true;
}

QString SciDatabaseConnector::getDocument(const QString &docId, const QString &rootElementName)
{
    qCDebug(logCategorySci) << docId << rootElementName;

    Strata::SGDocument doc(database_.data(), docId.toStdString());
    if (!doc.exist()) {
        return QString();
    }

    if (rootElementName.isEmpty()) {
        return QString::fromStdString(doc.asDict()->toJSONString());
    } else {
        const fleece::impl::Value* value = doc.get(rootElementName.toStdString());
        if (value == nullptr) {
            return QString();
        }

        return QString::fromStdString(value->toJSONString());
    }
}

bool SciDatabaseConnector::running() const {
    return running_;
}

void SciDatabaseConnector::setRunning(const bool running)
{
    if (running_ != running) {
        running_ = running;
        emit runningChanged();
    }
}
