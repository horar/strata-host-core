/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include <StrataRPC/DeferredRequest.h>

using namespace strata::strataRPC;

DeferredRequest::DeferredRequest(const int &id, QObject *parent) : QObject(parent), id_(id)
{
}

DeferredRequest::~DeferredRequest()
{
}

int DeferredRequest::getId() const
{
    return id_;
}

void DeferredRequest::callSuccessCallback(const QJsonObject &jsonPayload)
{
    emit finishedSuccessfully(jsonPayload);
}

void DeferredRequest::callErrorCallback(const QJsonObject &jsonPayload)
{
    emit finishedWithError(jsonPayload);
}
