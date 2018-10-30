//
// Created by Luay Alshawi on 10/25/18.
//
#include <iostream>
#include <thread>// std::this_thread::sleep_for

#include "SGDatabase.h"
#include "SGDocument.h"
using namespace std;
int main(){

    SGDatabase sgDatabase("mydb");
    std::this_thread::sleep_for (std::chrono::milliseconds(5000));

    SGDocument usbPDDocument(&sgDatabase, "usb-pd");
    SGDocument newdocument(&sgDatabase, "newdocuemtn");

    // Create document if does not exist
    // TODO: This can also save document changes
    sgDatabase.save(&usbPDDocument);

    sgDatabase.save(&newdocument);

    cout << "document: body" << usbPDDocument.getBody() << endl;

    sgDatabase.deleteDocument(&usbPDDocument);

    std::this_thread::sleep_for (std::chrono::milliseconds(5000));

    return 0;
}
