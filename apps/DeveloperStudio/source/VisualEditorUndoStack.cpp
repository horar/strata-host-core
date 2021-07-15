#include "VisualEditorUndoStack.h"
#include "logging/LoggingQtCategories.h"

VisualEditorUndoStack::VisualEditorUndoStack(QObject *parent) : QObject(parent) {}

void VisualEditorUndoStack::undo() {
    if (!isUndoPossible()) {
        return;
    }

    UndoCommand poppedCmd = undoStack.pop();
    redoStack.push(poppedCmd);

    switch (poppedCmd.commandType) {
        case CommandType::propertyChanged:
            emit runCommand(poppedCmd.file, poppedCmd.uuid, poppedCmd.propertyName, poppedCmd.undoValue);
            break;
        case CommandType::itemAdded:
            emit runItemAdded(poppedCmd.file, poppedCmd.uuid);
            break;
        case CommandType::itemDeleted:
            emit runItemDeleted(poppedCmd.file, poppedCmd.uuid, poppedCmd.objectString);
            break;
        case CommandType::itemMoved:
            emit runItemMoved(poppedCmd.file, poppedCmd.uuid, poppedCmd.undoX, poppedCmd.undoY, poppedCmd.x, poppedCmd.y);
            break;
        case CommandType::itemResized:
            emit runItemResized(poppedCmd.file, poppedCmd.uuid, poppedCmd.undoX, poppedCmd.undoY, poppedCmd.x, poppedCmd.y);
            break;
    }

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

void VisualEditorUndoStack::redo() {
    if (!isRedoPossible()) {
        return;
    }

    UndoCommand poppedCmd = redoStack.pop();
    undoStack.push(poppedCmd);

    switch (poppedCmd.commandType) {
        case CommandType::propertyChanged:
            emit runCommand(poppedCmd.file, poppedCmd.uuid, poppedCmd.propertyName, poppedCmd.value);
            break;
        case CommandType::itemAdded:
            emit runItemDeleted(poppedCmd.file, poppedCmd.uuid, poppedCmd.objectString);
            break;
        case CommandType::itemDeleted:
            emit runItemAdded(poppedCmd.file, poppedCmd.uuid);
            break;
        case CommandType::itemMoved:
            emit runItemMoved(poppedCmd.file, poppedCmd.uuid, poppedCmd.x, poppedCmd.y, poppedCmd.undoX, poppedCmd.undoY);
            break;
        case CommandType::itemResized:
            emit runItemResized(poppedCmd.file, poppedCmd.uuid, poppedCmd.x, poppedCmd.y, poppedCmd.undoX, poppedCmd.undoY);
            break;
    }

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

void VisualEditorUndoStack::addCommand(QString file, QString uuid, QString propertyName, QString value, QString undoValue) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.propertyName = propertyName;
    cmd.value = value;
    cmd.undoValue = undoValue;
    cmd.commandType = CommandType::propertyChanged;

    undoStack.push(cmd);
    redoStack.clear();

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

void VisualEditorUndoStack::addXYCommand(QString file, QString uuid, QString propertyName, int x, int y, int undoX, int undoY) {
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

    undoStack.push(cmd);
    redoStack.clear();

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

void VisualEditorUndoStack::addItem(QString file, QString uuid, QString objectString) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.objectString = objectString;
    cmd.commandType = CommandType::itemAdded;

    undoStack.push(cmd);
    redoStack.clear();

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

void VisualEditorUndoStack::removeItem(QString file, QString uuid, QString objectString) {
    UndoCommand cmd;
    cmd.file = file;
    cmd.uuid = uuid;
    cmd.objectString = objectString;
    cmd.commandType = CommandType::itemDeleted;

    undoStack.push(cmd);
    redoStack.clear();

    emit undoRedoState(isUndoPossible(), isRedoPossible());
}

bool VisualEditorUndoStack::isUndoPossible() {
    return !undoStack.isEmpty();
}

bool VisualEditorUndoStack::isRedoPossible() {
    return !redoStack.isEmpty();
}

QString VisualEditorUndoStack::trimQmlEmptyLines(QString fileContents) {
    return fileContents.replace(QString("\n\n\n"), QString("\n"));
}
