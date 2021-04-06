#include "CouchChat.h"
#include "Database/CouchbaseDocument.h"
#include "../src/CouchbaseDatabase.h"

#include <QDebug>
#include <thread>

using namespace strata::Database;

CouchChat::CouchChat(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent) {
    engine_ = engine;
    auto documentListenerCallback = std::bind(&CouchChat::documentListener, this, std::placeholders::_1, std::placeholders::_2);

    databaseManager_ = std::make_unique<DatabaseManager>();
    if (databaseManager_->init("", endpointURL_, nullptr, documentListenerCallback) == false) {
        qDebug() << "Error with initialization of database manager. Verify endpoint URL" << endpointURL_ << "is valid.";
    }
}

void CouchChat::login(const QString &loginUsername, const QString &desiredChatroom) {
    auto documentListenerCallback = std::bind(&CouchChat::documentListener, this, std::placeholders::_1, std::placeholders::_2);
    DB_ = databaseManager_->login(loginUsername, desiredChatroom, nullptr, documentListenerCallback);

    loginUsername_ = loginUsername;
    channelName_ = desiredChatroom;
    usernameChanged();
    channelChanged();
}

void CouchChat::logout() {
    loginUsername_ = "";
    channelName_ = "";
    DB_->close();
    delete DB_;
}

void CouchChat::sendMessage(const QString &message) {
    if (DB_ == nullptr) {
        return;
    }

    CouchbaseDocument Doc("CouchChat_Message");

    QString body_string("{\"msg\":\"" + message + "\","
        + "\"user\":\"" + loginUsername_  + "\","
        + "\"channels_available\":[\"" + channelName_  + "\"]"
        + "}");

    if (Doc.setBody(body_string)) {
        qDebug() << "Successfully set document contents.";
    } else {
        qDebug() << "Failed to set document contents, body must be in JSON format.";
        return;
    }

    if (DB_->write(&Doc, channelName_)) {
        qDebug() << "Successfully saved to database document with msg:" << message;
    } else {
        qDebug() << "Error saving database.";
        return;
    }
}

void CouchChat::documentListener(bool isPush, const std::vector<DatabaseAccess::ReplicatedDocument, std::allocator<DatabaseAccess::ReplicatedDocument>> documents) {
    qDebug() << "---" << documents.size() << "docs" << (isPush ? "pushed:" : "pulled:");
    if (DB_ == nullptr) {
        return;
    }
    if (documents.size() == 2 && (documents[0].id == documents[1].id)) {
        qDebug() << documents[0].id;
        auto result_obj = DB_->getDocumentAsJsonObj(documents[0].id, channelName_);
        auto user = result_obj.value("user");
        auto msg = result_obj.value("msg");
        emit receivedMessage(user.toString(), msg.toString());
    } else for (unsigned i = 0; i < documents.size(); ++i) {
        qDebug() << documents[i].id;
        auto result_obj = DB_->getDocumentAsJsonObj(documents[i].id, channelName_);
        auto user = result_obj.value("user");
        auto msg = result_obj.value("msg");
        emit receivedMessage(user.toString(), msg.toString());
    }
}

QString CouchChat::getLoginUsername() const {
    return loginUsername_;
}

QString CouchChat::getChannel() const {
    return channelName_;
}

QStringList CouchChat::getAllDocumentIDs() {
    if (DB_) {
        return DB_->getDatabaseAsJsonObj().keys();
    } else {
        return QStringList();
    }
}

QStringList CouchChat::readChannelsAccessGrantedOfUser(const QString &loginUsername) {
    if (databaseManager_) {
        return databaseManager_->readChannelsAccessGrantedOfUser(loginUsername);
    } else {
        return QStringList();
    }
}
