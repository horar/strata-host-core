#ifndef SGSSLCONFIGURATION_H
#define SGSSLCONFIGURATION_H

#include <QObject>
#include <QSslConfiguration>
#include <QFile>
#include <QSslKey>

class QmlSslConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootCertificate READ getCaCertificate WRITE setCaCertificate NOTIFY caCertificateChanged)
    Q_PROPERTY(QString clientCertificate READ getLocalCertificate WRITE setLocalCertificate NOTIFY localCertificateChanged)
    Q_PROPERTY(QString clientKey READ getPrivateKey WRITE setPrivateKey NOTIFY privateKeyChanged)

public:
    QmlSslConfiguration(QObject *parent = nullptr);
    ~QmlSslConfiguration();

    QByteArray readKey(const QString &fileName);
    QSslConfiguration getQsslConfigurationObject() const;

    QString getCaCertificate() const;
    QString getLocalCertificate() const;
    QString getPrivateKey() const;

    void setCaCertificate(const QString &rootCertificate);
    void setLocalCertificate(const QString &lcoalCertificate);
    void setPrivateKey(const QString &PrivateKey);

signals:
    void caCertificateChanged(const QString &rootCertificate);
    void localCertificateChanged(const QString &lcoalCertificate);
    void privateKeyChanged(const QString &PrivateKey);

private:
    Q_DISABLE_COPY(QmlSslConfiguration)
    QString rootCertificate_;
    QString localCertificate_;
    QString privateKey_;
    QSslConfiguration qSslConfiguration_;

};

#endif // SGSSLCONFIGURATION_H
