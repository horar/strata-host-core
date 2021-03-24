#pragma once

#include <PlatformManager.h>

#include <SciPlatform.h>


#include <QAbstractListModel>

class SciPlatform;

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

    Q_PROPERTY(bool condensedAtStartup
               READ condensedAtStartup
               WRITE setCondensedAtStartup
               NOTIFY condensedAtStartupChanged)

public:
    SciPlatformModel(strata::BoardManager *boardManager, QObject *parent = nullptr);
    virtual ~SciPlatformModel() override;

    enum ModelRole {
        PlatformRole = Qt::UserRole + 1,
        /*
         * bug: FileDialog (QtQuick.Dialogs 1.3) calls data() of outside model (QTBUG-83423)
         * hack fix: make sure there is more than 1 role
         */
        BugFixRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

    int maxScrollbackCount() const;
    void setMaxScrollbackCount(int maxScrollbackCount);

    int maxCmdInHistoryCount() const;
    void setMaxCmdInHistoryCount(int maxCmdInHistoryCount);

    bool condensedAtStartup() const;
    void setCondensedAtStartup(bool condensedAtStartup);

    Q_INVOKABLE void releasePort(int index, int disconnectDuration=0);
    Q_INVOKABLE void removePlatform(int index);
    Q_INVOKABLE void reconnect(int index);

signals:
    void countChanged();
    void maxScrollbackCountChanged();
    void maxCmdInHistoryCountChanged();
    void condensedAtStartupChanged();
    void platformConnected(int index);
    void platformReady(int index);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private slots:
    void boardConnectedHandler(const QByteArray& deviceId);
    void boardReadyHandler(const QByteArray& deviceId, bool recognized);
    void boardDisconnectedHandler(const QByteArray& deviceId);

private:
    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;

    strata::BoardManager *boardManager_ = nullptr;
    QList<SciPlatform*> platformList_;
    SciPlatformSettings sciSettings_;

    int maxScrollbackCount_ = 99;
    int maxCmdInHistoryCount_ = 99;
    bool condensedAtStartup_ = false;

    void setModelRoles();
    int findPlatform(const QByteArray& deviceId) const;

    void appendNewPlatform(const QByteArray& deviceId);
};
