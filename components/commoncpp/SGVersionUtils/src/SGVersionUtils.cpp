/*
 * Copyright (c) 2018-2022 onsemi.
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
#include <QRegExp>
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
    QString cleanedV1 = cleanVersion(version1, true);
    QString cleanedV2 = cleanVersion(version2, true);

    int suffixIndexV1 = -1;
    int suffixIndexV2 = -1;
    QVersionNumber v1 = QVersionNumber::fromString(cleanedV1, &suffixIndexV1);
    QVersionNumber v2 = QVersionNumber::fromString(cleanedV2, &suffixIndexV2);

    if (v1.isNull() || v2.isNull()) {
        if (error != nullptr) {
            *error = true;
        }
        return -2;
    }
    // normalization must be done after isNull() check, because 0.0.0 ends as null
    v1 = v1.normalized();
    v2 = v2.normalized();

    int result = QVersionNumber::compare(v1, v2);

    if (result < 0) {
        return -1;
    } else if (result > 0) {
        return 1;
    } else {
        QString suffixV1 = cleanedV1.mid(suffixIndexV1);
        QString suffixV2 = cleanedV2.mid(suffixIndexV2);
        return compareSuffix(suffixV1, suffixV2);
    }
}

int SGVersionUtils::compareSuffix(const QString &suffix1, const QString &suffix2) {
    QString cleanedV1 = cleanSuffix(suffix1);
    QString cleanedV2 = cleanSuffix(suffix2);

    if (cleanedV1 == cleanedV2) {
        return 0;
    }

    // Note: https://en.wikipedia.org/wiki/Software_release_life_cycle
    // alpha < beta < rc < rtm < ga < production release
    auto decodeSuffix = [](const QString &suffix, int &version, bool &alpha, bool &beta, bool &rc, bool &rtm, bool &ga, bool &production)
    {
        alpha = beta = rc = rtm = ga = production = false;
        version = 0;
        if (suffix.isEmpty()) {
            production = true;
        } else if (suffix.startsWith("ga")) {
            ga = true;
        } else if (suffix.startsWith("rtm")) {
            rtm = true;
        } else {
            QString versionString = suffix;
            if (suffix.startsWith("rc")) {
                rc = true;
                versionString.remove(0, 2);
            } else if (suffix.startsWith("beta")) {
                beta = true;
                versionString.remove(0, 4);
            } else if (suffix.startsWith("alpha")) {
                alpha = true;
                versionString.remove(0, 5);
            }
            if (versionString.isEmpty() == false) {
                version = versionString.toInt();    // will be 0 if it fails
            }
        }
    };

    int versionV1, versionV2;
    bool alphaV1, betaV1, rcV1, rtmV1, gaV1, productionV1;
    bool alphaV2, betaV2, rcV2, rtmV2, gaV2, productionV2;
    decodeSuffix(cleanedV1, versionV1, alphaV1, betaV1, rcV1, rtmV1, gaV1, productionV1);
    decodeSuffix(cleanedV2, versionV2, alphaV2, betaV2, rcV2, rtmV2, gaV2, productionV2);

    if (productionV1) {
        return 1;   // V1 is official release
    } else if (productionV2) {
        return -1;  // V2 is official release
    } else if (gaV1) {
        return 1;   // V1 is GA release
    } else if (gaV2) {
        return -1;  // V2 is GA release
    } else if (rtmV1) {
        return 1;   // V1 is RTM release
    } else if (rtmV2) {
        return -1;  // V2 is RTM release
    } else {
        if (rcV1 && rcV2 == false) {
            return 1;   // V1 is RC release
        } else if (rcV2 && rcV1 == false) {
            return -1;  // V2 is RC release
        } else if (betaV1 && betaV2 == false) {
            return 1;   // V1 is BETA release
        } else if (betaV2 && betaV1 == false) {
            return -1;  // V2 is BETA release
        } else if (alphaV1 && alphaV2 == false) {
            return 1;   // V1 is ALPHA release
        } else if (alphaV2 && alphaV1 == false) {
            return -1;  // V2 is ALPHA release
        } else {
            // we compare the numbers after the strings
            if (versionV1 < versionV2) {
                return -1;
            } else if (versionV1 > versionV2) {
                return 1;
            } else {
                return 0;
            }
        }
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

QString SGVersionUtils::cleanVersion(QString version, bool retainSuffix) {
    if (version.startsWith("v")) {
        version.remove(0, 1);
    }
    if (QRegExp("^([0-9]+\\.)*[0-9]+(\\-.+)?$").exactMatch(version)) {
        int suffixIndex = -1;
        QVersionNumber v = QVersionNumber::fromString(version, &suffixIndex);
        if (v.isNull() == false) {
            return v.toString() + (retainSuffix ? version.mid(suffixIndex) : QString());
        }
    }

    return QString();
}

QString SGVersionUtils::cleanSuffix(QString suffix) {
    if (suffix.startsWith("-")) {
        suffix.remove(0, 1);
    }
    suffix = suffix.toLower();
    QRegExp rx("^((?:(?:alpha|beta|rc)[0-9]*)|(?:rtm|ga))(?:\\-.+)?$");
    if (rx.exactMatch(suffix)) {
        QStringList suffixList = rx.capturedTexts();
        if (suffixList.size() == 2) {
            // there should be exactly 2 capture group
            // first is whole text that matched, second is the desired substring in parenthesis
            return suffixList.last();
        }
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
