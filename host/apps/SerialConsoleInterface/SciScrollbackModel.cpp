#include "SciScrollbackModel.h"
#include "logging/LoggingQtCategories.h"
#include "SciPlatform.h"
#include <QSaveFile>

SciScrollbackModel::SciScrollbackModel(SciPlatform *platform)
    : QAbstractListModel(platform),
      platform_(platform)
{
    setModelRoles();
}

SciScrollbackModel::~SciScrollbackModel()
{
    if (autoExportIsActive_) {
        stopAutoExport();
    }
}

QVariant SciScrollbackModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    const ScrollbackModelItem &item = data_.at(row);

    switch (role) {
    case MessageRole:
        return item.message;
    case TypeRole:
        return static_cast<int>(item.type);
    case TimestampRole:
        return item.timestamp;
    case CondensedRole:
        return item.condensed;
    }

    return QVariant();
}

QVariant SciScrollbackModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciScrollbackModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return data_.length();
}

int SciScrollbackModel::count() const
{
    return data_.length();
}

void SciScrollbackModel::append(const QByteArray &message, MessageType type)
{
    beginInsertRows(QModelIndex(), data_.length(), data_.length());

    ScrollbackModelItem item;
    item.message = message;
    item.type = type;
    item.timestamp = QDateTime::currentDateTime();
    item.condensed = condensedMode_;
    data_.append(item);

    endInsertRows();

    emit countChanged();

    if (autoExportIsActive_) {
        qint64 bytesWritten = exportFile_.write(stringify(data_.last()));
        if (bytesWritten <= 0) {
            qCCritical(logCategorySci)  << "write failed" << exportFile_.errorString();
            setAutoExportErrorString(exportFile_.errorString());
            stopAutoExport();
        }
    }

    sanitize();
}

void SciScrollbackModel::setAllCondensed(bool condensed)
{
    for (auto &item : data_) {
        item.condensed = condensed;
    }

    emit dataChanged(
                createIndex(0, 0),
                createIndex(data_.length() - 1, 0),
                QVector<int>() << CondensedRole);
}

void SciScrollbackModel::setCondensed(int index, bool condensed)
{
    if (index < 0 || index >= data_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return;
    }

    data_[index].condensed = condensed;

    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << CondensedRole);
}

void SciScrollbackModel::clear()
{
    beginResetModel();
    data_.clear();
    endResetModel();
    emit countChanged();
}

void SciScrollbackModel::clearAutoExportError()
{
    setAutoExportErrorString("");
}

QString SciScrollbackModel::exportToFile(QString filePath)
{
    QSaveFile file(filePath);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(logCategorySci) << "open failed:" << file.errorString() << filePath;
        return file.errorString();
    }

    platform_->storeExportPath(filePath);
    setExportFilePath(filePath);

    qint64 bytesWritten = file.write(getTextForExport());
    if (bytesWritten <= 0) {
        QString errorString = exportFile_.errorString();
        qCCritical(logCategorySci) << "write failed" << file.errorString() << filePath;
        return file.errorString();
    }

    bool committed = file.commit();
    if (committed == false) {
        qCCritical(logCategorySci) << "commit failed:" << file.errorString() << filePath;
        return file.errorString();
    }

    return QString();
}

bool SciScrollbackModel::startAutoExport(const QString &filePath)
{
    if (autoExportIsActive_) {
        return false;
    }

    setAutoExportErrorString("");

    exportFile_.setFileName(filePath);
    bool ret = exportFile_.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false ) {
        qCCritical(logCategorySci) << "open fiiled" << filePath << exportFile_.errorString();
        setAutoExportErrorString(exportFile_.errorString());
        return false;
    }

    platform_->storeAutoExportPath(filePath);
    setAutoExportFilePath(filePath);

    setAutoExportIsActive(true);
    return true;
}

void SciScrollbackModel::stopAutoExport()
{
    exportFile_.close();
    setAutoExportIsActive(false);
}

QByteArray SciScrollbackModel::stringify(const ScrollbackModelItem &item) const
{
    QByteArray line;

    line += item.timestamp.toString(Qt::ISODate).toUtf8();
    line += " ";
    line += item.type == MessageType::Request ? "request" : "response";
    line += " ";
    line += item.message;
    line += "\n";

    return line;
}

QByteArray SciScrollbackModel::getTextForExport() const
{
    QByteArray text;
    for (const auto &item : data_) {
        text.append(stringify(item));
    }

    return text;
}

bool SciScrollbackModel::condensedMode() const
{
    return condensedMode_;
}

void SciScrollbackModel::setCondensedMode(bool condensedMode)
{
    if (condensedMode_ != condensedMode) {
        condensedMode_ = condensedMode;
        emit condensedModeChanged();
    }
}

int SciScrollbackModel::maximumCount() const
{
    return maximumCount_;
}

void SciScrollbackModel::setMaximumCount(int maximumCount)
{
    if (maximumCount_ != maximumCount) {
        maximumCount_ = maximumCount;
        sanitize();
    }
}

QString SciScrollbackModel::exportFilePath() const
{
    return exportFilePath_;
}

void SciScrollbackModel::setExportFilePath(const QString &filePath)
{
    if (exportFilePath_ != filePath) {
        exportFilePath_ = filePath;
        emit exportFilePathChanged();
    }
}

bool SciScrollbackModel::autoExportIsActive() const
{
    return autoExportIsActive_;
}

QString SciScrollbackModel::autoExportFilePath() const
{
    return autoExportFilePath_;
}

void SciScrollbackModel::setAutoExportFilePath(const QString &filePath)
{
    if (autoExportFilePath_ != filePath) {
        autoExportFilePath_ = filePath;
        emit autoExportFilePathChanged();
    }
}

QString SciScrollbackModel::autoExportErrorString() const
{
    return autoExportErrorString_;
}

QHash<int, QByteArray> SciScrollbackModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciScrollbackModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(MessageRole, "message");
    roleByEnumHash_.insert(TypeRole, "type");
    roleByEnumHash_.insert(TimestampRole, "timestamp");
    roleByEnumHash_.insert(CondensedRole, "condensed");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

void SciScrollbackModel::sanitize()
{
    int removeCount = data_.length() - maximumCount_;
    if (removeCount > 0) {
        beginRemoveRows(QModelIndex(), 0, removeCount - 1);

        for (int i = 0; i < removeCount; ++i) {
            data_.removeFirst();
        }

        endRemoveRows();
        emit countChanged();
    }
}

void SciScrollbackModel::setAutoExportIsActive(bool exportIsActive)
{
    if (autoExportIsActive_ != exportIsActive) {
        autoExportIsActive_ = exportIsActive;
        emit autoExportIsActiveChanged();
    }
}

void SciScrollbackModel::setAutoExportErrorString(const QString &errorString)
{
    if (autoExportErrorString_ != errorString) {
        autoExportErrorString_ = errorString;
        emit autoExportErrorStringChanged();
    }
}
