#include "command-validator-test.h"

#include "CommandValidator.h"
#include <rapidjson/writer.h>


void CommandValidatorTest::printJsonDoc(rapidjson::Document &doc)    {
    // print the doc
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    std::cout << buffer.GetString() << std::endl;
}

void CommandValidatorTest::SetUp()
{
}

void CommandValidatorTest::TearDown()
{
}

TEST_F(CommandValidatorTest, updateFWResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"update_firmware",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::updateFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"update_firmware",
                "payload":{
                    "status":"failed"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::updateFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"update_firmware",
                "payload":{
                    "status":"invalid FIB state"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::parseJson(testCommand, doc));
    EXPECT_TRUE(CommandValidator::validate(CommandValidator::JsonType::updateFwRes, doc));


    // Invalid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"update_firm",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::updateFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"update_firmware",
                "payload":{
                    "status": 56465
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::updateFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"update_firmware",
                "payload":{
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::updateFwRes, doc));
}

TEST_F(CommandValidatorTest, flashFWResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::flashFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status":"some error"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::flashFwRes, doc));

    // Invalid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmre",
                "payload":{
                    "status":"ok"
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::flashFwRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::flashFwRes, doc));

        testCommand = R"(
        {
            "notification":{
                "value":"flash_firmware",
                "payload":{
                    "status": -1
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::flashFwRes, doc));
}

TEST_F(CommandValidatorTest, getFWInfoResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"158.58.54",
                        "date":"2018-04-01",
                        "checksum": "dsfdsf"
                    },
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": 232332
                    }
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {},
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": 232332
                    }
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"158.58.54",
                        "date":"2018-04-01",
                        "checksum": "dsfdsf"
                    },
                    "application": {}
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));

    // Invalid test commands
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version": 1.1.1,
                        "date":"2018-4-1",
                        "checksum": ""
                    },
                    "application": {
                        "version":"1.1.1",
                        "date":"2018-04-01",
                        "checksum": ""
                    }
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));

    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {
                        "version":"a.a.a",
                        "date": 20180410,
                        "checksum": ""
                    },
                    "application": {
                        "version":"213",
                        "date":"2018-04-01",
                        "checksum": ""
                    }
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));

// This JSON is not valid, but schema does not covers this situation (empty application and bootloader).
/*
    testCommand = R"(
        {
            "notification": {
                "value":"get_firmware_info",
                "payload": {
                    "bootloader": {},
                    "application": {}
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::getFwInfoRes, doc));
*/
}

TEST_F(CommandValidatorTest, setPlatformIdResTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid testing commands
    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{
                    "status": "OK"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::setPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{
                    "status": "Else"
                }
            }
        })";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::setPlatIdRes, doc));

    // Invalid testing commands
    testCommand = R"(
        {
            "notification":{
                "value":"set_plat",
                "payload":{
                    "status": "OK"
                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::setPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"set_platform_id",
                "payload":{

                }
            }
        })";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::setPlatIdRes, doc));
}

TEST_F(CommandValidatorTest, notificationTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"Hello Strata","platform_id":"126","class_id":"226","count":0,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"notification":{"value":"pot"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));

    testCommand = R"({"value":"pot","payload":{"volts":2.83,"bits":3220}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::notification, doc));
}

TEST_F(CommandValidatorTest, ackTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid testing commands
    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id"})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::ack, doc));
}

TEST_F(CommandValidatorTest, sampleTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id": 101,
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));
}

