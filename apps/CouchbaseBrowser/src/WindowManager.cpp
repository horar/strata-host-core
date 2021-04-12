#include "WindowManager.h"

#include <QQmlProperty>
#include <QQmlApplicationEngine>

void WindowManager::createNewWindow()
{
    window_idx_++;
    engine_->load(QUrl(QStringLiteral("qrc:/qml/MainWindow.qml")));
    all_windows_[window_idx_] = engine_->rootObjects().last();
    QQmlProperty::write(all_windows_[window_idx_], "windowId", window_idx_);
}

void WindowManager::closeWindow(const int &id)
{
        all_windows_[id]->deleteLater();
}
