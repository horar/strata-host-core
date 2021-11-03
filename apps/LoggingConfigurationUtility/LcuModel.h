/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#ifndef LCUMODEL_H
#define LCUMODEL_H

#include <QAbstractItemModel>

class IniFiles;

class LcuModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(IniFiles *list READ list WRITE setList)

public:
    explicit LcuModel(QObject *parent = nullptr);

    enum {
        UserRole,
        DisplayRole
    };

    // Basic functionality:
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

//    bool setData(const QModelIndex &index, const QVariant &value,int role = Qt::EditRole) override;

    IniFiles *list() const;
    void setList(IniFiles *list);

private:
    IniFiles *list_;
    QStringList iniFiles_;
};

#endif // LCUMODEL_H
