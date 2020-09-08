#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QHash>
#include <QByteArray>
#include <QString>
#include <QUrl>
#include <QList>
#include <QVariantMap>

class QrcItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY filenameChanged)
    Q_PROPERTY(QUrl filepath READ filepath WRITE setFilepath NOTIFY filepathChanged)
    Q_PROPERTY(QStringList relativePath READ relativePath NOTIFY relativePathChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool open READ open WRITE setOpen NOTIFY openChanged)

public:
    explicit QrcItem(QObject *parent = nullptr);
    QrcItem(QString filename, QUrl path, QObject *parent = nullptr);

    QString filename() const;
    QUrl filepath() const;
    QStringList relativePath() const;
    bool visible() const;
    bool open() const;

    void setFilename(QString filename);
    void setFilepath(QUrl filepath);
    void setRelativePath(QStringList relativePath);
    void setVisible(bool visible);
    void setOpen(bool open);

signals:
    void filenameChanged();
    void filepathChanged();
    void relativePathChanged();
    void visibleChanged();
    void openChanged();
private:
    QString filename_;
    QUrl filepath_;
    QStringList relativePath_;
    bool visible_;
    bool open_;
};

Q_DECLARE_METATYPE(QrcItem*)

class SGQrcListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    enum QrcRoles {
        FilenameRole = Qt::UserRole + 1,
        FilepathRole,
        RelativePathRole,
        VisibleRole,
        OpenRole
    };

    explicit SGQrcListModel(QObject *parent = nullptr);
    virtual ~SGQrcListModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<QrcItem*> &list);
    void readQrcFile();
    void clear(bool emitSignals=true);
    QUrl url() const;
    void setUrl(QUrl url);

    Q_INVOKABLE QrcItem* get(int index) const;
signals:
    void countChanged();
    void urlChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;
private:
    QList<QrcItem*> data_;
    QUrl url_;
};
