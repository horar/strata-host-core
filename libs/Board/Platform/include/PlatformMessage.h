#pragma once

#include <QObject>
#include <QSharedData>
#include <QByteArray>
#include <QString>

#include <rapidjson/document.h>

namespace strata::platform {

class PlatformMessageData;

class PlatformMessage
{
public:
    /**
     * Default constructor.
     */
    PlatformMessage();

    /**
     * PlatformMessage constructor (parses provided raw message to JSON).
     * @param rawMessage raw message from device
     */
    PlatformMessage(const QByteArray& rawMessage);

    /**
     * Copy constructor.
     * @param other existing PlatformMessage which will be copied into new one
     */
    PlatformMessage(const PlatformMessage& other);

    /**
     * Destructor.
     */
    ~PlatformMessage();

    /**
     * Getter for raw message.
     * @return raw message received from device
     */
    const QByteArray& raw() const;

    /**
     * Getter for JSON.
     * @return JSON parsed from raw message
     */
    const rapidjson::Document& json() const;

    /**
     * Check if PlatformMessage contains valid JSON.
     * @return true if JSON in PlatformMessage is valid, false otherwise
     */
    bool isJsonValid() const;

    /**
     * Check if PlatformMessage contains valid JSON object (Strata JSONs always contains object at top level).
     * @return true if JSON in PlatformMessage has valid JSON object, false otherwise
     */
    bool isJsonValidObject() const;

    /**
     * Getter for error string of JSON parsing.
     * @return error string if JSON parsing failed, empty (null) string otherwise
     */
    const QString& jsonErrorString() const;

    /**
     * Getter for offset of JSON parse error.
     * @return offset of JSON parse error (in raw message), 0 by default (but error can also occurs at offset 0)
     */
    ulong jsonErrorOffset() const;

private:
    QSharedDataPointer<PlatformMessageData> data_;
};

}  // namespace

Q_DECLARE_METATYPE(strata::platform::PlatformMessage);
