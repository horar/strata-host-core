/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGConversion.h"
#include "logging/LoggingQtCategories.h"

#include <QDataStream>


SGConversion::SGConversion(QObject *parent)
    : QObject(parent)
{
}

SGConversion::~SGConversion()
{
}

QObject *SGConversion::singletonTypeProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    SGConversion *object = new SGConversion();
    return object;
}

qint8 SGConversion::hexStringLeToInt8(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    qint8 number;
    stream >> number;

    return number;
}

qint16 SGConversion::hexStringLeToInt16(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    qint16 number;
    stream >> number;

    return number;
}

qint32 SGConversion::hexStringLeToInt32(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    qint32 number;
    stream >> number;

    return number;
}

quint8 SGConversion::hexStringLeToUint8(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    quint8 number;
    stream >> number;

    return number;
}

quint16 SGConversion::hexStringLeToUint16(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    quint16 number;
    stream >> number;

    return number;
}

quint32 SGConversion::hexStringLeToUint32(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setByteOrder(QDataStream::LittleEndian);

    quint32 number;
    stream >> number;

    return number;
}

float SGConversion::hexStringLeToFloat32(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setFloatingPointPrecision(QDataStream::SinglePrecision);
    stream.setByteOrder(QDataStream::LittleEndian);

    float number;
    stream >> number;

    return number;
}

double SGConversion::hexStringLeToFloat64(const QByteArray &hexString)
{
    QDataStream stream(QByteArray::fromHex(hexString));
    stream.setFloatingPointPrecision(QDataStream::DoublePrecision);
    stream.setByteOrder(QDataStream::LittleEndian);

    double number;
    stream >> number;

    return number;
}

QByteArray SGConversion::int8ToHexStringLe(qint8 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(qint8)).toHex();
}

QByteArray SGConversion::int16ToHexStringLe(qint16 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(qint16)).toHex();
}

QByteArray SGConversion::int32ToHexStringLe(qint32 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(qint32)).toHex();
}

QByteArray SGConversion::uint8ToHexStringLe(quint8 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(quint8)).toHex();
}

QByteArray SGConversion::uint16ToHexStringLe(quint16 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(quint16)).toHex();
}

QByteArray SGConversion::uint32ToHexStringLe(quint32 number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(quint32)).toHex();
}

QByteArray SGConversion::float32ToHexStringLe(float number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(float)).toHex();
}

QByteArray SGConversion::float64ToHexStringLe(double number)
{
    return QByteArray::fromRawData(
                reinterpret_cast<char*>(&number),
                sizeof(double)).toHex();
}
