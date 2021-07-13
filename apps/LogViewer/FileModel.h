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

    void append(const QString &path);
    int remove(const QString &path); /*returns index at which the file was removed*/
    void clear();
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QString getFilePathAt(const int &pos) const;
    Q_INVOKABLE bool containsFilePath(const QString &path);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QStringList data_;
};

#endif
