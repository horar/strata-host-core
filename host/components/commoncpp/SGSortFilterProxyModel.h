#ifndef SGSORTFILTERPROXYMODEL_H
#define SGSORTFILTERPROXYMODEL_H

#include <QtCore/qsortfilterproxymodel.h>
#include <QtQml/qqmlparserstatus.h>
#include <QCollator>

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
    void classBegin() override;
    void componentComplete() override;

    Q_INVOKABLE int naturalCompare(const QString &left, const QString &right) const;
    Q_INVOKABLE QVariant get(int row) const;
    Q_INVOKABLE int mapIndexToSource(int i);
    Q_INVOKABLE int mapIndexFromSource(int i);

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
    QString sortRole_;
    QString filterRole_;
    QCollator collator_;

    void doSetSortRole();
    void doSetFilterRole();
    bool callFilterAcceptsRow(int sourceRow) const;
    bool callLessThan(int leftRow, int rightRow) const;
    void disconnectFromSourceModel();

private slots:
    void sourceModelRolesMaybeChanged();
};

#endif  // SGSORTFILTERPROXYMODEL_H
