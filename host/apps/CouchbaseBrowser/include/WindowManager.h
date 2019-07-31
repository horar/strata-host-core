#ifndef WINDOW_MANAGE
#define WINDOW_MANAGE

#include <QObject>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <QDir>
#include <iostream>

class windowManage : public QObject
{
    Q_OBJECT
public:
    windowManage(QQmlApplicationEngine *engine) : engine (engine) {}
    ~windowManage() {}
    Q_INVOKABLE void createNewWindow() {
        ids++;
        engine->load(mainDir);
        allWindows[ids] = engine->rootObjects().last();
        QQmlProperty::write(allWindows[ids],"windowId",ids);
    }
    Q_INVOKABLE void closeWindow(int id) {
        allWindows[id]->deleteLater();
    }
private:
    const QUrl mainDir = QUrl(QStringLiteral("qrc:/qml/MainWindow.qml"));
    QQmlApplicationEngine *engine =  nullptr;
    std::map<int, QObject*> allWindows;
    int ids = 0;
};

#endif
