#include "SciSuggestionFilterModel.h"
#include "logging/LoggingQtCategories.h"
#include <QDebug>
#include <QJsonDocument>

#include "SciPlatform.h"

SciSuggestionFilterModel::SciSuggestionFilterModel(SciPlatform *platform)
    : QAbstractListModel(platform),
      platform_(platform)
{
}

SciSuggestionFilterModel::~SciSuggestionFilterModel()
{
}

int SciSuggestionFilterModel::count() const
{
  return suggestionList_.length();
}

QStringList SciSuggestionFilterModel::getSuggestionList() const
{
    QStringList list;
    for (const auto &item : suggestionList_) {
        list.append(item.suggestion);
    }

    return list;
}

int SciSuggestionFilterModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
   return suggestionList_.length();
}

QVariant SciSuggestionFilterModel::data(const QModelIndex &index, int role) const
{
   int row = index.row();
    if (row < 0 || row >= suggestionList_.count()) {
        return QVariant();
    }

    const SciSuggestionFilterModelItem &item = suggestionList_.at(row);

    switch (role) {
    case SuggestionRole:
        return item.suggestion;
    }

    return QVariant();
}
    

QVariantMap SciSuggestionFilterModel::get(int row)
{
    if (row < 0 || row >= suggestionList_.count()) {
        return QVariantMap();
    }

    QVariantMap map;
    map["name"] = suggestionList_.at(row).suggestion;

    return map;
}

QHash<int, QByteArray> SciSuggestionFilterModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SuggestionRole] = "name";

    return roles;
}

void SciSuggestionFilterModel::add(const QByteArray &message)
{ 
    QJsonDocument doc = QJsonDocument::fromJson(message);
    QJsonValue notification = doc[QLatin1String("notification")];
    if (notification != QJsonValue::Undefined) {
        QString value = notification[QLatin1String("value")].toString();
        // check if same notification is already present
        int index = -1;
        for (int i = 0; i < suggestionList_.count(); ++i) {
            if (suggestionList_.at(i).suggestion == value) {
                index = i;
                break;
            }
        }
        
        // if suggestion is not present add it
        if (index < 0) {
          beginInsertRows(QModelIndex(), suggestionList_.length(), suggestionList_.length());

          SciSuggestionFilterModelItem item;
          item.suggestion = value;
          suggestionList_.append(item);

          endInsertRows();
          emit countChanged();
        }
    } 
}
