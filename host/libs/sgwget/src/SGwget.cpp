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

#include "SGwget.h"
#include <curl.h>
#include <easy.h>
#include <sstream>
#include <iostream>
#include <cstdlib>
#include <stdio.h>
#include <errno.h>

// This variable will tell the library the number of attempts to find the 
// name of a file in non-overwrite mode. eg: schematics(9).pdf
const int g_maximum_file_rename_tries = 10;

// This is the default thread count required for downloading asynchoronously
// This will not be used if the thread_count_ is set by the user
const int g_default_thread_count = 1; 

using namespace std;
size_t write_data(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}

FILE *SGwget::fileOpen(const string& file_name, const string& file_mode)
{
    if(file_mode == "read") {
        #if _WIN32
            return _fsopen(file_name.c_str(),"r",_SH_DENYNO);
        #else
            return fopen(file_name.c_str(),"r");
        #endif
    }
    else { // write mode
        #if _WIN32
            return  _fsopen(file_name.c_str(),"wb",_SH_DENYNO);
        #else
            return fopen(file_name.c_str(), "wb");
        #endif	
    }
}


/* TODO [Prasanth]
   SCT-323 SGwget download file name to support unicode
*/
bool SGwget::getFilename(string& file_name,const string& file_type)
{
    std::lock_guard<std::mutex> lock(filename_mutex_);
    FILE *fp;
    if(file_type == "non-overwrite") {
        // [prasanth] TODO : needs more code clarity
        // The following fopen is only on windows and only for the case when the file is opened in the
        // background and when you try to redownload, the fopen fails under write mode.
        // Hence in order to solve this we increment a number at the end of the file 
        int file_counter = 0;
        string l_file_name = file_name;
        while ((fp = fileOpen(l_file_name,"read")) && (file_counter < g_maximum_file_rename_tries)) {
            cout << "file already exists: "<<l_file_name<<" and other file is "<<file_name<<"\n";
            string counter = to_string(++file_counter);
            size_t pos = 0;
            string name;
            //  TODO : The following approach will
            if((pos = file_name.find("."))!= std::string::npos) {
                name = file_name.substr(0, pos);
                name += "(";
                name += counter;
                name += ")";
                cout << "file name before dwonload " << file_name.substr(pos) << endl;
                l_file_name = name+file_name.substr(pos);
                cout << "file name is "<<l_file_name<<endl;
            }
            // Incase if the file name does not have "."
            else {
                l_file_name += "(";
                l_file_name += counter;
                l_file_name += ")";
            }
            fclose(fp);
        }
        if(file_counter >= g_maximum_file_rename_tries) {
            cout << "There are ten copies of the file are already available. Please delete them" << endl;
            return false;
        }
        file_name = l_file_name;
    }
    else {
        cout << "The file is being overwritten " << file_name << endl;
    }
    return true;
}

SGwget::SGwget()
{
}

SGwget::~SGwget()
{
}

bool SGwget::setThreadCount(unsigned int count)
{
    if((count > 0) && (thread_pool_ != nullptr)) {
        thread_pool_ = unique_ptr<ThreadPool>(new ThreadPool(count));
        return true;
    }
    cout << "Setting the thread count failed due to count is 0 or already been set or both" << endl;  
    return false;
}

bool SGwget::download(const std::string& url,const std::string& file_path,const std::string& file_type)
{
    FILE *fp = nullptr;
    string file_name = file_path;
    if(!getFilename(file_name,file_type)) {
        return false;
    }
    fp = fileOpen(file_name,"write");
    if(fp == nullptr) {
        return false;
    }
    CURL *curl = curl_easy_init();
    if(curl == NULL) {
        remove(file_name.c_str());
        return false;
    }
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    /* we tell libcurl to follow redirection */
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1); //Prevent "longjmp causes uninitialized stack frame" bug
    curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "deflate");
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
    /* Perform the request, res will get the return code */
    CURLcode res = curl_easy_perform(curl);
    /* Check for errors */
    if (res != CURLE_OK) {
        fprintf(stderr, "curl_easy_perform() failed: %s\n",
                curl_easy_strerror(res));
        // remove the file created when download fails
        remove(file_name.c_str());
        curl_easy_cleanup(curl);
        return false;
    }
    cout << "Done downloading" << endl;
    fclose(fp);
    curl_easy_cleanup(curl);
    return true;
}

bool SGwget::download(const std::string& url,const std::string& file_path,const std::string& file_type,DownloadMode mode)
{
    switch(mode) {
        case DownloadMode::SYNC:  
            if(download(url,file_path,file_type)) {
                return true;
            }
            break;
        case DownloadMode::ASYNC:
            cout<<"async download";
            if(asyncDownload(url,file_path,file_type)) {
                return true;
            }
            break;
        default:
            cout << "Please check the download mode" << endl;
            return false;
    }
    return false;
}

bool SGwget::asyncDownload(const std::string& url,const std::string& file_path,const std::string& file_type)
{
    if(thread_pool_ == nullptr) {
        thread_pool_ = unique_ptr<ThreadPool>(new ThreadPool(g_default_thread_count));
    }
    try {
        thread_pool_->enqueue([url,file_path,file_type,this] {
            bool download_success = download(url,file_path,file_type);
            if(on_download_callback_) {
                on_download_callback_(download_success,file_path);
            }
        });
    }
    catch(runtime_error& e) {
        return false;
    }
    return true;
}

void SGwget::setAsyncDownloadListner(const std::function<void(bool , const std::string&)> &callback)
{
    on_download_callback_ = callback;
}
