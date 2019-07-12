#include "SGSortFilterProxyModel.h"
#include <QDebug>

SGSortFilterProxyModel::SGSortFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent),
      complete_(true),
      naturalSort_(true),
      sortAscending_(true),
      invokeCustomFilter_(false),
      invokeCustomLessThan_(false)
{
    connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this,SIGNAL(countChanged()));
    connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
    connect(this, SIGNAL(layoutChanged()), this, SIGNAL(countChanged()));

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

    QAbstractItemModel *m = qobject_cast<QAbstractItemModel *>(sourceModel);
    if (m != nullptr) {
        disconnectFromSourceModel();

        /* In case source model is a ListModel, it does not have roles until first item is inserted,
           so we have to wait for it */
        connect(m, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this,
                SLOT(sourceModelRolesMaybeChanged()));
        connect(m, SIGNAL(modelReset()), this, SLOT(sourceModelRolesMaybeChanged()));
        connect(m, SIGNAL(layoutChanged()), this, SLOT(sourceModelRolesMaybeChanged()));
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
        if (complete_) {
            QSortFilterProxyModel::sort(0, sortAscending_ ? Qt::AscendingOrder : Qt::DescendingOrder);
        }

        emit sortAscendingChanged();
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

void SGSortFilterProxyModel::classBegin()
{
    complete_ = false;
}

void SGSortFilterProxyModel::componentComplete()
{
    complete_ = true;
    doSetFilterRole();
    doSetSortRole();

    QSortFilterProxyModel::sort(0, sortAscending_ ? Qt::AscendingOrder : Qt::DescendingOrder);
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

    QModelIndex sourceIndex =
        QSortFilterProxyModel::sourceModel()->index(sourceRow, 0, sourceParent);
    QString value = QSortFilterProxyModel::sourceModel()->data(sourceIndex, QSortFilterProxyModel::filterRole()).toString();
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
    if (role >= 0 && role != QSortFilterProxyModel::filterRole()) {
        QSortFilterProxyModel::setSortRole(role);
    }
}

void SGSortFilterProxyModel::doSetFilterRole()
{
    if (!sourceModel()) {
        return;
    }

    int role = roleNames().key(filterRole_.toUtf8(), -1);
    if (role >= 0 && role != QSortFilterProxyModel::filterRole()) {
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
        disconnect(QSortFilterProxyModel::sourceModel(), nullptr, this, SLOT(sourceModelRolesMaybeChanged()));
    }
}

void SGSortFilterProxyModel::sourceModelRolesMaybeChanged()
{
    if (QSortFilterProxyModel::sourceModel()->roleNames().count() > 0) {
        doSetFilterRole();
        doSetSortRole();
        disconnectFromSourceModel();
    }
}
