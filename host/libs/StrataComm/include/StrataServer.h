#pragma once

#include <QObject>

namespace strata::strataComm {

class StrataServer : public QObject {
    Q_OBJECT

public:
    StrataServer(QObject *parent = nullptr);
    ~StrataServer();
};

}   // namespace strata::strataComm
