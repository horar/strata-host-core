
#include "HostControllerService.h"
#include "HCS_Client.h"
#include "StorageManager.h"
#include "ReplicatorCredentials.h"
#include "logging/LoggingQtCategories.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <QJsonObject>
#include <QJsonDocument>

#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QDebug>


HostControllerService::HostControllerService(QObject* parent) : QObject(parent)
    , db_(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation).toStdString())
    , dbLogAdapter_("strata.hcs.database")
    , clientsLogAdapter_("strata.hcs.clients")
{
    //handlers for 'cmd'
    clientCmdHandler_.insert( { std::string("request_hcs_status"), std::bind(&HostControllerService::onCmdHCSStatus, this, std::placeholders::_1) });
    clientCmdHandler_.insert( { std::string("register_client"), std::bind(&HostControllerService::onCmdRegisterClient, this, std::placeholders::_1) } );
    clientCmdHandler_.insert( { std::string("unregister"), std::bind(&HostControllerService::onCmdUnregisterClient, this, std::placeholders::_1) } );
    clientCmdHandler_.insert( { std::string("platform_select"), std::bind(&HostControllerService::onCmdPlatformSelect, this, std::placeholders::_1) } );
    clientCmdHandler_.insert( { std::string("request_available_platforms"), std::bind(&HostControllerService::onCmdRequestAvaibilePlatforms, this, std::placeholders::_1) } );

    hostCmdHandler_.insert( { std::string("jwt_token"), std::bind(&HostControllerService::onCmdHostJwtToken, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("advertise_platforms"), std::bind(&HostControllerService::onCmdHostAdvertisePlatforms, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("get_platforms"), std::bind(&HostControllerService::onCmdHostGetPlatforms, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("remote_disconnect"), std::bind(&HostControllerService::onCmdHostRemoteDisconnect, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("disconnect_remote_user"), std::bind(&HostControllerService::onCmdHostDisconnectRemoteUser, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("disconnect_platform"), std::bind(&HostControllerService::onCmdHostDisconnectPlatform, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("unregister"), std::bind(&HostControllerService::onCmdHostUnregister, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("download_files"), std::bind(&HostControllerService::onCmdHostDownloadFiles, this, std::placeholders::_1) });
    hostCmdHandler_.insert( { std::string("dynamic_platform_list"), std::bind(&HostControllerService::onCmdDynamicPlatformList, this, std::placeholders::_1) } );

}

HostControllerService::~HostControllerService()
{
    stop();
}

bool HostControllerService::initialize(const QString& config)
{
    if (parseConfig(config) == false) {
        return false;
    }

    db_.setLogAdapter(&dbLogAdapter_);
    clients_.setLogAdapter(&clientsLogAdapter_);

    dispatcher_.setMsgHandler(std::bind(&HostControllerService::handleMesages, this, std::placeholders::_1) );

    rapidjson::Value& db_cfg = config_["database"];

    if (!db_.open("strata_db")) {
        qCCritical(logCategoryHcs) << "Failed to open database.";
        return false;
    }

    db_.setDispatcher(&dispatcher_);

    // TODO: Will resolved in SCT-517
    //db_.addReplChannel("platform_list");

    storage_ = new StorageManager(&dispatcher_, this);

    connect(storage_, &StorageManager::singleDownloadProgress, this, &HostControllerService::singleDownloadProgressHandler);
    connect(storage_, &StorageManager::singleDownloadFinished, this, &HostControllerService::singleDownloadFinishedHandler);

    QString baseUrl = QString::fromStdString( db_cfg["file_server"].GetString() );
    storage_->setBaseUrl(baseUrl);
    storage_->setDatabase(&db_);

    db_.initReplicator(db_cfg["gateway_sync"].GetString(), replicator_username, replicator_password);

    boards_.initialize(&dispatcher_);

    rapidjson::Value& hcs_cfg = config_["host_controller_service"];

    clients_.initialize(&dispatcher_, hcs_cfg);
    return true;
}

void HostControllerService::start()
{
    if (dispatcherThread_.get_id() != std::thread::id()) {
        return;
    }

    dispatcherThread_ = std::thread(&HCS_Dispatcher::dispatch, &dispatcher_);

    qCInfo(logCategoryHcs) << "Host controller service started.";
}

void HostControllerService::stop()
{
    if (dispatcherThread_.get_id() == std::thread::id()) {
        return;
    }

    dispatcher_.stop();

    dispatcherThread_.join();
    qCInfo(logCategoryHcs) << "Host controller service stoped.";
}

void HostControllerService::onAboutToQuit()
{
    stop();
}

void HostControllerService::singleDownloadProgressHandler(QString filename, qint64 bytesReceived, qint64 bytesTotal)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "single_download_progress");
    payload.insert("filename", filename);
    payload.insert("bytes_received", bytesReceived);
    payload.insert("bytes_total", bytesTotal);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(current_client_->getClientId(), doc.toJson(QJsonDocument::Compact).toStdString());
}

void HostControllerService::singleDownloadFinishedHandler(QString filename, QString errorString)
{
    QJsonDocument doc;
    QJsonObject message;
    QJsonObject payload;

    payload.insert("type", "single_download_finished");
    payload.insert("filename", filename);
    payload.insert("error_string", errorString);

    message.insert("hcs::notification", payload);

    doc.setObject(message);

    clients_.sendMessage(current_client_->getClientId(), doc.toJson().toStdString());
}

bool HostControllerService::parseConfig(const QString& config)
{
    QString filename;
    if (config.isEmpty()) {
        filename  = QDir(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation)).filePath("hcs.config");
    }
    else {
        filename = config;
    }

    QFile file(filename);
    if (file.open(QIODevice::ReadOnly) == false) {
        qCCritical(logCategoryHcs) << "Unable to open config file:" << filename;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    rapidjson::Document configuration;
    if (configuration.Parse<rapidjson::kParseCommentsFlag>(data.data()).HasParseError()) {
        qCCritical(logCategoryHcs) << "Parse error on config file!";
        return false;
    }

    if( ! configuration.HasMember("host_controller_service") ) {
        qCCritical(logCategoryHcs) << "ERROR: No Host Controller Configuration parameters.";
        return false;
    }

    config_ = std::move(configuration);
    return true;
}

void HostControllerService::handleMesages(const PlatformMessage& msg)
{
    switch(msg.msg_type)
    {
        case PlatformMessage::eMsgPlatformConnected:            platformConnected(msg); break;
        case PlatformMessage::eMsgPlatformDisconnected:         platformDisconnected(msg); break;
        case PlatformMessage::eMsgPlatformMessage:              sendMessageToClients(msg); break;

        case PlatformMessage::eMsgClientMessage:                handleClientMsg(msg); break;
        case PlatformMessage::eMsgDynamicPlatformListResponse:  handleDynamicPlatformListResponse(msg); break;
        case PlatformMessage::eMsgCouchbaseMessage:             handleCouchbaseMsg(msg); break;

        case PlatformMessage::eMsgStorageRequest:               handleStorageRequest(msg); break;
        case PlatformMessage::eMsgStorageResponse:              handleStorageResponse(msg); break;

        default:
            assert(false);
            break;
    }
}

void HostControllerService::platformConnected(const PlatformMessage& item)
{
    if (item.from_connectionId.is_set == false) {
        return;
    }

    std::string classId = boards_.getClassId(item.from_connectionId.conn_id);

    if (classId.empty()) {
        qCWarning(logCategoryHcs) << "Connected platform doesn't have class Id.";
        return;
    }

    // TODO: Logic will be changed in SCT-517
    //db_.addReplChannel(classId);

    //send update to all clients
    std::string platformList;
    boards_.createPlatformsList(platformList);
    broadcastMessage(platformList);
}

void HostControllerService::platformDisconnected(const PlatformMessage& item)
{
    rapidjson::Document doc;
    if (doc.Parse<rapidjson::kParseCommentsFlag>(item.message.data()).HasParseError()) {
        qCWarning(logCategoryHcs) << "Parse error!";
        return;
    }

    if (doc.HasMember("class_id") == false || doc.HasMember("platform_id") == false) {
        qCWarning(logCategoryHcs) << "Parse error! no members";
        return;
    }

    std::string platformId = doc["platform_id"].GetString();
    HCS_Client* client = findClientByPlatformId(platformId);
    if (client != nullptr) {
        client->resetPlatformId();
    }

    std::string classId = doc["class_id"].GetString();
    if (!classId.empty()) {
        // TODO: Logic will be changed in SCT-517
        //db_.remReplChannel(classId);
    }

    //send update to all clients
    std::string platformList;
    boards_.createPlatformsList(platformList);
    broadcastMessage(platformList);
}

void HostControllerService::sendMessageToClients(const PlatformMessage& msg)
{
    if (msg.from_connectionId.is_set) {
        std::string clientId = boards_.getClientId(msg.from_connectionId.conn_id);
        if (clientId.empty() == false) {
            clients_.sendMessage(clientId, msg.message);
        }
    }
}

// clients handler...
void HostControllerService::onCmdHCSStatus(const rapidjson::Value* )
{
    HCS_Client* client = getSenderClient();
    Q_ASSERT(client);

    rapidjson::Document doc;
    doc.SetObject();
    doc.AddMember("hcs::notification", "hcs_active", doc.GetAllocator() );

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    clients_.sendMessage(client->getClientId(), strbuf.GetString() );
}

void HostControllerService::onCmdRegisterClient(const rapidjson::Value* )
{
    // TODO - this function does nothing?
    std::string platformList;
    boards_.createPlatformsList(platformList);
}

void HostControllerService::onCmdDynamicPlatformList(const rapidjson::Value * )
{
    std::string clientId = getSenderClient()->getClientId();
    if (storage_->requestPlatformList("platform_list", clientId) == false) {
        qCCritical(logCategoryHcs) << "Requested platform document error.";

        // create empty list
        std::string empty_list;
        rapidjson::Document document;
        document.SetObject();
        rapidjson::Document::AllocatorType& allocator = document.GetAllocator();
        rapidjson::Value nested_object;
        nested_object.SetObject();
        nested_object.AddMember("type","all_platforms",allocator);
        nested_object.AddMember("list",rapidjson::kArrayType,allocator);
        document.AddMember("hcs::notification",nested_object,allocator);
        rapidjson::StringBuffer strbuf;
        rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
        document.Accept(writer);
        empty_list = strbuf.GetString();

        //send error to requesting client
        clients_.sendMessage(clientId,  empty_list);
    }
}

void HostControllerService::onCmdUnregisterClient(const rapidjson::Value* )
{
    HCS_Client* client = getSenderClient();
    Q_ASSERT(client);

    if (int conn_id; boards_.getConnectionIdByClientId(client->getClientId(), conn_id)) {
        boards_.clearClientId(conn_id);
    }

    client->resetPlatformId();
    client->clearUsernameAndToken();
}

void HostControllerService::onCmdPlatformSelect(const rapidjson::Value* payload)
{
    if (!payload->HasMember("platform_uuid")) {
        return;
    }

    HCS_Client* client = getSenderClient();
    assert(client);

    std::string classId = (*payload)["platform_uuid"].GetString();
    if (classId.empty()) {
        return;
    }

    QString clientId = QByteArray::fromRawData(client->getClientId().data(), static_cast<int>(client->getClientId().size()) ).toHex();
//    QString clientId = QString::fromStdString(client->getClientId());
    qCInfo(logCategoryHcs) << "Client:" << clientId <<  " Selected platform:" << QString::fromStdString(classId);

    //TODO: download all necessary documents from db/cloud  (asynchronous)
    //      and send message to client
    //

    rapidjson::Document* request = new rapidjson::Document();
    request->SetObject();
    rapidjson::Document::AllocatorType& allocator = request->GetAllocator();
    request->AddMember("cmd", "request", allocator);
    request->AddMember("class_id", rapidjson::Value(classId.c_str(), allocator), allocator);
    request->AddMember("client_id", rapidjson::Value(client->getClientId().c_str(), allocator), allocator);

    PlatformMessage msg;
    msg.msg_type = PlatformMessage::eMsgStorageRequest;
    msg.from_client = client->getClientId();
    msg.message = std::string();
    msg.msg_document = request;

    dispatcher_.addMessage(msg);

    if (int connId; boards_.getFirstConnectionIdByClassId(classId, connId) ) {
        std::string platformId = boards_.getPlatformId(connId);
        if (platformId.empty()) {
            qCWarning(logCategoryHcs) << "Board doesn't have platfomId!";
            return;
        }
        if (boards_.setClientId(client->getClientId(), connId) == false) {
            qCWarning(logCategoryHcs) << "Board is allready assigned to some client!";
            return;
        }
        client->setPlatformId(platformId);
    }
}

void HostControllerService::onCmdHostDisconnectPlatform(const rapidjson::Value* )
{
    HCS_Client* client = getSenderClient();
    Q_ASSERT(client);

    if (int conn_id; boards_.getConnectionIdByClientId(client->getClientId(), conn_id)) {
        boards_.clearClientId(conn_id);
    }

    storage_->cancelDownloadPlatformDoc(client->getClientId());
    client->resetPlatformId();
}

void HostControllerService::onCmdRequestAvaibilePlatforms(const rapidjson::Value* )
{
}

void HostControllerService::onCmdHostJwtToken(const rapidjson::Value* payload)
{
    HCS_Client* client = getSenderClient();

    if (payload->HasMember("jwt") == false ||
        payload->HasMember("user_name") == false) {
        qCWarning(logCategoryHcs) << "CmdHostJwtToken() invalid payload.";
        return;
    }

    client->setJWT( (*payload)["jwt"].GetString() );
    client->setUsername( (*payload)["user_name"].GetString() );

//TODO:
//    if (!discovery_service_)
//        return;

    //TODO: do something with discovery service...
    // unfinished
    //
    // discovery_service_->setJWT(jwt);
    //
}

void HostControllerService::onCmdHostAdvertisePlatforms(const rapidjson::Value* payload)
{
    if (payload) {
//TODO:        bool remote_advertise = (*payload)["advertise_platforms"].GetBool();
//        PDEBUG(PRINT_DEBUG,"is remote session ON? %d",remote_advertise);

//TODO:        handleRemotePlatformRegistration(remote_advertise);
    }
}

void HostControllerService::onCmdHostGetPlatforms(const rapidjson::Value* )
{

}

void HostControllerService::onCmdHostRemoteDisconnect(const rapidjson::Value* )
{

}

void HostControllerService::onCmdHostDisconnectRemoteUser(const rapidjson::Value* )
{

}

void HostControllerService::onCmdHostUnregister(const rapidjson::Value* )
{
    HCS_Client* client = getSenderClient();
    Q_ASSERT(client);

    if (int conn_id; boards_.getConnectionIdByClientId(client->getClientId(), conn_id)) {
        boards_.clearClientId(conn_id);
    }

    client->clearUsernameAndToken();
}

void HostControllerService::onCmdHostDownloadFiles(const rapidjson::Value* payload)
{

#if _WIN32
    const std::string substring_toremove("file:///");
#else
    const std::string substring_toremove("file://");
#endif

    std::string save_path;
    std::vector<std::string> files;

    if (payload->IsArray()) {

        for(auto it = payload->Begin(); it != payload->End(); ++it) {
            if (it->HasMember("file") == false || it->HasMember("path") == false) {
                continue;
            }

            std::string file = (*it)["file"].GetString();
            std::string path = (*it)["path"].GetString();

            //There is only one path selected in UI, so only one destination folder
            if (save_path.empty()) {
                std::string::size_type position_remove = path.find(substring_toremove);
                if (position_remove != std::string::npos) {
                    path.erase(position_remove, substring_toremove.length());
                }
                save_path = path;
            }

            files.push_back(file);
        }
    }

#ifdef NEWER_VERSION
    if (payload->HasMember("files") == false) {
        return;
    }

    const rapidjson::Value& array = (*payload)["files"];
    std::string save_path = (*payload)["path"].GetString();

    std::string::size_type position_remove = save_path.find(substring_toremove);
    if (position_remove != std::string::npos) {
        save_path.erase(position_remove, substring_toremove.length());
    }

    std::vector<std::string> files;
    for(auto it = array.Begin(); it != array.End(); ++it) {
        std::string file = (*it)["file"].GetString();
        files.push_back(file);
    }
#endif

    storage_->requestDownloadFiles(files, save_path);
}

HCS_Client* HostControllerService::getClientById(const std::string& client_id)
{
    auto findIt = std::find_if(clientList_.begin(), clientList_.end(),
                               [&](HCS_Client* val) { return client_id == val->getClientId(); }  );

    return (findIt != clientList_.end()) ? *findIt : nullptr;
}

void HostControllerService::handleClientMsg(const PlatformMessage& msg)  //const std::string& read_message, const std::string& dealer_id
{
    QString clientId = QByteArray::fromRawData(msg.from_client.data(), static_cast<int>(msg.from_client.size()) ).toHex();

    //check the client's ID (dealer_id) is in list
    HCS_Client* client = getClientById(msg.from_client);
    if (client == nullptr) {
        qCInfo(logCategoryHcs) << "new Client:" << clientId;

        client = new HCS_Client(msg.from_client);
        clientList_.push_back(client);
    }

    current_client_ = client;

    rapidjson::Document service_command;
    if (service_command.Parse(msg.message.c_str()).HasParseError()) {
        qCWarning(logCategoryHcs) << "Client:" << clientId << "parse error!";
        return;
    }

    auto firstIt = service_command.MemberBegin();
    std::string msg_type = firstIt->name.GetString();

    rapidjson::Value* payload = nullptr;
    if (service_command.HasMember("payload")) {
        payload = &(service_command["payload"]);
    }

    std::string cmd_name = firstIt->value.GetString();
    qCInfo(logCategoryHcs) << "Client:" << clientId << "Type:" << QString::fromStdString(msg_type) << "cmd:" << QString::fromStdString(cmd_name);

    if (msg_type == "hcs::cmd") {

        auto findIt = hostCmdHandler_.find(cmd_name);
        if (findIt == hostCmdHandler_.end()) {
            //TODO: error handling...
            return;
        }

        findIt->second(payload);
    }
    else if (msg_type == "cmd") {

        auto findIt = clientCmdHandler_.find(cmd_name);
        if (findIt == clientCmdHandler_.end()) {

            disptachMessageToPlatforms(msg.from_client, msg.message);
            return;
        }

        findIt->second(payload);
    }

}

void HostControllerService::handleCouchbaseMsg(const PlatformMessage& msg)
{
    storage_->updatePlatformDoc(msg.from_client);
}

void HostControllerService::handleStorageRequest(const PlatformMessage& msg)
{
    assert(msg.msg_document != nullptr);
    rapidjson::Document* request_doc = msg.msg_document;

    std::string classId = (*request_doc)["class_id"].GetString();

    if (storage_->requestPlatformDoc(classId, msg.from_client, StorageManager::RequestGroupType::eContentViews) == false) {
        qCCritical(logCategoryHcs) << "Requested platform document error.";

        // create error JSON
        std::string error_msg;
        rapidjson::Document document;
        document.SetObject();
        rapidjson::Document::AllocatorType& allocator = document.GetAllocator();
        rapidjson::Value nested_object;
        nested_object.SetObject();
        nested_object.AddMember("type","document",allocator);
        nested_object.AddMember("error","DB platform document not found or malformed",allocator);
        document.AddMember("cloud::notification",nested_object,allocator);
        rapidjson::StringBuffer strbuf;
        rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
        document.Accept(writer);
        error_msg = strbuf.GetString();

        //send error to requesting client
        clients_.sendMessage(msg.from_client, error_msg);
    }

    delete msg.msg_document;
}

void HostControllerService::handleDynamicPlatformListResponse(const PlatformMessage& msg)
{
    qCInfo(logCategoryHcs) << "Sending Dynamic Platform List response to client";

    assert(msg.msg_document != nullptr);

    clients_.sendMessage(msg.from_client, msg.message.c_str() );

    delete msg.msg_document;
}

void HostControllerService::handleStorageResponse(const PlatformMessage& msg)
{
    assert(msg.msg_document != nullptr);

    rapidjson::Document* storage_response_doc = msg.msg_document;

    rapidjson::Document client_doc;
    client_doc.SetObject();
    rapidjson::Document::AllocatorType& allocator = client_doc.GetAllocator();

    rapidjson::Value document_obj;
    document_obj.SetObject();
    document_obj.AddMember("type","document",allocator);

    auto itr = storage_response_doc->FindMember("error");
    if (itr != storage_response_doc->MemberEnd()) {

        document_obj.AddMember("error",(*storage_response_doc)["error"],allocator);

    } else {
        rapidjson::Value& list = (*storage_response_doc)["list"];
        rapidjson::Value& downloads = (*storage_response_doc)["downloads"];

        rapidjson::Value array(rapidjson::kArrayType);

        for(auto it = list.Begin(); it != list.End(); ++it) {
            std::string uri  = (*it)["uri"].GetString();
            std::string name = (*it)["name"].GetString();

            rapidjson::Value array_object;
            array_object.SetObject();
            array_object.AddMember("uri", rapidjson::Value(uri.c_str(), allocator), allocator);
            array_object.AddMember("name", rapidjson::Value(name.c_str(), allocator), allocator);

            array.PushBack(array_object, allocator);
        }

        for(auto it = downloads.Begin(); it != downloads.End(); ++it) {
            std::string file  = (*it)["file"].GetString();

            rapidjson::Value array_object;
            array_object.SetObject();
            array_object.AddMember("uri", rapidjson::Value(file.c_str(), allocator), allocator);
            array_object.AddMember("name", rapidjson::Value("download", allocator), allocator);

            array.PushBack(array_object, allocator);
        }

        document_obj.AddMember("documents", array, allocator);
    }

    delete msg.msg_document;

    client_doc.AddMember("cloud::notification", document_obj, allocator);

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    client_doc.Accept(writer);

    qCInfo(logCategoryHcs) << "Sending response to client. Msg:" << QString::fromStdString( strbuf.GetString() );

    clients_.sendMessage(msg.from_client, strbuf.GetString() );
}

bool HostControllerService::disptachMessageToPlatforms(const std::string& dealer_id, const std::string& message )
{
    int connectionId;
    if (boards_.getConnectionIdByClientId(dealer_id, connectionId) == false) {
        qCWarning(logCategoryHcs) << "No board attached to client.";
        return false;
    }

    boards_.sendMessage(connectionId, message);
    return true;
}

bool HostControllerService::broadcastMessage(const std::string& message)
{
    qCInfo(logCategoryHcs) << "broadcast msg:" << QString::fromStdString(message);
    for(auto item : clientList_) {
        std::string clientId = item->getClientId();
        clients_.sendMessage(clientId, message);
    }

    return false;
}

HCS_Client* HostControllerService::findClientByPlatformId(const std::string& platformId)
{
    for(HCS_Client* item : clientList_) {
        if (item->getPlatformId() == platformId) {
            return item;
        }
    }

    return nullptr;
}

