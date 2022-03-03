/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
