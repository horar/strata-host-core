
#include "PlatformDocument.h"
#include "logging/LoggingQtCategories.h"

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
        qCWarning(logCategoryHcsPlatformDocument) << "documents key does not exist in the platform document";
        return false;
    }
    rapidjson::Value& documents = class_doc["documents"];
    for(auto it = documents.MemberBegin(); it != documents.MemberEnd(); ++it) {
        name = it->name.GetString();
        rapidjson::Value& jsonFileList = documents[name.c_str()];
        if(jsonFileList.IsArray() == false){
            qCWarning(logCategoryHcsPlatformDocument) << "Encounter a non-array field under documents object";
            continue;
        }
        nameValueMapList list;
        createFilesList(jsonFileList, list);
        document_files_.insert( { name, list } );
    }

    // Platform selector
    if(class_doc.HasMember("platform_selector") == false){
        qCWarning(logCategoryHcsPlatformDocument) << "platform_selector does not exist in the platform document";
        return false;
    }
    rapidjson::Value& platform_selector = class_doc["platform_selector"];
    nameValueMap platform_image;
    if(createFileObject(platform_selector, platform_image)){
        // Although, platform_selector is an object we need to add it to list to be consistent
        nameValueMapList platform_image_list;
        platform_image_list.push_back(platform_image);
        document_files_.insert( { "platform_selector", platform_image_list } );
    }

    return true;
}

bool PlatformDocument::createFileObject(const rapidjson::Value& jsonObject, nameValueMap& file)
{
    if(jsonObject.IsObject() == false){
        return false;
    }

    if (jsonObject.HasMember("file") == false ||
        jsonObject.HasMember("md5") == false  ||
        jsonObject.HasMember("name") == false ||
        jsonObject.HasMember("timestamp") == false){
        return false;
    }

    std::string value;
    value = jsonObject["file"].GetString();
    file.insert({ "file", value});

    value = jsonObject["md5"].GetString();
    file.insert({"md5", value});

    value = jsonObject["name"].GetString();
    file.insert({"name", value});

    value = jsonObject["timestamp"].GetString();
    file.insert({"timestamp", value});

    return true;
}

void PlatformDocument::createFilesList(const rapidjson::Value& jsonFileList, std::vector<nameValueMap>& filesList)
{
    for(auto it = jsonFileList.Begin(); it != jsonFileList.End(); ++it)
    {
        nameValueMap valuesMap;
        if(createFileObject(*it, valuesMap) == false){
            continue;
        }
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

