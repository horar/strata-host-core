/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#ifndef LCUMODEL_H
#define LCUMODEL_H

#include <QObject>
#include <QAbstractItemModel>

class LcuModel : public QObject
{
    Q_OBJECT
public:
    explicit LcuModel(QObject *parent = nullptr);
    virtual ~LcuModel();
    Q_INVOKABLE void configFileSelectionChanged(QString fileName);

signals:

};

#endif // LCUMODEL_H
