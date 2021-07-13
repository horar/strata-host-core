#pragma once

#include <QFile>

namespace strata::sds::config
{
class ConfigFile final : private QFile
{
public:
    explicit ConfigFile(const QString &name = QString(), QObject *parent = nullptr);

    std::tuple<QByteArray, bool> loadData();
};

}  // namespace strata::sds::config
