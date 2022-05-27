#pragma once

#include <QObject>
#include <QAbstractListModel>



class SciPlatformTestMessageModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformTestMessageModel)

public:

    enum MessageType {
        Info,
        Warning,
        Error,
        Success,
        TestEndSuccess,
        TestEndError,
    };
    Q_ENUM(MessageType)

    enum ModelRole {
        TextRole = Qt::UserRole + 1,
        TypeRole,
    };


    SciPlatformTestMessageModel(QObject *parent = nullptr);
    virtual ~SciPlatformTestMessageModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    void clear();
    void addMessage(MessageType type, QString text);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;


private:



    struct TestMessageItem {
        MessageType type;
        QString text;

    };

    QList<TestMessageItem> data_;

};

Q_DECLARE_METATYPE(SciPlatformTestMessageModel::MessageType)
