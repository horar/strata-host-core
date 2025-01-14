/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include "Url.h"

#include <QString>
#include <QUrl>

namespace strata::sds::config
{
class AppConfig final
{
public:
    explicit AppConfig(const QString &fileName);

    bool parse();

    QUrl hcsDealerAddresss() const;

private:
    QString fileName_;
    Url hcsDealerAddresss_;
};

}  // namespace strata::sds::config
