/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#include "SciPlatformTestModel.h"
#include "SciPlatformTestMessageModel.h"
#include "SciPlatformTests.h"

#include <ValidationStatus.h>

namespace validation = strata::platform::validation;

SciPlatformTestModel::SciPlatformTestModel(
        SciPlatformTestMessageModel *messageModel,
        const strata::platform::PlatformPtr& platform,
        QObject *parent)
    : QAbstractListModel(parent),
      messageModel_(messageModel),
      platformRef_(platform),
      isRunning_(false),
      allTestsDisabled_(true)
{
    data_.append(new IdentificationTest(platformRef_, this));
    data_.append(new BootloaderApplicationTest(platformRef_, this));
    data_.append(new EmbeddedRegistrationTest(platformRef_, this));
    data_.append(new AssistedRegistrationTest(platformRef_, this));
    data_.append(new FirmwareFlashingTest(platformRef_, this));

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

    SciPlatformBaseTest *item = data_.at(row);

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

    unsigned enabledCount = 0;
    for (int i = 0; i < data_.size(); ++i) {
        if (data_.at(i)->enabled()) {
            ++enabledCount;
        }
    }
    setAllTestsDisabled(enabledCount == 0);
}

void SciPlatformTestModel::runTests()
{
    if (isRunning_ == false) {
        setIsRunning(true);

        messageModel_->clear();
        activeTestIndex_ = -1;  // index before first test
        runNextTest();
    }
}

bool SciPlatformTestModel::isRunning() const
{
    return isRunning_;
}

bool SciPlatformTestModel::allTestsDisabled() const
{
    return allTestsDisabled_;
}

QHash<int, QByteArray> SciPlatformTestModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[EnabledRole] = "enabled";
    return roles;
}

void SciPlatformTestModel::finishedHandler()
{
    disconnect(data_.at(activeTestIndex_), nullptr, this, nullptr);

    messageModel_->addMessage(SciPlatformTestMessageModel::Plain, "");

    runNextTest();
}

void SciPlatformTestModel::statusHandler(validation::Status status, QString text, bool rewriteLast)
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

    if (rewriteLast) {
        messageModel_->changeLastMessage(msgType, text);
    } else {
        messageModel_->addMessage(msgType, text);
    }
}

void SciPlatformTestModel::runNextTest()
{
    ++activeTestIndex_;

    while (activeTestIndex_ < data_.length()) {
        if (data_.at(activeTestIndex_)->enabled()) {
            connect(data_.at(activeTestIndex_), &SciPlatformBaseTest::status, this, &SciPlatformTestModel::statusHandler);
            connect(data_.at(activeTestIndex_), &SciPlatformBaseTest::finished, this, &SciPlatformTestModel::finishedHandler);

            data_.at(activeTestIndex_)->run();

            return;
        } else {  // current test is not enabled, move to next test
            ++activeTestIndex_;
        }
    }

    if (activeTestIndex_ >= data_.length()) {
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

void SciPlatformTestModel::setAllTestsDisabled(bool allTestsDisabled)
{
    if (allTestsDisabled_ == allTestsDisabled) {
        return;
    }

    allTestsDisabled_ = allTestsDisabled;
    emit allTestsDisabledChanged();
}
