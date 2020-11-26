#include "SGJsonSyntaxHighlighter.h"

SGJsonSyntaxHighlighter::SGJsonSyntaxHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    attributeFormat_.setForeground(QColor(143,48,140));
    stringFormat_.setForeground(QColor(159,41,24));
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
    Token token, nextToken;

    resolveNextToken(text, 0, token);

    while (token.type != TokenType::TextAtEnd) {
        resolveNextToken(text, token.startIndex + token.length, nextToken);

        QTextCharFormat *format = nullptr;
        switch (token.type) {
        case TokenType::LeftBracket:
        case TokenType::RightBracket:
        case TokenType::LeftSquareBracket:
        case TokenType::RightSquareBracket:
        case TokenType::Colon:
        case TokenType::Comma:
        case TokenType::SyntaxError:
        case TokenType::Bool:
        case TokenType::Null:
        case TokenType::TextAtEnd:
            ; // no format
            break;
        case TokenType::Integer:
        case TokenType::Real:
            format = &numberFormat_;
            break;
        case TokenType::String:
            if (nextToken.type == TokenType::Colon) {
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

void SGJsonSyntaxHighlighter::resolveNextToken(const QString &text, int startIndex, Token &nextToken)
{
    nextToken.type = TokenType::TextAtEnd;
    nextToken.length = 0;
    nextToken.startIndex = startIndex;

    ScannerState state = ScannerState::Start;

    int i = startIndex;
    while(i < text.length()) {
        QChar c = text.at(i);
        switch (state) {
        case ScannerState::Start:
            if (c.isSpace()) {
                ;
            } else if (c.isDigit() || c == '+' || c == '-') {
                state = ScannerState::Integer;
                nextToken.type = TokenType::Integer;
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
            } else if (c == ":") {
                nextToken.type = TokenType::Colon;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == "{") {
                nextToken.type = TokenType::LeftBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == "}") {
                nextToken.type = TokenType::RightBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == "[") {
                nextToken.type = TokenType::LeftSquareBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else if (c == "]") {
                nextToken.type = TokenType::RightSquareBracket;
                nextToken.startIndex = i;
                nextToken.length = 1;
                return;
            } else {
                state = ScannerState::SyntaxError;
                nextToken.type = TokenType::SyntaxError;
            }
            break;
        case ScannerState::Integer:
            if (c.isDigit()) {
                ;
            } else if (c == ".") {
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
                if (word == "true" || word == false) {
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

    if (state == ScannerState::MaybeReal
            || state == ScannerState::MaybeExpReal
            || state == ScannerState::MaybeExpRealSign ) {
        nextToken.type = TokenType::SyntaxError;
    }

    if (nextToken.type != TokenType::TextAtEnd) {
        nextToken.length = i - nextToken.startIndex;
    }
}

bool SGJsonSyntaxHighlighter::isCorrectRightChar(const QChar &c)
{
    return c == '}' || c == ']' || c == ',' || c.isSpace();
}
