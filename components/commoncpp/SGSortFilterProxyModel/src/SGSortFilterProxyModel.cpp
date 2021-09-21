/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGSortFilterProxyModel.h"
#include <QDebug>

SGSortFilterProxyModel::SGSortFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent),
      complete_(true),
      naturalSort_(true),
      sortAscending_(true),
      invokeCustomFilter_(false),
      invokeCustomLessThan_(false),
      sortEnabled_(true)
{
    connect(this, &SGSortFilterProxyModel::rowsInserted, this, &SGSortFilterProxyModel::countChanged);
    connect(this, &SGSortFilterProxyModel::rowsRemoved, this, &SGSortFilterProxyModel::countChanged);
    connect(this, &SGSortFilterProxyModel::modelReset, this, &SGSortFilterProxyModel::countChanged);
    connect(this, &SGSortFilterProxyModel::layoutChanged, this, &SGSortFilterProxyModel::countChanged);

    setCaseSensitive(false);

    collator_.setCaseSensitivity(sortCaseSensitivity());
    collator_.setNumericMode(true);
}

int SGSortFilterProxyModel::count() const
{
    return rowCount();
}

QObject *SGSortFilterProxyModel::sourceModel() const
{
    return QSortFilterProxyModel::sourceModel();
}

void SGSortFilterProxyModel::setSourceModel(QObject *sourceModel)
{
    if (sourceModel == static_cast<QObject *>(QSortFilterProxyModel::sourceModel())) {
        return;
    }
    disconnectFromSourceModel();

    QAbstractItemModel *m = qobject_cast<QAbstractItemModel *>(sourceModel);
    if (m != nullptr && m->roleNames().count() == 0) {
        /* In case source model is a ListModel, it gains roles only after first item is inserted. */
        connect(m, &QAbstractItemModel::rowsInserted, this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);
        connect(m, &QAbstractItemModel::modelReset, this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);
        connect(m, &QAbstractItemModel::layoutChanged, this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);
    }

    QSortFilterProxyModel::setSourceModel(m);

    doSetFilterRole();
    doSetSortRole();

    emit sourceModelChanged();
}

QString SGSortFilterProxyModel::sortRole() const
{
    return sortRole_;
}

void SGSortFilterProxyModel::setSortRole(const QString &role)
{
    if (sortRole_ != role) {
        sortRole_ = role;
        emit sortRoleChanged();

        doSetSortRole();
    }
}

QString SGSortFilterProxyModel::filterRole() const
{
    return filterRole_;
}

void SGSortFilterProxyModel::setFilterRole(const QString &role)
{
    if (filterRole_ != role) {
        filterRole_ = role;
        emit filterRoleChanged();

        doSetFilterRole();
    }
}

QString SGSortFilterProxyModel::filterPattern() const
{
    return filterRegExp().pattern();
}

void SGSortFilterProxyModel::setFilterPattern(const QString &filter)
{
    if (filterPattern() != filter) {
        setFilterRegExp(QRegExp(filter,
                                QSortFilterProxyModel::filterCaseSensitivity(),
                                static_cast<QRegExp::PatternSyntax>(filterPatternSyntax())));

        emit filterPatternChanged();
    }
}

SGSortFilterProxyModel::FilterSyntax SGSortFilterProxyModel::filterPatternSyntax() const
{
    return static_cast<FilterSyntax>(filterRegExp().patternSyntax());
}

void SGSortFilterProxyModel::setFilterPatternSyntax(SGSortFilterProxyModel::FilterSyntax syntax)
{
    if (filterPatternSyntax() != syntax) {
        setFilterRegExp(QRegExp(filterPattern(),
                                QSortFilterProxyModel::filterCaseSensitivity(),
                                static_cast<QRegExp::PatternSyntax>(syntax)));

        emit filterPatternSyntaxChanged();
    }
}

bool SGSortFilterProxyModel::naturalSort() const
{
    return naturalSort_;
}

