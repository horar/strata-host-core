/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP

ColumnLayout {

    ColumnLayout {
        id: contentColumn
        spacing: 10
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
                focusPolicy: Qt.NoFocus
            }

            SGWidgets.SGRadioButton {
                id: wildCardRadioBtn
                text: "WildCard"
                focusPolicy: Qt.NoFocus
            }

            SGWidgets.SGRadioButton {
                id: fixedStringRadioBtn
                text: "FixedString"
                focusPolicy: Qt.NoFocus
            }
        }

        SGWidgets.SGCheckBox {
            id: caseSensitiveCheckBox
            text: "Case Sensitive"
            checked: false
            focusPolicy: Qt.NoFocus
        }
    }
}
