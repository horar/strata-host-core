/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.logger 1.0

import "console-messages"

Item {
    id: root
    width: parent.width
    height: parent.height

    property double fontMultiplier: 1.0
    property string searchText: ""
    property bool searchUseCase: false

    function validateSearchText() {
        consoleItems.invalidate()
        consoleLogs.deselectAll()
    }

    onFontMultiplierChanged: {
        if (fontMultiplier >= 2.5) {
            fontMultiplier = 2.5
        } else if (fontMultiplier <= 0.8) {
            fontMultiplier = 0.8
        }
    }

    onSearchTextChanged: {
        validateSearchText()
    }

    onSearchUseCaseChanged: {
        validateSearchText()
    }

    onVisibleChanged: {
        if (!visible) {
            consoleLogErrorCount = 0
            consoleLogWarningCount = 0
        }
    }

    ConsoleLogList {
        id: consoleLogs
    }

    SGSortFilterProxyModel {
        id: consoleItems
        sourceModel: consoleModel
        sortEnabled: true
        invokeCustomFilter: true

        function filterAcceptsRow(row) {
            var item = sourceModel.get(row)
            var notFilter = true
            var containFilterText = true

            if  (filterTypeWarning || filterTypeError) {
                if (filterTypeError && filterTypeWarning) {
                    notFilter = (item.type === "warning") || (item.type === "error")
                } else if (filterTypeWarning) {
                    notFilter = (item.type === "warning")
                } else {
                    notFilter = (item.type === "error")
                }
            }

            if (searchText !== "") {
                containFilterText = containsFilterText(item)
            }

            if (!filterTypeWarning && !filterTypeError && searchText === "") {
                return true
            } else {
                return containFilterText && notFilter
            }
        }

        function containsFilterText(item) {
            var searchMsg = item.time  + ` [ ${item.type} ] ` + item.msg

            if (searchUseCase) {
                if (searchMsg.includes(searchText)) {
                    return true
                } else {
                    return false
                }
            }
            if (searchMsg.toLowerCase().includes(searchText.toLowerCase())) {
                return true
            } else {
                return false
            }
        }
    }

    ListModel {
        id: consoleModel
    }

    Connections {
        id: srcConnection
        target: sdsModel.qtLogger

        onLogMsg: {
            if (controlViewCreatorRoot.visible && editor.fileTreeModel.url.toString() !== "" && msg) {
                consoleModel.append({
                                        time: timestamp(),
                                        type: getMsgType(type),
                                        msg: msg,
                                        current: true,
                                        state: "noneSelected",
                                        selection: "",
                                        selectionStart: 0,
                                        selectionEnd: 0
                                    })

                consoleLogs.logAdded()

                if (type === 1) {
                    consoleLogWarningCount += 1
                } else if (type === 2) {
                    consoleLogErrorCount += 1
                }
            }
        }
    }

    Connections {
        target: sdsModel.resourceLoader

        onFinishedRecompiling: {
            if (consoleModel.count > 0 && recompileRequested) {
                for (var i = 0; i < consoleModel.count; i++) {
                    consoleModel.get(i).current = false
                }
                consoleLogErrorCount = 0
                consoleLogWarningCount = 0
            }
        }
    }

    function getMsgType(type) {
        switch (type) {
            case 0:
                return "debug"
            case 1:
                return "warning"
            case 2:
                return "error"
            case 4:
                return "info"
            default:
                console.error(Logger.devStudioCategory, "Received invalid log message type.")
        }
    }

    function timestamp() {
        var date = new Date(Date.now())
        let hours = date.getHours()
        let minutes = date.getMinutes()
        let seconds = date.getSeconds()
        let millisecs = date.getMilliseconds()

        if (hours < 10) {
            hours = `0${hours}`
        }

        if (minutes < 10) {
            minutes = `0${minutes}`
        }

        if (seconds < 10) {
            seconds = `0${seconds}`
        }

        if (millisecs < 100) {
            if (millisecs < 10) {
                millisecs =`00${millisecs}`
            } else {
                millisecs = `0${millisecs}`
            }
        }

        return `${hours}:${minutes}:${seconds}.${millisecs}`
    }

    function clearLogs() {
        consoleModel.clear();
        consoleLogErrorCount = 0
        consoleLogWarningCount = 0
    }
}
