/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QAbstractProxyModel>
#include <QTimer>

class SciFilterScrollbackModel;

/*
This is a custom implementation of searching inside SciScrollbackModel. It is much faster than any model derived from QSortFilterProxyModel,
but it also has its limitations. New items can be only appended, existing items can be removed only from beginning. Any other change
has to be handled by model reset.
*/
class SciSearchScrollbackModel: public QAbstractProxyModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciSearchScrollbackModel)

    Q_PROPERTY(QString searchPattern READ searchPattern WRITE setSearchPattern NOTIFY searchPatternChanged)
    /* model handles changes in source model only if search pattern string is non-empty */
    Q_PROPERTY(bool isActive READ isActive NOTIFY isActiveChanged)

public:
    struct Mapping {
        QVector<int> proxyToSource;
        QVector<int> sourceToProxy;

        void clear() {
            proxyToSource.clear();
            sourceToProxy.clear();
        }
    };

    explicit SciSearchScrollbackModel(SciFilterScrollbackModel *filterModel, QObject *parent = nullptr);

    QString searchPattern() const;
    void setSearchPattern(const QString &searchPattern);
    bool isActive() const;
    void setSearchRole(int searchRole);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    void setSourceModel(QAbstractItemModel *sourceModel) override;
    QModelIndex mapFromSource(const QModelIndex &sourceIndex) const override;
    QModelIndex mapToSource(const QModelIndex &proxyIndex) const override;

    Q_INVOKABLE int mapIndexToSource(int i) const;
    Q_INVOKABLE int mapIndexFromSource(int i) const;

signals:
    void searchPatternChanged();
    void isActiveChanged();

private slots:
    void sourceRowsInserted(const QModelIndex &sourceParent, int start, int end);
    void sourceRowsAboutToBeRemoved(const QModelIndex &sourceParent, int start, int end);
    void sourceModelAboutToBeReset();
    void sourceModelReset();
    void sourceLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &sourceParents, LayoutChangeHint hint);
    void sourceLayoutChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint);
    void filterInvalidatedHandler();
    void updateSearchResuls();

private:
    bool filterAcceptsRow(int sourceRow) const;
    void resolveNewMapping();
    void setIsActive(bool isActive);
    void connectSlots();
    void disconnectSlots();

    QString searchPattern_;
    QString effectiveSearchPattern_;
    int searchRole_ = Qt::DisplayRole;
    bool isActive_ = false;
    Mapping mapping_;
    SciFilterScrollbackModel *filterModel_;
    QTimer delaySearchTimer_;
};
