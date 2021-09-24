/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <SpdLogger.h>

#include <QCoreApplication>
#include <QFileSystemWatcher>

namespace strata::loggers
{
/**
 * @brief The QtLoggerSetup class
 *
 * Load logger configuration from application configuration file.
 * Optionally, insert default settings into configuration file on application start
 * if these don't exists.
 */
class QtLoggerSetup final : public QObject
{
    Q_OBJECT

public:
    /**
     * @brief QtLoggerSetup
     * @param[in] app QApplication object to get application name and standard application paths
     *
     * Note: it is possible to read this string via static Qt call but this information
     * is valid only after QApplication object was instantiated.
     */
    explicit QtLoggerSetup(const QCoreApplication& app);
    ~QtLoggerSetup();

    QtMessageHandler getQtLogCallback() const;

private:
    void reload();

    /**
     * @brief Write default logging setup values into application config file
     *
     * Write only missing values.
     */
    void generateDefaultSettings() const;
    /**
     * @brief Setup and initiate spdlog logging framework
     * @param[in] app
     */
    void setupSpdLog(const QCoreApplication& app);
    /**
     * @brief Setup Qt logging framework from values defined in application setup
     */
    void setupQtLog();

    SpdLogger logger_;
    QFileSystemWatcher watchdog_;
    QString logLevel_;
};

}  // namespace strata::loggers
