pragma Singleton

import QtQuick 2.0

Item {
    id: fonts

    readonly property FontLoader sgiconsFont: FontLoader {
        source: "./sgicons.ttf"
    }

    readonly property FontLoader inconsolataFont: FontLoader {
        source: "./Inconsolata.otf"
    }

    readonly property string sgicons: fonts.sgiconsFont.name
    readonly property string inconsolata: fonts.inconsolataFont.name
}
