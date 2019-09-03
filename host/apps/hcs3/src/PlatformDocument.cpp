
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
    for(auto it = class_doc.MemberBegin(); it != class_doc.MemberEnd(); ++it) {
        name = it->name.GetString();

        rapidjson::Value& jsonFileList = document_[name.c_str()];

        nameValueMapList list;
        createFilesList(jsonFileList, list);

        document_files_.insert( { name, list } );
    }
    return true;
}

bool PlatformDocument::parsePlatformList(const std::string& document)
{
    rapidjson::Document class_doc;
    if (class_doc.Parse(document.c_str()).HasParseError()) {
        return false;
    }
    assert(class_doc.IsArray()); 
    std::string name = "image";
    for (rapidjson::Value::ValueIterator itr = class_doc.Begin(); itr != class_doc.End(); ++itr) {
        rapidjson::Value& attribute = *itr;
        assert(attribute.IsObject());
        rapidjson::Value& jsonFileList = attribute[name.c_str()];

        nameValueMapList list;
        createFilesList(jsonFileList, list);

        document_files_.insert( { name, list } );
    }
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

bool PlatformDocument::getImageFilesList(const std::string& groupName, stringVector& filesList)
{
    filesList.reserve(document_files_.count(groupName) );
    for (auto item =document_files_.equal_range(groupName).first; item !=document_files_.equal_range(groupName).second; ++item) {
        auto finder = (*item).second;
        for(const auto& items : item->second) {
            auto findIt = items.find("file");
            if (findIt != items.end()) {
                filesList.push_back( findIt->second );
            }
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

