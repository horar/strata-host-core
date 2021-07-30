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
            qCCritical(logCategoryStrataDevStudioConfig) << "raw data:" << qUtf8Printable(data);
            qCCritical(logCategoryStrataDevStudioConfig) << "parsing failed:" << parseError.errorString()
                                                   << "(offset:" << parseError.offset << ")";
            return false;
        }
        qCDebug(logCategoryStrataDevStudioConfig) << "json doc:" << loadDoc;
    } else {
        return false;
    }

    QJsonValue value = loadDoc[QLatin1String("cloud_service")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'cloud service' key";
        return false;
    }

    if (setUrlValue(value[QLatin1String("auth_server")], &authServer_) == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "authentication server was not set";
            return false;
    }

    value = loadDoc[QLatin1String("static_website")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'static website' key";
        return false;
    }

    if (setUrlValue(value[QLatin1String("sales_popup_url")], &salesPopupUrl_) == false ||
        setUrlValue(value[QLatin1String("license_url")], &licenseUrl_) == false ||
        setUrlValue(value[QLatin1String("privacy_policy_url")], &privacyPolicyUrl_) == false ||
        setUrlValue(value[QLatin1String("mouser_url")], &mouserUrl_) == false ||
        setUrlValue(value[QLatin1String("digikey_url")], &digiKeyUrl_) == false ||
        setUrlValue(value[QLatin1String("avnet_url")], &avnetUrl_) == false) {
            qCCritical(logCategoryStrataDevStudioConfig) << "at least one value from 'static websites' was not set";
            return false;
    }
        
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
