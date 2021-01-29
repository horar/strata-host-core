#include "UrlConfig.h"

#include "ConfigFile.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

namespace strata::sds::config {

UrlConfig::UrlConfig(QObject *parent) 
: QObject(parent) {
}

bool UrlConfig::parseUrl(const QString &fileName) {
    ConfigFile cfgFile(fileName);

    QJsonDocument loadDoc;
     if (const auto [data, ok] = cfgFile.loadData(); ok) {
        QJsonParseError parseError;
        loadDoc = QJsonDocument::fromJson(data, &parseError);
        if (parseError.error != QJsonParseError::NoError) {
            qCCritical(logCategoryStrataDevStudioConfig) << "raw data:" << qUtf8Printable(data);
            qCCritical(logCategoryStrataDevStudioConfig) << "parsing failed:" << parseError.errorString()
                                                   << "(offset:" << parseError.offset << ")";
            return false;
        }
        qCDebug(logCategoryStrataDevStudioConfig) << "json doc:" << loadDoc;
    } else {
        return false;
    }

    QJsonValue value = loadDoc[QLatin1String("url_cloud_service")];
    qInfo() << value;
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'url cloud service' key";
        return false;
    }

    setUrlValue(value[QLatin1String("auth_server")], &authServer_);
    setUrlValue(value[QLatin1String("sales_popup_url")], &salesPopupUrl_);
    setUrlValue(value[QLatin1String("license_url")], &licenseUrl_);
    setUrlValue(value[QLatin1String("privacy_policy_url")], &privacyPolicyUrl_);
    setUrlValue(value[QLatin1String("mouser_url")], &mouserUrl_);
    setUrlValue(value[QLatin1String("digikey_url")], &digiKeyUrl_);
    setUrlValue(value[QLatin1String("avnet_url")], &avnetUrl_);
        
    return true;
}

bool UrlConfig::setUrlValue(QJsonValue val, QString *url) {
    if (val == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing " << val <<  " key";
        return false;
    }

    if (val.isString() == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "value is not a string";
        return false;
    }

    *url = val.toString();
    // qCDebug(logCategoryStrataDevStudioConfig) << "URL:" << *url;

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

} // namespace strata::sds::config
