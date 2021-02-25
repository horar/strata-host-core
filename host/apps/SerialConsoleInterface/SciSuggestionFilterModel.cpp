#include "SciSuggestionFilterModel.h"
#include "SciPlatform.h"

SciSuggestionFilterModel::SciSuggestionFilterModel(SciPlatform *platform)
    : QAbstractListModel(platform),
      platform_(platform)
{
  fillSuggestionList();
}

SciSuggestionFilterModel::~SciSuggestionFilterModel()
{
}

void SciSuggestionFilterModel::fillSuggestionList() 
{
  suggestionList_ << "test1" << "test2" << "test3";
}

int SciSuggestionFilterModel::getSuggestionListCount() const
{
  return suggestionList_.count();
}

QStringList SciSuggestionFilterModel::getSuggestionList() const
{
  return suggestionList_;
}

int SciSuggestionFilterModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return suggestionList_.length();
}

QVariant SciSuggestionFilterModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || suggestionList_.size() > 0)
        return QVariant();

    switch (role) {
    case SuggestionRole:
        return QVariant(suggestionList_.at(index.row()));
    }
    return QVariant();
}

QVariantMap SciSuggestionFilterModel::get(int row)
{
    if (row < 0 || row >= suggestionList_.count()) {
        return QVariantMap();
    }

    QVariantMap map;
    map["name"] = suggestionList_.at(row);

    return map;
}

QHash<int, QByteArray> SciSuggestionFilterModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SuggestionRole] = "name";

    return roles;
}
