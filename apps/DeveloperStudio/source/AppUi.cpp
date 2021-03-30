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
    qCDebug(logCategoryStrataDevStudio) << "loading" << url;

    auto qLaterDeleter = [](QQmlComponent* p) { p->deleteLater(); };
    std::unique_ptr<QQmlComponent, qtLaterDeleterFunction> newComponent(new QQmlComponent(&engine_),
                                                                        qLaterDeleter);
    component_.swap(newComponent);
    QObject::connect(component_.get(), &QQmlComponent::statusChanged, this, &AppUi::statusChanged);
    component_->loadUrl(url);
}

void AppUi::statusChanged(QQmlComponent::Status status)
{
    qCDebug(logCategoryStrataDevStudio) << "loading status" << status;

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
        qCCritical(logCategoryStrataDevStudio)
            << "component creation critically failed:" << component_->errorString();
        emit uiFails();
        return;
    }
    qCDebug(logCategoryStrataDevStudio) << "UI ready";
    if (component_->url() != errorUrl_) {
        emit uiLoaded();
    }
}

void AppUi::loadFailed()
{
    qCCritical(logCategoryStrataDevStudio) << "details:";
    foreach (const QQmlError& error, component_->errors()) {
        qCCritical(logCategoryStrataDevStudio) << error.toString();
    }

    if (component_->url() == errorUrl_) {
        qCCritical(logCategoryStrataDevStudio)
            << "hell froze - fails to load error dialog; aborting...";
        emit uiFails();
        return;
    }

    const auto ctx{component_->engine()->rootContext()};
    ctx->setContextProperty("errorString", component_->errorString());
    loadUrl(errorUrl_);
}
