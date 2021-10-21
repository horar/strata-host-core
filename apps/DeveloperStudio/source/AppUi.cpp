/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "AppUi.h"

#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

AppUi::AppUi(QQmlApplicationEngine& engine, const QUrl& errorUrl, QObject* parent)
    : QObject(parent), engine_{engine}, errorUrl_{errorUrl}
{
}

void AppUi::loadUrl(const QUrl& url)
{
    qCDebug(logCategoryDevStudio) << "loading" << url;

    auto qLaterDeleter = [](QQmlComponent* p) { p->deleteLater(); };
    std::unique_ptr<QQmlComponent, qtLaterDeleterFunction> newComponent(new QQmlComponent(&engine_),
                                                                        qLaterDeleter);
    component_.swap(newComponent);
    QObject::connect(component_.get(), &QQmlComponent::statusChanged, this, &AppUi::statusChanged);
    component_->loadUrl(url);
}

void AppUi::statusChanged(QQmlComponent::Status status)
{
    qCDebug(logCategoryDevStudio) << "loading status" << status;

    if (status == QQmlComponent::Ready) {
        loadSuccess();
    } else if (status == QQmlComponent::Error) {
        loadFailed();
    }
}

void AppUi::loadSuccess()
{
    QObject* object = component_->create();
    if (object == nullptr) {
        qCCritical(logCategoryDevStudio)
            << "component creation critically failed:" << component_->errorString();
        emit uiFails();
        return;
    }
    qCDebug(logCategoryDevStudio) << "UI ready";
    if (component_->url() != errorUrl_) {
        emit uiLoaded();
    }
}

void AppUi::loadFailed()
{
    qCCritical(logCategoryDevStudio) << "details:";
    foreach (const QQmlError& error, component_->errors()) {
        qCCritical(logCategoryDevStudio) << error.toString();
    }

    if (component_->url() == errorUrl_) {
        qCCritical(logCategoryDevStudio)
            << "hell froze - fails to load error dialog; aborting...";
        emit uiFails();
        return;
    }

    const auto ctx{component_->engine()->rootContext()};
    ctx->setContextProperty("errorString", component_->errorString());
    loadUrl(errorUrl_);
}
