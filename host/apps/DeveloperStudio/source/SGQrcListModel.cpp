#include "SGQrcListModel.h"

#include <QFile>
#include <QDir>
#include <QXmlStreamReader>
#include <QDebug>
#include <QQmlEngine>

QrcItem::QrcItem(QObject *parent) : QObject(parent)
{
}

QrcItem::QrcItem(QString filename, QUrl path, int index, QObject *parent) : QObject(parent)
{
    QFileInfo file(filename);
    QDir fileDir(file.dir());
    while (fileDir.dirName() != ".") {
        relativePath_.append(fileDir.dirName());
        fileDir.cdUp();
    }
    filename_ = file.fileName();
    visible_ = false;
    open_ = false;
    index_ = index;

    QFileInfo qrcFile(QDir::toNativeSeparators(path.toLocalFile()));
    filepath_.setScheme("file");
    filepath_.setPath(qrcFile.dir().filePath(filename));
}

QString QrcItem::filename() const
{
    return filename_;
}

QUrl QrcItem::filepath() const
{
    return filepath_;
}

QStringList QrcItem::relativePath() const
{
    return relativePath_;
}

bool QrcItem::visible() const
{
    return visible_;
}

bool QrcItem::open() const
{
    return open_;
}

void QrcItem::setFilename(QString filename) {
    if (filename_ != filename) {
        filename_ = filename;
        emit dataChanged(index_);
    }
}

void QrcItem::setFilepath(QUrl filepath) {
    if (filepath_ != filepath) {
        filepath_ = filepath;
        emit dataChanged(index_);
    }
}

void QrcItem::setRelativePath(QStringList relativePath) {
    relativePath_ = relativePath;
    emit dataChanged(index_);
}

void QrcItem::setVisible(bool visible) {
    if (visible_ != visible) {
        visible_ = visible;
        emit dataChanged(index_);
    }
}

void QrcItem::setOpen(bool open) {
    if (open_ != open) {
        open_ = open;
        emit dataChanged(index_);
    }
}

void QrcItem::setIndex(int index)
{
    if (index_ != index) {
        index_ = index;
        emit dataChanged(index_);
    }
}

/* ********************************
 *  class SGQrcListModel
 * ********************************/
SGQrcListModel::SGQrcListModel(QObject *parent) : QAbstractListModel(parent)
{
    connect(this, &SGQrcListModel::urlChanged, this, &SGQrcListModel::readQrcFile);
}

SGQrcListModel::~SGQrcListModel()
{
    clear();
}

void SGQrcListModel::readQrcFile()
{
    beginResetModel();
    clear(false);
    QFile qrcIn(QDir::toNativeSeparators(url_.toLocalFile()));

    if (!qrcIn.exists()) {
        qCritical() << "QRC file does not exist." << qrcIn.fileName();
        return;
    }

    if (!qrcIn.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCritical() << "Failed to open qrc file";
        return;
    }

    QXmlStreamReader reader(&qrcIn);
    while (reader.readNextStartElement() && !reader.hasError()) {
        // Start of XML element
        if (reader.name() == "RCC" || reader.name() == "rcc") {
            if (reader.readNextStartElement()) {
                if (reader.name() == "qresource" && reader.attributes().hasAttribute("prefix")) {
                    if (reader.attributes().value("prefix").toString() != "/") {
                        reader.raiseError("Unexpected prefix for qresource");
                        break;
                    }
                }
                while (reader.readNextStartElement()) {
                    if (reader.name() == "file") {
                        QrcItem* item = new QrcItem(reader.readElementText(), url_, data_.count(), this);
                        QQmlEngine::setObjectOwnership(item, QQmlEngine::CppOwnership);
                        connect(item, &QrcItem::dataChanged, this, &SGQrcListModel::childrenChanged);
                        data_.push_back(item);
                    } else {
                        reader.skipCurrentElement();
                    }
                }
            }
        }
    }

    if (reader.hasError()) {
        qCritical() << "Error parsing qrc file:" << reader.errorString();
    } else {
        qDebug() << "Successfully parsed qrc file";
    }
    reader.clear();
    qrcIn.close();

    endResetModel();
    if (data_.count() > 0) {
        emit countChanged();
    }
    emit parsingFinished();
}

