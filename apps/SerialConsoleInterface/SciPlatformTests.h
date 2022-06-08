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

#include <Platform.h>
#include <Operations/PlatformValidation/BaseValidation.h>

// *** base class ***

class SciPlatformBaseTest: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformBaseTest)

public:
    SciPlatformBaseTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);
    virtual ~SciPlatformBaseTest();

    virtual void run() = 0;
    QString name() const;
    void setEnabled(bool enabled);
    bool enabled() const;

signals:
    void finished();
    void status(strata::platform::validation::Status status, QString text);

private:
    bool enabled_;

protected slots:
    void finishedHandler();

protected:
    QString name_;
    const strata::platform::PlatformPtr& platformRef_;

    typedef std::unique_ptr<strata::platform::validation::BaseValidation,
                            void(*)(strata::platform::validation::BaseValidation*)> ValidationPtr;
    ValidationPtr validation_;
    // deleter for validation_ unique pointer
    static void validationDeleter(strata::platform::validation::BaseValidation* validation);
};


// *** Identification ***

class IdentificationTest: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(IdentificationTest)

public:
    IdentificationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);

    void run() override;
};
