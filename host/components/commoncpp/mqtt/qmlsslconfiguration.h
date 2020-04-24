#ifndef QMLSSLCONFIGURATION_H
#define QMLSSLCONFIGURATION_H

#include <QObject>
#include <QSslConfiguration>
#include <QFile>
#include <QSslKey>

class QmlSslConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootCertificate READ getCaCertificate WRITE setCaCertificate NOTIFY caCertificateChanged)
    Q_PROPERTY(QString localCertificate READ getLocalCertificate WRITE setLocalCertificate NOTIFY localCertificateChainChanged)
    Q_PROPERTY(QString privateKey READ getPrivateKey WRITE setPrivateKey NOTIFY privateKeyChanged)

public:
    QmlSslConfiguration(QObject *parent = nullptr);
    ~QmlSslConfiguration();

    // helper methods
    QByteArray readKey(const QString &fileName);
    QSslConfiguration getQsslConfObject() const;

    // Q_PROPERTY READ Methods
    QString getCaCertificate() const;
    QString getLocalCertificate() const;
    QString getPrivateKey() const;

    // Q_PROPERTY WRITE Methods
    void setCaCertificate(const QString &rootCertificate);
    void setLocalCertificate(const QString &lcoalCertificate);
    void setPrivateKey(const QString &PrivateKey);

signals:
    void caCertificateChanged(const QString rootCertificate);
    void localCertificateChainChanged(const QString lcoalCertificate);
    void privateKeyChanged(const QString PrivateKey);

private:
    //Q_DISABLE_COPY(QmlSslConfiguration)
    QString m_rootCertificate;
    QString m_localCertificate;
    QString m_privateKey;
    QSslConfiguration m_qsslConfiguration;

};

#endif // QMLSSLCONFIGURATION_H