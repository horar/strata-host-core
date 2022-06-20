/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformTests.h"
#include <BaseValidation.h>
#include <Identification.h>
#include <BootloaderApplication.h>
#include <EmbeddedRegistration.h>
#include <AssistedRegistration.h>
#include <FirmwareFlashing.h>

namespace validation = strata::platform::validation;

// *** base class ***

SciPlatformBaseTest::SciPlatformBaseTest(const strata::platform::PlatformPtr& platformRef, Type type, const QString& name, QObject *parent)
    : QObject(parent),
      type_(type),
      enabled_(false),
      platformRef_(platformRef),
      name_(name),
      validation_(nullptr, nullptr)
{ }

SciPlatformBaseTest::~SciPlatformBaseTest()
{ }

QString SciPlatformBaseTest::name() const
{
    return name_;
}

SciPlatformBaseTest::Type SciPlatformBaseTest::type() const
{
    return type_;
}

void SciPlatformBaseTest::setEnabled(bool enabled)
{
    enabled_ = enabled;
}

bool SciPlatformBaseTest::enabled() const
{
    return enabled_;
}

void SciPlatformBaseTest::finishedHandler()
{
    if (validation_) {
        disconnect(validation_.get(), nullptr, this, nullptr);
        validation_.reset();
    }
    emit finished();
}

void SciPlatformBaseTest::statusHandler(validation::Status validationStatus, QString text)
{
    emit status(validationStatus, text, false);
}

void SciPlatformBaseTest::connectAndRun()
{
    connect(validation_.get(), &validation::BaseValidation::finished, this, &SciPlatformBaseTest::finishedHandler);
    connect(validation_.get(), &validation::BaseValidation::validationStatus, this, &SciPlatformBaseTest::statusHandler);

    validation_->run();
}

void SciPlatformBaseTest::validationDeleter(validation::BaseValidation* validation)
{
    validation->deleteLater();
}


// *** Identification ***

IdentificationTest::IdentificationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, Type::Identification, QStringLiteral("Identification"), parent)
{ }

void IdentificationTest::run(const QVariant& testData)
{
    Q_UNUSED(testData)

    validation_ = ValidationPtr(new validation::Identification(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Bootloader & Application Presence ***

BootloaderApplicationTest::BootloaderApplicationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, Type::BootloaderApplication, QStringLiteral("Bootloader & Application"), parent)
{ }

void BootloaderApplicationTest::run(const QVariant& testData)
{
    Q_UNUSED(testData)

    validation_ = ValidationPtr(new validation::BootloaderApplication(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Embedded platform registration ***

EmbeddedRegistrationTest::EmbeddedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, Type::EmbeddedRegistration, QStringLiteral("Embedded platform registration"), parent)
{ }

void EmbeddedRegistrationTest::run(const QVariant& testData)
{
    Q_UNUSED(testData)

    validation_ = ValidationPtr(new validation::EmbeddedRegistration(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Assisted platform registration ***

AssistedRegistrationTest::AssistedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, Type::AssistedRegistration, QStringLiteral("Assisted platform registration"), parent)
{ }

void AssistedRegistrationTest::run(const QVariant& testData)
{
    Q_UNUSED(testData)

    validation_ = ValidationPtr(new validation::AssistedRegistration(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Firmware flashing ***

FirmwareFlashingTest::FirmwareFlashingTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, Type::FirmwareFlashing, QStringLiteral("Firmware flashing"), parent),
      fwFlashing_(nullptr, nullptr)
{ }

void FirmwareFlashingTest::run(const QVariant& testData)
{
    QString firmwarePath = testData.toString();

    fwFlashing_ = FwFlashingPtr(new validation::FirmwareFlashing(platformRef_, name_, firmwarePath), fwFlashingDeleter);

    connect(fwFlashing_.get(), &validation::FirmwareFlashing::finished, this, &FirmwareFlashingTest::flashingFinishedHandler);
    connect(fwFlashing_.get(), &validation::FirmwareFlashing::validationStatus, this, &SciPlatformBaseTest::status);

    fwFlashing_->run();
}

void FirmwareFlashingTest::flashingFinishedHandler()
{
    if (fwFlashing_) {
        disconnect(fwFlashing_.get(), nullptr, this, nullptr);
        fwFlashing_.reset();
    }
    emit finished();
}

void FirmwareFlashingTest::fwFlashingDeleter(validation::FirmwareFlashing* fwFlashing)
{
    fwFlashing->deleteLater();
}
