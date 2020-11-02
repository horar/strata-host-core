#pragma once

#include <QObject>

class StrataClient : public QObject {
    Q_OBJECT

public:
    StrataClient(QObject *parent = nullptr);
    ~StrataClient();
};