QrcItem* SGQrcListModel::get(int index) const
{
    if (index < 0 || index >= data_.count()) {
        return nullptr;
    }

    QrcItem* item = data_.at(index);
    return item;
}

void SGQrcListModel::append(const QUrl &filepath) {
    beginInsertRows(QModelIndex(), data_.count(), data_.count());

    QFileInfo file(QDir::toNativeSeparators(filepath.toLocalFile()));
    QrcItem* item = new QrcItem(file.fileName(), filepath, data_.count(), this);
    QQmlEngine::setObjectOwnership(item, QQmlEngine::CppOwnership);
    data_.append(item);

    endInsertRows();

    emit countChanged();
}

QVariant SGQrcListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return QVariant();
    }

    QrcItem *item = data_.at(row);

    if (item == nullptr) {
        return QVariant();
    }

    switch (role) {
    case FilenameRole:
        return item->filename();
    case FilepathRole:
        return item->filepath();
    case RelativePathRole:
        return item->relativePath();
    case VisibleRole:
        return item->visible();
    case OpenRole:
        return item->open();
    }

    return QVariant();
}

int SGQrcListModel::count() const
{
    return data_.count();
}

QUrl SGQrcListModel::url() const
{
    return url_;
}

void SGQrcListModel::setUrl(QUrl url)
{
    if (url_ != url) {
        url_ = url;
        emit urlChanged();
    }
}

int SGQrcListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)

    return data_.count();
}

void SGQrcListModel::populateModel(const QList<QrcItem *> &list)
{
    beginResetModel();
    clear(false);

    for (int i = 0; i < list.length(); ++i) {
        QrcItem *item = list.at(i);
        data_.append(item);
    }

    endResetModel();

    emit countChanged();
}

bool SGQrcListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || row >= data_.count()) {
        return false;
    } else if (row + count - 1 < 0 || row + count - 1 >= data_.count()) {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    for (int i = row + count - 1; i >= row; i++) {
        delete data_[i];
        data_[i] = nullptr;
        data_.removeAt(i);
    }
    endRemoveRows();

    // Update the indices of the rows after the deleted ones
    for (int j = row; j < data_.count(); j++) {
        data_[j]->setIndex(j);
    }

    emit countChanged();
    return true;
}

Qt::ItemFlags SGQrcListModel::flags(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return Qt::ItemIsEditable;
}

bool SGQrcListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    int row = index.row();
    if (row < 0 || row >= data_.count()) {
        return false;
    }

    QrcItem* item = data_[row];

    switch (role) {
    case FilenameRole:
        item->setFilename(value.toString());
    case FilepathRole:
        item->setFilepath(value.toUrl());
    case VisibleRole:
        item->setVisible(value.toBool());
    case OpenRole:
        item->setOpen(value.toBool());
    }

    return true;
}

bool SGQrcListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || row > data_.count()) {
        return false;
    }

    beginInsertRows(parent, row, row + count - 1);
    for (int i = row; i < count; i++) {
        data_.insert(i, nullptr);
    }
    endInsertRows();
    emit countChanged();
    return true;
}

void SGQrcListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    int i = 0;
    for (; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
        if (i > 0) {
            emit countChanged();
        }
    }
}

QHash<int, QByteArray> SGQrcListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FilenameRole] = "filename";
    roles[FilepathRole] = "filepath";
    roles[RelativePathRole] = "relativePath";
    roles[VisibleRole] = "visible";
    roles[OpenRole] = "open";
    return roles;
}

void SGQrcListModel::childrenChanged(int index) {
    if (index >= 0 && index < data_.count()) {
        emit dataChanged(QAbstractListModel::index(index), QAbstractListModel::index(index));
    }
}
