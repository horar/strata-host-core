#pragma once

#include <QObject>

class StrataServer : public QObject {
    Q_OBJECT

public:
    StrataServer(QObject *parent = nullptr);
    ~StrataServer();
};
