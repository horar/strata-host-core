#pragma once

#include <QObject>
#include <QString>
#include <QDir>

class StorageInfo final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StorageInfo)

public:
    StorageInfo(QObject* = nullptr, QString cacheDir = "");
    ~StorageInfo() = default;

    void calculateSize() const;

    using FolderSize = std::tuple<QString, quint64>;

private:
    const QDir cacheDir_;
};
