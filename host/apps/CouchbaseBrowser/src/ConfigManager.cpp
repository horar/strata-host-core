#include "ConfigManager.h"
#include "DatabaseImpl.h"

#include <iostream>
#include <QDir>

using namespace std;

ConfigManager::ConfigManager(DatabaseImpl &db)
{
    cout << "\nHello from ConfigManager CTOR" << endl;
    cout << "\nPWD: " << QDir::currentPath().toStdString() << endl;

    cout << "\nDB name: " << db.getDBName().toStdString() << endl;


}
