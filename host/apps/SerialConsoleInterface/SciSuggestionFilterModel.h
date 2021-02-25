#pragma once

#include <QAbstractListModel>
#include <QStringList>

class SciPlatform;

class SciSuggestionFilterModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciSuggestionFilterModel)

public:
    explicit SciSuggestionFilterModel(SciPlatform *platform);
    virtual ~SciSuggestionFilterModel() override;
    
    enum ModelRole {
        SuggestionRole = Qt::UserRole,
    };

    QStringList getSuggestionList() const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int getSuggestionListCount() const;

    Q_INVOKABLE QVariantMap get(int row);

signals:

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private: 
    void fillSuggestionList();
    QStringList suggestionList_;
    SciPlatform *platform_;
};
