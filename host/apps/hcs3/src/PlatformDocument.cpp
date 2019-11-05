
#include "PlatformDocument.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <vector>

PlatformDocument::PlatformDocument(const std::string& classId, const std::string& revision)
        : classId_(classId), revision_(revision)
{
}

bool PlatformDocument::parseDocument(const std::string& document)
{
    rapidjson::Document class_doc;
    if (class_doc.Parse(document.c_str()).HasParseError()) {
        return false;
    }
    //TODO: check for validity

    document_.CopyFrom(class_doc, document_.GetAllocator());

    std::string name;

    // Documents
    if(class_doc.HasMember("documents") == false){
        printf("!HasMember documents\n");
        return false;
    }
    rapidjson::Value& documents = class_doc["documents"];
    for(auto it = documents.MemberBegin(); it != documents.MemberEnd(); ++it) {
        name = it->name.GetString();
        rapidjson::Value& jsonFileList = documents[name.c_str()];
        if(jsonFileList.IsArray() == false){
            continue;
        }
        nameValueMapList list;
        createFilesList(jsonFileList, list);
        document_files_.insert( { name, list } );
    }

    // Platform selector
    if(class_doc.HasMember("platform_selector") == false){
        printf("!HasMember platform_selector\n");
        return false;
    }
    rapidjson::Value& platform_selector = class_doc["platform_selector"];
    nameValueMapList platform_image;
    createFilesList(platform_selector, platform_image);
    document_files_.insert( { "platform_selector", platform_image } );

    return true;
}

void PlatformDocument::createFilesList(const rapidjson::Value& jsonFileList, std::vector<nameValueMap>& filesList)
{
    if(jsonFileList.IsArray()) {
        for(auto it = jsonFileList.Begin(); it != jsonFileList.End(); ++it)
        {
            nameValueMap valuesMap;

            std::string value;
            value = (*it)["file"].GetString();
            valuesMap.insert({ "file", value});

            value = (*it)["md5"].GetString();
            valuesMap.insert({"md5", value});

            value = (*it)["name"].GetString();
            valuesMap.insert({"name", value});

            value = (*it)["timestamp"].GetString();
            valuesMap.insert({"timestamp", value});

            filesList.push_back(valuesMap);
        }
    } else {
        nameValueMap valuesMap;

        std::string value;
        value = jsonFileList["file"].GetString();
        valuesMap.insert({ "file", value});

        value = jsonFileList["md5"].GetString();
        valuesMap.insert({"md5", value});

        value = jsonFileList["name"].GetString();
        valuesMap.insert({"name", value});

        value = jsonFileList["timestamp"].GetString();
        valuesMap.insert({"timestamp", value});

        filesList.push_back(valuesMap);
    }
}

bool PlatformDocument::getDocumentFilesList(const std::string& groupName, stringVector& filesList)
{
    auto groupIt = document_files_.find(groupName);
    if (groupIt == document_files_.end()) {
        return false;
    }

    filesList.reserve(groupIt->second.size() );
    for(const auto& item : groupIt->second) {
        auto findIt = item.find("file");
        if (findIt != item.end()) {
            filesList.push_back( findIt->second );
        }
    }
    return true;
}

PlatformDocument::nameValueMap PlatformDocument::findElementByFile(const std::string& file, const std::string& groupName)
{
    auto groupIt = document_files_.find(groupName);
    if (groupIt == document_files_.end()) {
        return nameValueMap();
    }

    for(const auto& item : groupIt->second) {
        auto findIt = item.find("file");
        if (findIt != item.end() && findIt->second == file) {
            return item;
        }
    }

    return nameValueMap();
}

