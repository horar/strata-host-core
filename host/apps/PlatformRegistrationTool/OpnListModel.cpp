#include "OpnListModel.h"
#include "RestClient.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>

OpnListModel::OpnListModel(RestClient *restClient, QObject *parent)
    : QAbstractListModel(parent),
      restClient_(restClient)
{
    roleNames_[OpnRole] = "opn";
    roleNames_[VerboseNameRole] = "verboseName";
    roleNames_[ClassIdRole] = "classId";
}

OpnListModel::~OpnListModel()
{
    clear();
}

QVariant OpnListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    OpnItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case OpnRole:
        return item->opn;
    case VerboseNameRole:
        return item->verboseName;
    case ClassIdRole:
        return item->classId;
    }

    return QVariant();
}

QVariant OpnListModel::data(int row, QByteArray role)
{
    int intRole = roleNames().key(role, -1);
    return data(index(row, 0), intRole);
}

int OpnListModel::count() const
{
    return data_.size();
}

int OpnListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.size();
}

void OpnListModel::clear()
{
    qDeleteAll(data_);
    data_.clear();
}

void OpnListModel::populate()
{
    Deferred *deferred = restClient_->get(QUrl("plats"));

    connect(deferred, &Deferred::finishedSuccessfully, [this] (int status, QByteArray data) {
        qCDebug(logCategoryPrt) << "status" << status;
        qCDebug(logCategoryPrt) << data << data;

        //TODO remove later
        //QByteArray fakeData = "[{\"opn\":\"STR-BHARATH-TEST-EVK\",\"verbose_name\":\"T2\",\"class_id\":\"ca8d9af0-8ad5-4759-abf1-b573174fe67f\"},{\"opn\":\"STR-NCP45560-ECOSWITCH-GEVB\",\"verbose_name\":\"STR-NCP45560-ECOSWITCH-GEVB\",\"class_id\":\"238\"},{\"opn\":\"STR-NCV48220-LDO-CP-GEVB\",\"verbose_name\":\"STR-NCV48220-LDO-CP-GEVB\",\"class_id\":\"240\"},{\"opn\":\"STR-NCV6357-GEVB\",\"verbose_name\":\"Strata Enabled NCV6357 EVB\",\"class_id\":\"216\"},{\"opn\":\"STR-SENSORS-GEVK\",\"verbose_name\":\"STR-SENSORS-GEVK\",\"class_id\":\"c53ca0c2-56b3-455f-bba5-17675d8d4dc1\"},{\"opn\":\"STR-BHARATH-TEST2-EVK\",\"verbose_name\":\"T2\",\"class_id\":\"a8de2cfb-0822-437b-8c47-f549549704bd\"},{\"opn\":\"STR-BHARATH-TEST1-EVK\",\"verbose_name\":\"T2\",\"class_id\":\"ca8d9af0-8ad5-4759-abf1-b573174fe67f\"},{\"opn\":\"STR-BHARATH-TEST3-EVK\",\"verbose_name\":\"T2\",\"class_id\":\"ca8d9af0-8ad5-4759-abf1-b573174fe67f\"},{\"opn\":\"STR-RSL10-MESK-KIT-GEVK\",\"verbose_name\":\"STR-RSL10-MESK-KIT-GEVK\",\"class_id\":\"246\"},{\"opn\":\"STR-LOGIC-GATES-EVK\",\"verbose_name\":\"Multi-function Logic Gate with GUI Control\",\"class_id\":\"201\"},{\"opn\":\"STR-NCP3231-EVK\",\"verbose_name\":\"NCP3231 Integrated MOSFET Synchronous Buck\",\"class_id\":\"220\"},{\"opn\":\"STR-NCP3235-EVK\",\"verbose_name\":\"NCP3235 Integrated MOSFET Synchronous Buck\",\"class_id\":\"207\"},{\"opn\":\"STR-NCP3232N-EVK\",\"verbose_name\":\"NCP3232 Integrated MOSFET Synchronous Buck\",\"class_id\":\"219\"}]";

        populateOpnList(data);
    });

    connect(deferred, &Deferred::finishedWithError, [] (int status, QString errorString) {
        qCCritical(logCategoryPrt) << status << errorString;
    });
}

QHash<int, QByteArray> OpnListModel::roleNames() const
{
    return roleNames_;
}

void OpnListModel::populateOpnList(const QByteArray &data)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCCritical(logCategoryPrt) << "JSON parse error:" << parseError.errorString();
        return;
    }

    QJsonArray opnList = doc.array();

    for (const QJsonValueRef value : opnList) {
        OpnItem *item = createOpnItem(value.toObject());
        if (item == nullptr) {
            qCCritical(logCategoryPrt) << "platform item not valid:" << value;
            continue;
        }

        data_.append(item);
    }

    beginInsertRows(QModelIndex(), 0, data_.length()-1);

    endInsertRows();
}

OpnItem *OpnListModel::createOpnItem(const QJsonObject &jsonObject)
{
    if (jsonObject.contains("opn") == false) {
        qCCritical(logCategoryPrt) << "opn key is missing";
        return nullptr;
    }

    if (jsonObject.contains("verbose_name") == false) {
        qCCritical(logCategoryPrt) << "verbose_name key is missing";
        return nullptr;
    }

    if (jsonObject.contains("class_id") == false) {
        qCCritical(logCategoryPrt) << "class_id key is missing";
        return nullptr;
    }

    OpnItem *item = new OpnItem();
    item->opn = jsonObject.value("opn").toString();
    item->verboseName = jsonObject.value("verbose_name").toString();
    item->classId = jsonObject.value("class_id").toString();

    return item;
}
