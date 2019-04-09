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
const int maximum_file_rename_tries = 10;

using namespace std;
size_t write_data(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}

FILE *fileOpen(const string& file_name, const string& file_mode)
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

bool getFilename(string& file_name,const string& file_type)
{
    FILE *fp;
    if(file_type == "non-overwrite") {
        // [prasanth] TODO : needs more code clarity
        // The following fopen is only on windows and only for the case when the file is opened in the
        // background and when you try to redownload, the fopen fails under write mode.
        // Hence in order to solve this we increment a number at the end of the file 
        int file_counter = 0;
        string l_file_name = file_name;
        while ((fp = fileOpen(l_file_name,"read")) && (file_counter < maximum_file_rename_tries)) {
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
        if(file_counter >= maximum_file_rename_tries) {
            cout << "There are ten copies of hte file already available. Please delete them\n";
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
    curl = curl_easy_init();
}

SGwget::~SGwget()
{
    curl_easy_cleanup(curl);
}

bool SGwget::download(const std::string& url,const std::string& file_path,const std::string& file_type)
{
    FILE *fp;
    string file_name = file_path;
    if(!getFilename(file_name,file_type)) {
        return false;
    }
    fp = fileOpen(file_name,"write");
    if(!curl) {
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
        return false;
    }
    cout<<"Done downloading\n";
    fclose(fp);
    return true;
}
