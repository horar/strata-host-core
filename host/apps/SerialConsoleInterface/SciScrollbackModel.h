#ifndef SCI_SCROLLBACK_MODEL_H
#define SCI_SCROLLBACK_MODEL_H

#include <QAbstractListModel>
#include <QDateTime>

/* forward declarations */
struct ScrollbackModelItem;


class SciScrollbackModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciScrollbackModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool condensedMode READ condensedMode WRITE setCondensedMode NOTIFY condensedModeChanged)

public:
    explicit SciScrollbackModel(QObject *parent = nullptr);
    virtual ~SciScrollbackModel() override;

    enum ModelRole {
        MessageRole = Qt::UserRole,
        TypeRole,
        TimestampRole,
        CondensedRole,
    };

    enum class MessageType {
        Request,
        Response,
    };

    Q_ENUM(MessageType)

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    Q_INVOKABLE QVariant data(int row, const QByteArray &role) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;
    void append(const QString &message, MessageType type);

    Q_INVOKABLE void setAllCondensed(bool condensed);
    Q_INVOKABLE void setCondensed(int index, bool condensed);
    Q_INVOKABLE void clear();

    QString getTextForExport() const;
    bool condensedMode() const;
    void setCondensedMode(bool condensedMode);
    int maximumCount() const;
    void setMaximumCount(int maximumCount);

signals:
    void countChanged();
    void condensedModeChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;
    QList<ScrollbackModelItem> data_;
    bool condensedMode_ = true;
    int maximumCount_ = 1;

    void setModelRoles();
    void sanitize();
};

struct ScrollbackModelItem {
    QString message;
    SciScrollbackModel::MessageType type;
    QDateTime timestamp;
    bool condensed;
};

Q_DECLARE_METATYPE(SciScrollbackModel::MessageType)

#endif //SCI_SCROLLBACK_MODEL_H
