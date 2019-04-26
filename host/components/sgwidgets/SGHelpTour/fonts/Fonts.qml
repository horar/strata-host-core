pragma Singleton

import QtQuick 2.0

Item {
    id: fonts

    readonly property FontLoader inconsolataFont: FontLoader {
        source: "./Inconsolata.otf"
    }

    readonly property FontLoader franklinGothicBoldFont: FontLoader {
        source: "./FranklinGothicBold.ttf"
    }

    readonly property FontLoader franklinGothicBookFont: FontLoader {
        source: "./FranklinGothicBook.otf"
    }

    readonly property FontLoader franklinGothicMediumFont: FontLoader {
        source: "./FranklinGothicMedium.otf"
    }

    readonly property string franklinGothicBold: fonts.franklinGothicBoldFont.name
    readonly property string franklinGothicBook: fonts.franklinGothicBookFont.name
    readonly property string franklinGothicMedium: fonts.franklinGothicMediumFont.name
    readonly property string inconsolata: fonts.inconsolataFont.name
}
