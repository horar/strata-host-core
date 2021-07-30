#pragma once

#include <QObject>
#include <QString>
#include <QDebug>

namespace strata::sds::config
{
class UrlConfig : public QObject{

    Q_OBJECT

    Q_PROPERTY(QString avnetUrl READ getAvnetUrl CONSTANT);
    Q_PROPERTY(QString mouserUrl READ getMouserUrl CONSTANT);
    Q_PROPERTY(QString digiKeyUrl READ getDigiKeyUrl CONSTANT);
    Q_PROPERTY(QString salesPopupUrl READ getSalesPopupUrl CONSTANT);
    Q_PROPERTY(QString privacyPolicyUrl READ getPrivacyPolicyUrl CONSTANT);
    Q_PROPERTY(QString licenseUrl READ getLicenseUrl CONSTANT);
    Q_PROPERTY(QString authServer READ getAuthServer CONSTANT);

public:
    explicit UrlConfig(const QString &fileName, QObject *parent = nullptr);

    QString getSalesPopupUrl() const;
    QString getLicenseUrl() const;
    QString getPrivacyPolicyUrl() const;
    QString getAuthServer() const;
    QString getMouserUrl() const;
    QString getDigiKeyUrl() const;
    QString getAvnetUrl() const;
    virtual ~UrlConfig();


    bool parseUrl();

private:
    QString fileName_;

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
