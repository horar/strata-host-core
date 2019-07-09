#include <DatabaseImpl.h>

#include <QObject>
#include <iostream>
#include <gtest/gtest.h>

int main()
{
    std::cout << "\nHello from cb-browser-test main()" << std::endl;

    DatabaseImpl *db = new DatabaseImpl(1);

    delete db;

    return 0;
}
