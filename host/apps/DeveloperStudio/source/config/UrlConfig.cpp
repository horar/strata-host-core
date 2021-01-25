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
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'host_controller_service' key";
        return false;
    }

    setUrlValue(value[QLatin1String("production_auth_server")], &m_productionAuthServer);
    setUrlValue(value[QLatin1String("sales_popup_url")], &m_salesPopupUrl);
    setUrlValue(value[QLatin1String("license_url")], &m_licenseUrl);
    setUrlValue(value[QLatin1String("privacy_policy_url")], &m_privacyPolicyUrl);
    setUrlValue(value[QLatin1String("mouser_url")], &m_mouserUrl);
    setUrlValue(value[QLatin1String("digikey_url")], &m_digiKeyUrl);
    setUrlValue(value[QLatin1String("avnet_url")], &m_avnetUrl);
        
    return true;
}

bool UrlConfig::setUrlValue(QJsonValue val, QString *url) {
    if (val == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing key";
        return false;
    }

    if (val.isString() == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "value is not a string";
        return false;
    }

    *url = val.toString();
    qCDebug(logCategoryStrataDevStudioConfig) << "URL:" << &url;

    return true;
}

QString UrlConfig::getSalesPopupUrl() const {
    return m_salesPopupUrl;
}

QString UrlConfig::getLicenseUrl() const {
    return m_licenseUrl;
}

QString UrlConfig::getPrivacyPolicyUrl() const {
    return m_privacyPolicyUrl;
}

QString UrlConfig::getProductionAuthServer() const {
    return m_productionAuthServer;
}

QString UrlConfig::getMouserUrl() const {
    return m_mouserUrl;
}

QString UrlConfig::getDigiKeyUrl() const {
    return m_digiKeyUrl;
}

QString UrlConfig::getAvnetUrl() const {
    return m_avnetUrl;
}

} // namespace strata::sds::config
