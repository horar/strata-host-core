/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#ifndef LCUMODEL_H
#define LCUMODEL_H

#include <QAbstractListModel>

class LcuModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit LcuModel(QObject *parent = nullptr);
    enum {
        textRole
    };
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
     void addItem(const QString fileName);

private:
    QStringList iniFiles_;
};

#endif // LCUMODEL_H
