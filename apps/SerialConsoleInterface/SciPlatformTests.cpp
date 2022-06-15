/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformTests.h"
#include <Operations/PlatformValidation/Identification.h>
#include <Operations/PlatformValidation/BootloaderApplication.h>
#include <Operations/PlatformValidation/EmbeddedRegistration.h>
#include <Operations/PlatformValidation/AssistedRegistration.h>

namespace validation = strata::platform::validation;

// *** base class ***

SciPlatformBaseTest::SciPlatformBaseTest(const strata::platform::PlatformPtr& platformRef, const QString& name, QObject *parent)
    : QObject(parent),
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

void SciPlatformBaseTest::connectAndRun()
{
    connect(validation_.get(), &validation::BaseValidation::finished, this, &SciPlatformBaseTest::finishedHandler);
    connect(validation_.get(), &validation::BaseValidation::validationStatus, this, &SciPlatformBaseTest::status);

    validation_->run();
}

void SciPlatformBaseTest::validationDeleter(validation::BaseValidation* validation)
{
    validation->deleteLater();
}


// *** Identification ***

IdentificationTest::IdentificationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, QStringLiteral("Identification"), parent)
{ }

void IdentificationTest::run()
{
    validation_ = ValidationPtr(new validation::Identification(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Bootloader & Application Presence ***

BootloaderApplicationTest::BootloaderApplicationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, QStringLiteral("Bootloader & Application"), parent)
{ }

void BootloaderApplicationTest::run()
{
    validation_ = ValidationPtr(new validation::BootloaderApplication(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Embedded platform registration ***

EmbeddedRegistrationTest::EmbeddedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, QStringLiteral("Embedded platform registration"), parent)
{ }

void EmbeddedRegistrationTest::run()
{
    validation_ = ValidationPtr(new validation::EmbeddedRegistration(platformRef_, name_), validationDeleter);

    connectAndRun();
}


// *** Assisted platform registration ***

AssistedRegistrationTest::AssistedRegistrationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, QStringLiteral("Assisted platform registration"), parent)
{ }

void AssistedRegistrationTest::run()
{
    validation_ = ValidationPtr(new validation::AssistedRegistration(platformRef_, name_), validationDeleter);

    connectAndRun();
}
