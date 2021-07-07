#pragma once

#include <QObject>
#include <QSyntaxHighlighter>
#include <QTextDocument>
#include <QQuickTextDocument>
#include <QRegExp>

class SGTextHighlighter: public QSyntaxHighlighter
{
    Q_OBJECT
    Q_DISABLE_COPY(SGTextHighlighter);

    Q_PROPERTY(QQuickTextDocument* textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString filterPattern READ filterPattern WRITE setFilterPattern NOTIFY filterPatternChanged)
    Q_PROPERTY(FilterSyntax filterPatternSyntax READ filterPatternSyntax WRITE setFilterPatternSyntax NOTIFY filterPatternSyntaxChanged)
    Q_PROPERTY(bool caseSensitive READ caseSensitive WRITE setCaseSensitive NOTIFY caseSensitiveChanged)

    Q_ENUMS(FilterSyntax)
public:
    explicit SGTextHighlighter(QObject *parent = nullptr);

    void setTextDocument(QQuickTextDocument *textDocument);
    QQuickTextDocument* textDocument() const;
    QString filterPattern() const;
    void setFilterPattern(const QString &filter);

    enum FilterSyntax { RegExp, Wildcard, FixedString };

    FilterSyntax filterPatternSyntax() const;
    void setFilterPatternSyntax(FilterSyntax syntax);
    bool caseSensitive() const;
    void setCaseSensitive(bool sensitive);

signals:
    void textDocumentChanged();
    void filterPatternChanged();
    void filterPatternSyntaxChanged();
    void caseSensitiveChanged();

protected:
    void highlightBlock(const QString &text) override;

private:
    QTextCharFormat highlightFormat_;
    QRegExp regularExpression_;

    QQuickTextDocument *textDocument_ = nullptr;

    void updateHighlight();
};
