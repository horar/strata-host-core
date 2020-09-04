#include "SGQrcListModel.h"

#include <QFile>
#include <QDir>
#include <QXmlStreamReader>
#include <QDebug>

QrcItem::QrcItem(QObject *parent) : QObject(parent)
{
}

QrcItem::QrcItem(QString filename, QString prefix, QUrl path, QObject *parent) : QObject(parent)
{
    filename_ = filename;
    prefix_ = prefix;
    visible_ = false;
    open_ = false;

    QFileInfo qrcFile(QDir::toNativeSeparators(path.toLocalFile()));
    filepath_ = qrcFile.dir().filePath(filename);
}

QString QrcItem::prefix() const
{
    return prefix_;
}

QString QrcItem::filename() const
{
    return filename_;
}

QString QrcItem::filepath() const
{
    return filepath_;
}

bool QrcItem::visible() const
{
    return visible_;
}

bool QrcItem::open() const
{
    return open_;
}

void QrcItem::setPrefix(QString prefix) {
    if (prefix_ != prefix) {
        prefix_ = prefix;
        emit prefixChanged();
    }
}

void QrcItem::setFilename(QString filename) {
    if (filename_ != filename) {
        filename_ = filename;
        emit filenameChanged();
    }
}

void QrcItem::setFilepath(QString filepath) {
    if (filepath_ != filepath) {
        filepath_ = filepath;
        emit filepathChanged();
    }
}

void QrcItem::setVisible(bool visible) {
    if (visible_ != visible) {
        visible_ = visible;
        emit visibleChanged();
    }
}

void QrcItem::setOpen(bool open) {
    if (open_ != open) {
        open_ = open;
        emit openChanged();
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
    QString prefix = "/";
    while (reader.readNextStartElement() && !reader.hasError()) {
        // Start of XML element
        if (reader.name() == "RCC" || reader.name() == "rcc") {
            if (reader.readNextStartElement()) {
                if (reader.name() == "qresource" && reader.attributes().hasAttribute("prefix")) {
                    prefix = reader.attributes().value("prefix").toString();
                }
                while (reader.readNextStartElement()) {
                    if (reader.name() == "file") {
                        data_.push_back(new QrcItem(reader.readElementText(), prefix, url_));
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
    emit countChanged();
}

QrcItem* SGQrcListModel::get(int index) const
{
    if (index < 0 || index >= data_.count()) {
        return NULL;
    }

    return data_.at(index);
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
    case PrefixRole:
        return item->prefix();
    case FilenameRole:
        return item->filename();
    case FilepathRole:
        return item->filepath();
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

void SGQrcListModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    for (int i = 0; i < data_.length(); i++) {
        delete data_[i];
    }
    data_.clear();

    if (emitSignals) {
        endResetModel();
        emit countChanged();
    }
}

QHash<int, QByteArray> SGQrcListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[PrefixRole] = "prefix";
    roles[FilenameRole] = "filename";
    roles[FilepathRole] = "filepath";
    roles[VisibleRole] = "visible";
    roles[OpenRole] = "open";
    return roles;
}
