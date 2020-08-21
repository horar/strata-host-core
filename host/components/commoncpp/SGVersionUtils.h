#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QRegularExpression>

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
     * @return Returns -1, 0, or 1 depending on if version1 is less than, equal to, or greater than version2, respectively
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

    Q_INVOKABLE static QString cleanVersion(const QString &version);


private:
    static inline const QRegularExpression validVersionRegexp = QRegularExpression("^[vV]?(\\d+$)|^[vV]?((\\d+\\.)+\\d+)\\D*[^\\.]*$");

    template <typename T>
    static int getLongestVersion(const QList<T> &v1, const QList<T> &v2);
    static QList<uint> convertStringToIntList(const QString &version, bool *error);
};
