/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef WINDOW_MANAGER
#define WINDOW_MANAGER

#include <QObject>

class QQmlApplicationEngine;

class WindowManager : public QObject
{
    Q_OBJECT

public:
    explicit WindowManager(QQmlApplicationEngine *engine) : engine_(engine) {}

    ~WindowManager() {}

    Q_INVOKABLE void createNewWindow();

    Q_INVOKABLE void closeWindow(const int &id);

private:
    QQmlApplicationEngine *engine_ = nullptr;

    int window_idx_ = 0;

    std::map<int, QObject*> all_windows_;
};

#endif
