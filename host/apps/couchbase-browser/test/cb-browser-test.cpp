#include <databaseinterface.h>

#include <QObject>
#include <iostream>
#include <gtest/gtest.h>

int main()
{
    std::cout << "\nHello from cb-browser-test main()" << std::endl;

    DatabaseInterface *db = new DatabaseInterface(1);

    delete db;

    return 0;
}
