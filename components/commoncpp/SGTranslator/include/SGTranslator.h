#pragma once

#include <QObject>
#include <QApplication>
#include <QTranslator>
#include <QQmlEngine>
#include <QQuickItem>
#include <QDebug>

class SGTranslator : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(SGTranslator)

public:
    SGTranslator(QQuickItem* parent = nullptr);
    virtual ~SGTranslator() {}

    Q_INVOKABLE void loadLanguageFile(QString languageFileName = "");

protected:
    void componentComplete();

private:
    QCoreApplication* mApp = QCoreApplication::instance();
    QQmlEngine* mEngine = nullptr;
    QTranslator mTranslator;
};
