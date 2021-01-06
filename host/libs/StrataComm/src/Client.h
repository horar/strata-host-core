#pragma once

#include <QByteArray>
#include <QString>
#include <QtCore>

namespace strata::strataComm
{
enum class ApiVersion { v1, v2, none };

class Client
{
public:
    /**
     * Client constructor.
     * @param [in] clientId Sets the client id.
     * @param [in] APIVersion sets the client's API version.
     */
    Client(const QByteArray clientId, const ApiVersion APIVersion);

    /**
     * Client destructor
     */
    ~Client();

    /**
     * getter for the client id
     * @return client id
     */
    QByteArray getClientID() const;

    /**
     * Getter for the client's api version
     * @return enum of the client API version.
     */
    ApiVersion getApiVersion() const;

private:
    QByteArray clientId_;
    ApiVersion APIVersion_;
};

}  // namespace strata::strataComm
