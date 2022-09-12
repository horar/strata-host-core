/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QAbstractListModel>

#include <Platform.h>

class SciPlatformTestMessageModel;
class SciPlatformBaseTest;

namespace strata::platform::validation {
enum class Status : short;
}

class SciPlatformTestModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformTestModel)

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(bool allTestsDisabled READ allTestsDisabled NOTIFY allTestsDisabledChanged)
    Q_PROPERTY(QString firmwareFilePath READ firmwareFilePath WRITE setFirmwareFilePath NOTIFY firmwareFilePathChanged)

public:
    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        EnabledRole,
        WarningTextRole,
    };

    explicit SciPlatformTestModel(
            SciPlatformTestMessageModel *messageModel,
            const strata::platform::PlatformPtr& platform,
            QObject *parent = nullptr);

    virtual ~SciPlatformTestModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE void setEnabled(int row, bool enabled);
    Q_INVOKABLE void runTests();

    bool isRunning() const;
    bool allTestsDisabled() const;

    QString firmwareFilePath();
    void setFirmwareFilePath(const QString &firmwareFilePath);

signals:
    void isRunningChanged();
    void allTestsDisabledChanged();
    void firmwareFilePathChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void finishedHandler();
    void statusHandler(
            strata::platform::validation::Status status,
            QString text,
            bool rewriteLast);

private:
    void runNextTest();
    void setIsRunning(bool isRunning);
    void setAllTestsDisabled(bool allTestsDisabled);

    SciPlatformTestMessageModel *messageModel_;

    // platformRef_ must be reference!
    // It refers to platform_ in SciPlatfrom class (we need reference to obtain its current value).
    const strata::platform::PlatformPtr& platformRef_;

    QList<SciPlatformBaseTest*> data_;

    int activeTestIndex_;

    bool isRunning_;
    bool allTestsDisabled_;
    QString firmwareFilePath_;
};
