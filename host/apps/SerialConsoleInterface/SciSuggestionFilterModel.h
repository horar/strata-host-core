#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include <QHash>

class SciPlatform;

struct SciSuggestionFilterModelItem {
    QString suggestion;
};

class SciSuggestionFilterModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciSuggestionFilterModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciSuggestionFilterModel(SciPlatform *platform);
    virtual ~SciSuggestionFilterModel() override;
    
    enum ModelRole {
        SuggestionRole = Qt::UserRole,
    };

    QStringList getSuggestionList() const;
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
    QList<SciSuggestionFilterModelItem> suggestionList_;
    SciPlatform *platform_;
};
