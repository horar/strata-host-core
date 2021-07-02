#pragma once

#include <QByteArray>

namespace strata::strataRPC
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
     * Getter for the client id
     * @return client id
     */
    [[nodiscard]] QByteArray getClientID() const;

    /**
     * Getter for the client's api version
     * @return enum of the client API version.
     */
    [[nodiscard]] ApiVersion getApiVersion() const;

    /**
     * Updates client's API version
     */
    void UpdateClientApiVersion(const ApiVersion &newAPIVersion);

private:
    QByteArray clientId_;
    ApiVersion APIVersion_;
};

}  // namespace strata::strataRPC
