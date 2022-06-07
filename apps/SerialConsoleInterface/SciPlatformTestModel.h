/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include <memory>

#include <QObject>
#include <QAbstractListModel>

#include <Platform.h>
#include <Operations/PlatformValidation/BaseValidation.h>

class SciPlatformTestMessageModel;
class SciPlatformValidation;

class SciPlatformTestModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformTestModel)

public:
    enum ModelRole {
        NameRole = Qt::UserRole + 1,
        EnabledRole,
    };

    explicit SciPlatformTestModel(SciPlatformTestMessageModel *messageModel, const strata::platform::PlatformPtr& platform, QObject *parent = nullptr);
    virtual ~SciPlatformTestModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Q_INVOKABLE void setEnabled(int row, bool enabled);
    Q_INVOKABLE void runTests();

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    bool isRunning() const;

signals:
    void isRunningChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void statusHandler(strata::platform::validation::Status status, QString text);
    void finishedHandler(bool success);

private:
    void runActiveTest();
    void setIsRunning(bool isRunning);

    SciPlatformTestMessageModel *messageModel_;

    // platformRef_ must be reference!
    // It refers to platform_ in SciPlatfrom class (we need reference to obtain its current value).
    const strata::platform::PlatformPtr& platformRef_;

    QList<SciPlatformValidation*> data_;

    int activeTestIndex_;

    bool isRunning_;
};

class SciPlatformValidation: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformValidation)

public:
    enum class Type {
        Identification
    };

    SciPlatformValidation(Type type,
                          const strata::platform::PlatformPtr& platformRef,
                          QObject *parent);
    void run();
    QString name();
    void setEnabled(bool enabled);
    bool enabled();

signals:
    void finished(bool success);
    void status(strata::platform::validation::Status status, QString text);

private:
    const Type type_;
    const strata::platform::PlatformPtr& platformRef_;
    bool enabled_;
    typedef std::unique_ptr<strata::platform::validation::BaseValidation,
                            void(*)(strata::platform::validation::BaseValidation*)> ValidationPtr;
    ValidationPtr validation_;
    // deleter for validation_ unique pointer
    static void validationDeleter(strata::platform::validation::BaseValidation* validation);
};
