/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef LOGMODEL_H
#define LOGMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlError>

#include "FileModel.h"
#include "LogLevel.h"

struct LogItem;
class QTimer;

class LogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(LogModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QDateTime oldestTimestamp READ oldestTimestamp NOTIFY oldestTimestampChanged)
    Q_PROPERTY(QDateTime newestTimestamp READ newestTimestamp NOTIFY newestTimestampChanged)
    Q_PROPERTY(FileModel* fileModel READ fileModel CONSTANT)

public:
    explicit LogModel(QObject *parent = nullptr);
    ~LogModel();

    enum ModelRole {
        TimestampRole = Qt::UserRole,
        PidRole,
        TidRole,
        LevelRole,
        MessageRole,
        IsMarkedRole,
    };

    Q_INVOKABLE QString followFile(const QString &path);
    Q_INVOKABLE void removeFile(const QString &path);
    Q_INVOKABLE void removeAllFiles();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void toggleIsMarked(int position);
    Q_INVOKABLE QVariant data(int row, const QByteArray &role) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QDateTime oldestTimestamp() const;
    QDateTime newestTimestamp() const;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    FileModel *fileModel();

public slots:
    void handleQmlWarning(const QList<QQmlError> &warnings);

private slots:
    void checkFile();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void oldestTimestampChanged();
    void newestTimestampChanged();
    void notifyQmlError(QString notifyQmlError);

private:
    QString getRotatedFilePath(const QString &path) const;
    void removeRowsFromModel(const uint pathHash);
    QList<LogItem*>::iterator insertChunk(const QList<LogItem*>::iterator insertIter, const QList<LogItem*> &chunk);
    QList<LogItem*>::iterator removeChunk(const QList<LogItem*>::iterator &chunkStart, const QList<LogItem*>::iterator &chunkEnd);
    LogItem* parseLine(const QByteArray &line, FileModel::FileMetadata &metadata);
    QString populateModel(const QString &path);
    void updateTimestamps();
    void setOldestTimestamp(const QDateTime &timestamp);
    void setNewestTimestamp(const QDateTime &timestamp);
    void setModelRoles();

    bool followingInitialized_ = false;
    QTimer *timer_;
    QDateTime oldestTimestamp_;
    QDateTime newestTimestamp_;
    QList<LogItem*> data_;
    FileModel fileModel_;
    QHash<QByteArray, int> roleByNameHash_;
    QHash<int, QByteArray> roleByEnumHash_;
};

struct LogItem {

    LogItem()
        : level(LogLevel::Value::LevelUnknown),
          isMarked(false)
    { }

    bool operator<(const LogItem& second) const {
        return (timestamp < second.timestamp);
    }

    static bool comparator(const LogItem* first, const LogItem* second) {
        return *first < *second;
    }

    QDateTime timestamp;
    QString pid;
    QString tid;
    QString message;
    LogLevel::Value level;
    uint filehash;
    bool isMarked;
};

#endif
