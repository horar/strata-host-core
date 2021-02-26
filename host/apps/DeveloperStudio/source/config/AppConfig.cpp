#include "AppConfig.h"

#include "ConfigFile.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

namespace strata::sds::config
{
AppConfig::AppConfig()
{
}

bool AppConfig::parse(const QString &fileName)
{
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

    QJsonValue value = loadDoc[QLatin1String("host_controller_service")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'host_controller_service' key";
        return false;
    }
    value = value[QLatin1String("dealer_address")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryStrataDevStudioConfig) << "missing 'dealer_address' key";
        return false;
    }

    if (value.isString() == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "'dealer_address' value is not a string";
        return false;
    }
    hcsDealerAddresss_ = value.toString();
    if (hcsDealerAddresss_.strictlyValid() == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "incomplete HCS dealer address";
        return false;
    }
    qCDebug(logCategoryStrataDevStudioConfig) << "HCS dealer addresss:" << hcsDealerAddresss_;

    return true;
}

QUrl AppConfig::hcsDealerAddresss() const
{
    return hcsDealerAddresss_;
}

}  // namespace strata::sds::config
