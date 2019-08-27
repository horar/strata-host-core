
#ifndef HOST_HCS_PLATFORMDOCUMENT_H__
#define HOST_HCS_PLATFORMDOCUMENT_H__

#include <rapidjson/document.h>
#include <string>
#include <vector>
#include <map>

class PlatformDocument
{
public:
    typedef std::map<std::string, std::string> nameValueMap;
    typedef std::vector<nameValueMap> nameValueMapList;

    typedef std::vector<std::string> stringVector;

public:
    PlatformDocument(const std::string& classId, const std::string& revision);

    std::string getClassId() const { return classId_; }
    std::string getRevision() const { return revision_; }

    /**
     * Parse the platform document and creates document_files_ map
     * @param document document to parse
     * @return true when succeeded, otherwise false
     */
    bool parseDocument(const std::string& document);

    /**
     * Returns list of filenames given by group name
     * @param groupName selected group name - like 'views', 'downloads'
     * @param filesList list of files or empty when section not found
     * @return returns true when succeeded, otherwise false
     */
    bool getDocumentFilesList(const std::string& groupName, stringVector& filesList);

    /**
     * Searches for the element by file url and in given section
     * @param url file url to search for
     * @param groupName selected group
     * @return returns element found or empty when not found
     */
    nameValueMap findElementByFile(const std::string& url, const std::string& groupName);

private:

    void createFilesList(const rapidjson::Value& jsonFileList, std::vector<nameValueMap>& filesList);

private:
    std::string classId_;
    std::string revision_;

    rapidjson::Document document_;

    std::map< std::string, nameValueMapList> document_files_;
};

#endif //HOST_HCS_PLATFORMDOCUMENT_H__
