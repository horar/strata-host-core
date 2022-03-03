/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
 * Enum to describe ClientConnector errors.
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
    ClientConnector(const QString &serverAddress,const QByteArray &dealerId = "StrataClient",
                    QObject *parent = nullptr)
        : QObject(parent), serverAddress_(serverAddress), dealerId_(dealerId)
    {
    }

    /**
     * ClientConnector destructor
     */
    ~ClientConnector();

    /**
     * Function to return the connection status.
     * @return True if the client is connected, false otherwise.
     */
    bool isConnected() const;

public slots:
    /**
     * initialize the client's zmq connector, then calls ClientConnector::connect()
     * @return True if the initialization is successful and "register_client" request is sent to the
     * server. False otherwise.
     * @note On success, initialized signal will be emitted.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool initialize();

    /**
     * disconnect the client from the server by sending "unregister" command, disconnect QSignals,
     * and close the zmq connector.
     * @return True if the "unregister" command is sent and the zmq connector is closed
     * successfully.
     * @note On success, disconnected signal will be emitted.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool disconnect();

    /**
     * opens zmq connector and send "register_client" command to the server.
     * @return True if the zmq connector is opened and "register_client" command was sent
     * successfully.
     * @return False if failed to open the zmq connector OR the connection is already established.
     * @note On success, connected signal will be emitted.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool connect();

    /**
     * Sends a message to the server.
     * @param [in] message QByteArray of the message
     * @return True if the message was sent successfully, False otherwise.
     * @note On failure, errorOccurred signal will be emitted.
     */
    bool sendMessage(const QByteArray &message);

signals:
    /**
     * Signal when there are new messages ready to be read
     * @param [in] message QByteArray of the new message.
     */
    void messageReceived(const QByteArray &message);

    /**
     * Emitted when an error has occurred.
     * @param [in] errorType error category description.
     * @param [in] errorMessage QString of the actual error.
     */
    void errorOccurred(const ClientConnectorError &errorType, const QString &errorMessage);

    /**
     * Emitted when the client connector was initialized successfully.
     */
    void initialized();

    /**
     * Emitted when the client connector was connected successfully.
     */
    void connected();

    /**
     * Emitted when the client connector was disconnected successfully.
     */
    void disconnected();

    /**
     * Private signal emitted when there is unhandled socket readReady event.
     */
    void messagesQueued(QPrivateSignal);

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
    std::unique_ptr<QSocketNotifier> readSocketNotifier_;
    QString serverAddress_;
    QByteArray dealerId_;
};

}  // namespace strata::strataRPC

Q_DECLARE_METATYPE(strata::strataRPC::ClientConnectorError);
