/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include <Operations/PlatformValidation/BaseValidation.h>

#include <Commands/PlatformCommands.h>
#include <Commands/PlatformCommandConstants.h>

#include <QLatin1String>

#include "logging/LoggingQtCategories.h"

namespace strata::platform::validation {

using command::BasePlatformCommand;
using command::CommandResult;

BaseValidation::BaseValidation(const PlatformPtr& platform, Type type):
    type_(type),
    running_(false),
    fatalFailure_(false),
    platform_(platform)
{ }

BaseValidation::~BaseValidation()
{
    // TODO: if "lock" will be used, unlock it aslo here (to be sure)
    // platform_->unlockDevice(reinterpret_cast<quintptr>(this));
}

void BaseValidation::run()
{
    if (platform_.get() == nullptr) {
        QString errStr(QStringLiteral("Device is not set."));
        qCWarning(lcPlatformValidation) << errStr;
        emit validationStatus(Status::Error, errStr);
        finishValidation(false);
        return;
    }

    if (platform_->deviceConnected() == false) {
        QString errStr(QStringLiteral("Cannot run validation, device is not connected."));
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
        finishValidation(false);
        return;
    }

    if (running_) {
        QString errStr(QStringLiteral("The validation is already running."));
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
        finishValidation(false);
        return;
    }

    // TODO: if there will be need for "lock" implement it in same way as in 'PlatformOperations'

    for (auto it = commandList_.begin(); it != commandList_.end(); ++it) {
        command::BasePlatformCommand* cmd = (*it).command.get();
        cmd->enablePlatformValidation(true);
        connect(cmd, &BasePlatformCommand::finished, this, &BaseValidation::handleCommandFinished);
        connect(cmd, &BasePlatformCommand::validationFailure, this, &BaseValidation::handleValidationFailure);
        connect(cmd, &BasePlatformCommand::receivedNotification, this, &BaseValidation::handlePlatformNotification);

        it->notificationReceived = false;
    }
    currentCommand_ = commandList_.begin();
    fatalFailure_ = false;
    running_ = true;

    QMetaObject::invokeMethod(this, &BaseValidation::sendCommand, Qt::QueuedConnection);
}

Type BaseValidation::type() const
{
    return type_;
}

// This is only first iteration of command validation, as more validations (and functionality)
// will be required, add here more logic from 'BasePlatformOperation::handleCommandFinished' method.
void BaseValidation::handleCommandFinished(CommandResult result, int status)
{
    Q_UNUSED(status)

    if (running_ == false) {
        return;
    }
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    switch (result) {
    case CommandResult::Done :  // OK
        {
            bool success = currentCommand_->notificationCheck ? currentCommand_->notificationCheck() : true;
            if (success) {
                ++currentCommand_;  // move to next command
                if (currentCommand_ == commandList_.end()) {  // end of command list - finish validation
                    finishValidation(success);
                } else {
                    QMetaObject::invokeMethod(this, &BaseValidation::sendCommand, Qt::QueuedConnection);
                }
            } else {
                finishValidation(false);
            }
        }
        break;
    case CommandResult::Timeout :  // Expected notification was not received (or received notification was not OK).
        if (currentCommand_->notificationReceived && currentCommand_->notificationCheck) {
            emit validationStatus(Status::Plain, QStringLiteral("Checking last received notification."));
            currentCommand_->notificationCheck();
        }
        finishValidation(false);
        break;
    default :  // other results are failure
        finishValidation(false);
        break;
    }
}

void BaseValidation::handleValidationFailure(QString error, bool fatal) {
    Status status = Status::Warning;
    if (fatal) {
        fatalFailure_ = true;
        status = Status::Error;
    }
    emit validationStatus(status, error);
}

void BaseValidation::handlePlatformNotification(PlatformMessage message)
{
    if (currentCommand_ != commandList_.end()) {
        lastPlatformNotification_ = message;
        currentCommand_->notificationReceived = true;
    }
}

void BaseValidation::sendCommand()
{
    if (currentCommand_ != commandList_.end()) {
        emit validationStatus(Status::Plain, QStringLiteral("Validating '") + currentCommand_->command->name() + QStringLiteral("'."));
        // TODO: if there will be need for "lock" use 'reinterpret_cast<quintptr>(this)' as sendCommand parameter
        currentCommand_->command->sendCommand(0);
    }
}

void BaseValidation::finishValidation(bool success)
{
    for (auto it = commandList_.begin(); it != commandList_.end(); ++it) {
        disconnect((*it).command.get(), nullptr, this, nullptr);
    }
    currentCommand_ = commandList_.end();
    // TODO: if "lock" will be used, unlock it here
    // platform_->unlockDevice(reinterpret_cast<quintptr>(this));

    running_ = false;

    emit finished((fatalFailure_) ? false : success);
}

BaseValidation::CommandTest::CommandTest(CommandPtr&& platformCommand, const std::function<bool()>& notificationCheckFn)
    : command(std::move(platformCommand)),
      notificationCheck(notificationCheckFn),
      notificationReceived(false)
{ }

// *** helper functions for validations ***
QString BaseValidation::joinKeys(const QVector<const char*>& keys, const char* key) const
{
    QString result;
    for (QVector<const char*>::const_iterator it = keys.constBegin(); it != keys.constEnd(); ++it) {
        result.append(QChar('/'));
        result.append(*it);
    }
    if (key) {
        result.append(QChar('/'));
        result.append(key);
    }
    return result;
}

QString BaseValidation::missingKey(const QString& key) const
{
    return QStringLiteral("Missing '") + key + QStringLiteral("' key.");
}

QString BaseValidation::badKeyType(const QString& key, KeyType type) const
{
    QString result = QStringLiteral("Key '") + key + QStringLiteral("' is not ");
    switch (type) {
    case KeyType::Object :
        result += QStringLiteral("an object.");
        break;
    case KeyType::String :
        result += QStringLiteral("a string.");
        break;
    case KeyType::Integer :
        result += QStringLiteral("an integer.");
        break;
    case KeyType::Unsigned :
        result += QStringLiteral("an unsigned integer.");
        break;
    }
    return result;
}

QString BaseValidation::unsupportedValue(const QString& key, const QString& value) const
{
    QString result = QStringLiteral("Unsupported value of '") + key
                     + QStringLiteral("' key: '") + value + QStringLiteral("'.");
    if (value.isEmpty()) {
        result += QStringLiteral(" Value is empty.");
    }
    return result;
}

bool BaseValidation::checkKey(const rapidjson::Value& jsonObject, const char* key, KeyType type, const QVector<const char*>& jsonPath)
{
    if (jsonObject.HasMember(key) == false) {
        emit validationStatus(Status::Error, missingKey(joinKeys(jsonPath, key)));
        return false;
    }

    const rapidjson::Value& value = jsonObject[key];
    bool typeOk = false;

    switch (type) {
    case KeyType::Object :
        if (value.IsObject()) {
            typeOk = true;
        }
        break;
    case KeyType::String :
        if (value.IsString()) {
            typeOk = true;
        }
        break;
    case KeyType::Integer :
        if (value.IsInt64()) {
            typeOk = true;
        }
        break;
    case KeyType::Unsigned :
        if (value.IsUint64()) {
            typeOk = true;
        }
        break;
    }

    if (typeOk == false) {
        emit validationStatus(Status::Error, badKeyType(joinKeys(jsonPath, key), type));
        return false;
    }

    return true;
}

bool BaseValidation::generalNotificationCheck(const rapidjson::Document& json, const QString& commandName)
{
    using namespace strata::platform::command;

    QVector<const char*> jsonPath;  // successfuly checked JSON path

    // check "notification"
    if (checkKey(json, JSON_NOTIFICATION, KeyType::Object, jsonPath) == false) {
        return false;
    }
    const rapidjson::Value& notification = json[JSON_NOTIFICATION];
    jsonPath.append(JSON_NOTIFICATION);

    {  // check "value"
        if (checkKey(notification, JSON_VALUE, KeyType::String, jsonPath) == false) {
            return false;
        }
        const rapidjson::Value& value = notification[JSON_VALUE];
        QLatin1String notificationCommandName(value.GetString(), value.GetStringLength());
        if (notificationCommandName != commandName) {
            QString msg = QStringLiteral("Other command name (") + notificationCommandName
                          + QStringLiteral(") than expected (") + commandName + QStringLiteral(").");
            emit validationStatus(Status::Error, msg);
            return false;
        }
    }

    // check "payload"
    if (checkKey(notification, JSON_PAYLOAD, KeyType::Object, jsonPath) == false) {
        return false;
    }

    return true;
}
// *** end of helper functions for validations ***

}  // namespace
