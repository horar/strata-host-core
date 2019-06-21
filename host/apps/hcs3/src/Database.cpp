
#include "Database.h"
#include "Dispatcher.h"

#include <SGCouchBaseLite.h>
#include <SGFleece.h>
#include <include/LoggingAdapter.h>

using namespace Spyglass;

Database::Database()
{

}
Database::~Database()
{
    if (sg_replicator_) {
        sg_replicator_->stop();
    }

    delete sg_replicator_;
    delete url_endpoint_;
    delete sg_replicator_configuration_;
    delete basic_authenticator_;

    delete sg_database_;
}

void Database::setDispatcher(HCS_Dispatcher* dispatcher)
{
    dispatcher_ = dispatcher;
}

void Database::setLogAdapter(LoggingAdapter* adapter)
{
    logAdapter_ = adapter;
}

bool Database::open(const std::string& db_name)
{
    if (sg_database_ != nullptr) {
        return false;
    }

    // opening the db
    sg_database_ = new SGDatabase(db_name);
    if (sg_database_->open() != SGDatabaseReturnStatus::kNoError) {
        if (logAdapter_) {
            logAdapter_->Log(LoggingAdapter::eLvlInfo, "Failed to open database");
        }
        return false;
    }

    return true;
}

bool Database::addReplChannel(const std::string& channel)
{
    assert(channel.empty() == false);
    auto findIt = channels_.find(channel);
    if (findIt == channels_.end()) {

        channels_.insert(channel);
        updateChannels();
    }

    return true;
}

bool Database::remReplChannel(const std::string& channel)
{
    assert(channel.empty() == false);
    auto findIt = channels_.find(channel);
    if (findIt != channels_.end()) {

        channels_.erase(channel);
        updateChannels();
    }

    return true;
}

void Database::updateChannels()
{
    if (sg_replicator_ == nullptr || sg_replicator_configuration_ == nullptr) {
        return;
    }

    bool wasRunning = isRunning_;
    if (isRunning_) {
        sg_replicator_->stop();
    }

    std::vector<std::string> myChannels;
    myChannels.reserve(channels_.size());
    std::copy(channels_.begin(), channels_.end(), std::back_inserter(myChannels));

    sg_replicator_configuration_->setChannels(myChannels);

    if (wasRunning) {
        if (sg_replicator_->start() == false) {
            if (logAdapter_) {
                logAdapter_->Log(LoggingAdapter::eLvlInfo, "Replicator start failed!");
            }
        }
    }
}

bool Database::getDocument(const std::string& doc_id, const std::string& root_element_name, std::string& result)
{
    SGDocument doc(sg_database_, doc_id);
    if (!doc.exist()) {
        return false;
    }

    const fleece::impl::Value* value = doc.get(root_element_name);
    if (value == nullptr) {
        return false;
    }

    result = value->toJSONString();
    return true;
}

bool Database::initReplicator(const std::string& replUrl)
{
    if (url_endpoint_ != nullptr || dispatcher_ == nullptr) {
        return false;
    }

    url_endpoint_ = new SGURLEndpoint(replUrl);
    if (url_endpoint_->init() == false) {
        if (logAdapter_) {
            logAdapter_->Log(LoggingAdapter::eLvlInfo, "Replicator endpoint URL is failed!");
        }
        return false;
    }

    sg_replicator_configuration_ = new SGReplicatorConfiguration(sg_database_, url_endpoint_);
    sg_replicator_configuration_->setReplicatorType(SGReplicatorConfiguration::ReplicatorType::kPull);
    sg_replicator_ = new SGReplicator(sg_replicator_configuration_);

    sg_replicator_->addDocumentEndedListener(std::bind(&Database::onDocumentEnd, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));

    if (sg_replicator_->start() == false) {
        if (logAdapter_) {
            logAdapter_->Log(LoggingAdapter::eLvlWarning, "Replicator start failed!");
        }

        delete sg_replicator_; sg_replicator_ = nullptr;
        delete sg_replicator_configuration_; sg_replicator_configuration_ = nullptr;
        delete url_endpoint_; url_endpoint_ = nullptr;

        return false;
    }

    isRunning_ = true;
    return isRunning_;
}

void Database::onDocumentEnd(bool /*pushing*/, std::string doc_id, std::string /*error_message*/, bool /*is_error*/, bool /*error_is_transient*/)
{
    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgCouchbaseMessage;
    msg.from_client = doc_id;
    msg.message = "update_doc";

    if (dispatcher_) {
        dispatcher_->addMessage(msg);
    }
}