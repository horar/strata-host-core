/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QUrl>

namespace strata::sds::config
{
class Url final : public QUrl
{
public:
    Url();
    explicit Url(const QUrl& url);

    Url(const Url& other);
    Url& operator=(const Url& other);
    Url& operator=(const QString& other);

    bool strictlyValid() const;
};

}  // namespace strata::sds::config
