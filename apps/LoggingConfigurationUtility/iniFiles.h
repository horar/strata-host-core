/***************************************************************************
 *                                                                         *
 *   Copyright (C) 2021 by ONsemiconductor     *
 *                                                                         *
 *   http://onsemi.com                                          *
 *                                                                         *
 ***************************************************************************/
#ifndef INIFILES_H
#define INIFILES_H

#include <QObject>


class IniFiles : public QObject
{
    Q_OBJECT
public:
    explicit IniFiles(QObject *parent = nullptr);
    QStringList items();

    bool setItemAt(int index, QString item);
signals:
    void preItemAppanded();
    void postItemAppended();

public slots:
    void appendItem();

private:
    QStringList iniFiles_;
};

#endif // INIFILES_H
