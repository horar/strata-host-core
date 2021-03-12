#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QStringList>

class SciPlatform;

struct SciFilterSuggestionModelItem {
    QString suggestion;
};

class SciFilterSuggestionModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciFilterSuggestionModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciFilterSuggestionModel(QObject *parent = nullptr);
    virtual ~SciFilterSuggestionModel() override;

    enum ModelRole {
        SuggestionRole = Qt::UserRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;
    void add(const QByteArray &message);

    Q_INVOKABLE QVariantMap get(int row);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<SciFilterSuggestionModelItem> suggestionList_;
};
