#include "SGTextHighlighter.h"

#include <QAbstractTextDocumentLayout>


SGTextHighlighter::SGTextHighlighter(QObject *parent)
    : QSyntaxHighlighter(parent)
{
    setCaseSensitive(false);
    setFilterPatternSyntax(FixedString);

    highlightFormat_.setForeground(QColor(0,0,0));
    highlightFormat_.setBackground(QColor(255,255,0));
}

bool SGTextHighlighter::caseSensitive() const
{
    return regularExpression_.caseSensitivity() == Qt::CaseSensitive;
}

void SGTextHighlighter::setCaseSensitive(bool sensitive)
{
    if (caseSensitive() != sensitive) {
        Qt::CaseSensitivity caseSensitive = sensitive ? Qt::CaseSensitive : Qt::CaseInsensitive;
        regularExpression_.setCaseSensitivity(caseSensitive);
        emit caseSensitiveChanged();

        updateHighlight();
    }
}

SGTextHighlighter::FilterSyntax SGTextHighlighter::filterPatternSyntax() const
{
   return static_cast<FilterSyntax>(regularExpression_.patternSyntax());
}

void SGTextHighlighter::setFilterPatternSyntax(SGTextHighlighter::FilterSyntax syntax)
{
    if (filterPatternSyntax() != syntax) {
        regularExpression_.setPatternSyntax(static_cast<QRegExp::PatternSyntax>(syntax));
        emit filterPatternSyntaxChanged();

        updateHighlight();
    }
}

void SGTextHighlighter::setTextDocument(QQuickTextDocument *textDocument)
{
    if (textDocument_ == textDocument) {
        return;
    }

    textDocument_ = textDocument;
    setDocument(textDocument->textDocument());
    emit textDocumentChanged();
}

QQuickTextDocument *SGTextHighlighter::textDocument() const
{
    return textDocument_;
}

QString SGTextHighlighter::filterPattern() const
{
    return regularExpression_.pattern();
}

void SGTextHighlighter::setFilterPattern(const QString &filter)
{
    if (filterPattern() != filter) {
        regularExpression_.setPattern(filter);
        emit filterPatternChanged();

        updateHighlight();
    }
}

void SGTextHighlighter::highlightBlock(const QString &text)
{
    if (regularExpression_.isEmpty()) {
        return;
    }

    int pos = 0;
    while (pos != -1) {
        int substringStart = regularExpression_.indexIn(text, pos);
        if (substringStart == -1 || regularExpression_.matchedLength() == 0) {
            break;
        }

        if (highlightFormat_.isEmpty() == false) {
            setFormat(substringStart, regularExpression_.matchedLength(), highlightFormat_);
        }
        pos += regularExpression_.matchedLength();
    }
}

void SGTextHighlighter::updateHighlight()
{
    if (textDocument_ == nullptr) {
        return;
    }
    // Due to qt bug https://bugreports.qt.io/browse/QTBUG-94704 we are not able to update
    // whole document with rehighlight() but we have to update document block by block.
    int blockCount = textDocument_->textDocument()->blockCount();

    for (int i = 0; i < blockCount; i++) {
        rehighlightBlock(textDocument_->textDocument()->findBlockByLineNumber(i));
        emit textDocument_->textDocument()->documentLayout()->updateBlock(textDocument_->textDocument()->findBlockByLineNumber(i));
    }
}
