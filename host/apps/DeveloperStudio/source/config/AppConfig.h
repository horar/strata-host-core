#pragma once

#include "Url.h"

#include <QString>
#include <QUrl>

namespace strata::sds::config
{
class AppConfig final
{
public:
    explicit AppConfig();

    bool parse(const QString &fileName);

    QUrl hcsDealerAddresss() const;

private:
    Url hcsDealerAddresss_;
};

}  // namespace strata::sds::config
