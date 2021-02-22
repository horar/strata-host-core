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

    bool parse();

    QUrl hcsDealerAddresss() const;

private:
    Url hcsDealerAddresss_;
};

}  // namespace strata::sds::config
