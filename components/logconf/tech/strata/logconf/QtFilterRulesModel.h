/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QAbstractListModel>
#include "QFileInfo"

class QtFilterRulesModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(QtFilterRulesModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit QtFilterRulesModel(QObject *parent = nullptr);
    enum ModelRole{
        FilterNameRole = Qt::UserRole
    };
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    int count() const;

    Q_INVOKABLE void createModel(QString qtFilterRules);
    Q_INVOKABLE void modifyList(int index, QString newText);
    Q_INVOKABLE QString joinItems();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private slots:
    void addItem(const QString newRule);

private:
    QStringList filterRulesList_;
};
