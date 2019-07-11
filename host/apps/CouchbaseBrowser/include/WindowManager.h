#ifndef WINDOW_MANAGE
#define WINDOW_MANAGE

#include <QObject>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDir>

class windowManage : public QObject
{
    Q_OBJECT
public:
    windowManage(QQmlApplicationEngine *engine) : engine (engine) {}
    ~windowManage() {}
    Q_INVOKABLE void createNewWindow() {
        engine->load(mainDir);
    }
private:
    const QUrl mainDir = QUrl(QStringLiteral("qrc:/qml/MainWindow.qml"));
    QQmlApplicationEngine *engine =  nullptr;
};

#endif
