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
    enum class TokenType {
        Integer,
        Real,
        String,
        Bool,
        Null,
        LeftBracket,
        RightBracket,
        LeftSquareBracket,
        RightSquareBracket,
        Colon,
        Comma,
        SyntaxError,
        TextAtEnd,
    };

    enum class ScannerState {
        Start,
        String,
        Integer,
        MaybeReal,         // maybe real number (12.), digit has to follow
        Real,              // real number (12.3)
        MaybeExpReal,      // maybe real number in exp format (12.34e), digid or sign has to follow
        MaybeExpRealSign,  // maybe real number in exp form with sign (12.23e+), digit has to follow
        ExpReal,           // real number in exp form (12.34e1 or 12e3 or 12e-3 or 12e+3 or etc)
        Escape,
        OnlyLettersType,   // maybe true, false or null
        SyntaxError
    };

    struct Token {
        TokenType type;
        int startIndex;
        int length;
    };

    QTextCharFormat attributeFormat_;
    QTextCharFormat stringFormat_;
    QTextCharFormat numberFormat_;

    QQuickTextDocument *textDocument_ = nullptr;

    void resolveNextToken(const QString &text, int startIndex, Token &nextToken);
    bool isCorrectRightChar(const QChar &c);
};
