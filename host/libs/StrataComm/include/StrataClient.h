#pragma once

#include <QObject>

namespace strata::strataComm {

class StrataClient : public QObject {
    Q_OBJECT

public:
    StrataClient(QObject *parent = nullptr);
    ~StrataClient();
};

}   // namespace strata::strataComm
