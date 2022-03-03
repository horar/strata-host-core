/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGJsonSyntaxHighlighter.h"
#include "SGJsonFormatter.h"

SGJsonSyntaxHighlighter::SGJsonSyntaxHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    attributeFormat_.setForeground(QColor(110,37,108));
    stringFormat_.setForeground(QColor(207,53,31));
    numberFormat_.setForeground(QColor(23,60,233));
}

void SGJsonSyntaxHighlighter::setTextDocument(QQuickTextDocument *textDocument)
{
    if (textDocument_ == textDocument) {
        return;
    }

    textDocument_ = textDocument;
    setDocument(textDocument->textDocument());
    emit textDocumentChanged();
}

QQuickTextDocument *SGJsonSyntaxHighlighter::textDocument() const
{
    return textDocument_;
}

void SGJsonSyntaxHighlighter::highlightBlock(const QString &text)
{
    SGJsonFormatter::Token token, nextToken;

    SGJsonFormatter::resolveNextToken(text, 0, token);

    while (token.type != SGJsonFormatter::TokenType::TextAtEnd) {
        SGJsonFormatter::resolveNextToken(text, token.startIndex + token.length, nextToken);

        QTextCharFormat *format = nullptr;
        switch (token.type) {
        case SGJsonFormatter::TokenType::LeftBracket:
        case SGJsonFormatter::TokenType::RightBracket:
        case SGJsonFormatter::TokenType::LeftSquareBracket:
        case SGJsonFormatter::TokenType::RightSquareBracket:
        case SGJsonFormatter::TokenType::Colon:
        case SGJsonFormatter::TokenType::Comma:
        case SGJsonFormatter::TokenType::SyntaxError:
        case SGJsonFormatter::TokenType::Bool:
        case SGJsonFormatter::TokenType::Null:
        case SGJsonFormatter::TokenType::TextAtEnd:
            ; // no format
            break;
        case SGJsonFormatter::TokenType::Integer:
        case SGJsonFormatter::TokenType::Real:
            format = &numberFormat_;
            break;
        case SGJsonFormatter::TokenType::String:
            if (nextToken.type == SGJsonFormatter::TokenType::Colon) {
                format = &attributeFormat_;
            } else {
                format = &stringFormat_;
            }
            break;
        }

        if (format != nullptr) {
            setFormat(token.startIndex, token.length, *format);
        }

        token = nextToken;
    }
}
