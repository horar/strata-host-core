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

#include <memory>

#include <Platform.h>
#include <Operations/PlatformValidation/BaseValidation.h>

class SciPlatformValidation : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformValidation)

public:
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)

    SciPlatformValidation(const strata::platform::PlatformPtr& platform, QObject *parent = nullptr);
    ~SciPlatformValidation();

    bool isRunning() const;

    Q_INVOKABLE void runIdentification();

signals:
    void validationFinished(bool success);
    void validationStatus(strata::platform::validation::Status status, QString description);
    void isRunningChanged();

private slots:
    void finishedHandler(bool success);

private:
    // platformRef_ must be reference!
    // It refers to platform_ in SciPlatfrom class (we need reference to obtain its current value).
    const strata::platform::PlatformPtr& platformRef_;

    typedef std::unique_ptr<strata::platform::validation::BaseValidation,
                            void(*)(strata::platform::validation::BaseValidation*)> ValidationPtr;
    ValidationPtr validation_;
    // deleter for validation_ unique pointer
    static void validationDeleter(strata::platform::validation::BaseValidation* validation);

    bool running_;

};
