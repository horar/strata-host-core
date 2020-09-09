#include "SGQrcListModel.h"
#include "SGUtilsCpp.h"

#include <QDir>
#include <QDebug>
#include <QQmlEngine>
#include <QDomNodeList>

/**********************************************************************************
 *  class QrcItem
 **********************************************************************************/
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
        emit dataChanged(index_, SGQrcListModel::FilenameRole);
    }
}

void QrcItem::setFilepath(QUrl filepath) {
    if (filepath_ != filepath) {
        filepath_ = filepath;
        emit dataChanged(index_, SGQrcListModel::FilepathRole);
    }
}

void QrcItem::setRelativePath(QStringList relativePath) {
    relativePath_ = relativePath;
    emit dataChanged(index_, SGQrcListModel::RelativePathRole);
}

void QrcItem::setVisible(bool visible) {
    if (visible_ != visible) {
        visible_ = visible;
        emit dataChanged(index_, SGQrcListModel::VisibleRole);
    }
}

void QrcItem::setOpen(bool open) {
    if (open_ != open) {
        open_ = open;
        emit dataChanged(index_, SGQrcListModel::OpenRole);
    }
}

void QrcItem::setIndex(int index)
{
    if (index_ != index) {
        index_ = index;
        emit dataChanged(index_);
    }
}


/**********************************************************************************
 *  class SGQrcListModel
 **********************************************************************************/

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

    QFile qrcFile(SGUtilsCpp::urlToLocalFile(url_));

    if (!qrcDoc_.isNull()) {
        qrcDoc_.clear();
    }

    if (!qrcFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCritical() << "Failed to open qrc file";
        return;
    }

    if (!qrcDoc_.setContent(&qrcFile)) {
        qCritical() << "Failed to parse qrc file";
    }

    QDomNode qresource = qrcDoc_.elementsByTagName("qresource").at(0);
    if (qresource.hasAttributes() && qresource.attributes().contains("prefix") && qresource.attributes().namedItem("prefix").nodeValue() != "/" ) {
        qCritical() << "Unexpected prefix for qresource";
        return;
    }

    QDomNodeList files = qrcDoc_.elementsByTagName("file");
    for (int i = 0; i < files.count(); i++) {
        QDomElement element = files.at(i).toElement();
        QrcItem* item = new QrcItem(element.text(), url_, data_.count(), this);
        QQmlEngine::setObjectOwnership(item, QQmlEngine::CppOwnership);
        connect(item, &QrcItem::dataChanged, this, &SGQrcListModel::childrenChanged);
        data_.append(item);
    }

    qDebug() << "Successfully parsed qrc file";
    endResetModel();

    qrcFile.close();
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
    QFile qrcFile(SGUtilsCpp::urlToLocalFile(url_));
    if (!qrcFile.open(QIODevice::Truncate | QIODevice::WriteOnly | QIODevice::Text)) {
        qCritical() << "Could not open" << url_;
        return;
    }

    // If the file that we are adding is not a child of the .qrc file, then move it to the directory.
    // below gets the base directory for the qrc file
    QDir dir(QFileInfo(SGUtilsCpp::urlToLocalFile(url_)).dir());
    QFileInfo file(SGUtilsCpp::urlToLocalFile(filepath));

    if (SGUtilsCpp::fileIsChildOfDir(file.filePath(), dir.path()) == false) {
        QFileInfo outputFileLocation(SGUtilsCpp::joinFilePath(dir.path(), file.fileName()));
        QString ext = outputFileLocation.suffix();
        QString filenameWithoutExt = outputFileLocation.fileName().split(".", QString::SkipEmptyParts)[0];

        for (int i = 1; ;i++) {
            if (!outputFileLocation.exists()) {
                break;
            }

            // Output file location is already taken, add "-{i}" to the end of the filename and try again
            outputFileLocation.setFile(SGUtilsCpp::joinFilePath(dir.path(), filenameWithoutExt + "-" + QString::number(i) + "." + ext));
        }

        // Copy the file to the base directory under the new name
        QFile::copy(file.filePath(), outputFileLocation.filePath());
        file.setFile(outputFileLocation.filePath());
    }

    beginInsertRows(QModelIndex(), data_.count(), data_.count());

    QrcItem* item = new QrcItem(dir.relativeFilePath(file.filePath()), file.filePath(), data_.count(), this);
    connect(item, &QrcItem::dataChanged, this, &SGQrcListModel::childrenChanged);
    QQmlEngine::setObjectOwnership(item, QQmlEngine::CppOwnership);
    data_.append(item);

    endInsertRows();

    // Add the QDomElement to qrcDoc_
    QDomElement fileElement = qrcDoc_.createElement("file");
    QDomElement qresources = qrcDoc_.elementsByTagName("qresource").at(0).toElement();
    QDomText text = qrcDoc_.createTextNode(dir.relativeFilePath(file.filePath()));
    fileElement.appendChild(text);
    qresources.appendChild(fileElement);

    // Write the change to disk
    QTextStream stream(&qrcFile);
    stream << qrcDoc_.toString();
    qrcFile.close();
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

void SGQrcListModel::childrenChanged(int index, int role) {
    if (index >= 0 && index < data_.count()) {
        if (role != Qt::UserRole) {
            QVector<int> roleChanged = { role };
            emit dataChanged(QAbstractListModel::index(index), QAbstractListModel::index(index), roleChanged);
        } else {
            emit dataChanged(QAbstractListModel::index(index), QAbstractListModel::index(index));
        }
    }
}
