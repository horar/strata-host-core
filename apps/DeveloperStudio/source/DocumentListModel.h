/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef DOCUMENT_LIST_MODEL_H
#define DOCUMENT_LIST_MODEL_H

#include <QAbstractListModel>

struct DocumentItem {

    DocumentItem(
            const QString &uri,
            const QString &filename,
            const QString &dirname,
            const QString &md5 = "")
    {
        this->uri = uri;
        this->prettyName = filename;
        this->dirname = dirname;
        this->md5 = md5;
        this->historyState = "seen";
    }

    QString uri;
    QString prettyName;
    QString dirname;
    QString md5;
    QString historyState;
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
        HistoryStateRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<DocumentItem* > &list);
    void clear(bool emitSignals=true);

    Q_INVOKABLE QString getFirstUri();
    Q_INVOKABLE QString dirname(int index);
    Q_INVOKABLE QString getMD5();
    Q_INVOKABLE void setHistoryState(const QString &doc, const QString &state);
    Q_INVOKABLE void setAllHistoryStateToSeen();
    Q_INVOKABLE bool anyItemsUnseen();
    Q_INVOKABLE QStringList getItemsUnseen();

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<DocumentItem*>data_;
};

#endif //DOCUMENT_LIST_MODEL_H
