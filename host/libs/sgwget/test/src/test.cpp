/**
 * SGwgetExample.cpp
 *
 * A simple C++ wrapper for the libcurl easy API.
 * This file contains example code on how to use the SGwget class.
 *
 * Compile like this: g++ -o SGwgetExample SGwgetExample.cpp SGwget.cpp -lcurl
 *
 * Written by Uli Köhler (techoverflow.net)
 * Published under CC0 1.0 Universal (public domain)
 */
#include "SGwget.h"
#include <iostream>
#include <string>

#ifdef WINDOWS
#include <direct.h>
#define GetCurrentDir _getcwd
#else
#include <unistd.h>
#define GetCurrentDir getcwd
#endif

using namespace std;

string GetCurrentWorkingDir( void ) {
  char buff[FILENAME_MAX];
  GetCurrentDir( buff, FILENAME_MAX );
  string current_working_dir(buff);
  return current_working_dir;
}

void onDownloadCallback(bool result,const string& file) {
    cout << "\n file name is "<<file<<endl;
}

int main(int argc, char** argv) {
    if(argc <3) {
        cout << " missing the link \nCorrect Usage:./main <pdf web link> <local path to download\n";
        exit(0);
    }
    SGwget downloader;
    downloader.addAsyncDownloadListner(bind(&onDownloadCallback,placeholders::_1,placeholders::_2));
    
    for (int i=0;i<100;i++) {
      bool content = downloader.download(argv[1],argv[2],"non-overwrite",DownloadMode::ASYNC);
    }
}
