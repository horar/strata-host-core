#include "ConfigFile.h"

#include "logging/LoggingQtCategories.h"

namespace strata::sds::config
{

strata::sds::config::ConfigFile::ConfigFile(const QString &name, QObject *parent)
    : QFile(name, parent)
{
}

strata::sds::config::ConfigFile::ConfigFile(QObject *parent)
    : QFile(parent)
{
    const QString appDirPath = QCoreApplication::applicationDirPath();

    #ifdef Q_OS_WIN
    const QString sdsPath{ QDir::cleanPath(QString("%1/Strata Developer Studio.exe").arg(appDirPath)) };
    #if WINDOWS_INSTALLER_BUILD
        QString sdsConfigPath;
        TCHAR programDataPath[MAX_PATH];
        if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, programDataPath))) {
            sdsConfigPath = QDir::cleanPath(QString("%1/ON Semiconductor/Strata Developer Studio/sds.config").arg(programDataPath));
            qCInfo(logCategoryStrataDevStudio) << QStringLiteral("sdsConfigPath:") << sdsConfigPath;
        }else{
            qCCritical(logCategoryStrataDevStudio) << "Failed to get ProgramData path using windows API call...";
        }
    #else
        const QString sdsConfigPath{ QDir::cleanPath(QString("%1/sds.config").arg(appDirPath)) };
    #endif
    #endif

    #ifdef Q_OS_MACOS
        const QString sdsPath{ QDir::cleanPath(QString("%1/../../../Strata Developer Studio.app").arg(appDirPath)) };
        const QString sdsConfigPath{ QDir::cleanPath( QString("%1/../../../sds.config").arg(appDirPath)) };
    #endif

    #ifdef Q_OS_LINUX
        const QString sdsPath{ QDir::cleanPath(QString("%1/Strata Developer Studio").arg(appDirPath)) };
        const QString sdsConfigPath{ QDir::cleanPath(QString("%1/sds.config").arg(appDirPath))};
    #endif

    if (QFile::exists(sdsPath)) {
        this->setFileName(sdsConfigPath);
    }
    else {
        qCCritical(logCategoryStrataDevStudio) << "Failed: SDS config does not exist";
    }
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
