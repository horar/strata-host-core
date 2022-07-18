/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciScrollbackModel.h"
#include "logging/LoggingQtCategories.h"
#include "SciPlatform.h"
#include <SGUtilsCpp.h>
#include <SGJsonFormatter.h>

#include <QSaveFile>
#include <QJsonDocument>
#include <QJsonObject>

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
    case RawMessageRole:
        return item.rawMessage;
    case CondensedMessageRole:
        return item.condensedMessage;
    case ExpandedMessageRole:
        return item.expandedMessage;
    case TypeRole:
        return static_cast<int>(item.type);
    case TimestampRole:
        return item.timestamp.toString(timestampFormat_);
    case IsCondensedRole:
        return item.isCondensed;
    case IsJsonValidRole:
        return item.isJsonValid;
    case ValueRole:
        return item.value;
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

void SciScrollbackModel::append(const QByteArray &message, bool isRequest)
{
    ScrollbackModelItem item;
    item.rawMessage = message;

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);
    item.isJsonValid = parseError.error == QJsonParseError::NoError;

    if (isRequest) {
        item.type = MessageType::Request;
    } else {
        item.type = MessageType::UnknownReply;

        if (item.isJsonValid && doc.isObject()) {
            QJsonObject root = doc.object();
            if (root.contains("notification")) {
                item.type = MessageType::NotificationReply;

                QString value = root.value("notification").toObject().value("value").toString();
                if (value.isEmpty() == false) {
                    item.value = value.toLower();
                }
            } else if (root.contains("ack")) {
                item.type = MessageType::AckReply;

                QString value = root.value("ack").toString();
                if (value.isEmpty() == false) {
                    item.value = value.toLower();
                }
            }
        }
    }

    if (item.isJsonValid) {
        item.condensedMessage = SGJsonFormatter::minifyJson(message);
        item.expandedMessage = SGJsonFormatter::prettifyJson(message, true);
    } else {
        //store invalid json message as is
        item.condensedMessage = message;
        item.expandedMessage = message;
    }

    item.timestamp = QDateTime::currentDateTime();
    item.isCondensed = condensedMode_;

    beginInsertRows(QModelIndex(), data_.length(), data_.length());

    data_.append(item);

    endInsertRows();

    emit countChanged();

    if (autoExportIsActive_) {
        qint64 bytesWritten = exportFile_.write(stringify(data_.last()));
        if (bytesWritten <= 0) {
            qCCritical(lcSci)  << "write failed" << exportFile_.errorString();
            setAutoExportErrorString(exportFile_.errorString());
            stopAutoExport();
        }
    }

    sanitize();
}

void SciScrollbackModel::setIsCondensedAll(bool condensed)
{
    for (auto &item : data_) {
        item.isCondensed = condensed;
    }

    emit dataChanged(
                createIndex(0, 0),
                createIndex(data_.length() - 1, 0),
                QVector<int>() << IsCondensedRole);
}

void SciScrollbackModel::setIsCondensed(int index, bool condensed)
{
    if (index < 0 || index >= data_.count()) {
        qCCritical(lcSci) << "index out of range";
        return;
    }

    if (data_.at(index).isCondensed == condensed) {
        return;
    }

    data_[index].isCondensed = condensed;

    emit dataChanged(
                createIndex(index, 0),
                createIndex(index, 0),
                QVector<int>() << IsCondensedRole);
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
    if (filePath.isEmpty()) {
        QString errorString(QStringLiteral("No file name specified"));
        qCCritical(lcSci) << errorString;
        return errorString;
    }

    QFileInfo fileInfo(filePath);
    if (fileInfo.isRelative()) {
        QString errorString(QStringLiteral("Cannot use relative path for export"));
        qCCritical(lcSci) << errorString;
        return errorString;
    }

    if (SGUtilsCpp::containsForbiddenCharacters(fileInfo.fileName())) {
        QString errorString("A filename cannot contain any of the following characters: " +  SGUtilsCpp::joinForbiddenCharacters());
        qCCritical(lcSci) << errorString;
        return errorString;
    }

    QSaveFile file(filePath);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(lcSci) << "open failed:" << file.errorString() << filePath;
        return file.errorString();
    }

    platform_->storeExportPath(filePath);
    setExportFilePath(filePath);

    qint64 bytesWritten = file.write(getTextForExport());
    if (bytesWritten <= 0) {
        qCCritical(lcSci) << "write failed" << file.errorString() << filePath;
        return file.errorString();
    }

    bool committed = file.commit();
    if (committed == false) {
        qCCritical(lcSci) << "commit failed:" << file.errorString() << filePath;
        return file.errorString();
    }

    return QString();
}

bool SciScrollbackModel::startAutoExport(const QString &filePath)
{
    QString errorString;

    if (autoExportIsActive_) {
        errorString = "Export already active";
        qCCritical(lcSci) << errorString;
        setAutoExportErrorString(errorString);
        return false;
    }

    if (filePath.isEmpty()) {
        errorString = "No file name specified";
        qCCritical(lcSci) << errorString;
        setAutoExportErrorString(errorString);
        return false;
    }

    QFileInfo fileInfo(filePath);
    if (fileInfo.isRelative()) {
        errorString = "Cannot use relative path for export";
        qCCritical(lcSci) << errorString;
        setAutoExportErrorString(errorString);
        return false;
    }

    if (SGUtilsCpp::containsForbiddenCharacters(fileInfo.fileName())) {
        errorString = "A filename cannot contain any of the following characters: " + SGUtilsCpp::joinForbiddenCharacters();
        qCCritical(lcSci) << errorString;
        setAutoExportErrorString(errorString);
        return false;
    }

    exportFile_.setFileName(filePath);
    bool ret = exportFile_.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Append);
    if (ret == false ) {
        errorString = exportFile_.errorString();
        qCCritical(lcSci) << "open failed" << filePath << errorString;
        setAutoExportErrorString(errorString);
        return false;
    }

    platform_->storeAutoExportPath(filePath);
    setAutoExportFilePath(filePath);

    setAutoExportIsActive(true);
    setAutoExportErrorString("");
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
    line += item.condensedMessage.toUtf8();
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

QString SciScrollbackModel::timestampFormat() const
{
    return timestampFormat_;
}

QHash<int, QByteArray> SciScrollbackModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciScrollbackModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(RawMessageRole, "rawMessage");
    roleByEnumHash_.insert(CondensedMessageRole, "condensedMessage");
    roleByEnumHash_.insert(ExpandedMessageRole, "expandedMessage");
    roleByEnumHash_.insert(TypeRole, "type");
    roleByEnumHash_.insert(TimestampRole, "timestamp");
    roleByEnumHash_.insert(IsCondensedRole, "isCondensed");
    roleByEnumHash_.insert(IsJsonValidRole, "isJsonValid");
    roleByEnumHash_.insert(ValueRole, "value");

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
