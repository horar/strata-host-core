/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <StrataRPC/StrataServer.h>
#include <QObject>

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