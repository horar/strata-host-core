#include "ConfigFile.h"

#include "logging/LoggingQtCategories.h"

namespace strata::sds::config
{
strata::sds::config::ConfigFile::ConfigFile(const QString &name, QObject *parent)
    : QFile(name, parent)
{
}

std::tuple<QByteArray, bool> strata::sds::config::ConfigFile::loadData()
{
    qCInfo(logCategoryStrataDevStudioConfig) << "loading configuration from" << fileName();

    QByteArray data;
    if (open(QIODevice::ReadOnly | QIODevice::Text) == false) {
        qCCritical(logCategoryStrataDevStudioConfig) << "opening failed:" << errorString();
        return std::make_tuple(std::move(data), false);
    }

    if (size() == 0) {
        qCCritical(logCategoryStrataDevStudioConfig) << "empty file";
        return std::make_tuple(std::move(data), false);
    }

    data = readAll();
    return std::make_tuple(std::move(data), true);
}

}  // namespace strata::sds::config
