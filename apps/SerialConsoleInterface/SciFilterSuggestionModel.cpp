/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciFilterSuggestionModel.h"
#include <QDebug>
#include <QJsonDocument>
#include "logging/LoggingQtCategories.h"

SciFilterSuggestionModel::SciFilterSuggestionModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

SciFilterSuggestionModel::~SciFilterSuggestionModel()
{
}

int SciFilterSuggestionModel::count() const
{
    return suggestionList_.length();
}

int SciFilterSuggestionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return suggestionList_.length();
}

QVariant SciFilterSuggestionModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= suggestionList_.count()) {
        return QVariant();
    }

    const SciFilterSuggestionModelItem &item = suggestionList_.at(row);

    switch (role) {
        case SuggestionRole:
            return item.suggestion;
    }

    return QVariant();
}

QVariantMap SciFilterSuggestionModel::get(int row)
{
    if (row < 0 || row >= suggestionList_.count()) {
        return QVariantMap();
    }

    QVariantMap map;
    map["suggestion"] = suggestionList_.at(row).suggestion;

    return map;
}

QHash<int, QByteArray> SciFilterSuggestionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SuggestionRole] = "suggestion";

    return roles;
}

void SciFilterSuggestionModel::add(const QByteArray &message)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);
    QJsonValue notification = doc["notification"];
    if (parseError.error == QJsonParseError::NoError && notification != QJsonValue::Undefined) {
        QString value = notification["value"].toString().toLower();
        // check if same notification is already present
        int index = -1;
        for (int i = 0; i < suggestionList_.count(); ++i) {
            if (suggestionList_.at(i).suggestion.toLower() == value) {
                index = i;
                break;
            }
        }

        // if suggestion is not present add it
        if (index < 0) {
            beginInsertRows(QModelIndex(), suggestionList_.length(), suggestionList_.length());

            SciFilterSuggestionModelItem item;
            item.suggestion = value;
            suggestionList_.append(item);

            endInsertRows();
            emit countChanged();
        }
    }
}
