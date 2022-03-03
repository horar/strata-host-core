/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGFileTabModel.h"
#include "logging/LoggingQtCategories.h"
#include "SGUtilsCpp.h"

/*******************************************************************
 * class SGFileTabItem
 ******************************************************************/

SGFileTabItem::SGFileTabItem()
{
}

SGFileTabItem::SGFileTabItem(const QString &filename, const QUrl &filepath, const QString &filetype, const QString id) :
    id_(id),
    filename_(filename),
    filepath_(filepath),
    filetype_(filetype)
{
    unsavedChanges_ = false;
    exists_ = true;
}

QString SGFileTabItem::filename() const
{
    return filename_;
}

QUrl SGFileTabItem::filepath() const
{
    return filepath_;
}

QString SGFileTabItem::filetype() const
{
    return filetype_;
}

bool SGFileTabItem::unsavedChanges() const
{
    return unsavedChanges_;
}

bool SGFileTabItem::exists() const
{
    return exists_;
}

QString SGFileTabItem::id() const
{
    return id_;
}

bool SGFileTabItem::setFilename(const QString &filename)
{
    if (filename_ != filename) {
        filename_ = filename;
        return true;
    }
    return false;
}

bool SGFileTabItem::setFilepath(const QUrl &filepath)
{
    if (filepath_ != filepath) {
        filepath_ = filepath;
        return true;
    }
    return false;
}

bool SGFileTabItem::setFiletype(const QString &filetype)
{
    if (filetype_ != filetype) {
        filetype_ = filetype;
        return true;
    }
    return false;
}

bool SGFileTabItem::setId(const QString &id)
{
    if (id_ != id) {
        id_ = id;
        return true;
    }
    return false;
}

bool SGFileTabItem::setUnsavedChanges(const bool &unsaved)
{
    if (unsavedChanges_ != unsaved) {
        unsavedChanges_ = unsaved;
        return true;
    }
    return false;
}

bool SGFileTabItem::setExists(const bool &exists)
{
    if (exists_ != exists) {
        exists_ = exists;
        return true;
    }
    return false;
}

/*******************************************************************
 * class SGFileTabModel
 ******************************************************************/

SGFileTabModel::SGFileTabModel(QObject *parent) : QAbstractListModel(parent)
{
    currentIndex_ = 0;
}

SGFileTabModel::~SGFileTabModel()
{
    clear(false);
}

// OVERRIDES BEGIN

QHash<int, QByteArray> SGFileTabModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(FilenameRole, "filename");
    roles.insert(FilepathRole, "filepath");
    roles.insert(FiletypeRole, "filetype");
    roles.insert(UIdRole, "id");
    roles.insert(UnsavedChangesRole, "unsavedChanges");
    roles.insert(ExistsRole, "exists");
    return roles;
}

QVariant SGFileTabModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= data_.size()) {
        qCWarning(lcControlViewCreator) << "Trying to access to out of range index in file tab list";
        return QVariant();
    }

    SGFileTabItem* tab = data_.at(row);

    switch (role) {
        case FilenameRole:
            return tab->filename();
        case FilepathRole:
            return tab->filepath();
        case FiletypeRole:
            return tab->filetype();
        case UIdRole:
            return tab->id();
        case UnsavedChangesRole:
            return tab->unsavedChanges();
        case ExistsRole:
            return tab->exists();
        default:
            return QVariant();
    }
}

bool SGFileTabModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    int row = index.row();
    if (row < 0 || row >= data_.size()) {
        qCWarning(lcControlViewCreator) << "Trying to access to out of range index in file tab list";
        return false;
    }

    SGFileTabItem* tab = data_.at(row);
    bool success;

    switch (role) {
        case FilenameRole:
            success = tab->setFilename(value.toString());
            break;
        case FilepathRole:
            success = tab->setFilepath(value.toUrl());
            break;
        case FiletypeRole:
            success = tab->setFiletype(value.toString());
            break;
        case UIdRole:
            tabIds_.remove(tab->id());
            if (currentId_ == tab->id()) {
                success = tab->setId(value.toString());
                tabIds_.insert(tab->id());
                setCurrentId(tab->id());
            } else {
                success = tab->setId(value.toString());
                tabIds_.insert(tab->id());
            }
            break;
        case UnsavedChangesRole:
            success = tab->setUnsavedChanges(value.toBool());
            break;
        case ExistsRole:
            success = tab->setExists(value.toBool());
            break;
        default:
            return false;
    }

    if (success) {
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}

int SGFileTabModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return data_.count();
}

Qt::ItemFlags SGFileTabModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

// OVERRIDES END

// CUSTOM FUNCTIONS BEGIN

