#include "SciFilterScrollbackModel.h"
#include "SciScrollbackModel.h"

#include <QDebug>

SciFilterScrollbackModel::SciFilterScrollbackModel(QObject *parent)
    : SGSortFilterProxyModel(parent)
{
}

void SciFilterScrollbackModel::setSourceModel(SciScrollbackModel *sourceModel)
{
    SGSortFilterProxyModel::setSourceModel(sourceModel);
    sourceModel_ = sourceModel;
}

QVariant SciFilterScrollbackModel::filterList()
{
    return filterList_;
}

bool SciFilterScrollbackModel::disableAllFiltering()
{
    return disableAllFiltering_;
}

void SciFilterScrollbackModel::invalidateFilter(QVariantList filterList, bool disableAllFiltering)
{
    setFilterList(filterList);
    setDisableAllFiltering(disableAllFiltering);

    SGSortFilterProxyModel::invalidateFilter();
    emit filterInvalidated();
}

bool SciFilterScrollbackModel::filterAcceptsRow(int sourceRow)
{
    return filterAcceptsRow(sourceRow, QModelIndex());
}

bool SciFilterScrollbackModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    if (disableAllFiltering_) {
        return true;
    }

    if (filterConditions_.isEmpty()) {
        return true;
    }

    if (SciScrollbackModel::NotificationReply != sourceModel_->data(createIndex(sourceRow, 1), SciScrollbackModel::TypeRole)) {
        return true;
    }

    QString value = sourceModel_->data(createIndex(sourceRow, 1), SciScrollbackModel::ValueRole).toString();

    for (const auto &filterCondition : filterConditions_) {
        if (filterCondition.type == "contains" && value.contains(filterCondition.patern, Qt::CaseInsensitive)) {
            return false;
        }
        if (filterCondition.type == "equal" && value.contains(filterCondition.patern, Qt::CaseInsensitive)) {
            return false;
        }
        if (filterCondition.type == "startswith" && value.startsWith(filterCondition.patern, Qt::CaseInsensitive)) {
            return false;
        }
        if (filterCondition.type == "endswith" && value.endsWith(filterCondition.patern, Qt::CaseInsensitive)) {
            return false;
        }
    }

    return true;
}

void SciFilterScrollbackModel::setFilterList(QVariantList filterList)
{
    if (filterList_ == filterList) {
        return;
    }

    filterList_ = filterList;
    emit filterListChanged();

    filterConditions_.clear();

    for (const auto &filterObject: qAsConst(filterList)) {
        FilterConditionItem item;
        item.patern = filterObject.toMap().value("filter_string").toString();
        item.type = filterObject.toMap().value("condition").toString();
        filterConditions_ << item;
    }
}

void SciFilterScrollbackModel::setDisableAllFiltering(bool disableAllFiltering)
{
    if (disableAllFiltering_ == disableAllFiltering) {
        return;
    }

    disableAllFiltering_ = disableAllFiltering;
    emit disableAllFilteringChanged();
}
