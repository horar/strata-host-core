#include "SciMockCommandModel.h"
#include "logging/LoggingQtCategories.h"

using strata::device::MockCommand;

SciMockCommandModel::SciMockCommandModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
    setModelData();
}

SciMockCommandModel::~SciMockCommandModel()
{
    clear();
}

void SciMockCommandModel::clear()
{
    beginResetModel();

    commands_.clear();

    endResetModel();
    emit countChanged();
}

QVariantMap SciMockCommandModel::get(int row)
{
    QHashIterator<int, QByteArray> iter(roleByEnumHash_);
    QVariantMap res;
    while (iter.hasNext()) {
        iter.next();
        QModelIndex idx = index(row, 0);
        QVariant data = idx.data(iter.key());
        res[iter.value()] = data;
    }
    return res;
}

int SciMockCommandModel::find(const QVariant& type) const
{
    MockCommand command = type.value<MockCommand>();
    int count = 0;
    for (auto iter = commands_.constBegin(); iter != commands_.constEnd(); ++iter) {
        if (iter->type_ == command) {
            return count;
        }
        ++count;
    }
    return -1;
}

QVariant SciMockCommandModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= commands_.count()) {
        qCWarning(logCategorySci) << "Trying to access to out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case NameRole:
        return commands_.at(row).name_;
    case TypeRole:
        return QVariant::fromValue(commands_.at(row).type_);
    }

    return QVariant();
}

QVariant SciMockCommandModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciMockCommandModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return commands_.length();
}

int SciMockCommandModel::count() const
{
    return commands_.length();
}

QHash<int, QByteArray> SciMockCommandModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMockCommandModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(TypeRole, "type");
    roleByEnumHash_.insert(NameRole, "name");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

void SciMockCommandModel::setModelData()
{
    commands_.clear();
    commands_.push_back({MockCommand::Any_command,              "Any Command"});
    commands_.push_back({MockCommand::Get_firmware_info,        "Get Firmware Info"});
    commands_.push_back({MockCommand::Request_platform_id,      "Request Platform Id"});
    commands_.push_back({MockCommand::Start_bootloader,         "Start Bootloader"});
    commands_.push_back({MockCommand::Start_application,        "Start Application"});
    commands_.push_back({MockCommand::Flash_firmware,           "Flash Firmware"});
    commands_.push_back({MockCommand::Flash_bootloader,         "Flash Bootloader"});
    commands_.push_back({MockCommand::Start_flash_firmware,     "Start Flash Firmware"});
    commands_.push_back({MockCommand::Start_flash_bootloader,   "Start Flash Bootloader"});
    commands_.push_back({MockCommand::Set_assisted_platform_id, "Set Assisted Platform id"});
    commands_.push_back({MockCommand::Set_platform_id,          "Set Platform Id"});
    commands_.push_back({MockCommand::Start_backup_firmware,    "Start Backup Firmware"});
    commands_.push_back({MockCommand::Backup_firmware,          "Backup Firmware"});
}
