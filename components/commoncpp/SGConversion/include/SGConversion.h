/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>

class SGConversion : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGConversion)

public:
    explicit SGConversion(QObject *parent = nullptr);
    virtual ~SGConversion();

    static QObject* singletonTypeProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE static qint8 hexStringLeToInt8(const QByteArray &hexString);
    Q_INVOKABLE static qint16 hexStringLeToInt16(const QByteArray &hexString);
    Q_INVOKABLE static qint32 hexStringLeToInt32(const QByteArray &hexString);
    Q_INVOKABLE static quint8 hexStringLeToUint8(const QByteArray &hexString);
    Q_INVOKABLE static quint16 hexStringLeToUint16(const QByteArray &hexString);
    Q_INVOKABLE static quint32 hexStringLeToUint32(const QByteArray &hexString);
    Q_INVOKABLE static float hexStringLeToFloat32(const QByteArray &hexString);
    Q_INVOKABLE static double hexStringLeToFloat64(const QByteArray &hexString);

    Q_INVOKABLE static QByteArray int8ToHexStringLe(qint8 number);
    Q_INVOKABLE static QByteArray int16ToHexStringLe(qint16 number);
    Q_INVOKABLE static QByteArray int32ToHexStringLe(qint32 number);
    Q_INVOKABLE static QByteArray uint8ToHexStringLe(quint8 number);
    Q_INVOKABLE static QByteArray uint16ToHexStringLe(quint16 number);
    Q_INVOKABLE static QByteArray uint32ToHexStringLe(quint32 number);
    Q_INVOKABLE static QByteArray float32ToHexStringLe(float number);
    Q_INVOKABLE static QByteArray float64ToHexStringLe(double number);
};
