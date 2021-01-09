#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QFile>
#include <QTextStream>


struct ScrollbackModelItem;
class SciPlatform;


class SciScrollbackModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciScrollbackModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(bool condensedMode READ condensedMode WRITE setCondensedMode NOTIFY condensedModeChanged)
    Q_PROPERTY(QString exportFilePath READ exportFilePath NOTIFY exportFilePathChanged)
    Q_PROPERTY(bool autoExportIsActive READ autoExportIsActive NOTIFY autoExportIsActiveChanged)
    Q_PROPERTY(QString autoExportFilePath READ autoExportFilePath NOTIFY autoExportFilePathChanged)
    Q_PROPERTY(QString autoExportErrorString READ autoExportErrorString NOTIFY autoExportErrorStringChanged)
    Q_PROPERTY(QString timestampFormat READ timestampFormat CONSTANT)

public:
    explicit SciScrollbackModel(SciPlatform *platform);
    virtual ~SciScrollbackModel() override;

    enum ModelRole {
        MessageRole = Qt::UserRole,
        TypeRole,
        TimestampRole,
        IsCondensedRole,
        IsJsonValidRole,
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
    void append(const QByteArray &message, MessageType type);

    Q_INVOKABLE void setIsCondensedAll(bool condensed);
    Q_INVOKABLE void setIsCondensed(int index, bool condensed);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void clearAutoExportError();
    Q_INVOKABLE QString exportToFile(QString filePath);
    Q_INVOKABLE bool startAutoExport(const QString &filePath);
    Q_INVOKABLE void stopAutoExport();

    QByteArray stringify(const ScrollbackModelItem &item) const;
    QByteArray getTextForExport() const;
    bool condensedMode() const;
    void setCondensedMode(bool condensedMode);
    int maximumCount() const;
    void setMaximumCount(int maximumCount);
    QString exportFilePath() const;
    void setExportFilePath(const QString &filePath);
    bool autoExportIsActive() const;
    QString autoExportFilePath() const;
    void setAutoExportFilePath(const QString &filePath);
    QString autoExportErrorString() const;
    QString timestampFormat() const;

signals:
    void countChanged();
    void condensedModeChanged();
    void exportFilePathChanged();
    void autoExportIsActiveChanged();
    void autoExportFilePathChanged();
    void autoExportErrorStringChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;
    QList<ScrollbackModelItem> data_;
    bool condensedMode_ = false;
    int maximumCount_ = 1;
    bool autoExportIsActive_ = false;
    QString exportFilePath_;
    QString autoExportFilePath_;
    QFile exportFile_;
    SciPlatform *platform_;
    QString autoExportErrorString_;
    QString timestampFormat_ = "hh:mm:ss.zzz";

    void setModelRoles();
    void sanitize();
    void setAutoExportIsActive(bool autoExportIsActive);
    void setAutoExportErrorString(const QString &errorString);
};

struct ScrollbackModelItem {
    QString message;
    SciScrollbackModel::MessageType type;
    QDateTime timestamp;
    bool isCondensed;
    bool isJsonValid;
};

Q_DECLARE_METATYPE(SciScrollbackModel::MessageType)
