#ifndef SCI_PLATFORM_MODEL_H
#define SCI_PLATFORM_MODEL_H

#include <BoardManager.h>
#include "SciScrollbackModel.h"
#include "SciCommandHistoryModel.h"
#include "SciPlatformSettings.h"

#include <QAbstractListModel>

class SciPlatformModelItem;

class SciPlatformModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_PROPERTY(int maxScrollbackCount
               READ maxScrollbackCount
               WRITE setMaxScrollbackCount
               NOTIFY maxScrollbackCountChanged)

    Q_PROPERTY(int maxCmdInHistoryCount
               READ maxCmdInHistoryCount
               WRITE setMaxCmdInHistoryCount
               NOTIFY maxCmdInHistoryCountChanged)

    Q_PROPERTY(bool ignoreNewConnections
               READ ignoreNewConnections
               WRITE setIgnoreNewConnections
               NOTIFY ignoreNewConnectionsChanged)

public:
    SciPlatformModel(spyglass::BoardManager *boardManager, QObject *parent = nullptr);
    virtual ~SciPlatformModel() override;

    enum ModelRole {
        VerboseNameRole = Qt::UserRole,
        AppVersionRole,
        BootloaderVersionRole,
        StatusRole,
        ScrollbackModelRole,
        ConnectionIdRole,
        CommandHistoryModelRole,
    };

    enum PlatformStatus {
        Disconnected,
        Connected,
        Ready,
        NotRecognized,
    };
    Q_ENUM(PlatformStatus)

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE QVariant data(int row, const QByteArray &role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    bool setData(int row, const QVariant &value, int role);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

    int maxScrollbackCount() const;
    void setMaxScrollbackCount(int maxScrollbackCount);

    int maxCmdInHistoryCount() const;
    void setMaxCmdInHistoryCount(int maxCmdInHistoryCount);

    bool ignoreNewConnections() const;
    void setIgnoreNewConnections(bool ignoreNewConnections);

    Q_INVOKABLE void disconnectPlatformFromSci(int connectionId);
    Q_INVOKABLE void removePlatform(int index);
    Q_INVOKABLE QVariantMap sendMessage(int index, QString message);
    Q_INVOKABLE void reconectAll();
    Q_INVOKABLE bool exportScrollback(int index, QString filePath) const;

signals:
    void countChanged();
    void maxScrollbackCountChanged();
    void maxCmdInHistoryCountChanged();
    void ignoreNewConnectionsChanged();
    void platformReady(int index);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void boardConnectedHandler(int connectionId);
    void boardReadyHandler(int connectionId, bool recognized);
    void boardDisconnectedHandler(int connectionId);
    void newMessageHandler(int connectionId, QString message);

private:
    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;

    spyglass::BoardManager *boardManager_ = nullptr;
    QList<SciPlatformModelItem*> platformList_;
    SciPlatformSettings sciSettings_;

    int maxScrollbackCount_;
    int maxCmdInHistoryCount_;
    bool ignoreNewConnections_ = false;

    void setModelRoles();
    int findPlatfrom(int connectionId) const;
    void appendNewPlatform(int connectionId);
};

class SciPlatformModelItem: public QObject {
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformModelItem)

public:
    SciPlatformModelItem(int maxScrollbackCount, int maxCmdInHistoryCount, QObject *parent = nullptr);
    virtual ~SciPlatformModelItem();

    QString verboseName;
    int connectionId;
    QString appVersion;
    QString bootloaderVersion;
    SciPlatformModel::PlatformStatus status;
    SciScrollbackModel *scrollbackModel;
    SciCommandHistoryModel *commandHistoryModel;
};

#endif //SCI_PLATFORM_MODEL_H
