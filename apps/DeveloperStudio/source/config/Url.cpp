/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "Url.h"

#include "logging/LoggingQtCategories.h"

namespace strata::sds::config
{
Url::Url()
{
}

Url::Url(const QUrl &url) : QUrl(url)
{
}

Url::Url(const Url &other)
{
    setUrl(other.url());
}

Url &Url::operator=(const QString &other)
{
    setUrl(other);
    return *this;
}

Url &Url::operator=(const Url &other)
{
    setUrl(other.url());
    return *this;
}

bool Url::strictlyValid() const
{
    const bool valid{isValid()};
    if (valid == false) {
        qCCritical(logCategoryDevStudioConfig) << "invalid url:" << errorString();
    }
    const bool hasScheme{scheme().isEmpty() == false};
    const bool hasHost{host().isEmpty() == false};
    const bool hasPort{port() != -1};

    return valid && hasScheme && hasHost && hasPort;
}

}  // namespace strata::sds::config
