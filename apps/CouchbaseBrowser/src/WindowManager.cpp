/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
