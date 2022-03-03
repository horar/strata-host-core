/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "VisualEditorUndoStack.h"
#include "logging/LoggingQtCategories.h"

VisualEditorUndoStack::VisualEditorUndoStack(QObject *parent) : QObject(parent) {}

void VisualEditorUndoStack::undo(const QString &file) {
    if (!isUndoPossible(file)) {
        return;
    }

    UndoCommand poppedCmd = commandTable[file].first.pop();
    commandTable[file].second.push(poppedCmd);

    switch (poppedCmd.commandType) {
        case CommandType::propertyChanged:
            emit undoCommand(poppedCmd.file, poppedCmd.uuid, poppedCmd.propertyName, poppedCmd.undoValue);
            break;
        case CommandType::itemAdded:
            emit undoItemAdded(poppedCmd.file, poppedCmd.uuid);
            break;
        case CommandType::itemDeleted:
            emit undoItemDeleted(poppedCmd.file, poppedCmd.uuid, poppedCmd.objectString);
            break;
        case CommandType::itemMoved:
            emit undoItemMoved(poppedCmd.file, poppedCmd.uuid, poppedCmd.undoX, poppedCmd.undoY, poppedCmd.x, poppedCmd.y);
            break;
        case CommandType::itemResized:
            emit undoItemResized(poppedCmd.file, poppedCmd.uuid, poppedCmd.undoX, poppedCmd.undoY, poppedCmd.x, poppedCmd.y);
            break;
    }

    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::redo(const QString &file) {
    if (!isRedoPossible(file)) {
        return;
    }

    UndoCommand poppedCmd = commandTable[file].second.pop();
    commandTable[file].first.push(poppedCmd);

    switch (poppedCmd.commandType) {
        case CommandType::propertyChanged:
            emit undoCommand(poppedCmd.file, poppedCmd.uuid, poppedCmd.propertyName, poppedCmd.value);
            break;
        case CommandType::itemAdded:
            emit undoItemDeleted(poppedCmd.file, poppedCmd.uuid, poppedCmd.objectString);
            break;
        case CommandType::itemDeleted:
            emit undoItemAdded(poppedCmd.file, poppedCmd.uuid);
            break;
        case CommandType::itemMoved:
            emit undoItemMoved(poppedCmd.file, poppedCmd.uuid, poppedCmd.x, poppedCmd.y, poppedCmd.undoX, poppedCmd.undoY);
            break;
        case CommandType::itemResized:
            emit undoItemResized(poppedCmd.file, poppedCmd.uuid, poppedCmd.x, poppedCmd.y, poppedCmd.undoX, poppedCmd.undoY);
            break;
    }

    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::addCommand(const QString &file, const QString &uuid, const QString &propertyName, const QString &value, const QString &undoValue) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.propertyName = propertyName;
    cmd.value = value;
    cmd.undoValue = undoValue;
    cmd.commandType = CommandType::propertyChanged;

    addToHashTable(file, cmd);
    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::addXYCommand(const QString &file, const QString &uuid, const QString &propertyName, const int x, const int y, const int undoX, const int undoY) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.x = x;
    cmd.y = y;
    cmd.undoX = undoX;
    cmd.undoY = undoY;

    if (propertyName == "move") {
        cmd.commandType = CommandType::itemMoved;
    } else if (propertyName == "resize") {
        cmd.commandType = CommandType::itemResized;
    } else {
        return;
    }

    addToHashTable(file, cmd);
    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::addItem(const QString &file, const QString &uuid, const QString &objectString) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.objectString = objectString;
    cmd.commandType = CommandType::itemAdded;

    addToHashTable(file, cmd);
    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::removeItem(const QString &file, const QString &uuid, const QString &objectString) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.objectString = objectString;
    cmd.commandType = CommandType::itemDeleted;

    addToHashTable(file, cmd);
    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

void VisualEditorUndoStack::addToHashTable(const QString &file, const UndoCommand cmd) {
    if (commandTable.contains(file)) {
        commandTable[file].first.push(cmd);
        commandTable[file].second.clear();
    } else {
        commandTable.insert(file, qMakePair(QStack<UndoCommand>(), QStack<UndoCommand>()));
        commandTable[file].first.push(cmd);
    }
}

void VisualEditorUndoStack::clearStack(const QString &file) {
    if (!commandTable.contains(file)) {
        return;
    }
    commandTable[file].first.clear();
    commandTable[file].first.squeeze();
    commandTable[file].second.clear();
    commandTable[file].second.squeeze();

    emit undoRedoState(file, isUndoPossible(file), isRedoPossible(file));
}

bool VisualEditorUndoStack::isUndoPossible(const QString &file) {
    if (!commandTable.contains(file) || commandTable[file].first.isEmpty()) {
        return false;
    }
    return true;
}

bool VisualEditorUndoStack::isRedoPossible(const QString &file) {
    if (!commandTable.contains(file) || commandTable[file].second.isEmpty()) {
        return false;
    }
    return true;
}

QString VisualEditorUndoStack::trimQmlEmptyLines(QString fileContents) {
    return fileContents.replace(QString("\n\n\n"), QString("\n\n"));
}
