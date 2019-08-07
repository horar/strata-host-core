#ifndef WINDOW_MANAGER
#define WINDOW_MANAGER

#include <QObject>

class QQmlApplicationEngine;

class WindowManager : public QObject
{
    Q_OBJECT

public:
    explicit WindowManager(QQmlApplicationEngine *engine) : engine_(engine) {}

    ~WindowManager() {}

    Q_INVOKABLE void createNewWindow();

    Q_INVOKABLE void closeWindow(const int &id);

private:
    QQmlApplicationEngine *engine_ = nullptr;

    int window_idx_ = 0;

    std::map<int, QObject*> all_windows_;
};

#endif
