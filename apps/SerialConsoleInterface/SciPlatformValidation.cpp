/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformValidation.h"
#include "logging/LoggingQtCategories.h"

#include <Operations/PlatformValidation/Identification.h>

using strata::platform::validation::Status;
using strata::platform::validation::Identification;

SciPlatformValidation::SciPlatformValidation(const strata::platform::PlatformPtr& platform, QObject *parent)
    : QObject(parent),
      platformRef_(platform),
      running_(false)
{ }

SciPlatformValidation::~SciPlatformValidation()
{ }

bool SciPlatformValidation::isRunning() const
{
    return running_;
}

void SciPlatformValidation::finishedHandler(bool success)
{
    if (running_) {
        running_ = false;
        emit isRunningChanged();
    }
    validation_.reset();
    emit validationFinished(success);
}

void SciPlatformValidation::runIdentification()
{
    if ((platformRef_.get() != nullptr) && (running_ == false)) {
        running_ = true;
        emit isRunningChanged();

        validation_ = std::make_unique<Identification>(platformRef_);
        connect(validation_.get(), &Identification::finished, this, &SciPlatformValidation::finishedHandler);
        connect(validation_.get(), &Identification::validationStatus, this, &SciPlatformValidation::validationStatus);

        validation_->run();
    }
}
