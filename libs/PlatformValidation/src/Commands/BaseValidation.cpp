/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "BaseValidation.h"
#include "ValidationStatus.h"
#include "logging/LoggingQtCategories.h"

#include <PlatformCommands.h>
#include <PlatformCommandConstants.h>

#include <QLatin1String>

namespace strata::platform::validation {

using command::BasePlatformCommand;
using command::CommandResult;

BaseValidation::BaseValidation(const PlatformPtr& platform, const QString& name):
    running_(false),
    extraNotifications_(0),
    platform_(platform),
    name_(name),
    fatalFailure_(false),
    incomplete_(false),
    ignoreCmdRejected_(false),
    ignoreTimeout_(false),
    ignoreFaultyNotification_(false)
{ }

BaseValidation::~BaseValidation()
{
    // TODO: if "lock" will be used, unlock it aslo here (to be sure)
    // platform_->unlockDevice(reinterpret_cast<quintptr>(this));
}

void BaseValidation::run()
{
    if (platform_.get() == nullptr) {
        QString errStr(QStringLiteral("Device is not set"));
        qCWarning(lcPlatformValidation) << errStr;
        emit validationStatus(Status::Error, errStr);
        finishValidation(ValidationResult::Failed);
        return;
    }

    if (platform_->deviceConnected() == false) {
        QString errStr(QStringLiteral("Cannot run validation, device is not connected"));
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
        finishValidation(ValidationResult::Failed);
        return;
    }

    if (running_) {
        QString errStr(QStringLiteral("The validation is already running"));
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
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

    extraNotifications_ = 0;
    fatalFailure_ = false;
    incomplete_ = false;
    ignoreCmdRejected_ = false;
    ignoreTimeout_ = false;
    ignoreFaultyNotification_ = false;

    QString message = name_ + QStringLiteral(" is about to start");
    qCInfo(lcPlatformValidation) << platform_ << message;
    emit validationStatus(Status::Plain, message);

    running_ = true;

    if (commandList_.size() > 0) {
        QMetaObject::invokeMethod(this, &BaseValidation::sendCommand, Qt::QueuedConnection);
    } else {
        finishValidation(ValidationResult::Incomplete);
    }
}

// When more validations (and functionality) will be required,
// add here more logic from 'BasePlatformOperation::handleCommandFinished' method.
void BaseValidation::handleCommandFinished(CommandResult result, int status)
{
    Q_UNUSED(status)

    if (running_ == false) {
        return;
    }
    if (currentCommand_ == commandList_.end()) {
        return;
    }

    if (currentCommand_->afterAction) {
        currentCommand_->afterAction(result, status);  // this can modify result and status
    }
    // Note: If there will be skipped next command (incremented 'currentCommand_' iterator) in 'afterAction',
    // check for 'currentCommand_->notificationReceived' will be false because 'currentCommand_' iterator
    // now points to command which was not sent and none notification was received for it.

    switch (result) {
    // OK
    case CommandResult::Done :
        {
            ValidationResult outcome = ValidationResult::Passed;
            if (currentCommand_->notificationReceived && currentCommand_->notificationCheck) {
                outcome = currentCommand_->notificationCheck();
            }
            if (outcome == ValidationResult::Passed) {
                ++currentCommand_;  // move to next command
                if (currentCommand_ == commandList_.end()) {  // end of command list - finish validation
                    finishValidation(ValidationResult::Passed);
                } else {
                    QMetaObject::invokeMethod(this, &BaseValidation::sendCommand, Qt::QueuedConnection);
                }
            } else {
                finishValidation(outcome);
            }
        }
        break;

    // Retry
    case CommandResult::Retry :
        {
            QString message = QStringLiteral("No response to '") + currentCommand_->command->name()
                              + QStringLiteral("' (board is probably not ready yet), sending it again");
            qCInfo(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Info, message);
        }
        QMetaObject::invokeMethod(this, &BaseValidation::sendCommand, Qt::QueuedConnection);  // send same command again
        break;

    // Expected notification was not received (or received notification was not OK).
    default :
        if (currentCommand_->notificationReceived && currentCommand_->notificationCheck) {
            if (result == CommandResult::Timeout) {
                QString message(QStringLiteral("Checking last received notification"));
                qCInfo(lcPlatformValidation) << platform_ << message;
                emit validationStatus(Status::Plain, message);
            }
            currentCommand_->notificationCheck();
        } else {
            QString message = currentCommand_->command->name() + QStringLiteral(" failed");
            qCWarning(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Error, message);
        }
        finishValidation(ValidationResult::Failed);
        break;
    }
}

void BaseValidation::handleValidationFailure(QString error, command::ValidationFailure failure) {
    if (failure == command::ValidationFailure::UnexpectedNotification) {
        // ignore unexpected notifications for sent command
        ++extraNotifications_;
        return;
    }

    if (ignoreCmdRejected_ && (failure == command::ValidationFailure::CmdRejected)) {
        return;
    }
    if (ignoreTimeout_ && (failure == command::ValidationFailure::Timeout)) {
        return;
    }
    if (ignoreFaultyNotification_ && (failure == command::ValidationFailure::FaultyNotification)) {
        return;
    }

    Status status = Status::Warning;
    if (failure != command::ValidationFailure::Warning) {
        // all other validation failures here except 'Warning' are fatal
        fatalFailure_ = true;
        status = Status::Error;
    }

    qCWarning(lcPlatformValidation) << platform_ << error;
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
        if (currentCommand_->command->type() != command::CommandType::Wait) {
            QString message(QStringLiteral("Validating '") + currentCommand_->command->name() + '\'');
            qCInfo(lcPlatformValidation) << platform_ << message;
            emit validationStatus(Status::Plain, message);
        }

        if (currentCommand_->beforeAction) {
            currentCommand_->beforeAction();
        }
        // TODO: if there will be need for "lock" use 'reinterpret_cast<quintptr>(this)' as sendCommand parameter
        currentCommand_->command->sendCommand(0);
    }
}

void BaseValidation::finishValidation(ValidationResult result)
{
    for (auto it = commandList_.begin(); it != commandList_.end(); ++it) {
        disconnect((*it).command.get(), nullptr, this, nullptr);
    }
    currentCommand_ = commandList_.end();
    // TODO: if "lock" will be used, unlock it here
    // platform_->unlockDevice(reinterpret_cast<quintptr>(this));

    running_ = false;

    if (extraNotifications_ > 0) {
        QString message = QStringLiteral("Count of received notifications that did not belong to the sent commnads: ")
                          + QString::number(extraNotifications_);
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Info, message);
    }

