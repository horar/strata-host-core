/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGJsonFormatter.h"


SGJsonFormatter::SGJsonFormatter(QObject *parent)
    : QObject(parent)
{
}

QString SGJsonFormatter::prettifyJson(
        const QString &jsonString,
        bool softWrap,
        int indentSize)
{
    QString prettifiedJson;
    QChar spaceChar = QChar::Space;
    QChar breakLineChar = softWrap ? softBreakLine_ : hardBreakLine_;
    Token previousToken, token, nextToken;

    resolveNextToken(jsonString, 0, token);

    int level = 0;
    while (token.type != TokenType::TextAtEnd) {
        resolveNextToken(jsonString, token.startIndex + token.length, nextToken);

        prettifiedJson.append(jsonString.midRef(token.startIndex, token.length));

        switch (token.type) {

        case TokenType::LeftBracket:
        case TokenType::LeftSquareBracket:
            ++level;
            if (nextToken.type == TokenType::RightBracket || nextToken.type == TokenType::RightSquareBracket) {
                ; //do not wrap when object or array is empty
            } else {
                prettifiedJson.append(breakLineChar);
                prettifiedJson.append(QString(indentSize * level, spaceChar));
            }
            break;
        case TokenType::RightBracket:
        case TokenType::RightSquareBracket:
            --level;
            if (previousToken.type != TokenType::LeftBracket && previousToken.type != TokenType::LeftSquareBracket) {
                prettifiedJson.insert(prettifiedJson.size()-1,breakLineChar);
                prettifiedJson.insert(prettifiedJson.size()-1, QString(indentSize * level, spaceChar));
            }
            break;
        case TokenType::Colon:
            prettifiedJson.append(spaceChar);
            break;
        case TokenType::Comma:
            prettifiedJson.append(breakLineChar);
            prettifiedJson.append(QString(indentSize * level, spaceChar));
            break;
        case TokenType::Bool:
        case TokenType::Null:
        case TokenType::Integer:
        case TokenType::Real:
        case TokenType::String:
        case TokenType::SyntaxError:
        case TokenType::TextAtEnd:
            ;
        }

        previousToken = token;
        token = nextToken;
    }

    return prettifiedJson;
}

QString SGJsonFormatter::minifyJson(const QString &jsonString)
{
    QString minifiedJson;
    Token token;

    while (true) {
        resolveNextToken(jsonString, token.startIndex + token.length, token);

        if (token.type == TokenType::TextAtEnd) {
            break;
        }

        minifiedJson.append(jsonString.midRef(token.startIndex, token.length));
    };

    return minifiedJson;
}

QString SGJsonFormatter::convertToHardBreakLines(const QString &text)
{
    QString textWithHardBreakLines = text;
    return textWithHardBreakLines.replace(softBreakLine_, hardBreakLine_);
}

void SGJsonFormatter::resolveNextToken(
        const QString &text,
        int startIndex,
        Token &nextToken)
{
    nextToken.type = TokenType::TextAtEnd;
    nextToken.length = 0;
    nextToken.startIndex = startIndex;

    ScannerState state = ScannerState::Start;

    int i = startIndex;
    while (i < text.length()) {
        QChar c = text.at(i);
        switch (state) {
        case ScannerState::Start:
            if (c.isSpace()) {
                ;
            } else if (c.isDigit()) {
                state = ScannerState::Integer;
                nextToken.type = TokenType::Integer;
                nextToken.startIndex = i;
            } else if (c == '+' || c == '-') {
                state = ScannerState::MaybeInteger;
                nextToken.startIndex = i;
            } else if (c == '"') {
                state = ScannerState::String;
                nextToken.startIndex = i;
            } else if (c.isLetter()) {
                state = ScannerState::OnlyLettersType;
                nextToken.startIndex = i;
            } else if (c == ',') {
                nextToken.type = TokenType::Comma;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == ':') {
                nextToken.type = TokenType::Colon;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == '{') {
                nextToken.type = TokenType::LeftBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == '}') {
                nextToken.type = TokenType::RightBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == '[') {
                nextToken.type = TokenType::LeftSquareBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == ']') {
                nextToken.type = TokenType::RightSquareBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.startIndex = i;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::MaybeInteger:
            if (c.isDigit()) {
                state = ScannerState::Integer;
                nextToken.type = TokenType::Integer;
            } else {
                state = ScannerState::SyntaxError;
            }
            break;
        case ScannerState::Integer:
            if (c.isDigit()) {
                ;
            } else if (c == '.') {
                state = ScannerState::MaybeReal;
            } else if (c == 'e' || c == 'E') {
                state = ScannerState::MaybeExpReal;
            } else if (isCorrectRightChar(c)) {
                nextToken.type = TokenType::Integer;
                nextToken.length = i - nextToken.startIndex;
                return;
            } else {
                 state = ScannerState::SyntaxError;
                 nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::MaybeReal:
            if (c.isDigit()) {
                state = ScannerState::Real;
            } else {
                 state = ScannerState::SyntaxError;
                 nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::Real:
            if (c.isDigit()) {
                ;
            } else if (c == 'e' || c == 'E') {
                state = ScannerState::MaybeExpReal;
            } else if (isCorrectRightChar(c)) {
                nextToken.type = TokenType::Real;
                nextToken.length = i - nextToken.startIndex;
                return;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::MaybeExpReal:
            if (c.isDigit()) {
                state = ScannerState::ExpReal;
            } else if (c == '-' || c == '+') {
                state = ScannerState::MaybeExpRealSign;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::MaybeExpRealSign:
            if (c.isDigit()) {
                state = ScannerState::ExpReal;
            } else {
                 state = ScannerState::SyntaxError;
                 nextToken.type = TokenType::SyntaxError;
            }
        case ScannerState::ExpReal:
            if(c.isDigit()) {
                ;
            } else if (isCorrectRightChar(c)) {
                nextToken.type = TokenType::Real;
                nextToken.length = i - nextToken.startIndex;
                return;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::String:
            if (c == '"') {
                nextToken.type = TokenType::String;
                nextToken.length = i - nextToken.startIndex + 1;
                return;
            } else if (c == '\\') {
                state = ScannerState::Escape;
            }
            break;
        case ScannerState::OnlyLettersType:
            if (c.isLetter()) {
                ;
            } else if (isCorrectRightChar(c)) {
                QString word = text.mid(nextToken.startIndex, i - nextToken.startIndex).toLower();
                if (word == "true" || word == "false") {
                    nextToken.type = TokenType::Bool;
                } else if (word == "null") {
                    nextToken.type = TokenType::Null;
                } else {
                    nextToken.type = TokenType::SyntaxError;
                }

                nextToken.length = i - nextToken.startIndex;
                return;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::Escape:
            state = ScannerState::String;
            break;
        case ScannerState::SyntaxError:
            if (isCorrectRightChar(c)) {
                nextToken.type = TokenType::SyntaxError;
                nextToken.length = i - nextToken.startIndex;
                return;
            }
        }

        ++i;
    }

    //text input for block is over, but token was not determined

    if (state == ScannerState::MaybeInteger
            || state == ScannerState::MaybeReal
            || state == ScannerState::MaybeExpReal
            || state == ScannerState::MaybeExpRealSign
            || state == ScannerState::OnlyLettersType) {
        nextToken.type = TokenType::SyntaxError;
    }

    if (nextToken.type != TokenType::TextAtEnd) {
        nextToken.length = i - nextToken.startIndex;
    }
}

bool SGJsonFormatter::isCorrectRightChar(const QChar &c)
{
    return c == '}' || c == ']' || c == ',' || c.isSpace();
}
