/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "DocumentListModel.h"

#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>

DocumentListModel::DocumentListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

DocumentListModel::~DocumentListModel()
{
    clear();
}

QVariant DocumentListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    DocumentItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case UriRole:
        return item->uri;
    case PrettyNameRole:
        return item->prettyName;
    case DirnameRole:
        return item->dirname;
    case PreviousDirnameRole:
        return data(DocumentListModel::index(row - 1, 0), DirnameRole);
    case HistoryStateRole:
        return item->historyState;
    }

    return QVariant();
}

int DocumentListModel::count() const
{
    return data_.length();
}

int DocumentListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.length();
}

void DocumentListModel::populateModel(const QList<DocumentItem *> &list)
{
    beginResetModel();

    clear(false);
    data_.append(list);

    endResetModel();

    emit countChanged();
}

void DocumentListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
        emit countChanged();
    }
}

QString DocumentListModel::getFirstUri()
{
    if (data_.length() == 0) {
        return QString();
    }

    return data_.at(0)->uri;
}

QString DocumentListModel::dirname(int index) {
    if (index < 0 || index >= data_.count()) {
        return QString();
    }

    return data_.at(index)->dirname;
}

QHash<int, QByteArray> DocumentListModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[UriRole] = "uri";
    names[PrettyNameRole] = "prettyName";
    names[DirnameRole] = "dirname";
    names[PreviousDirnameRole] = "previousDirname";
    names[HistoryStateRole] = "historyState";

    return names;
}

QString DocumentListModel::getMD5()
{
    QJsonObject jsonObj;
    for (const auto &item : data_) {
        jsonObj.insert(item->dirname + "_" + item->prettyName, item->md5);
    }
    QJsonDocument doc(jsonObj);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    return strJson;
}

void DocumentListModel::setHistoryState(const QString &doc, const QString &state)
{
    for (int i = 0; i < data_.length(); ++i) {
        DocumentItem* item = data_.at(i);
        if (item == nullptr) {
            qCCritical(logCategoryDocumentManager) << "item is empty" << i;
            continue;
        }

        if (item->dirname + "_" + item->prettyName == doc) {
            item->historyState = state;
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
            return;
        }
    }
}

void DocumentListModel::setAllHistoryStateToSeen()
{
    for (const auto &item : data_) {
        item->historyState = "seen";
    }
}

bool DocumentListModel::anyItemsUnseen()
{
    for (const auto &item : data_) {
        if (item->historyState != "seen") {
            return true;
        }
    }
    return false;
}

QStringList DocumentListModel::getItemsUnseen()
{
    QStringList ls;
    for (const auto &item : data_) {
        if (item->historyState != "seen") {
            ls << item->prettyName;
        }
    }
    return ls;
}