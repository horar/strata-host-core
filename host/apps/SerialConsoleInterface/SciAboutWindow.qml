import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGAboutWindow {
    appLogoSource: "qrc:/images/sci-logo.svg"
    additionalAttributionText: {
        return "The conversion from Markdown to HTML is done with the help of the marked JavaScript library created by Christopher Jeffrey.<br>"+
                "<a href=\"https://github.com/markedjs/marked\">https://github.com/markedjs/marked</a><br>"+
                "The style sheet was created by Brett Terpstra.<br>"+
                "<a href=\"https://github.com/ttscoff/MarkedCustomStyles\">https://github.com/ttscoff/MarkedCustomStyles</a><br>"
    }
}
