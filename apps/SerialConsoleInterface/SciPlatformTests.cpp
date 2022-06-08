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

namespace validation = strata::platform::validation;

SciPlatformBaseTest::SciPlatformBaseTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : QObject(parent),
      enabled_(false),
      platformRef_(platformRef),
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

void SciPlatformBaseTest::validationDeleter(validation::BaseValidation* validation)
{
    validation->deleteLater();
}

IdentificationTest::IdentificationTest(const strata::platform::PlatformPtr& platformRef, QObject *parent)
    : SciPlatformBaseTest(platformRef, parent)
{
    name_ = QStringLiteral("Identification");
};

void IdentificationTest::run()
{
    validation_ = ValidationPtr(new validation::Identification(platformRef_), validationDeleter);

    connect(validation_.get(), &validation::BaseValidation::finished, this, &IdentificationTest::finishedHandler);
    connect(validation_.get(), &validation::BaseValidation::validationStatus, this, &SciPlatformBaseTest::status);

    validation_->run();
}