    if (result != ValidationResult::Failed) {
        if (fatalFailure_) {
            result = ValidationResult::Failed;
        } else if (incomplete_) {
            result = ValidationResult::Incomplete;
        }
    }

    QString message = name_;
    switch (result) {
    case ValidationResult::Passed :
        message += QStringLiteral(" PASS");
        qCInfo(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Success, message);
        break;
    case ValidationResult::Incomplete :
        message += QStringLiteral(" INCOMPLETE");
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Warning, message);
        break;
    case ValidationResult::Failed :
        message += QStringLiteral(" FAIL");
        qCWarning(lcPlatformValidation) << platform_ << message;
        emit validationStatus(Status::Error, message);
        break;
    }

    emit finished();
}

BaseValidation::CommandTest::CommandTest(CommandPtr&& platformCommand,
                                         const std::function<void()>& beforeFn,
                                         const std::function<void(command::CommandResult&, int&)>& afterFn,
                                         const std::function<ValidationResult()>& notificationCheckFn)
    : command(std::move(platformCommand)),
      beforeAction(beforeFn),
      afterAction(afterFn),
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
    return QStringLiteral("Missing '") + key + QStringLiteral("' key");
}

QString BaseValidation::badKeyType(const QString& key, KeyType type) const
{
    QString result = QStringLiteral("Key '") + key + QStringLiteral("' is not ");
    switch (type) {
    case KeyType::Object :
        result += QStringLiteral("an object");
        break;
    case KeyType::String :
        result += QStringLiteral("a string");
        break;
    case KeyType::Integer :
        result += QStringLiteral("an 32-bit integer");
        break;
    case KeyType::Integer64 :
        result += QStringLiteral("an 64-bit integer");
        break;
    case KeyType::Unsigned :
        result += QStringLiteral("an 32-bit unsigned integer");
        break;
    case KeyType::Unsigned64 :
        result += QStringLiteral("an 64-bit unsigned integer");
        break;
    }
    return result;
}

QString BaseValidation::unsupportedValue(const QString& key, const QString& value, bool unexpected) const
{
    QString result = (unexpected) ? QStringLiteral("Unexpected") : QStringLiteral("Unsupported");
    result += QStringLiteral(" value of '") + key + QStringLiteral("' key: '") + value + '\'';
    if (value.isEmpty()) {
        result += QStringLiteral(" Value is empty");
    }
    return result;
}

bool BaseValidation::checkKey(const rapidjson::Value& jsonObject, const char* key, KeyType type, const QVector<const char*>& jsonPath)
{
    if (jsonObject.HasMember(key) == false) {
        QString errStr = missingKey(joinKeys(jsonPath, key));
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
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
        if (value.IsInt()) {
            typeOk = true;
        }
        break;
    case KeyType::Integer64 :
        if (value.IsInt64()) {
            typeOk = true;
        }
        break;
    case KeyType::Unsigned :
        if (value.IsUint()) {
            typeOk = true;
        }
        break;
    case KeyType::Unsigned64 :
        if (value.IsUint64()) {
            typeOk = true;
        }
        break;
    }

    if (typeOk == false) {
        QString errStr = badKeyType(joinKeys(jsonPath, key), type);
        qCWarning(lcPlatformValidation) << platform_ << errStr;
        emit validationStatus(Status::Error, errStr);
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
            QString errStr = QStringLiteral("Other command name: '") + notificationCommandName
                             + QStringLiteral("' than expected: '") + commandName + '\'';
            qCWarning(lcPlatformValidation) << platform_ << errStr;
            emit validationStatus(Status::Error, errStr);
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
