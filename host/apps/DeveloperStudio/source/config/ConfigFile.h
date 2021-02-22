#pragma once

#include <QFile>
#include<QCoreApplication>
#include <QDir>

namespace strata::sds::config
{
class ConfigFile final : private QFile
{
public:
    explicit ConfigFile(const QString &name, QObject *parent = nullptr);
    explicit ConfigFile(QObject *parent = nullptr);

    std::tuple<QByteArray, bool> loadData();
};

}  // namespace strata::sds::config
