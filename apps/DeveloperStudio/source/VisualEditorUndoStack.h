#pragma once

#include <QObject>
#include <QStack>
#include <QHash>

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

    Q_INVOKABLE void undo(const QString &file);

    Q_INVOKABLE void redo(const QString &file);

    Q_INVOKABLE void addCommand(const QString &file, const QString &uuid, const QString &propertyName, const QString &value, const QString &undoValue);

    Q_INVOKABLE void addXYCommand(const QString &file, const QString &uuid, const QString &propertyName, const int x, const int y, const int undoX, const int undoY);

    Q_INVOKABLE void addItem(const QString &file, const QString &uuid, const QString &objectString);

    Q_INVOKABLE void removeItem(const QString &file, const QString &uuid, const QString &objectString);

    Q_INVOKABLE void clearStack(const QString &file);

    Q_INVOKABLE bool isUndoPossible(const QString &file);

    Q_INVOKABLE bool isRedoPossible(const QString &file);

    Q_INVOKABLE QString trimQmlEmptyLines(QString fileContents);

signals:
    void undoCommand(QString file, QString uuid, QString propertyName, QString value);

    void undoItemAdded(QString file, QString uuid);

    void undoItemDeleted(QString file, QString uuid, QString objectString);

    void undoItemMoved(QString file, QString uuid, int x, int y, int undoX, int undoY);

    void undoItemResized(QString file, QString uuid, int x, int y, int undoX, int undoY);

    void undoRedoState(QString file, bool undo, bool redo);

private:
    QHash<QString, QPair<QStack<UndoCommand>, QStack<UndoCommand>>> commandTable;

    void addToHashTable(const QString &file, const UndoCommand cmd);
};
