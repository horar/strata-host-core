/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SGVersionUtils.h"
#include "logging/LoggingQtCategories.h"

#include <QStringList>
#include <QList>
#include <QDebug>
#include <QRegularExpression>
#include <QVersionNumber>

SGVersionUtils::SGVersionUtils(QObject *parent) : QObject(parent)
{
}
SGVersionUtils::~SGVersionUtils()
{
}

bool SGVersionUtils::greaterThan(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) == 1;
}

bool SGVersionUtils::lessThan(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) == -1;
}

bool SGVersionUtils::equalTo(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) == 0;
}

int SGVersionUtils::compare(const QString &version1, const QString &version2, bool *error) {
    QString cleanedV1 = cleanVersion(version1);
    QString cleanedV2 = cleanVersion(version2);

    QVersionNumber v1 = QVersionNumber::fromString(cleanedV1);
    QVersionNumber v2 = QVersionNumber::fromString(cleanedV2);

    if (v1.isNull() || v2.isNull()) {
        if (error != nullptr) {
            *error = true;
        }
        return -2;
    }

    int result = QVersionNumber::compare(v1, v2);

    if (result < 0) {
        return -1;
    } else if (result > 0) {
        return 1;
    } else {
        return 0;
    }
}

int SGVersionUtils::getGreatestVersion(const QStringList &versions, bool *error) {
    if (versions.count() == 0) {
        if (error != nullptr) {
            *error = true;
        }
        return -1;
    }

    int greatestVersion = 0;
    bool err = false;

    for (int i = 1; i < versions.count(); i++) {
        if (greaterThan(versions[i], versions[greatestVersion], &err)) {
            greatestVersion = i;
        }
        if (err) {
            if (error != nullptr) {
                *error = err;
            }
            return -1;
        }
    }
    return greatestVersion;
}

bool SGVersionUtils::valid(const QString &version) {
    QString cleanedVersion = cleanVersion(version);
    if (cleanedVersion.isEmpty()) {
        return false;
    }

    return true;
}

QString SGVersionUtils::cleanVersion(QString version) {
    int vIndex = version.indexOf('v');

    if (vIndex == 0) {
        version.remove(0, 1);
    }

    QStringList vSeparated = version.split(".");
    QVector<int> vSeparatedInts;

    for (int i = 0; i < 3; i++) {
        if (i < vSeparated.count()) {
            bool ok = true;
            uint vInt = vSeparated[i].toUInt(&ok);
            if (!ok)
                return QString();

            vSeparatedInts.append(vInt);
        } else {
            vSeparatedInts.append(0);
        }
    }

    QVersionNumber v(vSeparatedInts);

    if (!v.isNull()) {
        return v.toString();
    }

    return QString();
}

QObject* SGVersionUtils::SingletonTypeProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    SGVersionUtils *utils = new SGVersionUtils();
    return utils;
}

