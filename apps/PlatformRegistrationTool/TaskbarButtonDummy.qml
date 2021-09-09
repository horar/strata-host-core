import QtQml 2.12
import QtQuick 2.12

/* This is dummy taskbar button to mimic behaviour from QtWinExtras,
 * which is only available for windows platform
 */
Item {
    property alias progress: progressObject

    QtObject {
        id: progressObject

        function stop() {}
        function show() {}
        function hide() {}
        function reset() {}
        function resume() {}
        function pause() {}
    }
}