TEST_F(CommandValidatorTest, requestPlatorfmIdResponseTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":"1",
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    testCommand = R"(
        {
            "notification": {
                "value": "platform_id",
                "payload": {
                    "verbose_name": "Motor Controller Evaluation Board",
                    "platform_id": "P2.2018.004.1.1.0.1.20180425112233.cbde0519-0f42-4431-a379-caee4a1494af",
                    "firmware_version": "0.1.20180425112233"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                        "verbose_name":"ON WaterHeater",
                        "verbose_name_error":"error_data_corrupted",
                        "platform_id":"SEC.2018.0.0.0.0.00000000-0000-0000-0000-000000000000",
                        "platform_id_error":"not_flashed"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    // Invalid test command
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":101,
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::reqPlatIdRes, doc));
}

TEST_F(CommandValidatorTest, isValidJsonTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::isValidJson(testCommand));
    EXPECT_TRUE(CommandValidator::parseJson(testCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{}
            }
        }
    )";
    EXPECT_TRUE(CommandValidator::isValidJson(testCommand));
    EXPECT_TRUE(CommandValidator::parseJson(testCommand, doc));

    // Invalid test command
    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"10a",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0"
                }
        }
    )";
    EXPECT_FALSE(CommandValidator::isValidJson(testCommand));
    EXPECT_FALSE(CommandValidator::parseJson(testCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform_id",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":101,
                    "class_id":"201",
                    "count":1,
                    "platform_id_version"
                }
            }
        }
    )";
    EXPECT_FALSE(CommandValidator::isValidJson(testCommand));
    EXPECT_FALSE(CommandValidator::parseJson(testCommand, doc));

    testCommand = R"(
        {
            "notification":{
                "value":"platform",
                "payload":{
                    "name":"WaterHeater",
                    "platform_id":"101",
                    "class_id":"201",
                    "count":1,
                    "platform_id_version":"2.0",
                }
            }
        }
    )";
    EXPECT_FALSE(CommandValidator::isValidJson(testCommand));
    EXPECT_FALSE(CommandValidator::parseJson(testCommand, doc));
}

TEST_F(CommandValidatorTest, isValidCmdTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // valid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":{"a":1, "b":0, "c":1}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::cmd, doc));

    testCommand = R"({"cmd":"nl7sz58_nand"})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::cmd, doc));

    // Invalid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":["a", "b", "c"]})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::cmd, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":"string"})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::cmd, doc));

    testCommand = R"("cmd":{"nl7sz58_nand":6})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::cmd, doc));
}

TEST_F(CommandValidatorTest, isValidStrataCommandTest)
{
    std::string testCommand;
    rapidjson::Document doc;

    // Valid test commands
    testCommand = R"({"notification": {"value":"get_firmware_info","payload": {"bootloader": {"version":"158.58.54","build-date":"2018-04-01","checksum": "dsfdsf"},"application": {"version":"1.1.1","build-date":"2018-04-01","checksum": 232332}}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"Hello Strata","platform_id":"126","class_id":"226","count":0,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"pot","payload":{"volts":2.83}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"flash_firmware","payload":{"status":"ok"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"flash_firmware","payload":{"status":"some error"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":true,"return_string":"command valid"}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"update_firmware","payload":{"status":"ok"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"update_firmware","payload":{"status":"failed"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"update_firmware","payload":{"status":"invalid FIB state"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"verbose_name":"ON WaterHeater","verbose_name_error":"error_data_corrupted","platform_id":"SEC.2018.0.0.0.0.00000000-0000-0000-0000-000000000000","platform_id_error":"not_flashed"}}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":{"a":1, "b":0, "c":1}})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"cmd":"nl7sz58_nand"})";
    EXPECT_TRUE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    // Invalid test commands
    testCommand = R"({"cmd":"nl7sz58_write_io","payload":["a", "b", "c"]})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"cmd":"nl7sz58_write_io","payload":"string"})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"("cmd":{"nl7sz58_nand":6})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification": {"value":"get_firmware_info","payload": {"bootloader": {"version": 1.1.1,"build-date":"2018-4-1","checksum": ""},"application": {"version":"1.1.1","build-date":"2018-04-01","checksum": ""}}}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":"10a","class_id":"201","count":1,"platform_id_version":"2.0"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"platform_id","payload":{"name":"WaterHeater","platform_id":101,"class_id":"201","count":1,"platform_id_version"}}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"platform","payload":{"name":"WaterHeater","platform_id":"101","class_id":"201","count":1,"platform_id_version":"2.0",}}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({  "notification":{  "value":"platform_id","payload":{  "name":"WaterHeater","platform_id":101,"class_id":"201","count":1,"platform_id_version":"2.0"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"payload":{"volts":2.83,"bits":3220}}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"notification":{"value":"pot"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"value":"pot","payload":{"volts":2.83,"bits":3220}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id"})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));

    testCommand = R"({"ack":"request_platform_id","payload":{"return_value":"true","return_string":"command valid"}})";
    EXPECT_FALSE(CommandValidator::validate(testCommand, CommandValidator::JsonType::strataCmd, doc));
}
