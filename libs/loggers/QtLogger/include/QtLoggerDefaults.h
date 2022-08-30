/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

namespace strata::loggers::defaults
{
constexpr unsigned LOGFILE_MAX_SIZE{1024 * 1024 * 5};
constexpr unsigned LOGFILE_MAX_COUNT{5};

constexpr char LOGLEVEL[] = "info";

constexpr char SPDLOG_MESSAGE_PATTERN_4CONSOLE[] = "%T.%e %^[%=7l]%$ %v";
constexpr char SPDLOG_MESSAGE_PATTERN_4FILE[] = "%Y-%m-%dT%T.%e%z\tPID:%P\tTID:%t\t[%L]\t%v";

constexpr char QT_FILTER_RULES[] = "strata.*=true";
constexpr char QT_MESSAGE_PATTERN[] =
    "%{if-category}%{category}: %{endif}"
    /*"%{file}:%{line}"*/
    "%{if-debug}%{function}%{endif}"
    "%{if-info}%{function}%{endif}"
    "%{if-warning}%{function}%{endif}"
    "%{if-critical}%{function}%{endif}"
    "%{if-fatal}%{function}%{endif}"
    " - %{message}";

}  // namespace strata::loggers::defaults
