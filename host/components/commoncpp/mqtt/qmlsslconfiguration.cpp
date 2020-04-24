#include "qmlsslconfiguration.h"

QmlSslConfiguration::QmlSslConfiguration(QObject *parent) :
    QObject(parent)
{
}

QmlSslConfiguration::~QmlSslConfiguration()
{
}

QByteArray QmlSslConfiguration::readKey(const QString &fileName)
{
    QFile input(fileName);
    if (!input.exists() || !input.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open key file for reading";
        return QByteArray();
    }
    return input.readAll();
}

QSslConfiguration QmlSslConfiguration::getQsslConfObject() const
{
    return m_qsslConfiguration;
}

QString QmlSslConfiguration::getCaCertificate() const
{
    return m_rootCertificate;
}

QString QmlSslConfiguration::getLocalCertificate() const
{
    return m_localCertificate;
}

QString QmlSslConfiguration::getPrivateKey() const
{
    return m_privateKey;
}

void QmlSslConfiguration::setCaCertificate(const QString &rootCertificate)
{
    if (m_rootCertificate != rootCertificate) {
        m_rootCertificate = rootCertificate;
        m_qsslConfiguration.setCaCertificates(QSslCertificate::fromPath(m_rootCertificate));
        emit caCertificateChanged(m_rootCertificate);
    }
}

void QmlSslConfiguration::setLocalCertificate(const QString &localCertificate)
{
    if (m_localCertificate != localCertificate) {
        m_localCertificate = localCertificate;
        m_qsslConfiguration.setLocalCertificateChain(QSslCertificate::fromPath(m_localCertificate));
        emit localCertificateChainChanged(m_localCertificate);
    }
}

void QmlSslConfiguration::setPrivateKey(const QString &privateKey)
{
    if (m_privateKey != privateKey) {
        m_privateKey = privateKey;
        QSslKey sslkey(readKey(privateKey), QSsl::Rsa);
        m_qsslConfiguration.setPrivateKey(sslkey);
        emit privateKeyChanged(m_privateKey);
    }
}
