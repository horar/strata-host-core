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
