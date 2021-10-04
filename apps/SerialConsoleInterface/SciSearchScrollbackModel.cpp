#include "SciSearchScrollbackModel.h"

#include "logging/LoggingQtCategories.h"
#include "SciFilterScrollbackModel.h"
#include <chrono>


SciSearchScrollbackModel::SciSearchScrollbackModel(SciFilterScrollbackModel *filterModel, QObject *parent)
    : QAbstractProxyModel(parent),
      filterModel_(filterModel)
{
    delaySearchTimer_.setInterval(std::chrono::milliseconds(500));
    delaySearchTimer_.setSingleShot(true);

    connect(&delaySearchTimer_, &QTimer::timeout,
            this, &SciSearchScrollbackModel::updateSearchResuls);
}

QString SciSearchScrollbackModel::searchPattern() const
{
    return searchPattern_;
}

void SciSearchScrollbackModel::setSearchPattern(const QString &searchPattern)
{
    if (searchPattern_ == searchPattern) {
        return;
    }

    searchPattern_ = searchPattern;
    emit searchPatternChanged();

    if (delaySearchTimer_.isActive()) {
       return;
    }

     updateSearchResuls();
}

bool SciSearchScrollbackModel::isActive()
{
    return isActive_;
}

void SciSearchScrollbackModel::setSearchRole(int searchRole)
{
    if (searchRole_ == searchRole) {
        return;
    }

    searchRole_ = searchRole;
}

int SciSearchScrollbackModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return mapping_.proxyToSource.length();
}

int SciSearchScrollbackModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return 0;
}

QModelIndex SciSearchScrollbackModel::index(int row, int column, const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return createIndex(row, column);
}

QModelIndex SciSearchScrollbackModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)
    return QModelIndex();
}

void SciSearchScrollbackModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    if (sourceModel == static_cast<QObject *>(QAbstractProxyModel::sourceModel())) {
        return;
    }

    disconnectSlots();
    QAbstractProxyModel::setSourceModel(sourceModel);
    setIsActive(false);
}

QModelIndex SciSearchScrollbackModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    int proxyRow = mapping_.sourceToProxy.at(sourceIndex.row());
    return this->index(proxyRow, 0);
}

QModelIndex SciSearchScrollbackModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if (proxyIndex.row() < 0 || proxyIndex.row() > mapping_.proxyToSource.length()) {
        return QModelIndex();
    }

    int sourceRow = mapping_.proxyToSource.at(proxyIndex.row());

    return this->index(sourceRow, 0);
}

int SciSearchScrollbackModel::mapIndexToSource(int i)
{
    return mapToSource(index(i, 0, QModelIndex())).row();
}

int SciSearchScrollbackModel::mapIndexFromSource(int i)
{
    if (sourceModel() == nullptr) {
        return -1;
    }

    return mapFromSource(sourceModel()->index(i, 0)).row();
}

void SciSearchScrollbackModel::sourceRowsInserted(
        const QModelIndex &sourceParent,
        int start,
        int end)
{
    Q_UNUSED(sourceParent)

    if (start < 0 || end < 0) {
        return;
    }

    if (start < this->sourceModel()->rowCount() - 1) {
        qCWarning(logCategorySci) << "Only append is supported";
    }

    //expand mapping
    mapping_.sourceToProxy.insert(start, end - start + 1, -1);

    //figure out which rows to add into mapping based on filter
    QVector<int> sourceRows;
    for (int i = start; i <= end; ++i) {
        if (filterAcceptsRow(i)) {
            sourceRows.append(i);
        }
    }

    if (sourceRows.isEmpty()) {
        return;
    }

    int startInProxy = mapping_.proxyToSource.size();

    //insert new rows
    beginInsertRows(QModelIndex(), startInProxy, startInProxy + sourceRows.size() - 1);

    for (int i = 0; i < sourceRows.size(); ++i) {
        mapping_.proxyToSource.insert(startInProxy + i, sourceRows.at(i));
        mapping_.sourceToProxy.replace(sourceRows.at(i), startInProxy + i);
    }

    endInsertRows();
}

void SciSearchScrollbackModel::sourceRowsAboutToBeRemoved(
        const QModelIndex &sourceParent,
        int start,
        int end)
{
    Q_UNUSED(sourceParent)

    if (start < 0 || end < 0 || start > end) {
        return;
    }

    int deltaRowCount = end - start + 1;

    //figure out which rows to remove from mapping based on filter
    QVector<int> sourceRows;
    for (int i = end; i >= start; --i) {
        if (mapping_.sourceToProxy.at(i) >= 0) {
            sourceRows.append(i);
        }
    }

    //update existing items in source_to_proxy
    for (int i = end+1; i < mapping_.sourceToProxy.size(); ++i) {
        int proxyRow = mapping_.sourceToProxy.at(i);
        if (proxyRow >= 0) {
            mapping_.sourceToProxy.replace(i, proxyRow - sourceRows.size());
        }
    }

    //find where to remove old rows in proxy_to_source
    int endInProxy = 0;
    for (int i = end; i >= 0; --i) {
        int proxyRow = mapping_.sourceToProxy.at(i);
        if (proxyRow >= 0) {
            endInProxy = proxyRow;
            break;
        }
    }

    //update existing items in proxy_to_source
    for (int i = endInProxy+1; i < mapping_.proxyToSource.size(); ++i) {
        mapping_.proxyToSource.replace(i, mapping_.proxyToSource.at(i) - deltaRowCount);
    }

    //remove mapping from source_to_proxy
    mapping_.sourceToProxy.remove(start, deltaRowCount);

    if (sourceRows.isEmpty()) {
        return;
    }

    beginRemoveRows(QModelIndex(), endInProxy - sourceRows.size() + 1 , endInProxy);

    mapping_.proxyToSource.remove(endInProxy - sourceRows.size() + 1, sourceRows.size());

    endRemoveRows();
}


