#pragma once

#include <Connector.h>

#include <QObject>
#include <QSocketNotifier>

namespace strata::connector
{
class Connector;
}

namespace strata::strataRPC
{
/**
 * Enum to describe errors
 */
enum class ClientConnectorError : short { FailedToConnect, FailedToDisconnect, FailedToSend };

class ClientConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ClientConnector);

public:
    /**
     * ClientConnector constructor.
     * @param [in] serverAddress sets the server address.
     * @param [in] dealerId sets the client id.
     */
    ClientConnector(QString serverAddress, QByteArray dealerId = "StrataClient",
                    QObject *parent = nullptr)
        : QObject(parent), serverAddress_(serverAddress), dealerId_(dealerId)
    {
    }

    /**
     * ClientConnector destructor
     */
    ~ClientConnector();

    bool isConnected();

public slots:
    /**
     * initialize the client's zmq connector, then calls ClientConnector::connectClient()
     * @return True if the initialization is successful and "register_client" request is sent to the
     * server. False otherwise.
     */
    bool initializeConnector();

    /**
     * disconnect the client from the server by sending "unregister" command, disconnect QSignals,
     * and close the zmq connector.
     * @return True if the "unregister" command is sent and the zmq connector is closed
     * successfully.
     */
    bool disconnectClient();

    /**
     * opens zmq connector and send "register_client" command to the server.
     * @return True if the zmq connector is opened and "register_client" command was sent
     * successfully.
     * @return False if failed to open the zmq connector OR the connection is already established.
     */
    bool connectClient();

    /**
     * Sends a message to the server.
     * @param [in] message QByteArray of the message
     * @return True if the message was sent successfully, False otherwise.
     */
    bool sendMessage(const QByteArray &message);

signals:
    /**
     * Signal when there are new messages ready to be read
     * @param [in] message QByteArray of the new message.
     */
    void newMessageReceived(const QByteArray &message);

    void errorOccurred(ClientConnectorError errorType, const QString &errorMessage);
    void clientInitialized();
    void clientConnected();
    void clientDisconnected();

private slots:
    /**
     * Slot to handle QSocketNotifier::activated signal.
     * @note the QSocketNotifier::activated signal only emitted if the buffer is empty and new
     * messages are received. If the buffer is not empty, the socket notifier won't emit anymore
     * signals. As a result, when handling this signal the buffer must be emptied by reading all
     * it's content, otherwise we will not be notified for new messages.
     */
    void readNewMessages(/*int socket*/);

private:
    /**
     * Empties the receive buffer and emits newMessageReceived signal for each new message.
     */
    void readMessages();

    std::unique_ptr<strata::connector::Connector> connector_;
    std::unique_ptr<QSocketNotifier> readSocketNotifier_;
    QString serverAddress_;
    QByteArray dealerId_;
};

}  // namespace strata::strataRPC

Q_DECLARE_METATYPE(strata::strataRPC::ClientConnectorError);
