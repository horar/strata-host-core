#pragma once

#include <QObject>
#include <QStack>

enum class CommandType
{
    propertyChanged,
    itemAdded,
    itemDeleted,
    itemMoved,
    itemResized
};

struct UndoCommand
{
    QString file;
    QString uuid;
    QString propertyName;
    QString value;
    QString undoValue;
    QString objectString;

    int x;
    int y;
    int undoX;
    int undoY;

    CommandType commandType;
};

class VisualEditorUndoStack : public QObject
{
    Q_OBJECT

public:
    VisualEditorUndoStack(QObject *parent = nullptr);

    Q_INVOKABLE void undo();

    Q_INVOKABLE void redo();

    Q_INVOKABLE void addCommand(QString file, QString uuid, QString propertyName, QString value, QString undoValue);

    Q_INVOKABLE void addXYCommand(QString file, QString uuid, QString propertyName, int x, int y, int undoX, int undoY);

    Q_INVOKABLE void addItem(QString file, QString uuid, QString objectString);

    Q_INVOKABLE void removeItem(QString file, QString uuid, QString objectString);

    Q_INVOKABLE QString trimQmlEmptyLines(QString fileContents);

signals:
    void runCommand(QString file, QString uuid, QString propertyName, QString value);

    void runItemAdded(QString file, QString uuid);

    void runItemDeleted(QString file, QString uuid, QString objectString);

    void runItemMoved(QString file, QString uuid, int x, int y, int undoX, int undoY);

    void runItemResized(QString file, QString uuid, int x, int y, int undoX, int undoY);

    void undoRedoState(bool undo, bool redo);

private:
    QStack<UndoCommand> undoStack;
    QStack<UndoCommand> redoStack;

    bool isUndoPossible();

    bool isRedoPossible();
};