void SGSortFilterProxyModel::setNaturalSort(bool naturalSort)
{
    if (naturalSort_ != naturalSort) {
        naturalSort_ = naturalSort;
        if (complete_) {
            invalidate();
        }

        emit naturalSortChanged();
    }
}

bool SGSortFilterProxyModel::sortAscending() const
{
    return sortAscending_;
}

void SGSortFilterProxyModel::setSortAscending(bool sortAscending)
{
    if (sortAscending_ != sortAscending) {
        sortAscending_ = sortAscending;
        emit sortAscendingChanged();

        doSort();
    }
}

bool SGSortFilterProxyModel::caseSensitive() const
{
    return sortCaseSensitivity() == Qt::CaseSensitive;
}

void SGSortFilterProxyModel::setCaseSensitive(bool sensitive)
{
    if (caseSensitive() != sensitive) {
        Qt::CaseSensitivity sensitivity = sensitive ? Qt::CaseSensitive : Qt::CaseInsensitive;
        collator_.setCaseSensitivity(sensitivity);
        setFilterCaseSensitivity(sensitivity);
        setSortCaseSensitivity(sensitivity);

        emit caseSensitiveChanged();
    }
}

bool SGSortFilterProxyModel::invokeCustomFilter() const
{
    return invokeCustomFilter_;
}

void SGSortFilterProxyModel::setInvokeCustomFilter(bool invokeCustomFilter)
{
    if (invokeCustomFilter_ != invokeCustomFilter) {
        invokeCustomFilter_ = invokeCustomFilter;
        if (complete_) {
            invalidateFilter();
        }

        emit invokeCustomFilterChanged();
    }
}

bool SGSortFilterProxyModel::invokeCustomLessThan() const
{
    return invokeCustomLessThan_;
}

void SGSortFilterProxyModel::setInvokeCustomLessThan(bool invokeCustomLessThan)
{
    if (invokeCustomLessThan_ != invokeCustomLessThan) {
        invokeCustomLessThan_ = invokeCustomLessThan;
        if (complete_) {
            invalidate();
        }

        emit invokeCustomLessThanChanged();
    }
}

bool SGSortFilterProxyModel::sortEnabled()
{
    return sortEnabled_;
}

void SGSortFilterProxyModel::setSortEnabled(bool sortEnabled)
{
    if (sortEnabled_ != sortEnabled) {
        sortEnabled_ = sortEnabled;
        emit sortEnabledChanged();

        doSort();
    }
}

void SGSortFilterProxyModel::classBegin()
{
    complete_ = false;
}

void SGSortFilterProxyModel::componentComplete()
{
    complete_ = true;
    doSetFilterRole();
    doSetSortRole();
    doSort();
}

int SGSortFilterProxyModel::naturalCompare(const QString &left, const QString &right) const
{
    return collator_.compare(left, right);
}

QVariant SGSortFilterProxyModel::get(int row) const
{
    QVariantMap value;

    if (row >= 0 && row < count()) {
        QHash<int, QByteArray> roles = roleNames();
        QHashIterator<int, QByteArray> iterator(roles);
        while (iterator.hasNext()) {
            iterator.next();
            value.insert(QString::fromUtf8(iterator.value()), data(index(row, 0), iterator.key()));
        }
    }

    return value;
}

int SGSortFilterProxyModel::mapIndexToSource(int i)
{
    return mapToSource(index(i, 0, QModelIndex())).row();
}

int SGSortFilterProxyModel::mapIndexFromSource(int i)
{
    if (sourceModel() == nullptr) {
        return -1;
    }

    return mapFromSource(QSortFilterProxyModel::sourceModel()->index(i, 0)).row();
}

bool SGSortFilterProxyModel::matches(const QString &text) const
{
    return filterRegExp().indexIn(text) != -1;
}

int SGSortFilterProxyModel::roleKey(const QString &role) const
{
    QHash<int, QByteArray> roles = roleNames();
    QHashIterator<int, QByteArray> i(roles);
    while (i.hasNext()) {
        i.next();
        if (QString(i.value()) == role) {
            return i.key();
        }
    }

    return -1;
}

