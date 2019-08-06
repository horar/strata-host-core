#include "WindowManager.h"

#include <QQmlProperty>

void WindowManager::createNewWindow()
{
    ids++;
    engine->load(mainDir);
    allWindows[ids] = engine->rootObjects().last();
    QQmlProperty::write(allWindows[ids],"windowId",ids);
}

void WindowManager::closeWindow(const int &id)
{
        allWindows[id]->deleteLater();
}
