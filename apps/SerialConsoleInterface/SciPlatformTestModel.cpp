/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformTestModel.h"

#include <QDebug>
#include "SciPlatformTestMessageModel.h"

#include <Operations/PlatformValidation/Identification.h>

namespace validation = strata::platform::validation;

SciPlatformTestModel::SciPlatformTestModel(
        SciPlatformTestMessageModel *messageModel,
        const strata::platform::PlatformPtr& platform,
        QObject *parent)
    : QAbstractListModel(parent),
      messageModel_(messageModel),
      platformRef_(platform),
      isRunning_(false)
{
    data_.append(new SciPlatformValidation(SciPlatformValidation::Type::Identification, platformRef_, this));

    setEnabled(0, true);  // enable first validation - identification
}

SciPlatformTestModel::~SciPlatformTestModel()
{
}

QVariant SciPlatformTestModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    SciPlatformValidation *item = data_.at(row);

    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return item->name();
    case EnabledRole:
        return item->enabled();
    }

    return QVariant();
}

int SciPlatformTestModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.size();
}

void SciPlatformTestModel::setEnabled(int row, bool enabled)
{
    if (row < 0 || row >= data_.count()) {
        return;
    }

    if (data_.at(row)->enabled() == enabled) {
        return;
    }

    data_.at(row)->setEnabled(enabled);

    emit dataChanged(createIndex(row, 0), createIndex(row, 0), {EnabledRole});
}

void SciPlatformTestModel::runTests()
{
    if (isRunning_ == false) {
        setIsRunning(true);

        messageModel_->clear();
        activeTestIndex_ = 0;  // first test
        runActiveTest();
    }
}

bool SciPlatformTestModel::isRunning() const
{
    return isRunning_;
}

QHash<int, QByteArray> SciPlatformTestModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[EnabledRole] = "enabled";
    return roles;
}

void SciPlatformTestModel::finishedHandler(bool success)
{
    Q_UNUSED(success)

    disconnect(data_.at(activeTestIndex_), nullptr, this, nullptr);

    messageModel_->addMessage(SciPlatformTestMessageModel::Plain, "");

    ++activeTestIndex_;  // move to next test
    runActiveTest();
}

void SciPlatformTestModel::statusHandler(validation::Status status, QString text)
{
    SciPlatformTestMessageModel::MessageType msgType;

    switch (status) {
    case validation::Status::Plain :
        msgType = SciPlatformTestMessageModel::Plain;
        break;
    case validation::Status::Info :
        msgType = SciPlatformTestMessageModel::Info;
        break;
    case validation::Status::Warning :
        msgType = SciPlatformTestMessageModel::Warning;
        break;
    case validation::Status::Error :
        msgType = SciPlatformTestMessageModel::Error;
        break;
    case validation::Status::Success :
        msgType = SciPlatformTestMessageModel::Success;
        break;
    }

    messageModel_->addMessage(msgType, text);
}

void SciPlatformTestModel::runActiveTest()
{
    while (activeTestIndex_ < data_.length()) {
        if (data_.at(activeTestIndex_)->enabled()) {
            connect(data_.at(activeTestIndex_), &SciPlatformValidation::status, this, &SciPlatformTestModel::statusHandler);
            connect(data_.at(activeTestIndex_), &SciPlatformValidation::finished, this, &SciPlatformTestModel::finishedHandler);

            data_.at(activeTestIndex_)->run();

            return;
        } else {  // current test is not enabled, move to next test
            ++activeTestIndex_;
        }
    }

    if (activeTestIndex_ == data_.length()) {
        setIsRunning(false);
    }
}

void SciPlatformTestModel::setIsRunning(bool isRunning)
{
    if (isRunning_ == isRunning) {
        return;
    }

    isRunning_ = isRunning;
    emit isRunningChanged();
}

SciPlatformValidation::SciPlatformValidation(Type type,
                                              const strata::platform::PlatformPtr& platformRef,
                                              QObject *parent)
    : QObject(parent),
      type_(type),
      platformRef_(platformRef),
      enabled_(false),
      validation_(nullptr, nullptr)
{ }

void SciPlatformValidation::run()
{
    if (validation_.get() == nullptr) {
        switch (type_) {
        case Type::Identification :
            validation_ = ValidationPtr(new validation::Identification(platformRef_), validationDeleter);
            break;
        }
        connect(validation_.get(), &validation::BaseValidation::finished, this, &SciPlatformValidation::finished);
        connect(validation_.get(), &validation::BaseValidation::validationStatus, this, &SciPlatformValidation::status);
    }
    validation_->run();
}

QString SciPlatformValidation::name()
{
    switch (type_) {
    case Type::Identification :
        return QStringLiteral("Identification");
    }

    return "-";
}

void SciPlatformValidation::setEnabled(bool enabled)
{
    enabled_ = enabled;
}

bool SciPlatformValidation::enabled()
{
    return enabled_;
}

void SciPlatformValidation::validationDeleter(validation::BaseValidation* validation)
{
    validation->deleteLater();
}
