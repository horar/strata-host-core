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

    delete replicator_;
    delete urlEndpoint_;
    delete replicatorConfiguration_;
    delete database_;
    delete autheticator_;
}

bool SciDatabaseConnector::open(const QString &dbName)
{
    if (database_ != nullptr) {
        return false;
    }

    database_ = new Spyglass::SGDatabase(
                dbName.toStdString(),
                QStandardPaths::writableLocation(QStandardPaths::AppDataLocation).toStdString());

    Spyglass::SGDatabaseReturnStatus ret = database_->open();
    if (ret != Spyglass::SGDatabaseReturnStatus::kNoError) {
        qCWarning(logCategorySci) << "Failed to open database error" << static_cast<int>(ret);
        return false;
    }

    return true;
}

bool SciDatabaseConnector::initReplicator(const QString &replUrl, const QStringList &channels)
{
    if (urlEndpoint_ != nullptr) {
        return false;
    }

    channels_ = channels;
    urlEndpoint_ = new Spyglass::SGURLEndpoint(replUrl.toStdString());

    if (urlEndpoint_->init() == false) {
        qCWarning(logCategorySci) << "Replicator endpoint URL is failed";
        return false;
    }

    replicatorConfiguration_ = new Spyglass::SGReplicatorConfiguration(database_, urlEndpoint_);
    replicatorConfiguration_->setReplicatorType(Spyglass::SGReplicatorConfiguration::ReplicatorType::kPull);
    replicator_ = new Spyglass::SGReplicator(replicatorConfiguration_);

    updateChannels();

    if (replicator_->start() != Spyglass::SGReplicatorReturnStatus::kNoError) {
        qCWarning(logCategorySci) << "Replicator start failed";

        delete replicator_; replicator_ = nullptr;
        delete replicatorConfiguration_; replicatorConfiguration_ = nullptr;
        delete urlEndpoint_; urlEndpoint_ = nullptr;
        delete autheticator_; autheticator_ = nullptr;

        return false;
    }

    setRunning(true);
    return true;
}

bool SciDatabaseConnector::addReplChannel(const QString &channel)
{
    if (channel.isEmpty()) {
        return false;
    }

    if (channels_.contains(channel) == false) {
        channels_.append(channel);
        updateChannels();
    }

    return true;
}

bool SciDatabaseConnector::removeReplChannel(const QString &channel)
{
    if (channel.isEmpty()) {
        return false;
    }

    if (channels_.removeOne(channel)) {
        updateChannels();
    }

    return true;
}

QString SciDatabaseConnector::getDocument(const QString &docId, const QString &rootElementName)
{
    qCDebug(logCategorySci) << docId << rootElementName;

    Spyglass::SGDocument doc(database_, docId.toStdString());
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

void SciDatabaseConnector::updateChannels()
{
    if (replicator_ == nullptr || replicatorConfiguration_ == nullptr) {
        return;
    }

    bool wasRunning = running_;
    if (running_) {
        replicator_->stop();
        setRunning(false);
    }

    std::vector<std::string> myChannels;
    for (int i=0; i < channels_.length(); ++i) {
        myChannels.push_back(channels_.at(i).toStdString());
    }

    replicatorConfiguration_->setChannels(myChannels);

    if (wasRunning) {
        if (replicator_->start() != Spyglass::SGReplicatorReturnStatus::kNoError) {
            qCWarning(logCategorySci) << "Replicator start failed";
            return;
        }

        setRunning(true);
    }
}

void SciDatabaseConnector::setRunning(bool running)
{
    if (running_ != running) {
        running_ = running;
        emit runningChanged();
    }
}
