/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "AppConfig.h"

#include "ConfigFile.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>

namespace strata::sds::config
{
AppConfig::AppConfig(const QString &fileName) : fileName_{fileName}
{
}

bool AppConfig::parse()
{
    ConfigFile cfgFile(fileName_);

    QJsonDocument loadDoc;
    if (const auto [data, ok] = cfgFile.loadData(); ok) {
        QJsonParseError parseError;
        loadDoc = QJsonDocument::fromJson(data, &parseError);
        if (parseError.error != QJsonParseError::NoError) {
            qCCritical(logCategoryDevStudioConfig) << "raw data:" << qUtf8Printable(data);
            qCCritical(logCategoryDevStudioConfig) << "parsing failed:" << parseError.errorString()
                                                   << "(offset:" << parseError.offset << ")";
            return false;
        }

        qCDebug(logCategoryDevStudioConfig) << "json doc:" << loadDoc;
    } else {
        return false;
    }

    QJsonValue value = loadDoc[QLatin1String("host_controller_service")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryDevStudioConfig) << "missing 'host_controller_service' key";
        return false;
    }
    value = value[QLatin1String("dealer_address")];
    if (value == QJsonValue::Undefined) {
        qCCritical(logCategoryDevStudioConfig) << "missing 'dealer_address' key";
        return false;
    }

    if (value.isString() == false) {
        qCCritical(logCategoryDevStudioConfig) << "'dealer_address' value is not a string";
        return false;
    }
    hcsDealerAddresss_ = value.toString();
    if (hcsDealerAddresss_.strictlyValid() == false) {
        qCCritical(logCategoryDevStudioConfig) << "incomplete HCS dealer address";
        return false;
    }
    qCDebug(logCategoryDevStudioConfig) << "HCS dealer addresss:" << hcsDealerAddresss_;

    return true;
}

QUrl AppConfig::hcsDealerAddresss() const
{
    return hcsDealerAddresss_;
}

}  // namespace strata::sds::config
