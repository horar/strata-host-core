#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QHash>
#include <QByteArray>
#include <QString>
#include <QUrl>
#include <QList>
#include <QVariantMap>
#include <QDomDocument>
#include <QFile>

/**
 * @brief QrcItem This class is used as an element in the SGQrcListModel
 */
class QrcItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY dataChanged)
    Q_PROPERTY(QUrl filepath READ filepath WRITE setFilepath NOTIFY dataChanged)
    Q_PROPERTY(QStringList relativePath READ relativePath NOTIFY dataChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY dataChanged)
    Q_PROPERTY(bool open READ open WRITE setOpen NOTIFY dataChanged)

public:
    explicit QrcItem(QObject *parent = nullptr);

    /**
     * @brief QrcItem Constructor used to populate QrcItem
     * @param filename The name of the file. Note* this should be as-is in the .qrc file. Ex) "control-views/view.qml" is valid
     * @param rootDirectoryPath The QUrl of the projects root directory
     * @param index Index of the item
     * @param parent Parent object
     */
    QrcItem(QString filename, QUrl rootDirectoryPath, int index, QObject *parent = nullptr);

    /**
     * @brief filename
     * @return Returns the `filename`
     */
    QString filename() const;

    /**
     * @brief filepath
     * @return Returns the `filepath`
     */
    QUrl filepath() const;

    /**
     * @brief relativePath
     * @return Returns the `relativePath`
     */
    QStringList relativePath() const;

    /**
     * @brief visible
     * @return Returns `visible`
     */
    bool visible() const;

    /**
     * @brief open
     * @return Returns `open`
     */
    bool open() const;

    /**
     * @brief setFilename Sets the `filename` property
     * @param filename The filename to set
     */
    void setFilename(QString filename);

    /**
     * @brief setFilepath Sets the `filepath` property
     * @param filepath The filepath to set
     */
    void setFilepath(QUrl filepath);

    /**
     * @brief setRelativePath Sets the `relativePath` property
     * @param relativePath The relativePath to set
     */
    void setRelativePath(QStringList relativePath);

    /**
     * @brief setVisible Sets the `visible` property
     * @param visible The value to set `visible` to
     */
    void setVisible(bool visible);

    /**
     * @brief setOpen Sets the `open` property
     * @param open The value to set `open` to
     */
    void setOpen(bool open);

    /**
     * @brief setIndex Sets the `index` property
     * @param index The index to set
     */
    void setIndex(int index);

signals:
    void dataChanged(int index, int role = Qt::UserRole);

private:
    QString filename_;
    QUrl filepath_;
    QStringList relativePath_;
    bool visible_;
    bool open_;
    int index_;
};

Q_DECLARE_METATYPE(QrcItem*)

/**
 * @brief SGQrcListModel Implements a model used in managing .qrc files and their contents
 */
class SGQrcListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QUrl projectDirectory READ projectDirectory NOTIFY projectDirectoryChanged)

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

    /**
     * @brief data An override for QAbstractListModel that returns an element's property
     * @param index The index to get
     * @param role The property role to get
     * @return Returns a QVariant of the object's property
     */
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /**
     * @brief rowCount An override for QAbstractListModel that returns the list's count
     * @param parent UNUSED
     * @return Returns the element count of `data_`
     */
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief clear Clears the `data_` list
     * @param emitSignals Setting this to true will emit the countChanged() signal. Default is true
     */
    void clear(bool emitSignals=true);

    /**
     * @brief removeRows Removes `count` amount of rows starting from `row`
     * @param row The starting index to remove
     * @param count The number of rows to remove starting from `row`
     * @param parent UNUSED
     * @return Returns true if rows were removed, otherwise returns false
     */
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    /**
     * @brief flags An override from QAbstractListModel that returns the Qt::ItemIsEditable flag
     * @param index The index of the item
     * @return Returns Qt::ItemIsEditable
     */
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    /**
     * @brief count Used from QML to return the count of `data_`
     * @return Returns data_.count()
     */
    int count() const;

    /**
     * @brief readQrcFile Reads a .qrc file and populates the model
     */
    void readQrcFile();

    /**
     * @brief url Returns the url to the .qrc file
     * @return The url to the .qrc file
     */
    QUrl url() const;

    /**
     * @brief projectDirectory Returns the url to the project root directory
     * @return The url to the project root directory
     */
    QUrl projectDirectory() const;

    /**
     * @brief setUrl Sets the url of the .qrc file
     * @param url The url to set
     */
    void setUrl(QUrl url);

    /**
     * @brief setData An override to allow data to be modifiable from delegates
     * @param index Index to modify
     * @param value Value to set
     * @param role Role to change
     * @return Returns true if successful, false otherwise
     */
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    /**
     * @brief get Gets the QrcItem* at index `index`
     * @param index The index to get
     * @return Returns the QrcItem* at index `index`
     */
    Q_INVOKABLE QrcItem* get(int index) const;

    /**
     * @brief append Appends a new QrcItem* to data_ and writes the change to disk
     * @param filepath The filepath of the new file
     */
    Q_INVOKABLE void append(const QUrl &filepath);
signals:
    void countChanged();
    void urlChanged();
    void projectDirectoryChanged();
    void parsingFinished();

public slots:
    void childrenChanged(int index, int role);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;
private:
    QList<QrcItem*> data_;
    /**
     * @brief url_ The QUrl of the .qrc file
     */
    QUrl url_;

    /**
     * @brief projectDir_ The QUrl of the project's root directory
     */
    QUrl projectDir_;

    QDomDocument qrcDoc_;

    /**
     * @brief save Saves the qrcDoc_ to disk
     */
    void save();
};