QHash<int, QByteArray> SGSortFilterProxyModel::roleNames() const
{
    if (sourceModel() == nullptr) {
        return QHash<int, QByteArray>();
    }

    return QSortFilterProxyModel::sourceModel()->roleNames();
}

bool SGSortFilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (invokeCustomFilter_) {
        return callFilterAcceptsRow(sourceRow);
    }

    return QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

bool SGSortFilterProxyModel::lessThan(const QModelIndex &sourceLeft,
                                      const QModelIndex &sourceRight) const
{
    if (invokeCustomLessThan_) {
        return callLessThan(sourceLeft.row(), sourceRight.row());
    }

    if (naturalSort_) {
        QString leftStr = QSortFilterProxyModel::sourceModel()
                              ->data(sourceLeft, QSortFilterProxyModel::sortRole())
                              .toString();
        QString rightStr = QSortFilterProxyModel::sourceModel()
                               ->data(sourceRight, QSortFilterProxyModel::sortRole())
                               .toString();
        return naturalCompare(leftStr, rightStr) < 0;
    }

    return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
}

void SGSortFilterProxyModel::doSetSortRole()
{
    if (!complete_ || sourceModel() == nullptr) {
        return;
    }

    int role = roleNames().key(sortRole_.toUtf8(), -1);
    if (role >= 0) {
        QSortFilterProxyModel::setSortRole(role);
    }
}

void SGSortFilterProxyModel::doSetFilterRole()
{
    if (!sourceModel()) {
        return;
    }

    int role = roleNames().key(filterRole_.toUtf8(), -1);
    if (role >= 0) {
        QSortFilterProxyModel::setFilterRole(role);
    }
}

bool SGSortFilterProxyModel::callFilterAcceptsRow(int sourceRow) const
{
    if (metaObject()->indexOfMethod("filterAcceptsRow(QVariant)") != -1) {
        QVariant accepted = false;
        QMetaObject::invokeMethod(
                    (QObject *)this,
                    "filterAcceptsRow",
                    Q_RETURN_ARG(QVariant, accepted),
                    Q_ARG(QVariant, sourceRow));

        return accepted.toBool();
    } else {
        qDebug() << "Cannot call filterAcceptsRow(QVariant)";
    }

    return false;
}

bool SGSortFilterProxyModel::callLessThan(int leftRow, int rightRow) const
{
    if (metaObject()->indexOfMethod("lessThan(QVariant,QVariant)") != -1) {
        QVariant retVal = false;
        QMetaObject::invokeMethod(
                    (QObject *)this,
                    "lessThan",
                    Q_RETURN_ARG(QVariant, retVal),
                    Q_ARG(QVariant, leftRow),
                    Q_ARG(QVariant, rightRow));

        return retVal.toBool();
    } else {
        qDebug() << "Cannot call lessThen(QVariant, QVariant)";
    }

    return false;
}

void SGSortFilterProxyModel::disconnectFromSourceModel()
{
    if (QSortFilterProxyModel::sourceModel()) {
        disconnect(QSortFilterProxyModel::sourceModel(), &QAbstractItemModel::rowsInserted,
                   this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);

        disconnect(QSortFilterProxyModel::sourceModel(), &QAbstractItemModel::modelReset,
                   this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);

        disconnect(QSortFilterProxyModel::sourceModel(), &QAbstractItemModel::layoutChanged,
                   this, &SGSortFilterProxyModel::sourceModelRolesMaybeChanged);
    }
}

void SGSortFilterProxyModel::doSort()
{
    if (complete_ == false) {
        return;
    }

    int column = sortEnabled_ ? 0 : -1;
    Qt::SortOrder order = sortAscending_ ? Qt::AscendingOrder : Qt::DescendingOrder;

    sort(column, order);
}

void SGSortFilterProxyModel::sourceModelRolesMaybeChanged()
{
    if (QSortFilterProxyModel::sourceModel()->roleNames().count() > 0) {
        doSetFilterRole();
        doSetSortRole();
        disconnectFromSourceModel();
    }
}
