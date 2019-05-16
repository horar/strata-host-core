pragma Singleton

import QtQuick 2.12

QtObject {
    id: root

    readonly property string franklinGothicBold: fontLoaders.franklinGothicBoldFont.name
    readonly property string franklinGothicBook: fontLoaders.franklinGothicBookFont.name
    readonly property string franklinGothicMedium: fontLoaders.franklinGothicMediumFont.name
    readonly property string inconsolata: fontLoaders.inconsolataFont.name

    readonly property string franklinGothicFontName: "franklinGothic"
    readonly property string inconsolataFontName: "Inconsolata"

    property QtObject fontLoaders : QtObject {
        id: fontLoaders

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
    }
}
