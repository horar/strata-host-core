/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <thread>
#include <QDir>
#include <QJsonArray>

#include "DatabaseImpl.h"

using namespace std;
using namespace cbl;

DatabaseImpl::DatabaseImpl(QObject *parent, const bool &mgr) : QObject(parent), cb_browser_("cb_browser")
{
    if (mgr) {
        config_mgr_ = make_unique<ConfigManager>();
        emit jsonConfigChanged();
    }
}

DatabaseImpl::~DatabaseImpl()
{
    if (isDBOpen()) {
        closeDB();
    }
}

void DatabaseImpl::openDB(const QString &file_path)
{
    if (file_path.length() < 2) {
        qCCritical(cb_browser_) << "Attempted to open database but received invalid file path.";
        return;
    }

    file_path_ = file_path;
    file_path_.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to open database with file path " << file_path_;

    if ((QDir::separator() != '/') && file_path_.startsWith('/')) {
        file_path_.remove(0, 1);
    }

    file_path_.replace("/", QDir::separator());
    QDir dir(file_path_);
    QFileInfo info(file_path_);

    if (!info.exists()) {
        qCCritical(cb_browser_) << "Attempting to open database but file was not found: " << file_path;
    }

    if (info.fileName() != "db.sqlite3" || !dir.cdUp()) {
        qCCritical(cb_browser_) << "Problem with path to database file: " << file_path_;
        setMessageAndStatus(MessageType::Error, "Problem with path to database file. The file must be located according to: \".../[DB name].cblite2/db.sqlite3\".");
        return;
    }

    QString dir_name = dir.dirName();
    dir_name.replace(".cblite2", "");

    if (!dir.cdUp()) {
        qCCritical(cb_browser_) << "Problem with path to database file: " << file_path_;
        setMessageAndStatus(MessageType::Error, "Problem with path to database file. The file must be located according to: \".../[DB name].cblite2/db.sqlite3\".");
        return;
    }

    if (isDBOpen()) {
        closeDB();
    }

    setDBName(dir_name);
    setDBPath(dir.path() + QDir::separator());

    QByteArray db_path_ba = db_path_.toLocal8Bit();
    const char *db_path_c = db_path_ba.data();
    CBLDatabaseConfiguration db_config = {db_path_c, kCBLDatabase_Create, nullptr};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    try {
        sg_db_ = make_unique<Database>(db_name_.toLocal8Bit().data(), db_config);
    }
    catch (CBLError) {
        setMessageAndStatus(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    if (!sg_db_ || !sg_db_->valid()) {
        setMessageAndStatus(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    setDBstatus(false);
    setRepstatus(false);
    latest_replication_.reset();
    setDBstatus(true);
    getChannelSuggestions();
    setAllChannelsStr();
    emitUpdate();

    if (config_mgr_) {
        config_mgr_->addDBToConfig(getDBName(), file_path_);
        emit jsonConfigChanged();
    }

    setMessageAndStatus(MessageType::Success, "Successfully opened database '" + getDBName() + "'.");
}

void DatabaseImpl::deleteConfigEntry(const QString &db_name)
{
    if (!config_mgr_) {
        setMessageAndStatus(MessageType::Error, "Unable to delete Config database entry '" + db_name + "'.");
        return;
    }

    if (config_mgr_->deleteConfigEntry(db_name)) {
        setMessageAndStatus(MessageType::Success, "Successfully deleted Config database entry '" + db_name + "'.");
        emit jsonConfigChanged();
        return;
    }

    setMessageAndStatus(MessageType::Error, "Unable to delete Config database entry '" + db_name + "'.");
}

void DatabaseImpl::clearConfig()
{
    if (!config_mgr_) {
        setMessageAndStatus(MessageType::Error, "Unable to clear Config database.");
        return;
    }

    if (config_mgr_->clearConfig()) {
        setMessageAndStatus(MessageType::Success, "Successfully cleared database suggestions.");
        emit jsonConfigChanged();
        return;
    }

    setMessageAndStatus(MessageType::Error, "Unable to clear Config database.");
}

QStringList DatabaseImpl::getChannelSuggestions()
{
    QStringList suggestions;

    if (!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to get channel suggestions, but database is not running.";
        return suggestions;
    }

    // Get channels previously used with this DB
    if (config_mgr_) {
        QJsonDocument config_doc = QJsonDocument::fromJson(config_mgr_->getConfigJson().toUtf8());

        if (config_doc.isNull() || config_doc.isEmpty()) {
            qCWarning(cb_browser_) << "Received empty list of previously used channels from the Config DB.";
            return suggestions;
        }

        QJsonObject config_obj = config_doc.object();
        QJsonObject db_entry_obj = config_obj.value(getDBName()).toObject();

        if (db_entry_obj.isEmpty()) {
            qCWarning(cb_browser_) << "Received empty list of previously used channels from the Config DB.";
            return suggestions;
        }

        QJsonValue channels_val = db_entry_obj.value("channels");
        QJsonArray channels_arr = channels_val.toArray();

        for (const QJsonValue channel : channels_arr) {
            suggestions << channel.toString();
        }
    }

    if (!setDocumentKeys()) {
        qCCritical(cb_browser_) << "Failed to reset document keys while getting channel suggestions.";
        return suggestions;
    }

    // Get channels from each document in the current DB
    for (const string &document_key : document_keys_) {
        Document doc = sg_db_.get()->getDocument(document_key);
        fleece::Dict read_dict = doc.properties();
        QJsonDocument json_doc = QJsonDocument::fromJson(QByteArray::fromStdString(read_dict.toJSONString()));

        if (json_doc.isNull() || json_doc.isEmpty()) {
            qCCritical(cb_browser_) << "Received empty or invalid JSON message.";
            return suggestions;
        }

        QJsonObject db_entry_obj = json_doc.object();
        if (db_entry_obj.contains("channels")) {
            QJsonValue channels_val = db_entry_obj.value("channels");

            if (channels_val.isUndefined() || channels_val.isNull()) {
                continue;
            }

            if (channels_val.isString()) {
                QString channel = channels_val.toString();
                channel = channels_val.toString();
                if (!channel.isEmpty()) {
                    suggestions << channel;
                }
            } else if (channels_val.isArray()) {
                QJsonArray channels_arr = channels_val.toArray();

                for (const QJsonValue channel : channels_arr) {
                    suggestions << channel.toString();
                }
            } else {
                qCCritical(cb_browser_) << "Read 'channels' key of document " << QString::fromStdString(document_key) << ", but its value was not a string or array.";
            }
        }
    }

    suggestions.removeDuplicates();
    suggested_channels_ = suggestions;
    return suggestions;
}

void DatabaseImpl::createNewDB(QString folder_path, const QString &db_name)
{
    if (folder_path.length() < 2 || db_name.simplified().isEmpty()) {
        setMessageAndStatus(MessageType::Error, "Attempted to create new database, but received invalid folder path or database name.");
        return;
    }

    folder_path.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to create new database '" << db_name << "' with folder path " << folder_path;

    if ((QDir::separator() != '/') && folder_path.startsWith('/')) {
        folder_path.remove(0, 1);
    }

    folder_path = QDir::fromNativeSeparators(folder_path);
    QDir dir(folder_path);

    if (!dir.isAbsolute() || !dir.mkpath(folder_path)) {
        qCCritical(cb_browser_) << "Problem with path to database file: " + file_path_;
        setMessageAndStatus(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    file_path_ = folder_path + QDir::separator() + db_name + ".cblite2" + QDir::separator() + "db.sqlite3";

    QFileInfo file(file_path_);

    if (file.exists()) {
        setMessageAndStatus(MessageType::Error, "Database '" + db_name + "' already exists in the selected location.");
        return;
    }

    if (db_name.contains('\\') || db_name.contains('/')) {
        setMessageAndStatus(MessageType::Error, "Database name cannot contain certain characters, such as slashes.");
        return;
    }

    if (getDBStatus()) {
        closeDB();
    }

    setDBName(db_name);
    setDBPath(folder_path);

    QByteArray db_path_ba = db_path_.toLocal8Bit();
    const char *db_path_c = db_path_ba.data();
    CBLDatabaseConfiguration db_config = {db_path_c, kCBLDatabase_Create, nullptr};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    try {
        sg_db_ = make_unique<Database>(db_name.toLocal8Bit().data(), db_config);
    }
    catch (CBLError) {
        setMessageAndStatus(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    if (!sg_db_ || !sg_db_->valid()) {
        setMessageAndStatus(MessageType::Error, "Problem with initialization of database.");
        return;
    }

    document_keys_.clear();
    latest_replication_.reset();
    suggested_channels_.clear();
    setDBstatus(true);
    emitUpdate();
    setAllChannelsStr();

    if (config_mgr_) {
        config_mgr_->addDBToConfig(getDBName(),file_path_);
        emit jsonConfigChanged();
    }

    setMessageAndStatus(MessageType::Success, "Successfully created database '" + db_name + "'.");
}

void DatabaseImpl::closeDB()
{
    if (!getDBStatus()) {
        setMessageAndStatus(MessageType::Error, "No open database, cannot close.");
        return;
    }

    setDBstatus(false);
    stopListening();
    document_keys_.clear();
    latest_replication_.reset();
    suggested_channels_.clear();
    setMessageAndStatus(MessageType::Success, "Successfully closed database '" + getDBName() + "'.");
    setDBName("");
    JsonDBContents_ = "{}";
    emit jsonDBContentsChanged();
}

void DatabaseImpl::emitUpdate()
{
    if (setDocumentKeys()) {
        setJSONResponse(document_keys_);
    }

    emit jsonDBContentsChanged();
    qCInfo(cb_browser_) << "Emitted update to UI.";
}

bool DatabaseImpl::stopListening()
{
    if (sg_replicator_) {
        manual_replicator_stop_ = true;
        if (ctoken_) {
            ctoken_->remove();
            ctoken_.reset();
        }
        sg_replicator_->stop();
    }

    sg_replicator_configuration_.reset();
    is_retry_ = false;
    setRepstatus(false);
    suggested_channels_ += latest_replication_.channels;
    suggested_channels_.removeDuplicates();
    setAllChannelsStr();
    return true;
}

void DatabaseImpl::createNewDoc(const QString &id, const QString &body)
{
    if (!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to create document " << id << " but database is not open.";
        return;
    }

    if (id.isEmpty() || body.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "ID and body contents of document may not be empty.");
        return;
    }

    if (docExistsInDB(id)) {
        setMessageAndStatus(MessageType::Error, "A document with ID '" + id + "' already exists. Modify the ID and try again.");
        return;
    }

    fleece::Doc fleece_doc = fleece::Doc::fromJSON(body.toStdString());

    if (!fleece_doc) {
        setMessageAndStatus(MessageType::Error, "Error setting document '" + id + "'. Verify the body is valid JSON.");
        return;
    }

    MutableDocument newDoc(id.toStdString());
    newDoc.setProperties(fleece_doc);
    sg_db_->saveDocument(newDoc);

    if (!getListenStatus()) {
        updateContents();
    }

    setMessageAndStatus(MessageType::Success, "Successfully created document '" + id + "'.");
}

bool DatabaseImpl::startListening(QString url, QString username, QString password, QString rep_type, vector<QString> channels)
{
    if (url.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "URL may not be empty.");
        return false;
    }

    if (!isDBOpen()) {
        setMessageAndStatus(MessageType::Error, "Database must be open and running for replication to be activated.");
        return false;
    }

    if (getListenStatus()) {
        setMessageAndStatus(MessageType::Error, "Replicator is already running, cannot start again.");
        return false;
    }

    sg_replicator_configuration_ = make_unique<ReplicatorConfiguration>(*sg_db_.get());
    sg_replicator_configuration_->endpoint.setURL(url.toUtf8());

    // Set replicator type (pull / push / push and pull)
    if (rep_type == "pull") {
        sg_replicator_configuration_->replicatorType = kCBLReplicatorTypePull;
    } else if (rep_type == "push") {
        sg_replicator_configuration_->replicatorType = kCBLReplicatorTypePush;
    } else if (rep_type == "pushpull") {
        sg_replicator_configuration_->replicatorType = kCBLReplicatorTypePushAndPull;
    } else {
        setMessageAndStatus(MessageType::Error, "Unidentified replicator type selected.");
        return false;
    }

    // Set basic replicator authentication (username / password)
    if (!username.isEmpty() && !password.isEmpty()) {
        sg_replicator_configuration_->authenticator.setBasic(username.toUtf8(), password.toUtf8());
    }

    if (!channels.empty()) {
        fleece::MutableArray channels_mutablearray = fleece::MutableArray::newArray();
        for (const auto &chan : channels) {
            channels_mutablearray.append(chan.toStdString());
        }
        sg_replicator_configuration_->channels = channels_mutablearray;
    }

    sg_replicator_configuration_->continuous = true;

    // Official CBL API: Replicator CTOR can throw so this is wrapped in try/catch
    try {
        sg_replicator_ = make_unique<Replicator>(*sg_replicator_configuration_);
    }
    catch (CBLError) {
        setMessageAndStatus(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    if (!sg_replicator_ || !sg_replicator_->valid()) {
        setMessageAndStatus(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    ctoken_ = make_unique<Replicator::ChangeListener>(sg_replicator_->addChangeListener(bind(&DatabaseImpl::repStatusChanged, this, placeholders::_1, placeholders::_2)));

    if (!ctoken_) {
        setMessageAndStatus(MessageType::Error, "Problem with start of replicator.");
        return false;
    }

    latest_replication_.url = url;
    latest_replication_.username = username;
    latest_replication_.password = password;
    latest_replication_.rep_type = rep_type;
    latest_replication_.channels.clear();

    for (const auto &chan : channels) {
        latest_replication_.channels << chan;
    }

    manual_replicator_stop_ = false;
    replicator_first_connection_ = true;

    // Start replicator and check return status
    unsigned int retries = 0;
    sg_replicator_->start();
    while (sg_replicator_->status().activity != kCBLReplicatorStopped && sg_replicator_->status().activity != kCBLReplicatorIdle) {
        ++retries;
        this_thread::sleep_for(REPLICATOR_RETRY_INTERVAL);
        if (sg_replicator_->status().error.code != 0) {
            if(is_retry_) {
                stopListening();
                return false;
            }
            stopListening();
            setMessageAndStatus(MessageType::Error, "Problem with start of replicator.");
            qCCritical(cb_browser_) << "Problem with start of replicator. Received replicator error code:" << sg_replicator_->status().error.code <<
                ", domain:" << sg_replicator_->status().error.domain << ", info:" << sg_replicator_->status().error.internal_info;
            return false;
        }
        if (retries >= REPLICATOR_RETRY_MAX) {
            stopListening();
            setMessageAndStatus(MessageType::Error, "Problem with start of replicator (out of retries).");
            qCCritical(cb_browser_) << "Problem with start of replicator (out of retries)";
            return false;
        }
    }

    if (config_mgr_) {
        vector<string> chan_strvec{};
        for (const auto &chan : channels) {
            chan_strvec.push_back(chan.toStdString());
        }
        config_mgr_->addRepToConfigDB(db_name_, url, username, rep_type, chan_strvec);
    }

    emit jsonConfigChanged();
    return true;
}

void DatabaseImpl::repStatusChanged(Replicator, const CBLReplicatorStatus &level)
{
    if (!sg_replicator_ || !isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to update status of replicator, but replicator is not running.";
        return;
    }

    // Check status for error, set retry flag
    if (sg_replicator_->status().error.code != 0) {
        qCCritical(cb_browser_) << "Received replicator error code:" << sg_replicator_->status().error.code <<
            ", domain:" << sg_replicator_->status().error.domain << ", info:" << sg_replicator_->status().error.internal_info;
        if (sg_replicator_->status().error.domain == 2 && sg_replicator_->status().error.code == 5) {
            is_retry_ = true;
            return;
        }
    }

    switch (level.activity) {
        case kCBLReplicatorStopped:
            activity_level_ = "Stopped";

            if (!manual_replicator_stop_) {
                setMessageAndStatus(MessageType::Error, "Problems connecting with replication service.");
            } else {
                setMessageAndStatus(MessageType::Success, "Successfully stopped replicator.");
            }

            manual_replicator_stop_ = false;
            sg_replicator_->stop();
            setRepstatus(false);
            break;
        case kCBLReplicatorIdle:
            activity_level_ = "Idle";
            setRepstatus(true);
            qCInfo(cb_browser_) << "Replicator activity level changed to 'Idle'";
            setMessageAndStatus(MessageType::Success, "Successfully received updates.");
            updateContents();
            break;
        case kCBLReplicatorBusy:
            activity_level_ = "Busy";
            setRepstatus(true);
            qCInfo(cb_browser_) << "Replicator activity level changed to 'Busy'";
            break;
        default:
            qCCritical(cb_browser_) << "Received unknown activity level.";
    }

    if (level.activity != kCBLReplicatorStopped && replicator_first_connection_) {
        setMessageAndStatus(MessageType::Success, "Successfully started replicator.");
    }

    replicator_first_connection_ = false;
    emit activityLevelChanged();
    emitUpdate();
}

void DatabaseImpl::editDoc(QString oldId, QString newId, QString body)
{
    if (!isDBOpen()) {
        setMessageAndStatus(MessageType::Error, "Attempted to edit document '" + oldId + "' but database is not open.");
        return;
    }

    if (oldId.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "Received empty existing document ID. Cannot edit.");
        return;
    }

    if (!docExistsInDB(oldId)) {
        setMessageAndStatus(MessageType::Error, "Document with ID = '" + oldId + "' does not exist. Cannot edit.");
        return;
    }

    if (!body.isEmpty()) {
        fleece::Doc fleece_doc = fleece::Doc::fromJSON(body.toStdString());
        if (!fleece_doc) {
            setMessageAndStatus(MessageType::Error, "Error editing document '" + oldId + "'. Verify the body is valid JSON.");
            return;
        }
    }

    oldId = oldId.simplified();
    newId = newId.simplified();

    if (newId.isEmpty() && body.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "Received empty new ID and body. Cannot edit.");
        return;
    }

    // Only need to edit body (no need to re-create document)
    if (newId.isEmpty() || newId == oldId) {
        MutableDocument doc = sg_db_->getMutableDocument(oldId.toStdString());
        doc.setPropertiesAsJSON(body.toStdString());
        sg_db_->saveDocument(doc);

        if (!getListenStatus()) {
            updateContents();
        }
    }
    // Other case: need to edit ID
    else {
        // If the given body is empty, use the body of the old document
        if (body.isEmpty()) {
            Document doc = sg_db_->getDocument(oldId.toStdString());
            body = QString::fromStdString(doc.propertiesAsJSON());
        }

        // Create new document with new ID and body, then delete old document
        createNewDoc(newId, body);
        if (current_status_ == MessageType::Error) {
            setMessageAndStatus(MessageType::Error, "Error editing document " + oldId + ".");
            return;
        }

        // Delete existing document with ID = OLD ID
        deleteDoc(oldId);
        if (current_status_ == MessageType::Error) {
            setMessageAndStatus(MessageType::Error, "Error editing document '" + oldId + "'.");
            return;
        }
    }

    if (newId.isEmpty() || newId == oldId) {
        setMessageAndStatus(MessageType::Success, "Successfully edited document '" + oldId + "'.");
    } else {
        if (!getListenStatus()) {
            setMessageAndStatus(MessageType::Success, "Successfully edited document (" + oldId + " -> " + newId + ").");
        } else {
            setMessageAndStatus(MessageType::Warning, "Successfully edited document (" + oldId + " -> " + newId + "). Local changes (document edition) may not reflect on remote server.");
        }
    }
}

void DatabaseImpl::deleteDoc(const QString &id)
{
    if (!isDBOpen()) {
        qCCritical(cb_browser_) << "Attempted to delete document " << id << " but database is not open.";
        return;
    }

    if (id.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "Received empty document ID, cannot delete.");
        return;
    }

    Document doc = sg_db_->getDocument(id.toStdString());

    if (!docExistsInDB(id)) {
        setMessageAndStatus(MessageType::Error, "Document with ID = '" + id + "' does not exist. Cannot delete.");
        return;
    }

    if (!doc.deleteDoc()) {
        setMessageAndStatus(MessageType::Error, "Error deleting document " + id + ".");
        return;
    }

    if (!getListenStatus()) {
        updateContents();
        setMessageAndStatus(MessageType::Success, "Successfully deleted document '" + id + "'.");
    } else {
        setMessageAndStatus(MessageType::Warning, "Successfully deleted document '" + id + "'. Local changes (document deletion) may not reflect on remote server.");
    }
}

void DatabaseImpl::saveAs(QString path, const QString &db_name)
{
    if (path.length() < 2 || db_name.isEmpty()) {
        setMessageAndStatus(MessageType::Error, "Received empty ID or path, unable to save.");
        return;
    }

    if (!isDBOpen()) {
        setMessageAndStatus(MessageType::Error, "Database must be open for it to be saved elsewhere.");
        return;
    }

    path.replace("file://","");
    qCInfo(cb_browser_) << "Attempting to save database '" << getDBName() << "' to path " << path << " and name '" << db_name << "'.";

    if ((QDir::separator() != '/') && path.startsWith('/')) {
        path.remove(0, 1);
    }

    path.replace("/", QDir::separator());
    QDir dir(path);
    path = dir.path() + QDir::separator();

    if (!dir.exists() || !dir.isAbsolute()) {
        setMessageAndStatus(MessageType::Error, "Received invalid path, unable to save.");
        return;
    }

    QString file_path = path + db_name + ".cblite2" + QDir::separator() + "db.sqlite3";
    QFileInfo file(file_path);

    if (file.exists()) {
        setMessageAndStatus(MessageType::Error, "Database '" + db_name + "' already exists in the selected location.");
        return;
    }

    QByteArray db_path_ba = db_path_.toLocal8Bit();
    const char *db_path_c = db_path_ba.data();
    CBLDatabaseConfiguration db_config = {db_path_c, kCBLDatabase_Create, nullptr};

    // Official CBL API: Database CTOR can throw so this is wrapped in try/catch
    unique_ptr<Database> temp_db;
    try {
        temp_db = make_unique<Database>(db_name.toLocal8Bit().data(), db_config);
    }
    catch (CBLError) {
        setMessageAndStatus(MessageType::Error, "Problem saving database.");
        return;
    }

    if (!temp_db->valid()) {
        setMessageAndStatus(MessageType::Error, "Problem saving database.");
        return;
    }

    for (const string &iter : document_keys_) {
        MutableDocument temp_doc(iter);
        Document existing_doc = sg_db_->getDocument(iter);
        temp_doc.setPropertiesAsJSON(existing_doc.propertiesAsJSON());
        temp_db->saveDocument(temp_doc);
    }

    if (config_mgr_) {
        path += QDir::separator() + db_name + ".cblite2" +  QDir::separator() + "db.sqlite3";
        config_mgr_->addDBToConfig(db_name, path);
        emit jsonConfigChanged();
    }

    setMessageAndStatus(MessageType::Success, "Saved database '" + db_name + "' successfully.");
}

bool DatabaseImpl::setDocumentKeys()
{
    document_keys_.clear();
    Query query(*sg_db_, kCBLN1QLLanguage, "SELECT _id");
    ResultSet results = query.execute();

    for (ResultSetIterator it = results.begin(); it != results.end(); ++it) {
        Result r = *it;
        fleece::slice value_sl = r.valueAtIndex(0).asString();
        document_keys_.push_back(string(value_sl));
    }

    return true;
}

void DatabaseImpl::setJSONResponse(vector<string> &docs)
{
    QJsonDocument document_json;
    QJsonObject total_json_message;

    for (const string &iter : docs) {
        Document doc = sg_db_.get()->getDocument(iter);
        fleece::Dict read_dict = doc.properties();
        document_json = QJsonDocument::fromJson(QByteArray::fromStdString(read_dict.toJSONString()));
        total_json_message.insert(QString::fromStdString(iter), document_json.object());
    }

    JsonDBContents_ = QJsonDocument(total_json_message).toJson();
}

void DatabaseImpl::setJSONResponse(const QString &response)
{
    JsonDBContents_ = response;
}

void DatabaseImpl::searchDocById(QString id)
{
    if (!isDBOpen()) {
        setMessageAndStatus(MessageType::Error, "Database must be open to search.");
        return;
    }

    // ID is empty, so return all documents as usual
    if (id.isEmpty()) {
        emitUpdate();
        setMessageAndStatus(MessageType::Success, "Empty document ID searched, showing all documents.");
        return;
    }

    vector<string> searchMatches{};
    id = id.simplified().toLower();

    for (const string &iter : document_keys_) {
        if (QString::fromStdString(iter).toLower().contains(id)) {
            searchMatches.push_back(iter);
        }
    }

    setJSONResponse(searchMatches);
    emit jsonDBContentsChanged();

    if (searchMatches.size() == 1) {
        setMessageAndStatus(MessageType::Success, "Found one document with ID containing '" + id + "'.");
        return;
    } else if (searchMatches.size() > 0) {
        setMessageAndStatus(MessageType::Success, "Found " + QString::number(searchMatches.size()) + " documents with ID containing '" + id + "'.");
        return;
    }

    setMessageAndStatus(MessageType::Success, "Found no documents containing ID = '" + id + "'.");
}

void DatabaseImpl::searchDocByChannel(const std::vector<QString> &channels)
{
    if (!getDBStatus()) {
        setMessageAndStatus(MessageType::Error,"Database must be open to change channel display.");
        return;
    }

    // No channels specified, so return all documents as usual
    if (channels.empty()) {
        toggled_channels_ = channels;
        emitUpdate();
        setMessageAndStatus(MessageType::Success, "Showing all documents.");
        return;
    }

    vector<string> channelMatches{};

    // Need to return a JSON response corresponding only to the channels requested
    for (const string &document_key : document_keys_) {
        Document doc = sg_db_->getDocument(document_key);
        QJsonDocument json_doc = QJsonDocument::fromJson(QByteArray::fromStdString(doc.propertiesAsJSON()));

        if (json_doc.isNull() || json_doc.isEmpty()) {
            qCCritical(cb_browser_) << "Received empty or invalid JSON message.";
            return;
        }

        QJsonObject db_entry_obj = json_doc.object();

        if (db_entry_obj.contains("channels")) {
            QJsonValue channels_val = db_entry_obj.value("channels");

            if (channels_val.isUndefined() || channels_val.isNull()) {
                continue;
            }

            if (channels_val.isString()) {
                QString channel = channels_val.toString();
                if (!channel.isEmpty()) {
                    if (find(channels.begin(), channels.end(), channel) != channels.end()) {
                        channelMatches.push_back(document_key);
                    }
                }
            } else if (channels_val.isArray()) {
                QJsonArray channels_arr = channels_val.toArray();
                for (const QJsonValue channel : channels_arr) {
                    if (find(channels.begin(), channels.end(), channel.toString()) != channels.end()) {
                        channelMatches.push_back(document_key);
                    }
                }
            } else {
                qCCritical(cb_browser_) << "Read 'channels' key of document " << QString::fromStdString(document_key) << ", but its value was not a string or array.";
            }
        }
    }

    toggled_channels_ = channels;
    setJSONResponse(channelMatches);
    emit jsonDBContentsChanged();
    setMessageAndStatus(MessageType::Success, "Successfully switched channel display.");
}

void DatabaseImpl::setDBstatus(const bool &status)
{
    if (db_is_running_ == status) {
        return;
    }

    db_is_running_ = status;
    emit dbStatusChanged();
}

void DatabaseImpl::setRepstatus(const bool &status)
{
    if (rep_is_running_ == status) {
        return;
    }

    rep_is_running_ = status;
    emit listenStatusChanged();
}

void DatabaseImpl::setDBName(const QString &db_name)
{
    if (db_name_ == db_name) {
        return;
    }

    db_name_ = db_name;
    emit dbNameChanged();
}

void DatabaseImpl::setMessageAndStatus(const MessageType &status, QString msg)
{
    if (msg.isEmpty()) {
        qCCritical(cb_browser_) << "The setMessageAndStatus function received an empty message.";
        return;
    }

    QJsonObject json_message;

    switch (status) {
        case MessageType::Error:
            current_status_ = MessageType::Error;
            json_message.insert("status", "error");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCCritical(cb_browser_) << "Emitted error message: " << msg;
            break;
        case MessageType::Success:
            current_status_ = MessageType::Success;
            json_message.insert("status", "success");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCInfo(cb_browser_) << "Emitted success message: " << msg;
            break;
        case MessageType::Warning:
            current_status_ = MessageType::Warning;
            json_message.insert("status", "warning");
            json_message.insert("msg", msg);
            message_ = QJsonDocument(json_message).toJson();
            qCWarning(cb_browser_) << "Emitted warning message: " << msg;
    }

    emit messageChanged();
}

void DatabaseImpl::setDBPath(const QString &db_path)
{
    db_path_ = db_path;
}

QString DatabaseImpl::getDBName() const
{
    return db_name_;
}

QString DatabaseImpl::getJsonDBContents() const
{
    return JsonDBContents_;
}

QString DatabaseImpl::getJsonConfig() const
{
    return config_mgr_ ? config_mgr_->getConfigJson() : "{}";
}

bool DatabaseImpl::getDBStatus() const
{
    return db_is_running_;
}

bool DatabaseImpl::getListenStatus() const
{
    return isDBOpen() && rep_is_running_;
}

void DatabaseImpl::setAllChannelsStr()
{
    QJsonObject json_message;
    QStringList listened_channels_copy = latest_replication_.channels;

    if (getListenStatus() && listened_channels_copy.empty() && !suggested_channels_.empty()) {
        listened_channels_copy << suggested_channels_;
    }

    // Add channels to the active channel list
    for (const QString &iter : listened_channels_copy) {
        json_message.insert(iter, "active");
    }

    // Add channels to the suggested channel list
    for (const QString &iter : suggested_channels_) {
        if (!listened_channels_copy.contains(iter)) {
            json_message.insert(iter, "suggested");
        }
    }

    JSONChannels_ = QJsonDocument(json_message).toJson();
    emit channelsChanged();
}

QString DatabaseImpl::getAllChannels() const
{
    return JSONChannels_;
}

QString DatabaseImpl::getMessage() const
{
    return message_;
}

QString DatabaseImpl::getActivityLevel() const
{
    return activity_level_;
}

MessageType DatabaseImpl::getCurrentStatus() const
{
    return current_status_;
}

bool DatabaseImpl::isDBOpen() const
{
    return sg_db_ && sg_db_->valid() && getDBStatus();
}

bool DatabaseImpl::docExistsInDB(const QString &doc_id) const
{
    if (!sg_db_ || doc_id.isEmpty()) {
        return false;
    }

    Query query(*sg_db_, kCBLN1QLLanguage, "SELECT _id WHERE _id = '" + doc_id.toUtf8() + "'");
    ResultSet results = query.execute();
    return results.begin() != results.end();
}

void DatabaseImpl::updateContents()
{
    getChannelSuggestions();
    setAllChannelsStr();
    searchDocByChannel(toggled_channels_);
}
