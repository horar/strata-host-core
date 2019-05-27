/**
******************************************************************************
* @file SGwget.cpp
* @author Prasanth Vivek
* $Rev: 1 $
* $Date: 2018-12-07
* @brief Implements the public Class for downloading pdfs and downloads
******************************************************************************

* @copyright Copyright 2018 ON Semiconductor
*/
#ifndef SGWGET_HPP
#define SGWGET_HPP
#include <string>
#include <thread>
#include <mutex> 
#include <ThreadPool.h>


// ENUM for overwrite download or non overwrite download
enum class DownloadMode {
    SYNC = 0,
    ASYNC
};

/**
 * A non-threadsafe simple libcURL-easy based HTTP downloader
 */
class SGwget {
public:
    SGwget();

    ~SGwget();

    /**
     * Download a file using curl  
     * @param url The URL to download 
     * @param location the path to download
     * @param type  overwrite / non-overwrite
     * @param mode  synch / async
     * @return true = download success else false
     */
    bool download(const std::string& url,const std::string& location,const std::string& type,DownloadMode flag);

    /**
     * Download a file using curl
     * @param url The URL to download
     * @param location the path to download
     * @param type  overwrite / non-overwrite
     * @return true = download success else false
     */
    bool download(const std::string& url,const std::string& location,const std::string& type);

    /**
     * Adding the callback function for the async download
     * @param callback function pointer
     */
    void setAsyncDownloadListner(const std::function<void(bool , const std::string&)> &callback);

    /**
     * Setting the number of threads that will be used for async download
     * @param count - unsigned int greater than 0
     * @return true = success else false
     */
    bool setThreadCount(unsigned int count);

private: 
    /**
     * assigns the download() to a thread in the thread pool
     * @param url The URL to download 
     * @param location the path to download
     * @param type  overwrite / non-overwrite
     * @return true = download success else false
     */
    bool asyncDownload(const std::string& url, const std::string& location, const std::string& type);

    /**
     * check the file, if exists add (n) to the end of the file name, where n =1,2,... 
     * @param file_name contains the name of the file to be checked 
     * @param file_type says if the file needs to overwritten or create a new file
     * @return true = download success else false
     */
    bool getFilename(std::string& file_name,const std::string& file_type);

    /**
     * Open/Create a File
     * @param file_name contains the name of the file to be opened or created 
     * @param file_mode says if the file needs to opened in read or write mode
     * @return file pointer of the opened/created file
     */
    FILE *fileOpen(const std::string& file_name, const std::string& file_mode);

    std::function<void(bool , const std::string &)> on_download_callback_;
    std::unique_ptr<ThreadPool> thread_pool_;
    std::mutex filename_mutex_;
};
#endif  /* SGwget_HPP */
