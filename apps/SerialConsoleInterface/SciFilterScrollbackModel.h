/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <SGSortFilterProxyModel.h>

class SciScrollbackModel;

class SciFilterScrollbackModel: public SGSortFilterProxyModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciFilterScrollbackModel)

    Q_PROPERTY(QVariant filterList READ filterList NOTIFY filterListChanged)
    Q_PROPERTY(bool disableAllFiltering READ disableAllFiltering NOTIFY disableAllFilteringChanged)

public:
    struct FilterConditionItem {
        QString type;
        QString patern;
    };

    explicit SciFilterScrollbackModel(QObject *parent = nullptr);
    void setSourceModel(SciScrollbackModel *sourceModel);
    QVariant filterList() const;
    bool disableAllFiltering() const;
    Q_INVOKABLE void invalidateFilter(QVariantList filterList, bool disableAllFiltering);
    bool filterAcceptsRow(int sourceRow) const;

signals:
    void filterListChanged();
    void disableAllFilteringChanged();
    void filterInvalidated();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    void setFilterList(QVariantList filterList);
    void setDisableAllFiltering(bool disableAllFiltering);

    QVariantList filterList_;
    QList<FilterConditionItem> filterConditions_;

    bool disableAllFiltering_ = false;

    //pointer to derived class so we dont have to cast sourceModel() every time
    SciScrollbackModel *sourceModel_;
};
