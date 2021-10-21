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
            qCCritical(lcDevStudioConfig) << "raw data:" << qUtf8Printable(data);
            qCCritical(lcDevStudioConfig) << "parsing failed:" << parseError.errorString()
                                                   << "(offset:" << parseError.offset << ")";
            return false;
        }

        qCDebug(lcDevStudioConfig) << "json doc:" << loadDoc;
    } else {
        return false;
    }

    QJsonValue value = loadDoc[QLatin1String("host_controller_service")];
    if (value == QJsonValue::Undefined) {
        qCCritical(lcDevStudioConfig) << "missing 'host_controller_service' key";
        return false;
    }
    value = value[QLatin1String("dealer_address")];
    if (value == QJsonValue::Undefined) {
        qCCritical(lcDevStudioConfig) << "missing 'dealer_address' key";
        return false;
    }

    if (value.isString() == false) {
        qCCritical(lcDevStudioConfig) << "'dealer_address' value is not a string";
        return false;
    }
    hcsDealerAddresss_ = value.toString();
    if (hcsDealerAddresss_.strictlyValid() == false) {
        qCCritical(lcDevStudioConfig) << "incomplete HCS dealer address";
        return false;
    }
    qCDebug(lcDevStudioConfig) << "HCS dealer addresss:" << hcsDealerAddresss_;

    return true;
}

QUrl AppConfig::hcsDealerAddresss() const
{
    return hcsDealerAddresss_;
}

}  // namespace strata::sds::config
