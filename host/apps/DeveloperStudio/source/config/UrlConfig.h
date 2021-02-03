#pragma once

#include <QObject>
#include <QString>
#include <QDebug>

namespace strata::sds::config
{
class UrlConfig : public QObject{

    Q_OBJECT

    Q_PROPERTY(QString getAvnetUrl READ getAvnetUrl);
    Q_PROPERTY(QString getMouserUrl READ getMouserUrl);
    Q_PROPERTY(QString getDigiKeyUrl READ getDigiKeyUrl);
    Q_PROPERTY(QString getSalesPopupUrl READ getSalesPopupUrl);
    Q_PROPERTY(QString getPrivacyPolicyUrl READ getPrivacyPolicyUrl);
    Q_PROPERTY(QString getLicenseUrl READ getLicenseUrl);
    Q_PROPERTY(QString getAuthServer READ getAuthServer);

public:
    explicit UrlConfig(QObject *parent = nullptr);

    QString getSalesPopupUrl() const;
    QString getLicenseUrl() const;
    QString getPrivacyPolicyUrl() const;
    QString getAuthServer() const;
    QString getMouserUrl() const;
    QString getDigiKeyUrl() const;
    QString getAvnetUrl() const;
    virtual ~UrlConfig();


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
