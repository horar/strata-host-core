/**
******************************************************************************
* @file Flasher.h
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Flasher header file.
******************************************************************************
* @copyright Copyright 2018 On Semiconductor
*
* @internal
*
* @endinternal
*
* @ingroup driver
*/

#ifndef Flasher_H_
#define Flasher_H_

#include <string>
#include <vector>

#include "rapidjson/schema.h"
#include "rapidjson/document.h"


class Connector;


class Flasher
{
public:

    Flasher() = delete;
    explicit Flasher(Connector* s, const std::string &firmwareFilename);
    ~Flasher();

    Flasher(const Flasher&) = delete;
    Flasher& operator=(const Flasher&) = delete;

    bool flash();
    bool rollback();
    bool startApplication();

private:

    /*! Flasher isPlatfromConnected.
   * \brief Wait for a platfrom to be connected and send firmware_update command to the platfrom's firmware.
   * \return true on success, false otherwise.
   */
    bool isPlatfromConnected();

    bool processCommandFlashFirmware();
    bool processCommandRollbackFirmware();
    bool processCommandStartApplication();

    enum class RESPONSE_STATUS
    {
        NONE,
        NEXT_CHUNK,
        RESEND_CHUNK
    };

    bool writeCommandFlash();
    bool writeCommandRollback(Flasher::RESPONSE_STATUS status);
    bool writeCommandStartApplication();
    bool writeCommandReadFib();

    bool readAck(const std::string& ackName);
    bool readNotify(const std::string& notificationName, std::string& status);
    bool readNotifyRollback(const std::string& notificationName, std::string& status);

    bool verify() const;

    int32_t getFileChecksum(const std::string &filname) const;
    int32_t getFileSize(const std::string &fileName) const;

    static rapidjson::SchemaDocument createJsonSchema(const std::string& schema);
    static bool validateJsonMessage(const std::string& message, const rapidjson::SchemaDocument& schemaDocument, rapidjson::Document& document);

    static rapidjson::SchemaDocument ackJsonSchema;
    static rapidjson::SchemaDocument notifyJsonSchema;
    static rapidjson::SchemaDocument notifyRollbackJsonSchema;

    struct Chunk
    {
        int32_t number;

        enum class SIZE : uint32_t
        {
            DEFAULT = 256
        };
        std::vector<uint8_t> data;
    } chunk_;

    Connector* serial_;
    const std::string firmwareFilename_;
};

#endif
