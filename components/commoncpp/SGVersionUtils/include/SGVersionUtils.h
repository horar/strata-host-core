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
#include <QString>
#include <QStringList>
#include <QQmlEngine>
#include <QJSEngine>

class SGVersionUtils : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SGVersionUtils)
public:
    explicit SGVersionUtils(QObject *parent = nullptr);
    virtual ~SGVersionUtils();

    /**
     * @brief greaterThan Checks if version1 is greater than version2
     * @param version1 LHS of greater than argument. Ex) version1 > version2
     * @param version2 RHS of greater than argument. Ex) version1 > version2
     * @return Returns true if version1 > version2. Otherwise returns false
     */
    Q_INVOKABLE static bool greaterThan(const QString &version1, const QString &version2, bool *error = nullptr);

    /**
     * @brief lessThan Checks if version1 is less than version2
     * @param version1 LHS of less than argument. Ex) version1 < version2
     * @param version2 RHS of less than argument. Ex) version1 < version2
     * @return Returns true if version1 < version2. Otherwise returns false
     */
    Q_INVOKABLE static bool lessThan(const QString &version1, const QString &version2, bool *error = nullptr);

    /**
     * @brief equalTo Checks if version1 is equal to version2
     * @param version1 LHS of equal to argument. Ex) version1 == version2
     * @param version2 RHS of equal to argument. Ex) version1 == version2
     * @return Returns true if version1 == version2. Otherwise returns false
     */
    Q_INVOKABLE static bool equalTo(const QString &version1, const QString &version2, bool *error = nullptr);

    /**
     * @brief compare
     * @param version1 The LHS of the compare. Ex) version1 < version2
     * @param version2 The RHS of the compare. Ex) version1 < version2
     * @return Returns -1, 0, or 1 depending on if version1 is less than, equal to, or greater than version2, respectively. Returns -2 either version is invalid
     */
    Q_INVOKABLE static int compare(const QString &version1, const QString &version2, bool *error = nullptr);

    /**
     * @brief getGreatestVersion Returns the index of the latest version in a list of versions
     * @param versions A QStringList of versions
     * @return Returns the index of the latest version
     */
    Q_INVOKABLE static int getGreatestVersion(const QStringList &versions, bool *error = nullptr);

    /**
     * @brief valid Checks if a version is valid. Valid is seen as all characters separated by '.' are positive integers.
     * @param version The version to check
     * @return Returns true if each part of the version is a positive integer
     */
    Q_INVOKABLE static bool valid(const QString &version);

    /**
     * @brief cleanVersion Returns a cleaned version of the version given
     * @param version The version to clean
     * @return Returns the cleaned version
     */
    Q_INVOKABLE static QString cleanVersion(QString version);

    static QObject* SingletonTypeProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
};
