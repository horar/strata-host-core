/**
******************************************************************************
* @file Flasher.h
* @author Luay Alshawi
* $Rev: 1 $
* $Date: 2018-06-13 17:46:28 +0100 (Wed, 23 June 2018) $
* @brief Flasher header file.
******************************************************************************
* @copyright Copyright 2018 ON Semiconductor
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

#include <rapidjson/schema.h>
#include <rapidjson/document.h>
#include <PlatformManager.h>
#include <PlatformConnection.h>


class Flasher
{
public:

    Flasher();

    /*!
     * Ctor
     * \param connector - serial connector
     * \param firmwareFilename - filename of new image to flash
     */
    Flasher(spyglass::PlatformConnectionShPtr connector, const std::string& firmwareFilename);
    virtual ~Flasher();


    Flasher(const Flasher&) = delete;
    Flasher& operator=(const Flasher&) = delete;

    /*!
     * The method sets serial connector.
     */
    void setConnector(spyglass::PlatformConnectionShPtr connector);

    /*!
     * The method sets filename of new image to flash.
     */
    void setFirmwareFilename(const std::string& firmwareFilename);

    /*!
     * The method checks whether bootloader is ready or tries to initialize it.
     * @return returns true when device is in bootloader mode otherwise false
     */
    bool initializeBootloader();

    /*!
     * Sets output stream for commands send/recv. For debugging purposes
     * @param output output stream
     */
    void setCommunicationMsgStream(std::ostream* output);

    /*!
     * The method flashes an image from the file firmwareFilename over connector, downloads the currently flashed image,
     * compare orig. image with downloaded image and start the image/application if it is requested.
     */
    bool flash(const bool forceStartApplication);

    /*!
     * The method downloads an current image from a device fo file firmwareFilename.rb
     */
    bool backup();

    /*!
     * The method start an image/application if it is valid.
     */
    bool startApplication();

private:
    enum ResponseState {
        eWaitForAck = 0,
        eWaitForNotify,
    };

    /*!
     * \brief Wait for a platform to be connected and send firmware_update command to the platform's firmware.
     * \return true on success, false otherwise.
     */
    bool waitForPlatformConnected(std::string &verbose_name);

    bool processCommandFlashFirmware();
    bool processCommandBackupFirmware();
    bool processCommandStartApplication();
    bool processCommandUpdateFirmware();

    const static int RESPONSE_STATUS_MAX_ERRORS = 10;

    enum class RESPONSE_STATUS
    {
        NONE,
        NEXT_CHUNK,
        RESEND_CHUNK
    };

    bool sendCommand(const std::string& cmd);
    bool writeCommandFlash();
    bool writeCommandBackup(Flasher::RESPONSE_STATUS status);
    bool writeCommandStartApplication();
    bool writeCommandReadFib();

    bool readAck(const std::string& ackName);
    bool readNotify(const std::string& notificationName);
    bool readNotifySimple(const std::string& notificationName, rapidjson::Value& payload);
    bool readNotifyBackup(const std::string& notificationName);

    bool verify() const;

    static int32_t getFileChecksum(const std::string &fileName);
    static int32_t getFileSize(const std::string &fileName);

    static rapidjson::SchemaDocument createJsonSchema(const std::string& schema);
    static bool validateJsonMessage(const std::string& message, const rapidjson::SchemaDocument& schemaDocument, rapidjson::Document& document);

    static rapidjson::SchemaDocument ackJsonSchema;
    static rapidjson::SchemaDocument notifySimpleJsonSchema;
    static rapidjson::SchemaDocument notifyJsonSchema;
    static rapidjson::SchemaDocument notifyBackupJsonSchema;

    struct Chunk
    {
        int32_t number;

        enum class SIZE : uint32_t
        {
            DEFAULT = 256
        };
        std::vector<uint8_t> data;
    };

    Chunk flashChunk_;
    Chunk backupChunk_;

    spyglass::PlatformConnectionShPtr serial_;
    spyglass::PauseConnectionListenerGuard serial_listener_guard_;

    std::string firmwareFilename_;
    std::ostream* dbg_out_stream_;
};

#endif
