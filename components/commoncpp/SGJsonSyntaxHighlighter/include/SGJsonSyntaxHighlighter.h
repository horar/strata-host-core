#pragma once

#include <QObject>
#include <QSyntaxHighlighter>
#include <QTextDocument>
#include <QQuickTextDocument>


class SGJsonSyntaxHighlighter: public QSyntaxHighlighter
{
    Q_OBJECT
    Q_DISABLE_COPY(SGJsonSyntaxHighlighter);

    Q_PROPERTY(QQuickTextDocument* textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)

public:
    SGJsonSyntaxHighlighter(QObject *parent = nullptr);

    void setTextDocument(QQuickTextDocument *textDocument);
    QQuickTextDocument* textDocument() const;

signals:
    void textDocumentChanged();

protected:
    void highlightBlock(const QString &text) override;

private:
    QTextCharFormat attributeFormat_;
    QTextCharFormat stringFormat_;
    QTextCharFormat numberFormat_;

    QQuickTextDocument *textDocument_ = nullptr;
};
