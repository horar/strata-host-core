/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
