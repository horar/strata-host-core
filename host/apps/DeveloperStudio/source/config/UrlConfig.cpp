#include "UrlConfig.h"

#include "ConfigFile.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

namespace strata::sds::config {
UrlConfig::UrlConfig(QObject *parent) : QObject(parent) {}

UrlConfig::UrlConfig(const QString &fileName) : fileName_{fileName} {}

bool UrlConfig::parse() {
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

    QJsonValue value = loadDoc[QLatin1String("url_cloud_service")];
    qInfo() << value;
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'host_controller_service' key";
        return false;
    }

    setUrlValue(value[QLatin1String("sales_popup_url")], &m_salesPopupUrl);
    qCDebug(logCategoryStrataDevStudioConfig) << m_salesPopupUrl;
    setUrlValue(value[QLatin1String("license_url")], &m_licenseUrl);
    qCDebug(logCategoryStrataDevStudioConfig) << m_licenseUrl;
    setUrlValue(value[QLatin1String("privacy_policy")], &m_privacyPolicyUrl);
    qCDebug(logCategoryStrataDevStudioConfig) << m_privacyPolicyUrl;
        
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

QString UrlConfig::salesPopupUrl() const {
    qInfo() << m_salesPopupUrl;
    return m_salesPopupUrl;
}

QString UrlConfig::licenseUrl() const {
    qInfo() << m_licenseUrl;
    return m_licenseUrl;
}

QString UrlConfig::privacyPolicyUrl() const {
    qInfo() << m_privacyPolicyUrl;
    return m_privacyPolicyUrl;
}

} // namespace strata::sds::config
