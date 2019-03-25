# Strata logging

## Description
Basic expectations from logging setup in Strata:

- allow define what kind of data are saved in addition to message (i.e. timestamp, PID, TID, component etc.)
- introduce log files rotation, based on file size and number of files
- allow change the scope of logging based on so named 'categories'
- change the logging level and scope of logging in runtime (not implemented yet)

Logger configuration information is stored in application ini configuration file.
If some configuration key is not present in this file (or on first start)
then default value is stored into this file.

At this time the user may change them and have to re/start application to use them.

## Libraries

1. SpdLogger
This setup library is based on 'spdlog' i.e. very fast small header-only library. Present approach utilize
one common logger with 2 sinks. One sing for developer's terminal and one sink for rotated log file.
2. QtLogger
Qt framework already contains logging framework.
QtLogger is a small helper library aimed to load and setup Qt logging framework and SpdLogger library
int our way.
Developer only add following line after app instiation:
```cpp

    QApplication app(argc, argv);
    const QtLoggerSetup loggerInitialization(app);

```
link the QtLogger library and standard Qt logging functions can be used.
Logging categories in Qt and QML are defined as described in Qt documentation.

## Configuration
Configuration file is stored:

- macOS: /Users/<USER>/.config/On Semiconductor/Strata Development Studio.ini
- Windows: TBD

### Log message formatting
#### spdlog
This library add prepend to message text following information:

- timestamp
- process id
- thread id
- log level

More details about customization and other available place holders:
    https://github.com/gabime/spdlog/wiki/3.-Custom-formatting

#### Qt
This library create a message with following content:

- logging category (i.e. component/subcomponent name)
- class/function name
- message

More details about customization and other available place holders:
    https://doc.qt.io/qt-5/qtglobal.html#qSetMessagePattern

### Logging categories
This is Qt feature that allow to install filtering rules that are applied on logged messages.
Only messages which pass these filters will be logged.
It allow to control which component log messages will be accepted. Moreover the log level may be controlled for particular components as well (pls. note this may be in conflict with spdlog logging level).

Ref:
    https://doc.qt.io/qt-5/qloggingcategory.html#details


### Configuration
The configuration file is stored in application data:

- macOS:
- Windows: TBD

### Example
Defaults are e.g.
```
[log]
level=info
level-comment="log level is one of: debug, info, warn, err, critical, off"
maxFileSize=5242880
maxNoFiles=5
qtFilterRules="strata.*=true"
qtMessagePattern=%{if-category}\x1b[32m%{category}: %{endif}%{if-debug}\x1b[0m(%{function})%{endif}%{if-info}\x1b[34m(%{function})%{endif}%{if-warning}\x1b[33m(
spdlogMessagePattern=%Y-%m-%d %T.%e PID:%P TID:%t [%L] %v
```

The Qt filter rule sub-strings are always separated by 2 characters '\n'.
Other sample sub-strings that may be used:

- disable all QML uncategorized messages: "qml=false"
- disable debug strata developer studio messages: "strata.devstudio.debug=false"
- enable all messages (incl. Qt internals): "*=true"
- disable all platform interaface messages: "strata.platformInterface.*=false"

## Log file
Logging files incl. rotated files will be stored:

- macOS: /Users/<USER>/Library/Application Support/On Semiconductor/Strata Development Studio/Strata\ Development\ Studio.log
- Windows: TBD
  
