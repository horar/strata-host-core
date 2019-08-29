
#include "PlatformDocument.h"

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>

#include <vector>
#include "logging/LoggingQtCategories.h"

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
    document_.CopyFrom(class_doc, document_.GetAllocator());
    std::string name;
    int i = 0;
    for (rapidjson::Value::ValueIterator itr = class_doc.Begin(); itr != class_doc.End(); ++itr) {
         rapidjson::Value& attribute = *itr;
        assert(attribute.IsObject());
        name = "image";//attribute["image"]["name"].GetString();
        rapidjson::Value& jsonFileList = attribute["image"];

        nameValueMapList list;
        createFilesList(jsonFileList, list);
        i++;
    qCInfo(logCategoryHcsStorage) << "*********";
    qCInfo(logCategoryHcsStorage) << "count "<<i;
    qCInfo(logCategoryHcsStorage) << "*********";
        document_files_.insert( { name, list } );
        for(const auto& items : list) {
            qCInfo(logCategoryHcsStorage) << "Inside set and its size is "<<items.size();
            auto findIt = items.find("file");
            if (findIt != items.end()) {
                // filesList.push_back( findIt->second );
                qCInfo(logCategoryHcsStorage) << "Inside set and its value is "<<findIt->second.c_str();
            }
        }
    }
    qCInfo(logCategoryHcsStorage) << "document files size "<<document_files_.size();
    return true;
}

void PlatformDocument::createFilesList(const rapidjson::Value& jsonFileList, std::vector<nameValueMap>& filesList)
{
    // assert(jsonFileList.IsArray()); 
    if(jsonFileList.IsArray()) {
        for(auto it = jsonFileList.Begin(); it != jsonFileList.End(); ++it)
        {
            qCInfo(logCategoryHcsStorage) << "Inside createlist loop";
            nameValueMap valuesMap;

            std::string value;
            value = (*it)["file"].GetString();
            valuesMap.insert({ "file", value});
            qCInfo(logCategoryHcsStorage) << "image value "<<value.c_str();

            value = (*it)["md5"].GetString();
            valuesMap.insert({"md5", value});

            value = (*it)["name"].GetString();
            valuesMap.insert({"name", value});

            value = (*it)["timestamp"].GetString();
            valuesMap.insert({"timestamp", value});

            filesList.push_back(valuesMap);
        }
    } else {
        qCInfo(logCategoryHcsStorage) << "Inside createlist loop";
        nameValueMap valuesMap;

        std::string value;
        value = jsonFileList["file"].GetString();
        valuesMap.insert({ "file", value});
        qCInfo(logCategoryHcsStorage) << "image value "<<value.c_str();

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
    qCInfo(logCategoryHcsStorage) << "Inside get and its size is "<<document_files_.size();
    if (groupIt == document_files_.end()) {
        qCInfo(logCategoryHcsStorage) << "get failed with group name " << groupName.c_str() ;
        return false;
    }

    filesList.reserve(groupIt->second.size() );
    qCInfo(logCategoryHcsStorage) << "second is "<<groupIt->second.size();
    for(const auto& item : groupIt->second) {
        auto findIt = item.find("file");
        if (findIt != item.end()) {
            filesList.push_back( findIt->second );
        }
    }
    qCInfo(logCategoryHcsStorage) << "string vector size is "<<filesList.size();
    return true;
}

bool PlatformDocument::getImageFilesList(const std::string& groupName, stringVector& filesList)
{
    // auto groupIt = document_files_.find(groupName);
    // qCInfo(logCategoryHcsStorage) << "Inside get and its size is "<<document_files_.size();
    // if (groupIt == document_files_.end()) {
    //     qCInfo(logCategoryHcsStorage) << "get failed with group name " << groupName.c_str() ;
    //     return false;
    // }
    // auto ret = document_files_.equal_range(groupName);
    filesList.reserve(document_files_.count(groupName) );
    std::multimap<std::string, nameValueMapList>::iterator it;
    for (auto item =document_files_.equal_range(groupName).first; item !=document_files_.equal_range(groupName).second; ++item) {
        auto finder = (*item).second;
        for(const auto& items : item->second) {
            qCInfo(logCategoryHcsStorage) << "Inside gettttt and its size is "<<items.size();
            auto findIt = items.find("file");
            if (findIt != items.end()) {
                filesList.push_back( findIt->second );
                qCInfo(logCategoryHcsStorage) << "Inside gettttt and its value is "<<findIt->second.c_str();
            }
        }
    }
    // for(const auto& item : groupIt->second) {
    //     auto findIt = item.find("file");
    //     if (findIt != item.end()) {
    //         filesList.push_back( findIt->second );
    //     }
    // }
    qCInfo(logCategoryHcsStorage) << "string vector size is "<<filesList.size();
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

