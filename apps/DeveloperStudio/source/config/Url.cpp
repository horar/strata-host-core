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
        qCCritical(logCategoryStrataDevStudioConfig) << "invalid url:" << errorString();
    }
    const bool hasScheme{scheme().isEmpty() == false};
    const bool hasHost{host().isEmpty() == false};
    const bool hasPort{port() != -1};

    return valid && hasScheme && hasHost && hasPort;
}

}  // namespace strata::sds::config
