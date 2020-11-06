#pragma once

#include <QObject>

#include <Dispatcher.h>
#include <ClientsController.h>

namespace strata::strataComm {

class StrataServer : public QObject {
    Q_OBJECT

public:
    StrataServer(QObject *parent = nullptr);
    ~StrataServer();

private:
    Dispatcher dispatcher_;
    ClientsController ClientsController;

};

}   // namespace strata::strataComm
