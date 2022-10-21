/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "QtFilterRulesModel.h"
#include "logging/LoggingQtCategories.h"

QtFilterRulesModel::QtFilterRulesModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

void QtFilterRulesModel::addItem(const QString newRule)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    filterRulesList_ << newRule;
    endInsertRows();

    emit countChanged();
}

void QtFilterRulesModel::removeItem(int index) {
    if(index >= 0 && index < filterRulesList_.length()) {
        beginRemoveRows(QModelIndex(), index, index);
        filterRulesList_.removeAt(index);
        endRemoveRows();

        emit countChanged();
    } else {
        qCDebug(lcLcu) << "Item not selected or index out of range";
        return;
    }
}

void QtFilterRulesModel::createModel(QString qtFilterRules)
{
    beginResetModel();
    filterRulesList_ = qtFilterRules.split("\\n");
    endResetModel();

    qCDebug(lcLcu) << filterRulesList_;

    if (filterRulesList_.empty()) {
        qCWarning(lcLcu) << "List empty.";
    }

    emit countChanged();
}

QString QtFilterRulesModel::joinItems()
{
    qCDebug(lcLcu) << "Removed " + QString::number(filterRulesList_.removeAll("")) + " items from qtFilterRules list.";
    return filterRulesList_.join("\n");
}

void QtFilterRulesModel::modifyList(int index, QString newText)
{
    if (index < 0 || index >= filterRulesList_.count()) {
        qCCritical(lcLcu) << "Index out of range";
        return;
    }

    filterRulesList_[index] = newText;
    qCInfo(lcLcu) << filterRulesList_;
}

int QtFilterRulesModel::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return filterRulesList_.count();
}

QVariant QtFilterRulesModel::data(const QModelIndex & index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= filterRulesList_.count()) {
        qCCritical(lcLcu) << "Index out of range";
        return QVariant();
    }

    switch (role) {
    case FilterNameRole:
        return filterRulesList_.at( index.row() );
    }

    return QVariant();
}

int QtFilterRulesModel::count() const
{
    return filterRulesList_.length();
}

QHash<int, QByteArray> QtFilterRulesModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[FilterNameRole] = "filterName";
    return names;
}
