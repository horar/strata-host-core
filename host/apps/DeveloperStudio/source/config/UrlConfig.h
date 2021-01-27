#pragma once

#include <QObject>
#include <QString>
#include <QDebug>

namespace strata::sds::config
{
class UrlConfig : public QObject{

    Q_OBJECT

public:
    explicit UrlConfig(QObject *parent = nullptr);
    Q_INVOKABLE QString getSalesPopupUrl() const;
    Q_INVOKABLE QString getLicenseUrl() const;
    Q_INVOKABLE QString getPrivacyPolicyUrl() const;
    Q_INVOKABLE QString getAuthServer() const;
    Q_INVOKABLE QString getMouserUrl() const;
    Q_INVOKABLE QString getDigiKeyUrl() const;
    Q_INVOKABLE QString getAvnetUrl() const;
    virtual ~UrlConfig(){}

    bool parseUrl(const QString &fileName);

private:
    QString authServer_;
    QString salesPopupUrl_;
    QString licenseUrl_;
    QString privacyPolicyUrl_;
    QString mouserUrl_;
    QString digiKeyUrl_;
    QString avnetUrl_;

    bool setUrlValue(QJsonValue val, QString *url);
};

}