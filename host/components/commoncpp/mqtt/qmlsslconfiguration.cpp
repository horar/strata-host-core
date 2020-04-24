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
    return qsslConfiguration_;
}

QString QmlSslConfiguration::getCaCertificate() const
{
    return rootCertificate_;
}

QString QmlSslConfiguration::getLocalCertificate() const
{
    return localCertificate_;
}

QString QmlSslConfiguration::getPrivateKey() const
{
    return privateKey_;
}

void QmlSslConfiguration::setCaCertificate(const QString &rootCertificate)
{
    if (rootCertificate_ != rootCertificate) {
        rootCertificate_ = rootCertificate;
        qsslConfiguration_.setCaCertificates(QSslCertificate::fromPath(rootCertificate_));
        emit caCertificateChanged(rootCertificate_);
    }
}

void QmlSslConfiguration::setLocalCertificate(const QString &localCertificate)
{
    if (localCertificate_ != localCertificate) {
        localCertificate_ = localCertificate;
        qsslConfiguration_.setLocalCertificateChain(QSslCertificate::fromPath(localCertificate_));
        emit localCertificateChainChanged(localCertificate_);
    }
}

void QmlSslConfiguration::setPrivateKey(const QString &privateKey)
{
    if (privateKey_ != privateKey) {
        privateKey_ = privateKey;
        QSslKey sslkey(readKey(privateKey), QSsl::Rsa);
        qsslConfiguration_.setPrivateKey(sslkey);
        emit privateKeyChanged(privateKey_);
    }
}
