#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QAbstractListModel>


struct FileItem;

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
    void clear(bool emitSignals = true);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QStringList getFilePaths() const;
    QString getFilePathAt(const int &pos) const;
    bool containsFilePath(const QString &path);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:

    QList<FileItem> data_;
};

struct FileItem {

    QString filepath;
};

#endif
