/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QQmlComponent>

#include "logging/LoggingQtCategories.h"

class QQmlApplicationEngine;
inline void initializeResources() { Q_INIT_RESOURCE(qml_minimal_ui); }

namespace strata::SGCore {

class AppUi : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(AppUi)

    using qtLaterDeleterFunction = std::function<void(QQmlComponent*)>;

public:
    AppUi(QQmlApplicationEngine& engine, const QUrl& errorUrl, QObject* parent = nullptr);
    ~AppUi() = default;

    void loadUrl(const QUrl& url);

signals:
    void uiLoaded();
    void uiFails();

private slots:
    void statusChanged(QQmlComponent::Status status);

private:
    void loadSuccess();
    void loadFailed();

    std::unique_ptr<QQmlComponent, qtLaterDeleterFunction> component_;
    QQmlApplicationEngine& engine_;
    QUrl errorUrl_;
};

} // namespace strata::SGCore