void SciSearchScrollbackModel::sourceModelAboutToBeReset()
{
    beginResetModel();
}

void SciSearchScrollbackModel::sourceModelReset()
{
    resolveNewMapping();

    endResetModel();
}

void SciSearchScrollbackModel::sourceLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    emit layoutAboutToBeChanged(sourceParents, hint);
}

void SciSearchScrollbackModel::sourceLayoutChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    resolveNewMapping();

    emit layoutChanged(sourceParents, hint);
}

void SciSearchScrollbackModel::filterInvalidatedHandler()
{
    beginResetModel();
    resolveNewMapping();
    endResetModel();
}

void SciSearchScrollbackModel::updateSearchResuls()
{
    if (effectiveSearchPattern_ == searchPattern_) {
        return;
    }

    effectiveSearchPattern_ = searchPattern_;
    delaySearchTimer_.start();

    if (effectiveSearchPattern_.isEmpty()) {
        disconnectSlots();
        beginResetModel();
        mapping_.clear();
        setIsActive(false);
        endResetModel();
    } else {
        if (isActive_ == false) {
            connectSlots();
        }

        beginResetModel();
        resolveNewMapping();
        setIsActive(true);
        endResetModel();
    }
}

bool SciSearchScrollbackModel::filterAcceptsRow(int sourceRow) const
{
    if (effectiveSearchPattern_.isEmpty()) {
        return false;
    }

    if (filterModel_->filterAcceptsRow(sourceRow) == false) {
        return false;
    }

    QModelIndex index = sourceModel()->index(sourceRow, 0);
    QString value = sourceModel()->data(index, searchRole_).toString();

    return value.contains(effectiveSearchPattern_, Qt::CaseInsensitive);
}

void SciSearchScrollbackModel::resolveNewMapping()
{
    mapping_.clear();

    for (int i = 0; i < sourceModel()->rowCount(); ++i) {
        if (filterAcceptsRow(i)) {
            mapping_.proxyToSource.append(i);
            mapping_.sourceToProxy.append(mapping_.proxyToSource.length() - 1);
        } else {
            mapping_.sourceToProxy.append(-1);
        }
    }
}

void SciSearchScrollbackModel::setIsActive(bool isActive)
{
    if (isActive_ == isActive) {
        return;
    }

    isActive_ = isActive;
    emit isActiveChanged();
}

void SciSearchScrollbackModel::connectSlots()
{
    if (QAbstractProxyModel::sourceModel() == nullptr) {
        return;
    }

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::rowsInserted,
            this, &SciSearchScrollbackModel::sourceRowsInserted);

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::rowsAboutToBeRemoved,
            this, &SciSearchScrollbackModel::sourceRowsAboutToBeRemoved);

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::modelAboutToBeReset,
            this, &SciSearchScrollbackModel::sourceModelAboutToBeReset);

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::modelReset,
            this, &SciSearchScrollbackModel::sourceModelReset);

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::layoutAboutToBeChanged,
            this, &SciSearchScrollbackModel::sourceLayoutAboutToBeChanged);

    connect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::layoutChanged,
            this, &SciSearchScrollbackModel::sourceLayoutChanged);

    connect(filterModel_, &SciFilterScrollbackModel::filterInvalidated,
            this, &SciSearchScrollbackModel::filterInvalidatedHandler);
}

void SciSearchScrollbackModel::disconnectSlots()
{
    if (QAbstractProxyModel::sourceModel() == nullptr) {
        return;
    }

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::rowsInserted,
               this, &SciSearchScrollbackModel::sourceRowsInserted);

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::rowsAboutToBeRemoved,
               this, &SciSearchScrollbackModel::sourceRowsAboutToBeRemoved);

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::modelAboutToBeReset,
               this, &SciSearchScrollbackModel::sourceModelAboutToBeReset);

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::modelReset,
               this, &SciSearchScrollbackModel::sourceModelReset);

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::layoutAboutToBeChanged,
               this, &SciSearchScrollbackModel::sourceLayoutAboutToBeChanged);

    disconnect(QAbstractProxyModel::sourceModel(), &QAbstractItemModel::layoutChanged,
               this, &SciSearchScrollbackModel::sourceLayoutChanged);

    disconnect(filterModel_, &SciFilterScrollbackModel::filterInvalidated,
            this, &SciSearchScrollbackModel::filterInvalidatedHandler);
}
