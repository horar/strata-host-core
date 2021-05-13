#include "SciMockResponseModel.h"
#include "logging/LoggingQtCategories.h"

using strata::device::MockResponse;

SciMockResponseModel::SciMockResponseModel(QObject *parent)
    : QAbstractListModel(parent)
{
    setModelRoles();
    setModelData();
}

SciMockResponseModel::~SciMockResponseModel()
{
    clear();
}

void SciMockResponseModel::clear()
{
    beginResetModel();

    responses_.clear();

    endResetModel();
    emit countChanged();
}

QVariantMap SciMockResponseModel::get(int row)
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

int SciMockResponseModel::find(const QVariant& type) const
{
    MockResponse response = type.value<MockResponse>();
    int count = 0;
    for (auto iter = responses_.constBegin(); iter != responses_.constEnd(); ++iter) {
        if (iter->type_ == response) {
            return count;
        }
        ++count;
    }
    return -1;
}

QVariant SciMockResponseModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= responses_.count()) {
        qCWarning(logCategorySci) << "Attempting to access out of range index when acquiring data";
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return responses_.at(row).name_;
    case TypeRole:
        return QVariant::fromValue(responses_.at(row).type_);
    }

    return QVariant();
}

QVariant SciMockResponseModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

int SciMockResponseModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return responses_.length();
}

int SciMockResponseModel::count() const
{
    return responses_.length();
}

QHash<int, QByteArray> SciMockResponseModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciMockResponseModel::setModelRoles()
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

void SciMockResponseModel::setModelData()
{
    responses_.clear();
    responses_.push_back({MockResponse::Normal,     "Normal"});
    responses_.push_back({MockResponse::No_payload, "No Payload"});
    responses_.push_back({MockResponse::No_JSON,    "No JSON"});
    responses_.push_back({MockResponse::Nack,       "Nack"});
    responses_.push_back({MockResponse::Invalid,    "Invalid"});
    responses_.push_back({MockResponse::Platform_config_embedded_app,           "Platform Config: Embedded App"});
    responses_.push_back({MockResponse::Platform_config_assisted_app,           "Platform Config: Assisted App"});
    responses_.push_back({MockResponse::Platform_config_assisted_no_board,      "Platform Config: Assisted No Board"});
    responses_.push_back({MockResponse::Platform_config_embedded_bootloader,    "Platform Config: Embedded Bootloader"});
    responses_.push_back({MockResponse::Platform_config_assisted_bootloader,    "Platform Config: Assisted Bootloader"});
    responses_.push_back({MockResponse::Flash_firmware_resend_chunk,            "Flash Firmware: Resend Chunk"});
    responses_.push_back({MockResponse::Flash_firmware_memory_error,            "Flash Firmware: Memory Error"});
    responses_.push_back({MockResponse::Flash_firmware_invalid_cmd_sequence,    "Flash Firmware: Invalid Cmd Sequence"});
    responses_.push_back({MockResponse::Flash_firmware_invalid_value,           "Flash Firmware: Invalid Value"});
    responses_.push_back({MockResponse::Start_flash_firmware_invalid,           "Start Flash Firmware: Invalid"});
}
