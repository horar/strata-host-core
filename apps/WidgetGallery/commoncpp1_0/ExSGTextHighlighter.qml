import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP

ColumnLayout {

    ColumnLayout {
        id: contentColumn
        spacing: 10
        enabled: editEnabledCheckBox.checked
        Layout.fillWidth: true 

        SGWidgets.SGTextEdit {
                id: noteText
                Layout.maximumWidth: flickWrapper.width - 10
                wrapMode: Text.Wrap
                textFormat: TextEdit.PlainText
                enabled: false
                text: "This example demonstrates how to highlight text by entering string into input field. When string is entered and if match is found, parts of THIS text will be highlighted. Syntax pattern used to highlight can be choosen from following options RegExp, Wildcard, FixedString and highlight can be case sensitive or insensitive."
                
        }

        SGWidgets.SGTextField {
            id: inputText

            CommonCPP.SGTextHighlighter {
                textDocument: noteText.textDocument
                filterPattern: inputText.text 
                filterPatternSyntax: {
                    if (regExpRadioBtn.checked) {
                        return CommonCPP.SGTextHighlighter.RegExp
                    } else if (wildCardRadioBtn.checked) {
                        return CommonCPP.SGTextHighlighter.Wildcard
                    } else {
                        return CommonCPP.SGTextHighlighter.FixedString
                    }
                }
                caseSensitive: caseSensitiveCheckBox.checked ? true : false
            }
        }

        SGWidgets.SGText {
            text: "Text highlighting options:"
            fontSizeMultiplier: 1.3
        }

        Row { 
            spacing: 20
            SGWidgets.SGRadioButton {
                id: regExpRadioBtn
                text: "RegExp"
                checked: true
            }

            SGWidgets.SGRadioButton {
                id: wildCardRadioBtn
                text: "WildCard"
            }

            SGWidgets.SGRadioButton {
                id: fixedStringRadioBtn
                text: "FixedString"
            }
        }

        SGWidgets.SGCheckBox {
            id: caseSensitiveCheckBox
            text: "Case Sensitive"
            checked: false
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox

        text: "Everything enabled"
        checked: true
    }
}
