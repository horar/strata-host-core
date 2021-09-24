/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>

class SGJsonFormatter: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGJsonFormatter);

public:
    explicit SGJsonFormatter(QObject *parent = nullptr);

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
    Q_ENUM(TokenType);

    struct Token {
        TokenType type = TokenType::SyntaxError;
        int startIndex = 0;
        int length = 0;
    };

    /*!
     * Format valid json string.
     * \param jsonString valid json string
     * \param indentSize number of spaces used for indentation
     * \return formatted json string
     */
    Q_INVOKABLE static QString prettifyJson(
            const QString &jsonString,
            bool softWrap=false,
            int indentSize=4);

    /*!
     * Removes all unnecessary white spaces from valid json string.
     * \param jsonString valid json string
     * \return json string without unnecessary spaces
     */
    Q_INVOKABLE static QString minifyJson(const QString &jsonString);


    /*!
     * Replaces all soft break lines with hard breaks
     * \param text text to be converted
     * \return converted text
     */
    Q_INVOKABLE static QString convertToHardBreakLines(const QString &text);

    static void resolveNextToken(
            const QString &text,
            int startIndex,
            Token &nextToken);

private:
    enum class ScannerState {
        Start,
        String,
        MaybeInteger,      // maybe integer (+ or -), digit has to follow
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

    /* Soft breaks allow to process whole text with SyntaxHighlighter at once,
     * otherwise text would be processed line by line */
    static constexpr QChar softBreakLine_ = QChar(0x2028);
    static constexpr QChar hardBreakLine_ = QChar('\n');

    bool static isCorrectRightChar(const QChar &c);
};
