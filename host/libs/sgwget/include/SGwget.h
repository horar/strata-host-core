/**
******************************************************************************
* @file SGwget.cpp
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-12-07
* @brief Implements the public Class for downloading pdfs and downloads
******************************************************************************

* @copyright Copyright 2018 On Semiconductor
*/
#ifndef SGWGET_HPP
#define SGWGET_HPP
#include <string>

// ENUM for overwrite download or non overwrite download
enum class DownloadFlag {
    OVERWRITE = 0,
    NON_OVERWRITE = 1,
};

/**
 * A non-threadsafe simple libcURL-easy based HTTP downloader
 */
class SGwget {
public:
    SGwget();
    ~SGwget();
    /**
     * Download a file using HTTP GET and store in in a std::string
     * @param url The URL to download; location the path to download;
     * flag - overwrite / non-overwrite
     * @return The download result
     */
    // [TODO] The following download is a blocking function. The main thread will
    // be waiting for this function to return and this function may take more time (slow internet, large file,..)
    // JIRA SCT-289 has been created to take care of this issue
    bool download(const std::string& url,const std::string& location,const std::string& type);
private:
    void* curl;
};
#endif  /* SGwget_HPP */
