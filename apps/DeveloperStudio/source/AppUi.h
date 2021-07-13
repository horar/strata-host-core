#pragma once

#include <QObject>
#include <QQmlComponent>

#include "logging/LoggingQtCategories.h"

class QQmlApplicationEngine;

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
