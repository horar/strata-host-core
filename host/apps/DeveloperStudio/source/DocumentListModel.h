#ifndef DOCUMENT_LIST_MODEL_H
#define DOCUMENT_LIST_MODEL_H

#include <QAbstractListModel>

struct DocumentItem {

    DocumentItem(
            const QString &uri,
            const QString &filename,
            const QString &dirname)
    {
        this->uri = uri;
        this->prettyName = filename;
        this->dirname = dirname;
    }

    QString uri;
    QString prettyName;
    QString dirname;
};

class DocumentListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(DocumentListModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit DocumentListModel(QObject *parent = nullptr);
    virtual ~DocumentListModel() override;

    enum {
        UriRole = Qt::UserRole,
        PrettyNameRole,
        DirnameRole,
        PreviousDirnameRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<DocumentItem* > &list);
    void clear(bool emitSignals=true);

    Q_INVOKABLE QString getFirstUri();
    Q_INVOKABLE QString dirname(int index);


signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<DocumentItem*>data_;
};

#endif //DOCUMENT_LIST_MODEL_H
