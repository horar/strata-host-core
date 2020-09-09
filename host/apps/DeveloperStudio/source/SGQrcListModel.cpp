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
                        QrcItem* item = new QrcItem(reader.readElementText(), url_, data_.size(), this);
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

    return data_.length();
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
    if (index >= 0 && index < data_.size()) {
        emit dataChanged(QAbstractListModel::index(index), QAbstractListModel::index(index));
    }
}
