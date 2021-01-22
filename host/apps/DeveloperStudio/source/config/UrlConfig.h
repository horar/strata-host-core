#ifndef URLCONFIG_H
#define URLCONFIG_H

#include <QObject>
#include <QString>
#include <QDebug>

namespace strata::sds::config
{
class UrlConfig : public QObject{

    Q_OBJECT

    Q_PROPERTY(const QString salesPopupUrl READ salesPopupUrl);
    Q_PROPERTY(const QString licenseUrl READ licenseUrl);
    Q_PROPERTY(const QString privacyPolicyUrl READ privacyPolicyUrl);

public:
    UrlConfig(QObject *parent = nullptr);
    UrlConfig(const QString &fileName);
    virtual ~UrlConfig(){}

    bool parse();

    QString salesPopupUrl() const;
    QString licenseUrl() const;
    QString privacyPolicyUrl() const;

private:
    QString fileName_;
    QString m_salesPopupUrl;
    QString m_licenseUrl;
    QString m_privacyPolicyUrl;

    bool setUrlValue(QJsonValue val, QString *url);
};

}

#endif // URLCONFIG_H
