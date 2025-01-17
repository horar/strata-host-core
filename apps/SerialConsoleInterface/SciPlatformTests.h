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
#include <QVariant>

#include <Platform.h>
#include <ValidationStatus.h>

namespace strata::platform::validation {
class BaseValidation;
class FirmwareFlashing;
}

// *** base class ***

class SciPlatformBaseTest: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformBaseTest)

public:
    enum class Type {
        Identification,
        BootloaderApplication,
        EmbeddedRegistration,
        AssistedRegistration,
        FirmwareFlashing
    };

    SciPlatformBaseTest(
            const strata::platform::PlatformPtr &platformRef,
            Type type,
            const QString &name,
            QObject *parent);

    virtual ~SciPlatformBaseTest();

    virtual void run(const QVariant& testData) = 0;
    QString name() const;
    Type type() const;
    void setEnabled(bool enabled);
    bool enabled() const;
    QString warningText();

signals:
    void finished();
    void status(strata::platform::validation::Status validationStatus, QString text, bool rewriteLast);

private:
    const Type type_;
    bool enabled_;

private slots:
    void finishedHandler();
    void statusHandler(strata::platform::validation::Status validationStatus, QString text);

protected:
    void connectAndRun();

    const strata::platform::PlatformPtr& platformRef_;
    const QString name_;
    QString warningText_;

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

    void run(const QVariant& testData) override;
};


// *** Bootloader & Application Presence ***

class BootloaderApplicationTest: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(BootloaderApplicationTest)

public:
    BootloaderApplicationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);

    void run(const QVariant& testData) override;
};


// *** Embedded board registration ***

class EmbeddedRegistrationTest: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(EmbeddedRegistrationTest)

public:
    EmbeddedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);

    void run(const QVariant& testData) override;
};


// *** Assisted board registration ***

class AssistedRegistrationTest: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(AssistedRegistrationTest)

public:
    AssistedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);

    void run(const QVariant& testData) override;
};


// *** Firmware flashing ***

class FirmwareFlashingTest: public SciPlatformBaseTest {
    Q_OBJECT
    Q_DISABLE_COPY(FirmwareFlashingTest)

public:
    FirmwareFlashingTest(const strata::platform::PlatformPtr& platformRef, QObject *parent);

    void run(const QVariant& testData) override;

private slots:
    void flashingFinishedHandler();

private:
    typedef std::unique_ptr<strata::platform::validation::FirmwareFlashing,
                            void(*)(strata::platform::validation::FirmwareFlashing*)> FwFlashingPtr;
    FwFlashingPtr fwFlashing_;
    // deleter for fwFlashing_ unique pointer
    static void fwFlashingDeleter(strata::platform::validation::FirmwareFlashing* fwFlashing);
};
