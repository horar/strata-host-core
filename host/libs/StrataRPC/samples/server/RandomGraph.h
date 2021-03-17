#pragma once

#include <QObject>

#include <StrataRPC/StrataServer.h>

class RandomGraph : public QObject
{
    Q_OBJECT;
    Q_DISABLE_COPY(RandomGraph);

public:
    RandomGraph(std::shared_ptr<strata::strataRPC::StrataServer> strataServer,
                QObject *parent = nullptr);
    ~RandomGraph();

    void generateGraph(const strata::strataRPC::Message &message);

private:
    std::shared_ptr<strata::strataRPC::StrataServer> strataServer_;
};