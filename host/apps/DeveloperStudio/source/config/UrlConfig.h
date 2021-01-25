#ifndef URLCONFIG_H
#define URLCONFIG_H

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
    Q_INVOKABLE QString getProductionAuthServer() const;
    Q_INVOKABLE QString getMouserUrl() const;
    Q_INVOKABLE QString getDigiKeyUrl() const;
    Q_INVOKABLE QString getAvnetUrl() const;
    virtual ~UrlConfig(){}

    bool parseUrl(const QString &fileName);

private:
    QString m_productionAuthServer;
    QString m_salesPopupUrl;
    QString m_licenseUrl;
    QString m_privacyPolicyUrl;
    QString m_mouserUrl;
    QString m_digiKeyUrl;
    QString m_avnetUrl;

    bool setUrlValue(QJsonValue val, QString *url);
};

}

#endif // URLCONFIG_H
