#ifndef URLCONFIGURATION_H
#define URLCONFIGURATION_H

#include <QObject>
#include <QString>
#include <QDebug>

class UrlConfiguration : public QObject{

    Q_OBJECT

    Q_PROPERTY(const QString salesPopupUrl READ salesPopupUrl);
    Q_PROPERTY(const QString licenseUrl READ licenseUrl);
    Q_PROPERTY(const QString privacyPolicyUrl READ privacyPolicyUrl);

public:
    explicit UrlConfiguration(QObject *parent = nullptr);
    virtual ~UrlConfiguration(){}

    const QString salesPopupUrl(){ return m_salesPopupUrl; }
    const QString licenseUrl(){ return m_licenseUrl; }
    const QString privacyPolicyUrl(){ return m_privacyPolicyUrl; }

private:
    const QString m_salesPopupUrl = "https://www.onsemi.com/PowerSolutions/locateSalesSupport.do";
    const QString m_licenseUrl = "https://www.openssl.org/source/license.html";
    const QString m_privacyPolicyUrl = "https://www.onsemi.com/privacy-policy";
};

#endif // URLCONFIGURATION_H
