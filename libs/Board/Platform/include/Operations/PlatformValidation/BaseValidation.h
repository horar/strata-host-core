/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <functional>
#include <vector>

#include <QObject>
#include <QString>
#include <QVector>

#include <Platform.h>
#include <PlatformMessage.h>

namespace strata::platform::command {

class BasePlatformCommand;
enum class CommandResult : int;
enum class ValidationFailure : int;

}

namespace strata::platform::validation {

Q_NAMESPACE

enum class Type : int {
    Identification,
    BtldrAppPresence
};

enum class Status : int {
    Plain,
    Info,
    Warning,
    Error,
    Success
};
Q_ENUM_NS(Status)

class BaseValidation : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(BaseValidation)

protected:
    /*!
     * BaseValidation constructor.
     * \param platform platform which will be used for platform validation
     * \param type type of validation (value from Type enum)
     */
    BaseValidation(const PlatformPtr& platform, Type type, const QString& name);

    enum class ValidationResult : int {
        Passed,
        Incomplete,
        Failed
    };

public:
    /*!
     * BaseValidation destructor.
     */
    virtual ~BaseValidation();

    /*!
     * Run validation.
     */
    virtual void run();

    /*!
     * Get type of validation.
     * \return validation type (value from enum Type)
     */
    virtual Type type() const final;

    /*!
     * Get validation name.
     * \return validation name
     */
    virtual QString name() const final;

signals:
    /*!
     * This signal is emitted when platform validation finishes.
     */
    void finished();

    /*!
     * This signal is emitted when some warning occurs during platform validation.
     * \param description - contains description of had happened during validation
     */
    void validationStatus(strata::platform::validation::Status status, QString description);

private slots:
    void handleCommandFinished(command::CommandResult result, int status);
    void handleValidationFailure(QString error, command::ValidationFailure failure);
    void handlePlatformNotification(strata::platform::PlatformMessage message);

private:
    void sendCommand();
    void finishValidation(ValidationResult result);

    const Type type_;
    bool running_;

protected:
    PlatformPtr platform_;
    const QString name_;

    // helper variables for determining the validation result
    bool fatalFailure_;  // if set to true, validation failed
    bool incomplete_;    // if set to true, validation is incomplete

    bool ignoreCmdRejected_;
    bool ignoreTimeout_;

    PlatformMessage lastPlatformNotification_;

    typedef std::unique_ptr<command::BasePlatformCommand> CommandPtr;

    struct CommandTest {
        CommandTest(CommandPtr&& platformCommand,
                    const std::function<void()>& beforeFn,
                    const std::function<void(command::CommandResult&, int&)>& afterFn,
                    const std::function<ValidationResult()>& notificationCheckFn);
        CommandPtr command;
        std::function<void()> beforeAction;
        std::function<void(command::CommandResult&, int&)> afterAction;
        std::function<ValidationResult()> notificationCheck;
        bool notificationReceived;
    };

    std::vector<CommandTest> commandList_;
    std::vector<CommandTest>::iterator currentCommand_;

    // *** helper functions for validations ***
    enum class KeyType {
        Object,
        String,
        Integer,
        Unsigned
    };
    /*!
     * Joins keys to string as "/key1/key2/key3".
     * \param keys - QVector containing keys which will be join
     * \param key - this key will be joined to keys in QVector (if not nullptr)
     * \return string containig joined keys
     */
    QString joinKeys(const QVector<const char*>& keys, const char* key = nullptr) const;
    /*!
     * \param key - JSON document key (use 'joinKeys' method to create it)
     * \return string with message about missing key
     */
    QString missingKey(const QString& key) const;
    /*!
     * \param key - JSON document key (use 'joinKeys' method to create it)
     * \param type - correct type for given key (value from 'KeyType' enum)
     * \return string with message about bad key type
     */
    QString badKeyType(const QString& key, KeyType type) const;
    /*!
     * \param key - JSON document key (use 'joinKeys' method to create it)
     * \param value - actual value of key (converted to string)
     * \return string with message about unsuported value for key
     */
    QString unsupportedValue(const QString& key, const QString& value) const;
    /*!
     * Check if given key exists and has correct type.
     * \param jsonObject - JSON object where the key should be located
     * \param key - key which will be checked
     * \param type - type of key (value from 'KeyType' enum)
     * \param keyPath - full path to jsonObject (array of keys from document root) - used for generating error strings
     * \return true if key exists and has correct type, otherwise false
     */
    bool checkKey(const rapidjson::Value& jsonObject, const char* key, KeyType type, const QVector<const char*>& keyPath);
    /*!
     * Check if notification has all fields which every notification must have.
     * \param json - JSON document with notification
     * \param commandName - name of command which must notification contain
     * \return true if notification contains all mandatory fields, otherwise false
     */
    bool generalNotificationCheck(const rapidjson::Document& json, const QString& commandName);
    // *** end of helper functions for validations ***
};

}  // namespace
