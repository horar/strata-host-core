#pragma once

#include <Connector.h>

#include <QObject>
#include <QSocketNotifier>

namespace strata::strataRPC
{
/**
 * Enum to describe ServerConnector errors
 */
enum class ServerConnectorError : short { FailedToInitialize, FailedToSend };

class ServerConnector : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ServerConnector);

public:
    /**
     * ServerConnector constructor
     * @param [in] serverAddress sets the server address
     */
    ServerConnector(const QString &serverAddress, QObject *parent = nullptr)
        : QObject(parent), connector_(nullptr), serverAddress_(serverAddress)
    {
    }

    /**
     * ServerConnector destructor
     */
    ~ServerConnector();

public slots:
    /**
     * initialize the client's zmq connector and star it. Also this connects QSocketNotifier
     * signals.
     * @return True if the initialization is successful, False otherwise.
     * @note On success, connected signal will be emitted.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool initialize();

    /**
     * Sends a message to a client.
     * @param [in] clientId client id to send the message to.
     * @param [in] message QByteArray of the message
     * @return True if the message was sent successfully, False otherwise.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool sendMessage(const QByteArray &clientId, const QByteArray &message);

signals:
    /**
     * Signal when there are new messages ready to be read
     * @param [in] clientId sender client id.
     * @param [in] message QByteArray of the new message.
     */
    void messageReceived(const QByteArray &clientId, const QByteArray &message);

    /**
     * Emitted when an error has occurred.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(const ServerConnectorError &errorType, const QString &errorMessage);

    /**
     * Emitted when the client connector was initialized successfully.
     */
    void initialized();

    void messageAvailable();

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
     * Empties the receive buffer and emits messageReceived signal for each new message.
     */
    void readMessages();

    std::unique_ptr<strata::connector::Connector> connector_;
    QSocketNotifier *readSocketNotifier_;
    QString serverAddress_;
};

}  // namespace strata::strataRPC

Q_DECLARE_METATYPE(strata::strataRPC::ServerConnectorError);
