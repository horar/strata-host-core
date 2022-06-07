/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QtCore/qsortfilterproxymodel.h>
#include <QtQml/qqmlparserstatus.h>
#include <QCollator>

/*
QSortFilterProxyModel always sorts. Even when only filterPatern in changed, model sorts results.
To keep stuff in order, sortRole has to be set, otherwise DisplayRole is used as sortRole.
Another option is to disable sorting at all, in which case order from sourceModel is taken.
*/

class SGSortFilterProxyModel : public QSortFilterProxyModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QObject *sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)
    Q_PROPERTY(QString sortRole READ sortRole WRITE setSortRole NOTIFY sortRoleChanged)
    Q_PROPERTY(QString filterRole READ filterRole WRITE setFilterRole NOTIFY filterRoleChanged)
    Q_PROPERTY(QString filterPattern READ filterPattern WRITE setFilterPattern NOTIFY filterPatternChanged)
    Q_PROPERTY(FilterSyntax filterPatternSyntax READ filterPatternSyntax WRITE setFilterPatternSyntax NOTIFY filterPatternSyntaxChanged)
    Q_PROPERTY(bool naturalSort READ naturalSort WRITE setNaturalSort NOTIFY naturalSortChanged)
    Q_PROPERTY(bool sortAscending READ sortAscending WRITE setSortAscending NOTIFY sortAscendingChanged)
    Q_PROPERTY(bool caseSensitive READ caseSensitive WRITE setCaseSensitive NOTIFY caseSensitiveChanged)
    Q_PROPERTY(bool invokeCustomFilter READ invokeCustomFilter WRITE setInvokeCustomFilter NOTIFY invokeCustomFilterChanged)
    Q_PROPERTY(bool invokeCustomLessThan READ invokeCustomLessThan WRITE setInvokeCustomLessThan NOTIFY invokeCustomLessThanChanged)
    /* When sort is disabled, order from source model is used */
    Q_PROPERTY(bool sortEnabled READ sortEnabled WRITE setSortEnabled NOTIFY sortEnabledChanged)

    Q_ENUMS(FilterSyntax)

public:
    explicit SGSortFilterProxyModel(QObject *parent = nullptr);

    int count() const;

    QObject *sourceModel() const;
    using QSortFilterProxyModel::setSourceModel;
    void setSourceModel(QObject *sourceModel);
    QString sortRole() const;
    void setSortRole(const QString &role);
    QString filterRole() const;
    void setFilterRole(const QString &role);
    QString filterPattern() const;
    void setFilterPattern(const QString &filter);

    enum FilterSyntax { RegExp, Wildcard, FixedString };

    FilterSyntax filterPatternSyntax() const;
    void setFilterPatternSyntax(FilterSyntax syntax);
    bool naturalSort() const;
    void setNaturalSort(bool naturalSort);
    bool sortAscending() const;
    void setSortAscending(bool sortAscending);
    bool caseSensitive() const;
    void setCaseSensitive(bool sensitive);
    bool invokeCustomFilter() const;
    void setInvokeCustomFilter(bool invokeCustomFilter);
    bool invokeCustomLessThan() const;
    void setInvokeCustomLessThan(bool invokeCustomLessThan);
    bool sortEnabled();
    void setSortEnabled(bool sortEnabled);
    void classBegin() override;
    void componentComplete() override;

    Q_INVOKABLE int naturalCompare(const QString &left, const QString &right) const;
    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE int mapIndexToSource(int i);
    Q_INVOKABLE int mapIndexFromSource(int i);
    Q_INVOKABLE bool matches(const QString &text) const;
    Q_INVOKABLE void invalidateFilter();

signals:
    void countChanged();
    void sourceModelChanged();
    void sortRoleChanged();
    void filterRoleChanged();
    void filterPatternChanged();
    void filterPatternSyntaxChanged();
    void naturalSortChanged();
    void sortAscendingChanged();
    void caseSensitiveChanged();
    void invokeCustomFilterChanged();
    void invokeCustomLessThanChanged();
    void sortEnabledChanged();

protected:
    int roleKey(const QString &role) const;
    QHash<int, QByteArray> roleNames() const override;
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

private:
    bool complete_;
    bool naturalSort_;
    bool sortAscending_;
    bool caseSensitive_;
    bool invokeCustomFilter_;
    bool invokeCustomLessThan_;
    bool sortEnabled_;
    QString sortRole_;
    QString filterRole_;
    QCollator collator_;

    void doSetSortRole();
    void doSetFilterRole();
    bool callFilterAcceptsRow(int sourceRow) const;
    bool callLessThan(int leftRow, int rightRow) const;
    void disconnectFromSourceModel();
    void doSort();

private slots:
    void sourceModelRolesMaybeChanged();
};
