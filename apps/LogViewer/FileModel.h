/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QAbstractListModel>


class FileModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(FileModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit FileModel(QObject *parent = nullptr);
    virtual ~FileModel() override;

    enum {
        FileNameRole = Qt::UserRole,
        FilePathRole,
    };

    int append(const QString &path);
    int remove(const QString &path); /*returns index at which the file was removed*/
    void clear();
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QString getFilePathAt(int index) const;
    qint64 getLastPositionAt(int index) const;
    void setLastPositionAt(int index, qint64 filePosition);
    Q_INVOKABLE bool containsFilePath(const QString &path) const;
    int getFileIndex(const QString &path) const;
    void copyFileMetadata(int fromIndex, int toIndex);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    struct FileData {
        explicit FileData(const QString &path)
            : path(path),
              lastPosition(0)
        { }
        QString path;
        qint64 lastPosition;
    };
    QList<FileData> data_;

    int getDataIndex(const QString &path) const;  // returns -1 if nothing was found
};

#endif
