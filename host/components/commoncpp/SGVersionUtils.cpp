#include "SGVersionUtils.h"
#include "logging/LoggingQtCategories.h"

#include <QStringList>
#include <QList>
#include <QDebug>
#include <QRegularExpression>

SGVersionUtils::SGVersionUtils(QObject *parent) : QObject(parent)
{
}
SGVersionUtils::~SGVersionUtils()
{
}

bool SGVersionUtils::greaterThan(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) > 0;
}

bool SGVersionUtils::lessThan(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) < 0;
}

bool SGVersionUtils::equalTo(const QString &version1, const QString &version2, bool *error) {
    return compare(version1, version2, error) == 0;
}

int SGVersionUtils::compare(const QString &version1, const QString &version2, bool *error) {
    // Keeping a local err helps allow usage of this class in both JS and C++, as on the JS side, they can't pass pointers to C++
    bool err = false;

    QList<uint> v1List = convertStringToIntList(version1, &err);
    QList<uint> v2List = convertStringToIntList(version2, &err);

    if (error != nullptr) {
        *error = err;
    }

    if (err) {
        return -2;
    }

    int longestVersionListCount = getLongestVersion(v1List, v2List);

    while (v1List.count() < longestVersionListCount) {
        v1List.append(0);
    }
    while (v2List.count() < longestVersionListCount) {
        v2List.append(0);
    }

    for (int i = 0; i < longestVersionListCount; i++) {
        if (v1List[i] < v2List[i]) {
            return -1;
        } else if (v1List[i] > v2List[i]) {
            return 1;
        }
    }
    return 0;
}

int SGVersionUtils::getGreatestVersion(const QStringList &versions, bool *error) {
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
    QRegularExpressionMatch match = validVersionRegexp.match(version);

    if (match.hasMatch()) {
        return true;
    }

    return false;
}

QString SGVersionUtils::cleanVersion(const QString &version) {
    QRegularExpressionMatch match = validVersionRegexp.match(version);

    /***
     * The captured groups here are populated as follows if there is a match:
     * Group 0: The entire string matched
     * Group 1: If the string was just a number (no "."), then it will return just the number. Ex) "1" returns "1"
     * Group 2: The part of the string containing no non-numeric characters. Ex) "1.2.3.5-124-fefe" returns "1.2.3.5"
     * Group 3: Irrelevant
     ***/
        if (match.hasMatch()) {
        // Here we check if the version was just an integer. Ex) "1"
        if (!match.captured(1).isEmpty()) {
            return match.captured(1);
        } else {
            return match.captured(2);
        }
    }

    return QString();
}

template<typename T>
int SGVersionUtils::getLongestVersion(const QList<T> &v1, const QList<T> &v2) {
    return v1.count() >= v2.count() ? v1.count() : v2.count();
}

QList<uint> SGVersionUtils::convertStringToIntList(const QString &version, bool *error) {
    QString cleanedVersion = cleanVersion(version);

    if (cleanedVersion.isNull() || cleanedVersion.isEmpty()) {
        if (error != nullptr) {
            *error = true;
        }
        return QList<uint>();
    }

    QList<uint> versionSeparated;

    for (QString version : cleanedVersion.split(".")) {
        bool valid;
        uint part = version.toUInt(&valid);
        if (!valid) {
            if (error != nullptr) {
                *error = true;
            }
            return QList<uint>();
        }
        versionSeparated.append(part);
    }
    return versionSeparated;
}

