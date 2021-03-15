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
