/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    Q_PROPERTY(QString serverType READ getServerType CONSTANT);

public:
    explicit UrlConfig(const QString &fileName, QObject *parent = nullptr);

    QString getSalesPopupUrl() const;
    QString getLicenseUrl() const;
    QString getPrivacyPolicyUrl() const;
    QString getAuthServer() const;
    QString getMouserUrl() const;
    QString getDigiKeyUrl() const;
    QString getAvnetUrl() const;
    QString getServerType() const;
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
    QString serverType_;

    bool setValue(QJsonValue val, QString *url);
};

}
