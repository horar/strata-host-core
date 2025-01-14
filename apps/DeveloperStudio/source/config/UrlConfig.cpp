/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "UrlConfig.h"

#include "ConfigFile.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

namespace strata::sds::config {

UrlConfig::UrlConfig(const QString &fileName, QObject *parent)
: QObject(parent), fileName_{fileName} {
}

UrlConfig::~UrlConfig() {
}

bool UrlConfig::parseUrl()
{

    ConfigFile cfgFile(fileName_);

    QJsonDocument loadDoc;
     if (const auto [data, ok] = cfgFile.loadData(); ok) {
        QJsonParseError parseError;
        loadDoc = QJsonDocument::fromJson(data, &parseError);
        if (parseError.error != QJsonParseError::NoError) {
            qCCritical(lcDevStudioConfig) << "raw data:" << qUtf8Printable(data);
            qCCritical(lcDevStudioConfig) << "parsing failed:" << parseError.errorString()
                                                   << "(offset:" << parseError.offset << ")";
            return false;
        }
        qCDebug(lcDevStudioConfig) << "json doc:" << loadDoc;
    } else {
        return false;
    }

    QJsonValue value = loadDoc[QLatin1String("cloud_service")];
    if (value == QJsonValue::Undefined) {
        qCCritical(lcDevStudioConfig) << "missing 'cloud service' key";
        return false;
    }

    if (setValue(value[QLatin1String("auth_server")], &authServer_) == false) {
        qCCritical(lcDevStudioConfig) << "authentication server was not set";
            return false;
    }

    if (value[QLatin1String("server")] != QJsonValue::Undefined) {
        setValue(value[QLatin1String("server")], &serverType_);
    }

    value = loadDoc[QLatin1String("static_website")];
    if (value == QJsonValue::Undefined) {
        qCCritical(lcDevStudioConfig) << "missing 'static website' key";
        return false;
    }

    if (setValue(value[QLatin1String("sales_popup_url")], &salesPopupUrl_) == false ||
        setValue(value[QLatin1String("license_url")], &licenseUrl_) == false ||
        setValue(value[QLatin1String("privacy_policy_url")], &privacyPolicyUrl_) == false ||
        setValue(value[QLatin1String("mouser_url")], &mouserUrl_) == false ||
        setValue(value[QLatin1String("digikey_url")], &digiKeyUrl_) == false ||
        setValue(value[QLatin1String("avnet_url")], &avnetUrl_) == false) {
            qCCritical(lcDevStudioConfig) << "at least one value from 'static websites' was not set";
            return false;
    }
        
    return true;
}

bool UrlConfig::setValue(QJsonValue val, QString *url) {
    if (val == QJsonValue::Undefined) {
        qCCritical(lcDevStudioConfig) << "missing " << val <<  " key";
        return false;
    }

    if (val.isString() == false) {
        qCCritical(lcDevStudioConfig) << "value is not a string";
        return false;
    }

    *url = val.toString();

    return true;
}

QString UrlConfig::getSalesPopupUrl() const {
    return salesPopupUrl_;
}

QString UrlConfig::getLicenseUrl() const {
    return licenseUrl_;
}

QString UrlConfig::getPrivacyPolicyUrl() const {
    return privacyPolicyUrl_;
}

QString UrlConfig::getAuthServer() const {
    return authServer_;
}

QString UrlConfig::getMouserUrl() const {
    return mouserUrl_;
}

QString UrlConfig::getDigiKeyUrl() const {
    return digiKeyUrl_;
}

QString UrlConfig::getAvnetUrl() const {
    return avnetUrl_;
}

QString UrlConfig::getServerType() const
{
    return serverType_;
}

} // namespace strata::sds::config
