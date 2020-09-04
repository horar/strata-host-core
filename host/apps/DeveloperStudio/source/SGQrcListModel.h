#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QHash>
#include <QByteArray>
#include <QString>
#include <QUrl>
#include <QList>

class QrcItem : QObject
{
    Q_OBJECT
    Q_PROPERTY(QString prefix READ prefix WRITE setPrefix NOTIFY prefixChanged)
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY filenameChanged)
    Q_PROPERTY(QString filepath READ filepath WRITE setFilepath NOTIFY filepathChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool open READ open WRITE setOpen NOTIFY openChanged)

public:
    explicit QrcItem(QObject *parent = nullptr);
    QrcItem(QString filename, QString prefix, QUrl path, QObject *parent = nullptr);

    QString prefix() const;
    QString filename() const;
    QString filepath() const;
    bool visible() const;
    bool open() const;

    void setPrefix(QString);
    void setFilename(QString);
    void setFilepath(QString);
    void setVisible(bool);
    void setOpen(bool);

signals:
    void prefixChanged();
    void filenameChanged();
    void filepathChanged();
    void visibleChanged();
    void openChanged();
private:
    QString prefix_;
    QString filename_;
    QString filepath_;
    bool visible_;
    bool open_;
};

class SGQrcListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    enum QrcRoles {
        PrefixRole = Qt::UserRole + 1,
        FilenameRole,
        FilepathRole,
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
