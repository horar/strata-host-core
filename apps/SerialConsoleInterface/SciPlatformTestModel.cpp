#include "SciPlatformTestModel.h"

#include <QDebug>
#include "SciPlatformTestMessageModel.h"

SciPlatformTestModel::SciPlatformTestModel(
        SciPlatformTestMessageModel *messageModel,
        QObject *parent)
    : QAbstractListModel(parent),
      messageModel_(messageModel)
{
    data_.append(new PlatformTest1(this));
    data_.append(new PlatformTest2(this));
    data_.append(new PlatformTest3(this));
    data_.append(new PlatformTest4(this));
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
    case NameRole: return item->name();
    case EnabledRole: return item->enabled();
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

    emit dataChanged(
                createIndex(row, 0),
                createIndex(row, 0),
                {EnabledRole});
}

void SciPlatformTestModel::runTests()
{
    messageModel_->clear();
    activeTestIndex_ = -1;
    runNextTest();
}

QHash<int, QByteArray> SciPlatformTestModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[EnabledRole] = "enabled";
    return roles;
}

void SciPlatformTestModel::infoStatusHandler(QString text)
{
    messageModel_->addMessage(SciPlatformTestMessageModel::Info, text);
}

void SciPlatformTestModel::warningStatusHandler(QString text)
{
    messageModel_->addMessage(SciPlatformTestMessageModel::Warning, text);
}

void SciPlatformTestModel::errorStatusHandler(QString text)
{
    messageModel_->addMessage(SciPlatformTestMessageModel::Error, text);
}

void SciPlatformTestModel::finishedHandler(bool success)
{
    if (success) {
        messageModel_->addMessage(SciPlatformTestMessageModel::Success, data_.at(activeTestIndex_)->name() + " PASS");
    } else {
        messageModel_->addMessage(SciPlatformTestMessageModel::Error, data_.at(activeTestIndex_)->name() + " FAIL");
    }

    messageModel_->addMessage(SciPlatformTestMessageModel::Info, "");

    disconnect(data_.at(activeTestIndex_), nullptr, this, nullptr);

    runNextTest();
}

void SciPlatformTestModel::runNextTest()
{
    for (int i = activeTestIndex_+1; i < data_.length(); ++i) {
        if (data_.at(i)->enabled()) {
            activeTestIndex_ = i;

            messageModel_->addMessage(SciPlatformTestMessageModel::Info, data_.at(i)->name() + " is about to start");

            connect(data_.at(i), &SciPlatformBaseTest::infoStatus, this, &SciPlatformTestModel::infoStatusHandler);
            connect(data_.at(i), &SciPlatformBaseTest::warningStatus, this, &SciPlatformTestModel::warningStatusHandler);
            connect(data_.at(i), &SciPlatformBaseTest::errorStatus, this, &SciPlatformTestModel::errorStatusHandler);
            connect(data_.at(i), &SciPlatformBaseTest::finished, this, &SciPlatformTestModel::finishedHandler);

            data_.at(i)->run();

            break;
        }
    }
}