bool SGFileTabModel::addTab(const QString &filename, const QUrl &filepath, const QString &filetype, const QString &id)
{
    if (hasTab(id)) {
        setCurrentId(id);
        return false;
    }

    if (id.isEmpty()) {
        qCCritical(lcControlViewCreator) << "File id is empty";
        return false;
    } else if (filename.isEmpty()) {
        qCCritical(lcControlViewCreator) << "File name is empty";
        return false;
    } else if (filetype.isEmpty()) {
        qCCritical(lcControlViewCreator) << "File type is empty";
        return false;
    }

    QString path = SGUtilsCpp::urlToLocalFile(filepath);
    if (!SGUtilsCpp::exists(path)) {
        qCCritical(lcControlViewCreator) << "File does not exist in file path";
        return false;
    }

    beginInsertRows(QModelIndex(), data_.count(), data_.count());
    data_.append(new SGFileTabItem(filename, filepath, filetype, id));
    tabIds_.insert(id);
    endInsertRows();

    setCurrentIndex(data_.count() - 1);
    emit countChanged();
    emit tabOpened(filepath);
    return true;
}

bool SGFileTabModel::closeTab(const QString &id)
{
    if (!hasTab(id)) {
        return false;
    }
    int index = 0;

    for (; index < data_.count(); index++) {
        if (id == data_.at(index)->id()) {
            break;
        }
    }

    return closeTabAt(index);
}

bool SGFileTabModel::closeTabAt(const int index)
{
    if (index < 0 || index >= data_.count()) {
        return false;
    }

    const QString id = data_[index]->id();
    const QUrl filepath = data_[index]->filepath();
    beginRemoveRows(QModelIndex(), index, index);
    delete data_[index];
    data_.removeAt(index);
    tabIds_.remove(id);
    endRemoveRows();

    // Set the current index
    if (index == currentIndex_) {
        // This handles the case where the closed tab is the current tab
        if (data_.count() == 0) {
            setCurrentIndex(0);
            emit countChanged();
            return true;
        }

        if (index >= data_.count()) {
            // Handle the case were last tab was removed
            setCurrentIndex(data_.count() - 1);
        } else {
            setCurrentIndex(currentIndex_);
        }
    } else if (index < currentIndex_) {
        setCurrentIndex(currentIndex_ - 1);
    }

    emit countChanged();
    emit tabClosed(filepath);
    return true;
}

void SGFileTabModel::closeAll()
{
    clear();
}

void SGFileTabModel::saveFileAt(const int index, bool close)
{
    if (index < 0 || index >= data_.count()) {
        return;
    }

    emit saveRequested(index, close);
}

void SGFileTabModel::saveAll(bool close)
{
    emit saveAllRequested(close);
}

bool SGFileTabModel::hasTab(const QString &id) const
{
    return tabIds_.contains(id);
}

void SGFileTabModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    qDeleteAll(data_.begin(), data_.end());
    data_.clear();
    tabIds_.clear();

    if (emitSignals) {
        emit countChanged();
        endResetModel();
    }
}

int SGFileTabModel::getIndexById(const QString &id) const
{
    if (hasTab(id)) {
        for (int i = 0; i < data_.count(); ++i) {
            if (data_[i]->id() == id) {
                return i;
            }
        }
    }
    return -1;
}

void SGFileTabModel::setExists(const QString &id, const bool &exists)
{
    int index = getIndexById(id);
    if (index >= 0) {
        if (data_[index]->unsavedChanges()) {
            setData(QAbstractListModel::index(index), exists, ExistsRole);
        } else {
            closeTabAt(index);
        }
    }
}

int SGFileTabModel::findTabByFilepath(const QUrl &filepath)
{
    for (int i = 0; i < data_.count(); ++i) {
        if (data_[i]->filepath() == filepath) {
            return i;
        }
    }
    return -1;
}

int SGFileTabModel::getUnsavedCount() const
{
    int count = 0;
    for (SGFileTabItem* tab : data_) {
        if (tab->unsavedChanges()) {
            ++count;
        }
    }
    return count;
}

bool SGFileTabModel::updateTab(const QString &id, const QString &filename, const QUrl &filepath, const QString &filetype)
{
    for (int i = 0; i < data_.count(); ++i) {
        if (data_[i]->id() == id) {
            QModelIndex index = QAbstractListModel::index(i);
            setData(index, filename, FilenameRole);
            setData(index, filepath, FilepathRole);
            setData(index, filetype, FiletypeRole);
            return true;
        }
    }
    return false;
}

int SGFileTabModel::count() const
{
    return data_.count();
}

int SGFileTabModel::currentIndex() const
{
    return currentIndex_;
}

QString SGFileTabModel::currentId() const
{
    return currentId_;
}

void SGFileTabModel::setCurrentIndex(const int index)
{
    // Here we want to emit that the current index has changed if:
    //  1. The actual index value changes
    //  2. The id at the current index changes
    if (currentIndex_ != index) {
        currentIndex_ = index;
        currentId_ = data_[index]->id();
        emit currentIndexChanged();
    } else if (data_.count() == 0) {
        currentId_.clear();
        emit currentIndexChanged();
    } else if (currentId_ != data_[currentIndex_]->id()) {
        currentId_ = data_[index]->id();
        emit currentIndexChanged();
    }
}

void SGFileTabModel::setCurrentId(const QString &id)
{
    if (currentId_ != id) {
        int i = 0;
        for (; i < data_.count(); i++) {
            if (data_.at(i)->id() == id) {
                break;
            }
        }

        if (i < data_.count()) {
            setCurrentIndex(i);
        }
    }
}

// CUSTOM FUNCTIONS END
