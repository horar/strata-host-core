/* 
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties

    If we need to add more QtQuick Objects the format will be
    "<QtType>": {
        "properties":{
            "property":{
                "meta_properties":[]
            },
        },
        "functions": {
            "function": {
                "param_names": []
            }
        },
        "signals": {
            "signal": {
                 "param_names:": []
            }
        },
        "inherits": "",
        "source" : "",
        "nonInstantiable": false,
        "isVisualWidget": false,
    },
*/

const qtTypeJson = {
    "sources": {
        "AbstractButton": {
            "properties": {
                "action": {
                    "meta_properties": []
                },
                "autoExclusive": {
                    "meta_properties": []
                },
                "autoRepeat": {
                    "meta_properties": []
                },
                "autoRepeatDelay": {
                    "meta_properties": []
                },
                "autoRepeatInterval": {
                    "meta_properties": []
                },
                "checkable": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "display": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
                "icon": {
                    "meta_properties": [
                        "name: ",
                        "source: ",
                        "width: ",
                        "height: ",
                        "color: ",
                    ]
                },
                "implicitIndicatorHeight": {
                    "meta_properties": []
                },
                "implicitIndicatorWidth": {
                    "meta_properties": []
                },
                "indicator": {
                    "meta_properties": []
                },
                "pressX": {
                    "meta_properties": []
                },
                "pressY": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                }
            },
            "functions": {
                "toggle": {
                    "params_name": []
                },
            },
            "signals": {
                "canceled": {
                    "params_name": []
                },
                "clicked": {
                    "params_name": []
                },
                "doubleClicked": {
                    "params_name": []
                },
                "pressAndHold": {
                    "params_name": []
                },
                "pressed": {
                    "params_name": []
                },
                "released": {
                    "params_name": []
                },
                "toggled": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "",
            "nonInstantiable": true,
            "isVisualWidget": false,
        },
        "Action": {
            "properties": {
                "checkable": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "enabled": {
                    "meta_properties": []
                },
                "icon": {
                    "meta_properties": [
                        "name: ",
                        "source: ",
                        "width: ",
                        "height: ",
                        "color: ",
                    ]
                },
                "shortcut": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                }

            },
            "functions": {
                "toggle": {
                    "params_name": ["source"]
                },
                "trigger": {
                    "params_name": ["source"]
                },
            },
            "signals": {
                "toggled": {
                    "params_name": ["source"]
                },
                "triggered": {
                    "params_name": ["source"]
                },
            },
            "inherits": "",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ApplicationWindow": {
            "properties": {
                "activeFocusControl": {
                    "meta_properties": []
                },
                "background": {
                    "meta_properties": []
                },
                "contentData": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": []
                },
                "footer": {
                    "meta_properties": []
                },
                "header": {
                    "meta_properties": []
                },
                "locale": {
                    "meta_properties": []
                },
                "menuBar": {
                    "meta_properties": []
                },
                "palette": {
                    "meta_properties": []
                },
                "window": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Window",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Behavior": {
            "properties": {
                "animation": {
                    "meta_properties": []
                },
                "enabled": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Binding": {
            "properties": {
                "delayed": {
                    "meta_properties": []
                },
                "property": {
                    "meta_properties": []
                },
                "target": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                },
                "when": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "QtQml",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "BusyIndicator": {
            "properties": {
                "running": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Button": {
            "properties": {
                "flat": {
                    "meta_properties": []
                },
                "highlighted": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Canvas": {
            "properties": {
                "available": {
                    "meta_properties": []
                },
                "canvasSize": {
                    "meta_properties": []
                },
                "context": {
                    "meta_properties": []
                },
                "contextType": {
                    "meta_properties": []
                },
                "renderStrategy": {
                    "meta_properties": []
                },
                "renderTarget": {
                    "meta_properties": []
                }
            },
            "functions": {
                "cancelRequestAnimationFrame": {
                    "params_name": ["handle"]
                },
                "getContext": {
                    "params_name": ["contextId", "...args"]
                },
                "isImageError": {
                    "params_name": ["image"]
                },
                "isImageLoaded": {
                    "params_name": ["image"]
                },
                "isImageLoading": {
                    "params_name": ["image"]
                },
                "loadImage": {
                    "params_name": ["image"]
                },
                "markDirty": {
                    "params_name": ["area"]
                },
                "requestAnimationFrame": {
                    "params_name": ["callback"]
                },
                "requestPaint": {
                    "params_name": []
                },
                "save": {
                    "params_name": ["filename"]
                },
                "toDataURL": {
                    "params_name": ["mimeType"]
                },
                "unloadImage": {
                    "params_name": ["image"]
                },
            },
            "signals": {
                "imageLoaded": {
                    "params_name": []
                },
                "paint": {
                    "params_name": ["region"]
                },
                "painted": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "CheckBox": {
            "properties": {
                "checkState": {
                    "meta_properties": []
                },
                "nextCheckState": {
                    "meta_properties": []
                },
                "tristate": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "CircularGauge": {
            "properties": {
                "maximumValue": {
                    "meta_properties": []
                },
                "minimumValue": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "tickmarksVisible": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "Extra",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Column": {
            "properties": {
                "add": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "move": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "populate": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                }
            },
            "functions": {
                "forceLayout": {
                    "params_name": []
                },
            },
            "signals": {
                "positioningComplete": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ColumnLayout": {
            "properties": {
                "layoutDirection": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Layouts",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ComboBox": {
            "properties": {
                "acceptableInput": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                },
                "currentText": {
                    "meta_properties": []
                },
                "delegate": {
                    "meta_properties": []
                },
                "displayText": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
                "editText": {
                    "meta_properties": []
                },
                "editable": {
                    "meta_properties": []
                },
                "flat": {
                    "meta_properties": []
                },
                "highlightedIndex": {
                    "meta_properties": []
                },
                "inputMethodComposing": {
                    "meta_properties": []
                },
                "inputMethodHints": {
                    "meta_properties": []
                },
                "model": {
                    "meta_properties": []
                },
                "popup": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "textRole": {
                    "meta_properties": []
                },
                "validator": {
                    "meta_properties": []
                }
            },
            "functions": {
                "decrementCurrentIndex": {
                    "params_name": []
                },
                "find": {
                    "params_name": ["text", "flags"]
                },
                "incrementCurrentIndex": {
                    "params_name": []
                },
                "selectAll": {
                    "params_name": []
                },
                "textAt": {
                    "params_name": ["index"]
                },
            },
            "signals": {
                "accepted": {
                    "params_name": []
                },
                "activated": {
                    "params_name": ["index"]
                },
                "highlighted": {
                    "params_name": ["index"]
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Component": {
            "properties": {
                "delegate": {
                    "meta_properties": []
                },
                "progress": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
                "url": {
                    "meta_properties": []
                },
                "id": {
                    "meta_properties": []
                }
            },
            "functions": {
                "createObject": {
                    "params_name": ["parent", "properties"]
                },
                "errorString": {
                    "params_name": []
                },
                "incubateObject": {
                    "params_name": ["parent", "properties", "mode"]
                },
            },
            "signals": {
                "completed": {
                    "params_name": []
                },
                "destruction": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Connections": {
            "properties": {
                "enabled": {
                    "meta_properties": []
                },
                "ignoreUnknownSignals": {
                    "meta_properties": []
                },
                "target": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "QtQml",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Control": {
            "properties": {
                "availableHeight": {
                    "meta_properties": []
                },
                "availableWidth": {
                    "meta_properties": []
                },
                "background": {
                    "meta_properties": []
                },
                "bottomInset": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "focusPolicy": {
                    "meta_properties": []
                },
                "focusReason": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": []
                },
                "horizontalPadding": {
                    "meta_properties": []
                },
                "hoverEnabled": {
                    "meta_properties": []
                },
                "hovered": {
                    "meta_properties": []
                },
                "implicitBackgroundHeight": {
                    "meta_properties": []
                },
                "implicitBackgroundWidth": {
                    "meta_properties": []
                },
                "implicitContentHeight": {
                    "meta_properties": []
                },
                "implicitContentWidth": {
                    "meta_properties": []
                },
                "leftInset": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "locale": {
                    "meta_properties": []
                },
                "mirrored": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "palette": {
                    "meta_properties": []
                },
                "rightInset": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topInset": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "verticalPadding": {
                    "meta_properties": []
                },
                "visualFocus": {
                    "meta_properties": []
                },
                "wheelEnabled": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Dialog": {
            "properties": {
                "footer": {
                    "meta_properties": []
                },
                "header": {
                    "meta_properties": []
                },
                "implicitFooterHeight": {
                    "meta_properties": []
                },
                "implicitFooterWidth": {
                    "meta_properties": []
                },
                "implicitHeaderHeight": {
                    "meta_properties": []
                },
                "implicitHeaderWidth": {
                    "meta_properties": []
                },
                "result": {
                    "meta_properties": []
                },
                "standardButtons": {
                    "meta_properties": []
                },
                "title": {
                    "meta_properties": []
                },
            },
            "functions": {
                "accept": {
                    "params_name": []
                },
                "done": {
                    "params_name": ["result"]
                },
                "reject": {
                    "params_name": []
                },
                "standardButton": {
                    "params_name": ["button"]
                },
            },
            "signals": {
                "accepted": {
                    "params_name": []
                },
                "applied": {
                    "params_name": []
                },
                "discarded": {
                    "params_name": []
                },
                "helpRequested": {
                    "params_name": []
                },
                "rejected": {
                    "params_name": []
                },
                "reset": {
                    "params_name": []
                },
            },
            "inherits": "Popup",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "FileDialog": {
            "properties": {
                "defaultSuffix": {
                    "meta_properties": []
                },
                "fileUrl": {
                    "meta_properties": []
                },
                "fileUrls": {
                    "meta_properties": []
                },
                "modality": {
                    "meta_properties": []
                },
                "nameFilters": {
                    "meta_properties": []
                },
                "selectExisting": {
                    "meta_properties": []
                },
                "selectFolder": {
                    "meta_properties": []
                },
                "selectMultiple": {
                    "meta_properties": []
                },
                "selectedNameFilter": {
                    "meta_properties": []
                },
                "shortcuts": {
                    "meta_properties": []
                },
                "sidebarVisible": {
                    "meta_properties": []
                },
                "title": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                },
            },
            "functions": {
                "close": {
                    "params_name": []
                },
                "open": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "Dialogs",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Flickable": {
            "properties": {
                "atXBeginning": {
                    "meta_properties": []
                },
                "atXEnd": {
                    "meta_properties": []
                },
                "atYBeginning": {
                    "meta_properties": []
                },
                "atYEnd": {
                    "meta_properties": []
                },
                "bottomMargin": {
                    "meta_properties": []
                },
                "boundsBehavior": {
                    "meta_properties": []
                },
                "boundsMovement": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "contentX": {
                    "meta_properties": []
                },
                "contentY": {
                    "meta_properties": []
                },
                "dragging": {
                    "meta_properties": []
                },
                "draggingHorizontally": {
                    "meta_properties": []
                },
                "draggingVertically": {
                    "meta_properties": []
                },
                "flickDeceleration": {
                    "meta_properties": []
                },
                "flickableDirection": {
                    "meta_properties": []
                },
                "flicking": {
                    "meta_properties": []
                },
                "flickingHorizontally": {
                    "meta_properties": []
                },
                "flickingVertically": {
                    "meta_properties": []
                },
                "horizontalOvershoot": {
                    "meta_properties": []
                },
                "horizontalVelocity": {
                    "meta_properties": []
                },
                "interactive": {
                    "meta_properties": []
                },
                "leftMargin": {
                    "meta_properties": []
                },
                "maximumFlickVelocity": {
                    "meta_properties": []
                },
                "moving": {
                    "meta_properties": []
                },
                "movingHorizontally": {
                    "meta_properties": []
                },
                "movingVertically": {
                    "meta_properties": []
                },
                "originX": {
                    "meta_properties": []
                },
                "originY": {
                    "meta_properties": []
                },
                "pixelAligned": {
                    "meta_properties": []
                },
                "pressDelay": {
                    "meta_properties": []
                },
                "rebound": {
                    "meta_properties": []
                },
                "rightMargin": {
                    "meta_properties": []
                },
                "synchronousDrag": {
                    "meta_properties": []
                },
                "topMargin": {
                    "meta_properties": []
                },
                "verticalOvershoot": {
                    "meta_properties": []
                },
                "verticalVelocity": {
                    "meta_properties": []
                },
                "visibleArea": {
                    "meta_properties": [
                        "xPosition: ",
                        "widthRatio: ",
                        "yPosition: ",
                        "heightRatio: ",
                    ]
                }
            },
            "functions": {
                "cancelFlick": {
                    "params_name": []
                },
                "flick": {
                    "params_name": ["xVelocity", "yVelocity"]
                },
                "resizeContent": {
                    "params_name": ["width", "height", "center"]
                },
                "returnToBounds": {
                    "params_name": []
                },
            },
            "signals": {
                "flickEnded": {
                    "params_name": []
                },
                "flickStarted": {
                    "params_name": []
                },
                "movementEnded": {
                    "params_name": []
                },
                "movementStarted": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Flow": {
            "properties": {
                "add": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "effectiveLayoutDirection": {
                    "meta_properties": []
                },
                "flow": {
                    "meta_properties": []
                },
                "layoutDirection": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "move": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "populate": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                }
            },
            "functions": {
                "forceLayout": {
                    "params_name": []
                },
            },
            "signals": {
                "positioningComplete": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Grid": {
            "properties": {
                "add": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "columnSpacing": {
                    "meta_properties": []
                },
                "columns": {
                    "meta_properties": []
                },
                "effectiveHorizontalItemAlignment": {
                    "meta_properties": []
                },
                "effectiveLayoutDirection": {
                    "meta_properties": []
                },
                "flow": {
                    "meta_properties": []
                },
                "horizontalItemAlignment": {
                    "meta_properties": []
                },
                "layoutDirection": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "move": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "populate": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "rowSpacing": {
                    "meta_properties": []
                },
                "rows": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "verticalItemAlignment": {
                    "meta_properties": []
                }
            },
            "functions": {
                "forceLayout": {
                    "params_name": []
                },
            },
            "signals": {
                "positioningComplete": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "GridLayout": {
            "properties": {
                "columnSpacing": {
                    "meta_properties": []
                },
                "columns": {
                    "meta_properties": []
                },
                "flow": {
                    "meta_properties": []
                },
                "layoutDirection": {
                    "meta_properties": []
                },
                "rowSpacing": {
                    "meta_properties": []
                },
                "rows": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Layouts",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Image": {
            "properties": {
                "asynchronous": {
                    "meta_properties": []
                },
                "autoTransform": {
                    "meta_properties": []
                },
                "cache": {
                    "meta_properties": []
                },
                "fillMode": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "mipMap": {
                    "meta_properties": []
                },
                "mirror": {
                    "meta_properties": []
                },
                "paintedheight": {
                    "meta_properties": []
                },
                "paintedWidth": {
                    "meta_properties": []
                },
                "progress": {
                    "meta_properties": []
                },
                "smooth": {
                    "meta_properties": []
                },
                "source": {
                    "meta_properties": []
                },
                "sourceSize": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Item": {
            "properties": {
                "activeFocus": {
                    "meta_properties": []
                },
                "activeFocusOnTab": {
                    "meta_properties": []
                },
                "anchors": {
                    "meta_properties": [
                        "alignWhenCentered: ",
                        "baseline: ",
                        "baselineOffset: ",
                        "bottom: ",
                        "bottomMargin: ",
                        "centerIn: ",
                        "fill: ",
                        "horizontalCenter: ",
                        "horizontalCenterOffset: ",
                        "left: ",
                        "leftMargin: ",
                        "margins: ",
                        "right: ",
                        "rightMargin: ",
                        "top: ",
                        "topMargin: ",
                        "verticalCenter: ",
                        "verticalCenterOffset: ",
                    ]

                },
                "antialiasing": {
                    "meta_properties": []
                },
                "baselineOffset": {
                    "meta_properties": []
                },
                "children": {
                    "meta_properties": []
                },
                "childrenRect": {
                    "meta_properties": [
                        "x:",
                        "y:",
                        "width:",
                        "height"
                    ]
                },
                "clip": {
                    "meta_properties": []
                },
                "containmentMask": {
                    "meta_properties": []
                },
                "data": {
                    "meta_properties": []
                },
                "enabled": {
                    "meta_properties": []
                },
                "focus": {
                    "meta_properties": []
                },
                "height": {
                    "meta_properties": []
                },
                "id": {
                    "meta_properties": []
                },
                "implicitHeight": {
                    "meta_properties": []
                },
                "implicitWidth": {
                    "meta_properties": []
                },
                "layer": {
                    "meta_properties": [
                        "effect: ",
                        "enabled: ",
                        "format: ",
                        "mipmap: ",
                        "sampleName: ",
                        "samples: ",
                        "smooth: ",
                        "sourceRect: ",
                        "textureMirroring: ",
                        "textureSize: ",
                        "wrapMode: ",
                    ]
                },
                "opacity": {
                    "meta_properties": []
                },
                "parent": {
                    "meta_properties": []
                },
                "resources": {
                    "meta_properties": []
                },
                "rotation": {
                    "meta_properties": []
                },
                "scale": {
                    "meta_properties": []
                },
                "smooth": {
                    "meta_properties": []
                },
                "state": {
                    "meta_properties": []
                },
                "states": {
                    "meta_properties": []
                },
                "transform": {
                    "meta_properties": []
                },
                "transformOrigin": {
                    "meta_properties": []
                },
                "transitions": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                },
                "visibleChildren": {
                    "meta_properties": []
                },
                "width": {
                    "meta_properties": []
                },
                "x": {
                    "meta_properties": []
                },
                "y": {
                    "meta_properties": []
                },
                "z": {
                    "meta_properties": []
                },
                "objectName": {
                    "meta_properties": []
                },
            },
            "functions": {
                "childAt": {
                    "params_name": ["x", "y"]
                },
                "contains": {
                    "params_name": ["point"]
                },
                "forceActiveFocus": {
                    "params_name": ["reason"]
                },
                "grabToImage": {
                    "params_name": ["callback", "targetSize"]
                },
                "mapFromGlobal": {
                    "params_name": ["x", "y"]
                },
                "mapFromItem": {
                    "params_name": ["item", "x", "y", "width", "height"]
                },
                "mapToGlobal": {
                    "params_name": ["x", "y"]
                },
                "mapToItem": {
                    "params_name": ["item", "x", "y", "width", "height"]
                },
                "nextItemInFocusChain": {
                    "params_name": ["forward"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Keys": {
            "properties": {
                "enabled": {
                    "meta_properties": []
                },
                "forwardTo": {
                    "meta_properties": []
                },
                "priority": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "asteriskPressed": {
                    "params_name": ["event"]
                },
                "backPressed": {
                    "params_name": ["event"]
                },
                "backtabPressed": {
                    "params_name": ["event"]
                },
                "callPressed": {
                    "params_name": ["event"]
                },
                "cancelPressed": {
                    "params_name": ["event"]
                },
                "context1Pressed": {
                    "params_name": ["event"]
                },
                "context2Pressed": {
                    "params_name": ["event"]
                },
                "context3Pressed": {
                    "params_name": ["event"]
                },
                "context4Pressed": {
                    "params_name": ["event"]
                },
                "deletePressed": {
                    "params_name": ["event"]
                },
                "digit0Pressed": {
                    "params_name": ["event"]
                },
                "digit1Pressed": {
                    "params_name": ["event"]
                },
                "digit2Pressed": {
                    "params_name": ["event"]
                },
                "digit3Pressed": {
                    "params_name": ["event"]
                },
                "digit4Pressed": {
                    "params_name": ["event"]
                },
                "digit5Pressed": {
                    "params_name": ["event"]
                },
                "digit6Pressed": {
                    "params_name": ["event"]
                },
                "digit7Pressed": {
                    "params_name": ["event"]
                },
                "digit8Pressed": {
                    "params_name": ["event"]
                },
                "digit9Pressed": {
                    "params_name": ["event"]
                },
                "downPressed": {
                    "params_name": ["event"]
                },
                "enterPressed": {
                    "params_name": ["event"]
                },
                "escapePressed": {
                    "params_name": ["event"]
                },
                "flipPressed": {
                    "params_name": ["event"]
                },
                "hangupPressed": {
                    "params_name": ["event"]
                },
                "leftPressed": {
                    "params_name": ["event"]
                },
                "menuPressed": {
                    "params_name": ["event"]
                },
                "noPressed": {
                    "params_name": ["event"]
                },
                "pressed": {
                    "params_name": ["event"]
                },
                "released": {
                    "params_name": ["event"]
                },
                "returnPressed": {
                    "params_name": ["event"]
                },
                "rightPressed": {
                    "params_name": ["event"]
                },
                "selectPressed": {
                    "params_name": ["event"]
                },
                "shortcutOverride": {
                    "params_name": ["event"]
                },
                "spacePressed": {
                    "params_name": ["event"]
                },
                "tabPressed": {
                    "params_name": ["event"]
                },
                "upPressed": {
                    "params_name": ["event"]
                },
                "volumeDownPressed": {
                    "params_name": ["event"]
                },
                "volumeUpPressed": {
                    "params_name": ["event"]
                },
                "yesPressed": {
                    "params_name": ["event"]
                },

            },
            "inherits": "",
            "source": "",
            "nonInstantiable": true,
            "isVisualWidget": false,
        },
        "Label": {
            "properties": {
                "background": {
                    "meta_properties": []
                },
                "bottomInset": {
                    "meta_properties": []
                },
                "implicitBackgroundHeight": {
                    "meta_properties": []
                },
                "implicitBackgroundWidth": {
                    "meta_properties": []
                },
                "leftInset": {
                    "meta_properties": []
                },
                "palette": {
                    "meta_properties": []
                },
                "rightInset": {
                    "meta_properties": []
                },
                "topInset": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Text",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Layout": {
            "properties": {
                "alignment": {
                    "meta_properties": []
                },
                "bottomMargin": {
                    "meta_properties": []
                },
                "column": {
                    "meta_properties": []
                },
                "columnSpan": {
                    "meta_properties": []
                },
                "fillHeight": {
                    "meta_properties": []
                },
                "fillWidth": {
                    "meta_properties": []
                },
                "leftMargin": {
                    "meta_properties": []
                },
                "margins": {
                    "meta_properties": []
                },
                "maximumHeight": {
                    "meta_properties": []
                },
                "maximumWidth": {
                    "meta_properties": []
                },
                "minimumHeight": {
                    "meta_properties": []
                },
                "minimumWidth": {
                    "meta_properties": []
                },
                "preferredHeight": {
                    "meta_properties": []
                },
                "preferredWidth": {
                    "meta_properties": []
                },
                "rightMargin": {
                    "meta_properties": []
                },
                "row": {
                    "meta_properties": []
                },
                "rowSpan": {
                    "meta_properties": []
                },
                "topMargin": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "Layouts",
            "nonInstantiable": true,
            "isVisualWidget": false,
        },
        "LayoutButton": {
            "properties": {
                "text": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "checkable": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "hovered": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "clicked": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutContainer": {
            "properties": {
                "layoutInfo": {
                    "meta_properties": [
                        "columnsWide: ",
                        "rowsTall: ",
                        "xColumns: ",
                        "yRows: ",
                        "uuid: ",
                    ]
                },
                "contentItem": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "Item",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutDivider": {
            "properties": {
                "orientation": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "thickness": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutInfo": {
            "properties": {
                "columnsWide": {
                    "meta_properties": []
                },
                "rowsTall": {
                    "meta_properties": []
                },
                "xColumns": {
                    "meta_properties": []
                },
                "yRows": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "QtObject",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": true,
            "isVisualWidget": true,
        },
        "LayoutRadioButtons": {
            "properties": {
                "model": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "radioColor": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "pixelSize": {
                    "meta_properties": []
                },
                "radioSize": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "clicked": {
                    "param_names:": ["index"]
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutRectangle": {
            "properties": {
                "color": {
                    "meta_properties": []
                },
                "border": {
                    "meta_properties": [
                        "width: ",
                        "color: ",
                    ]
                },
                "gradient": {
                    "meta_properties": []
                },
                "radius": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGButtonStrip": {
            "properties": {
                "model": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "exclusive": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "checkedIndices": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "clicked": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGCircularGauge": {
            "properties": {
                "value": {
                    "meta_properties": []
                },
                "gaugeFillColor1": {
                    "meta_properties": []
                },
                "gaugeFillColor2": {
                    "meta_properties": []
                },
                "gaugeBackgroundColor": {
                    "meta_properties": []
                },
                "centerTextColor": {
                    "meta_properties": []
                },
                "outerTextColor": {
                    "meta_properties": []
                },
                "unitTextFontSizeMultiplier": {
                    "meta_properties": []
                },
                "outerTextFontSizeMultiplier": {
                    "meta_properties": []
                },
                "valueDecimalPlaces": {
                    "meta_properties": []
                },
                "tickmarkDecimalPlaces": {
                    "meta_properties": []
                },
                "minimumValue": {
                    "meta_properties": []
                },
                "maximumValue": {
                    "meta_properties": []
                },
                "tickmarkStepSize": {
                    "meta_properties": []
                },
                "unitText": {
                    "meta_properties": []
                }
            },
            "functions": {
                "lerpColor": {
                    "param_names": ["color1", "color2", "x"]
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGComboBox": {
            "properties": {
                "textColor": {
                    "meta_properties": []
                },
                "indicatorColor": {
                    "meta_properties": []
                },
                "borderColor": {
                    "meta_properties": []
                },
                "borderColorFocused": {
                    "meta_properties": []
                },
                "boxColor": {
                    "meta_properties": []
                },
                "dividers": {
                    "meta_properties": []
                },
                "model": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                },
                "currentText": {
                    "meta_properties": []
                },
                "iconImage": {
                    "meta_properties": []
                },
                "textField": {
                    "meta_properties": []
                },
                "textFieldBackground": {
                    "meta_properties": []
                },
                "backgroundItem": {
                    "meta_properties": []
                },
                "popupItem": {
                    "meta_properties": []
                },
                "popupBackground": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "activated": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGGraph": {
            "properties": {
                "panXEnabled": {
                    "meta_properties": []
                },
                "panYEnabled": {
                    "meta_properties": []
                },
                "zoomXEnabled": {
                    "meta_properties": []
                },
                "zoomYEnabled": {
                    "meta_properties": []
                },
                "mouseArea": {
                    "meta_properties": []
                },
                "xMin": {
                    "meta_properties": []
                },
                "xMax": {
                    "meta_properties": []
                },
                "yMin": {
                    "meta_properties": []
                },
                "yMax": {
                    "meta_properties": []
                },
                "xTitle": {
                    "meta_properties": []
                },
                "yTitle": {
                    "meta_properties": []
                },
                "title": {
                    "meta_properties": []
                },
                "xGrid": {
                    "meta_properties": []
                },
                "yGrid": {
                    "meta_properties": []
                },
                "gridColor": {
                    "meta_properties": []
                }
            },
            "functions": {
                "createCurve": {
                    "param_names": ["name"]
                },
                "curve": {
                    "param_names": ["index"]
                },
                "shiftXAxis": {
                    "param_names": ["offset"]
                },
                "shiftYAxis": {
                    "param_names": ["offset"]
                },
                "removeCurve": {
                    "param_names": ["index"]
                },
                "update": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGIcon": {
            "properties": {
                "iconColor": {
                    "meta_properties": []
                },
                "source": {
                    "meta_properties": []
                },
                "mouseInteraction": {
                    "meta_properties": []
                },
                "containsMouse": {
                    "meta_properties": []
                },
                "cursorShape": {
                    "meta_properties": []
                },
                "hoverEnabled": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "clicked": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGInfoBox": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "placeholderText": {
                    "meta_properties": []
                },
                "readOnly": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "textPadding": {
                    "meta_properties": []
                },
                "invalidTextColor": {
                    "meta_properties": []
                },
                "boxColor": {
                    "meta_properties": []
                },
                "boxBorderColor": {
                    "meta_properties": []
                },
                "boxBorderWidth": {
                    "meta_properties": []
                },
                "unit": {
                    "meta_properties": []
                },
                "validator": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "contextMenuEnabled": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "accepted": {
                    "param_names:": []
                },
                "editingFinished": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGSlider": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "mirror": {
                    "meta_properties": []
                },
                "handleSize": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                },
                "from": {
                    "meta_properties": []
                },
                "to": {
                    "meta_properties": []
                },
                "horizontal": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
                "showTickmarks": {
                    "meta_properties": []
                },
                "showLabels": {
                    "meta_properties": []
                },
                "showInputBox": {
                    "meta_properties": []
                },
                "showToolTip": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "live": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "snapMode": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "grooveColor": {
                    "meta_properties": []
                },
                "fillColor": {
                    "meta_properties": []
                },
                "slider": {
                    "meta_properties": []
                },
                "inputBox": {
                    "meta_properties": []
                },
                "fromText": {
                    "meta_properties": []
                },
                "toText": {
                    "meta_properties": []
                },
                "tickmarkRepeater": {
                    "meta_properties": []
                },
                "inputBoxWidth": {
                    "meta_properties": []
                },
                "toolTip": {
                    "meta_properties": []
                },
                "toolTipText": {
                    "meta_properties": []
                },
                "toolTipBackground": {
                    "meta_properties": []
                },
                "validatorObject": {
                    "meta_properties": []
                },
                "handleObject": {
                    "meta_properties": []
                },
                "contextMenuEnabled": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "moved": {
                    "param_names:": []
                },
                "userSet": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGStatusLight": {
            "properties": {
                "status": {
                    "meta_properties": []
                },
                "customColor": {
                    "meta_properties": []
                },
                "flatStyle": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGStatusLogBox": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "handleColor": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "labelsInside": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "checkedLabel": {
                    "meta_properties": []
                },
                "uncheckedLabel": {
                    "meta_properties": []
                },
                "grooveFillColor": {
                    "meta_properties": []
                },
                "grooveColor": {
                    "meta_properties": []
                },
            },
            "functions": {
                "append": {
                    "param_names": ["message"]
                },
                "remove": {
                    "param_names": ["id"]
                },
                "updateMessageAtID": {
                    "param_names": ["message", "id"]
                },
                "clear": {
                    "param_names": []
                },
                "onFilter": {
                    "param_names": ["listElement"]  
                },
                "copySelectionTest": {
                    "param_names": ["index"] 
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutSGSwitch": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "handleColor": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "labelsInside": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "checkedLabel": {
                    "meta_properties": []
                },
                "uncheckedLabel": {
                    "meta_properties": []
                },
                "grooveFillColor": {
                    "meta_properties": []
                },
                "grooveColor": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "released": {
                    "param_names:": []
                },
                "canceled": {
                    "param_names:": []
                },
                "clicked": {
                    "param_names:": []
                },
                "toggled": {
                    "param_names:": []
                },
                "press": {
                    "param_names:": []
                },
                "pressAndHold": {
                    "param_names:": []
                },
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "LayoutText": {
            "properties": {
                "text": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": [
                        "bold: ",
                        "capitalization: ",
                        "family: ",
                        "hintingPreference: ",
                        "italic: ",
                        "kerning: ",
                        "letterSpacing: ",
                        "pixelSize: ",
                        "pointSize: ",
                        "preferShaping: ",
                        "strikeout: ",
                        "styleName: ",
                        "underline: ",
                        "weight: ",
                        "wordSpacing: ",
                    ]
                },
                "elide": {
                    "meta_properties": []
                },
                "fontSizeMode": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                },
                "maximumLineCount": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "LayoutContainer",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "ListElement": {
            "properties": {
                "property": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ListModel": {
            "properties": {
                "count": {
                    "meta_properties": []
                },
                "dynamicRoles": {
                    "meta_properties": []
                }
            },
            "functions": {
                "append": {
                    "params_name": ["dict"]
                },
                "clear": {
                    "params_name": []
                },
                "get": {
                    "params_name": ["index"]
                },
                "insert": {
                    "params_name": ["index", "dict"]
                },
                "move": {
                    "params_name": ["from", "to", "n"]
                },
                "remove": {
                    "params_name": ["index", "count"]
                },
                "set": {
                    "params_name": ["index", "dict"]
                },
                "setProperty": {
                    "params_name": ["index", "property", "value"]
                },
                "sync": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ListView": {
            "properties": {
                "add": {
                    "meta_properties": []
                },
                "addDisplaced": {
                    "meta_properties": []
                },
                "cachedBuffer": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                },
                "currentItem": {
                    "meta_properties": []
                },
                "currentSection": {
                    "meta_properties": []
                },
                "delegate": {
                    "meta_properties": []
                },
                "displaced": {
                    "meta_properties": []
                },
                "displayMarginBeginning": {
                    "meta_properties": []
                },
                "displayMarginEnd": {
                    "meta_properties": []
                },
                "effectiveLayoutDirection": {
                    "meta_properties": []
                },
                "footer": {
                    "meta_properties": []
                },
                "footerItem": {
                    "meta_properties": []
                },
                "footerPositioning": {
                    "meta_properties": []
                },
                "header": {
                    "meta_properties": []
                },
                "headerItem": {
                    "meta_properties": []
                },
                "headerPositioning": {
                    "meta_properties": []
                },
                "highlight": {
                    "meta_properties": []
                },
                "highlightFollowsCurrentItem": {
                    "meta_properties": []
                },
                "highlightItem": {
                    "meta_properties": []
                },
                "highlightMoveDuration": {
                    "meta_properties": []
                },
                "highlightMoveVelocity": {
                    "meta_properties": []
                },
                "highlightRangeMode": {
                    "meta_properties": []
                },
                "highlightResizeDuration": {
                    "meta_properties": []
                },
                "highlightResizeVelocity": {
                    "meta_properties": []
                },
                "keyNavigationEnabled": {
                    "meta_properties": []
                },
                "keyNavigationWraps": {
                    "meta_properties": []
                },
                "layoutDirection": {
                    "meta_properties": []
                },
                "model": {
                    "meta_properties": []
                },
                "move": {
                    "meta_properties": []
                },
                "moveDisplaced": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "populate": {
                    "meta_properties": []
                },
                "preferredHighlightBegin": {
                    "meta_properties": []
                },
                "preferredHighlightEnd": {
                    "meta_properties": []
                },
                "remove": {
                    "meta_properties": []
                },
                "removeDisplaced": {
                    "meta_properties": []
                },
                "section": {
                    "meta_properties": [
                        "property: ",
                        "criteria: ",
                        "delegate: ",
                        "labelPositioning: ",
                    ]
                },
                "snapMode": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "verticalLayoutDirection": {
                    "meta_properties": []
                },
                "delayRemove": {
                    "meta_properties": []
                },
                "isCurrentItem": {
                    "meta_properties": []
                },
                "nextSection": {
                    "meta_properties": []
                },
                "previousSection": {
                    "meta_properties": []
                },
                "section": {
                    "meta_properties": []
                },
                "view": {
                    "meta_properties": []
                }
            },
            "functions": {
                "decrementCurrentIndex": {
                    "params_name": []
                },
                "forceLayout": {
                    "params_name": []
                },
                "incrementCurrentIndex": {
                    "params_name": []
                },
                "indexAt": {
                    "params_name": ["x", "y"]
                },
                "itemAt": {
                    "params_name": ["x", "y"]
                },
                "positionViewAtBeginning": {
                    "params_name": []
                },
                "positionViewAtEnd": {
                    "params_name": []
                },
                "positionViewAtIndex": {
                    "params_name": ["index", "mode"]
                },
            },
            "signals": {
                "add": {
                    "params_name": []
                },
                "remove": {
                    "params_name": []
                },
            },
            "inherits": "Flickable",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Loader": {
            "properties": {
                "active": {
                    "meta_properties": []
                },
                "asynchronous": {
                    "meta_properties": []
                },
                "item": {
                    "meta_properties": []
                },
                "progress": {
                    "meta_properties": []
                },
                "source": {
                    "meta_properties": []
                },
                "sourceComponent": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
            },
            "functions": {
                "setSource": {
                    "params_name": ["source", "properties"]
                },
            },
            "signals": {
                "loaded": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Menu": {
            "properties": {
                "cascade": {
                    "meta_properties": []
                },
                "contentData": {
                    "meta_properties": []
                },
                "contentModel": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                },
                "delegate": {
                    "meta_properties": []
                },
                "focus": {
                    "meta_properties": []
                },
                "overlap": {
                    "meta_properties": []
                },
                "title": {
                    "meta_properties": []
                }
            },
            "functions": {
                "actionAt": {
                    "params_name": ["index"]
                },
                "addAction": {
                    "params_name": ["action"]
                },
                "addItem": {
                    "params_name": ["item"]
                },
                "addMenu": {
                    "params_name": ["menu"]
                },
                "dismiss": {
                    "params_name": []
                },
                "insertAction": {
                    "params_name": ["index", "action"]
                },
                "insertItem": {
                    "params_name": ["index", "item"]
                },
                "insertMenu": {
                    "params_name": ["index", "menu"]
                },
                "itemAt": {
                    "params_name": ["index"]
                },
                "menuAt": {
                    "params_name": ["index"]
                },
                "moveItem": {
                    "params_name": ["from", "to"]
                },
                "popup": {
                    "params_name": ["x", "y", "pos", "parent", "item"]
                },
                "removeAction": {
                    "params_name": ["action"]
                },
                "removeItem": {
                    "params_name": ["item"]
                },
                "removeMenu": {
                    "params_name": ["menu"]
                },
                "takeAction": {
                    "params_name": ["index"]
                },
                "takeItem": {
                    "params_name": ["index"]
                },
                "takeMenu": {
                    "params_name": ["index"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Popup",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "MenuItem": {
            "properties": {
                "arrow": {
                    "meta_properties": []
                },
                "highlighted": {
                    "meta_properties": []
                },
                "menu": {
                    "meta_properties": []
                },
                "subMenu": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "triggered": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "MenuSeparator": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "MouseArea": {
            "properties": {
                "acceptedButtons": {
                    "meta_properties": []
                },
                "containsMouse": {
                    "meta_properties": []
                },
                "containsPress": {
                    "meta_properties": []
                },
                "cursorShape": {
                    "meta_properties": []
                },
                "drag": {
                    "meta_properties": [
                        "target: ",
                        "active: ",
                        "axis: ",
                        "minimumX: ",
                        "maximumX: ",
                        "minimumX: ",
                        "minimumY: ",
                        "filterChildren: ",
                        "threshold: ",
                    ]
                },
                "enabled": {
                    "meta_properties": []
                },
                "hoverEnabled": {
                    "meta_properties": []
                },
                "mouseX": {
                    "meta_properties": []
                },
                "mouseY": {
                    "meta_properties": []
                },
                "pressAndHoldInterval": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "pressedButtons": {
                    "meta_properties": []
                },
                "preventStealing": {
                    "meta_properties": []
                },
                "propagateComposedEvents": {
                    "meta_properties": []
                },
                "scrollGestureEnabled": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "canceled": {
                    "params_name": []
                },
                "clicked": {
                    "params_name": ["mouse"]
                },
                "doubleClicked": {
                    "params_name": ["mouse"]
                },
                "entered": {
                    "params_name": []
                },
                "exited": {
                    "params_name": []
                },
                "positionChanged": {
                    "params_name": ["mouse"]
                },
                "pressAndHold": {
                    "params_name": ["mouse"]
                },
                "pressed": {
                    "params_name": ["mouse"]
                },
                "released": {
                    "params_name": ["mouse"]
                },
                "wheel": {
                    "params_name": ["wheel"]
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Overlay": {
            "properties": {
                "modal": {
                    "meta_properties": []
                },
                "modeless": {
                    "meta_properties": []
                },
                "overlay": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "pressed": {
                    "params_name": []
                },
                "released": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Popup": {
            "properties": {
                "activeFocus": {
                    "meta_properties": []
                },
                "anchors": {
                    "meta_properties": [
                        "centerIn: "
                    ]
                },
                "availableHeight": {
                    "meta_properties": []
                },
                "availableWidth": {
                    "meta_properties": []
                },
                "background": {
                    "meta_properties": []
                },
                "bottomInset": {
                    "meta_properties": []
                },
                "bottomMargin": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "clip": {
                    "meta_properties": []
                },
                "closePolicy": {
                    "meta_properties": []
                },
                "contentChildren": {
                    "meta_properties": []
                },
                "contentData": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "dim": {
                    "meta_properties": []
                },
                "enabled": {
                    "meta_properties": []
                },
                "enter": {
                    "meta_properties": []
                },
                "exit": {
                    "meta_properties": []
                },
                "focus": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": []
                },
                "height": {
                    "meta_properties": []
                },
                "horizontalPadding": {
                    "meta_properties": []
                },
                "implicitBackgroundHeight": {
                    "meta_properties": []
                },
                "implicitBackgroundWidth": {
                    "meta_properties": []
                },
                "implicitContentHeight": {
                    "meta_properties": []
                },
                "implicitContentWidth": {
                    "meta_properties": []
                },
                "implicitHeight": {
                    "meta_properties": []
                },
                "implicitWidth": {
                    "meta_properties": []
                },
                "leftInset": {
                    "meta_properties": []
                },
                "leftMargin": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "locale": {
                    "meta_properties": []
                },
                "margins": {
                    "meta_properties": []
                },
                "mirrored": {
                    "meta_properties": []
                },
                "modal": {
                    "meta_properties": []
                },
                "opacity": {
                    "meta_properties": []
                },
                "opened": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "parent": {
                    "meta_properties": []
                },
                "rightInset": {
                    "meta_properties": []
                },
                "rightMargin": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "scale": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topInset": {
                    "meta_properties": []
                },
                "topMargin": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "transformOrigin": {
                    "meta_properties": []
                },
                "verticalPadding": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                },
                "width": {
                    "meta_properties": []
                },
                "x": {
                    "meta_properties": []
                },
                "y": {
                    "meta_properties": []
                },
                "z": {
                    "meta_properties": []
                }
            },
            "functions": {
                "close": {
                    "params_name": []
                },
                "forceActiveFocus": {
                    "params_name": ["reason"]
                },
                "open": {
                    "params_name": []
                },
            },
            "signals": {
                "aboutToHide": {
                    "params_name": []
                },
                "aboutToShow": {
                    "params_name": []
                },
                "closed": {
                    "params_name": []
                },
                "opened": {
                    "params_name": []
                },
            },
            "inherits": "QtObject",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Qt": {
            "properties": {
                "application": {
                    "meta_properties": []
                },
                "inputMethod": {
                    "meta_properties": []
                },
                "platform": {
                    "meta_properties": []
                },
                "styleHints": {
                    "meta_properties": []
                }
            },
            "functions": {
                "atob": {
                    "params_name": ["data"]
                },
                "binding": {
                    "params_name": ["function"]
                },
                "btoa": {
                    "params_name": ["data"]
                },
                "callLater": {
                    "params_name": ["function", `$1`, `$2`, `$n`]
                },
                "colorEqual": {
                    "params_name": ["lhs", "rhs"]
                },
                "createComponent": {
                    "params_name": ["url", "mode", "parent"]
                },
                "createQmlObject": {
                    "params_name": ["qml", "parent", "filepath"]
                },
                "darker": {
                    "params_name": ["baseColor", "factor"]
                },
                "exit": {
                    "params_name": ["retCode"]
                },
                "font": {
                    "params_name": ["fontSpecifier"]
                },
                "fontFamilies": {
                    "params_name": []
                },
                "formatDate": {
                    "params_name": ["date", "format"]
                },
                "formatDateTime": {
                    "params_name": ["dateTime", "format"]
                },
                "formatTime": {
                    "params_name": ["time", "format"]
                },
                "hsla": {
                    "params_name": ["hue", "saturation", "lightness", "alpha"]
                },
                "hsva": {
                    "params_name": ["hue", "saturation", "value", "alpha"]
                },
                "include": {
                    "params_name": ["url", "callback"]
                },
                "isQtObject": {
                    "params_name": ["object"]
                },
                "lighter": {
                    "params_name": ["baseColor", "factor"]
                },
                "locale": {
                    "params_name": ["name"]
                },
                "md5": {
                    "params_name": ["data"]
                },
                "matrix4x4": {
                    "params_name": ["m11", "m12", "m13", "m14", "m21", "m22", "m23", "m24", "m31", "m32", "m33", "m34", "m41", "m42", "m43", "m44"]
                },
                "openUrlExteranlly": {
                    "params_name": ["target"]
                },
                "point": {
                    "params_name": ["x", "y"]
                },
                "qsTr": {
                    "params_name": ["sourceText", "disambiguation", "n"]
                },
                "qsTrId": {
                    "params_name": ["id", "n"]
                },
                "qsTrIdNoOp": {
                    "params_name": ["id"]
                },
                "qsTranslate": {
                    "params_name": ["context", "sourceText", "disambiguation", "n"]
                },
                "qsTranslateNoOp": {
                    "params_name": ["context", "sourceText", "disambiguation"]
                },
                "quanternion": {
                    "params_name": ["scalar", "x", "y", "z"]
                },
                "quit": {
                    "params_name": []
                },
                "rect": {
                    "params_name": ["x", "y", "width", "height"]
                },
                "resolvedUrl": {
                    "params_name": ["url"]
                },
                "rgba": {
                    "params_name": ["red", "green", "blue", "alpha"]
                },
                "size": {
                    "params_name": ["width", "height"]
                },
                "tint": {
                    "params_name": ["baseColor", "tintColor"]
                },
                "vector2d": {
                    "params_name": ["x", "y"]
                },
                "vector3d": {
                    "params_name": ["x", "y", "z"]
                },
                "vector4d": {
                    "params_name": ["x", "y", "z", "w"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": true,
            "isVisualWidget": false,
        },
        "QtObject": {
            "properties": {
                "objectName": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "RadioButton": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Rectangle": {
            "properties": {
                "antialiasing": {
                    "meta_properties": []
                },
                "border": {
                    "meta_properties": [
                        "width: ",
                        "color: ",
                    ]
                },
                "color": {
                    "meta_properties": []
                },
                "gradient": {
                    "meta_properties": []
                },
                "radius": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "RegExpValidator": {
            "properties": {
                "regExp": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Repeater": {
            "properties": {
                "count": {
                    "meta_properties": []
                },
                "delegate": {
                    "meta_properties": []
                },
                "model": {
                    "meta_properties": []
                },
            },
            "functions": {
                "itemAt": {
                    "params_name": ["index"]
                },
            },
            "signals": {
                "itemAdded": {
                    "params_name": ["index", "item"]
                },
                "itemRemoved": {
                    "params_name": ["index", "item"]
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Rotation": {
            "properties": {
                "angle": {
                    "meta_properties": []
                },
                "axis": {
                    "meta_properties": [
                        "x: ",
                        "y: ",
                        "z: ",
                    ]
                },
                "origin": {
                    "meta_properties": [
                        "x: ",
                        "y: ",
                    ]
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Row": {
            "properties": {
                "add": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "effectiveLayoutDirection": {
                    "meta_properties": []
                },
                "layoutDirection": {
                    "meta_properties": []
                },
                "move": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "populate": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
            },
            "functions": {
                "forceLayout": {
                    "params_name": []
                },
            },
            "signals": {
                "positioningComplete": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "RowLayout": {
            "properties": {
                "layoutDirection": {
                    "meta_properties": []
                },
                "spacing": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Layouts",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Scale": {
            "properties": {
                "origin": {
                    "meta_properties": [
                        "x: ",
                        "y: ",
                    ]
                },
                "xScale": {
                    "meta_properties": []
                },
                "yScale": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ScrollBar": {
            "properties": {
                "active": {
                    "meta_properties": []
                },
                "horizontal": {
                    "meta_properties": []
                },
                "interactive": {
                    "meta_properties": []
                },
                "minimumSize": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "policy": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "size": {
                    "meta_properties": []
                },
                "snapMode": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
                "visualSize": {
                    "meta_properties": []
                },
            },
            "functions": {
                "decrease": {
                    "params_name": []
                },
                "increase": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ScrollIndicator": {
            "properties": {
                "active": {
                    "meta_properties": []
                },
                "horizontal": {
                    "meta_properties": []
                },
                "interactive": {
                    "meta_properties": []
                },
                "minimumSize": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "policy": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "size": {
                    "meta_properties": []
                },
                "snapMode": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
                "visualSize": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ScrollView": {
            "properties": {
                "contentChildren": {
                    "meta_properties": []
                },
                "contentData": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Settings": {
            "properties": {
                "category": {
                    "meta_properties": []
                },
                "fileName": {
                    "meta_properties": []
                },
            },
            "functions": {
                "setValue": {
                    "params_name": ["key", "value"]
                },
                "value": {
                    "params_name": ["key", "defaultValue"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "labs.settings",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGAccordion": {
            "properties": {
                "accordionItems": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "openCloseTime": {
                    "meta_properties": []
                },
                "statusIcon": {
                    "meta_properties": []
                },
                "exclusive": {
                    "meta_properties": []
                },
                "contentsColor": {
                    "meta_properties": []
                },
                "textOpenColor": {
                    "meta_properties": []
                },
                "textClosedColor": {
                    "meta_properties": []
                },
                "headerOpenColor": {
                    "meta_properties": []
                },
                "headerClosedColor": {
                    "meta_properties": []
                },
                "dividerColor": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 0.9",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGAlignedLabel": {
            "properties": {
                "target": {
                    "meta_properties": []
                },
                "alignment": {
                    "meta_properties": []
                },
                "overrideLabelWidth": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "alternativeColorEnabled": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "implicitColor": {
                    "meta_properties": []
                },
                "alternativeColor": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "clickable": {
                    "meta_properties": []
                },
            },
            "functions": {
                "clearAnchors": {
                    "params_name": ["object"]
                },
                "setAnchors": {
                    "params_name": []
                },
            },
            "signals": {
                "clicked": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGButton": {
            "properties": {
                "alternativeColorEnabled": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "minimumContentHeight": {
                    "meta_properties": []
                },
                "minimumContentWidth": {
                    "meta_properties": []
                },
                "preferredContentWidth": {
                    "meta_properties": []
                },
                "preferredontentHeight": {
                    "meta_properties": []
                },
                "contentHorizontalAlignment": {
                    "meta_properties": []
                },
                "contentVerticalAlignment": {
                    "meta_properties": []
                },
                "backgroundOnlyOnHovered": {
                    "meta_properties": []
                },
                "scaleToFit": {
                    "meta_properties": []
                },
                "hintText": {
                    "meta_properties": []
                },
                "iconSize": {
                    "meta_properties": []
                },
                "iconMirror": {
                    "meta_properties": []
                },
                "iconColor": {
                    "meta_properties": []
                },
                "implicitColor": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "pressedColor": {
                    "meta_properties": []
                },
                "checkedColor": {
                    "meta_properties": []
                },
                "roundedLeft": {
                    "meta_properties": []
                },
                "roundedRight": {
                    "meta_properties": []
                },
                "roundedTop": {
                    "meta_properties": []
                },
                "roundedBottom": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Button",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGButtonStrip": {
            "properties": {
                "model": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "exclusive": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "checkedIndices": {
                    "meta_properties": []
                },
            },
            "functions": {
                "isChecked": {
                    "params_name": ["index"]
                },
            },
            "signals": {
                "clicked": {
                    "params_name": ["index"]
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGCircularGauge": {
            "properties": {
                "value": {
                    "meta_properties": []
                },
                "gaugeFillColor1": {
                    "meta_properties": []
                },
                "gaugeFillColor2": {
                    "meta_properties": []
                },
                "gaugeBackgroundColor": {
                    "meta_properties": []
                },
                "centerTextColor": {
                    "meta_properties": []
                },
                "outerTextColor": {
                    "meta_properties": []
                },
                "unitTextFontSizeMultiplier": {
                    "meta_properties": []
                },
                "outerTextFontSizeMultiplier": {
                    "meta_properties": []
                },
                "valueDecimalPlaces": {
                    "meta_properties": []
                },
                "tickmarkDecimalPlaces": {
                    "meta_properties": []
                },
                "minimumValue": {
                    "meta_properties": []
                },
                "maximumValue": {
                    "meta_properties": []
                },
                "tickmarkStepsize": {
                    "meta_properties": []
                },
                "unitText": {
                    "meta_properties": []
                },
            },
            "functions": {
                "lerpColor": {
                    "params_name": ["color1", "color2", "x"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGComboBox": {
            "properties": {
                "textColor": {
                    "meta_properties": []
                },
                "indicatorColor": {
                    "meta_properties": []
                },
                "borderColor": {
                    "meta_properties": []
                },
                "borderColorFocused": {
                    "meta_properties": []
                },
                "boxColor": {
                    "meta_properties": []
                },
                "dividers": {
                    "meta_properties": []
                },
                "popupHeight": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "placeHolderText": {
                    "meta_properties": []
                },
                "modelWidth": {
                    "meta_properties": []
                },
                "iconImage": {
                    "meta_properties": []
                },
                "textField": {
                    "meta_properties": []
                },
                "textFieldBackground": {
                    "meta_properties": []
                },
                "backgroundItem": {
                    "meta_properties": []
                },
                "popupItem": {
                    "meta_properties": []
                },
                "popupBackground": {
                    "meta_properties": []
                },
            },
            "functions": {
                "findWidth": {
                    "params_name": []
                },
                "colorMod": {
                    "params_name": ["color", "increment"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "ComboBox",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGGraph": {
            "properties": {
                "panXEnabled": {
                    "meta_properties": []
                },
                "panYEnabled": {
                    "meta_properties": []
                },
                "zoomXEnabled": {
                    "meta_properties": []
                },
                "zoomYEnabled": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "mouseArea": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGHueSlider": {
            "properties": {
                "color1": {
                    "meta_properties": []
                },
                "color2": {
                    "meta_properties": []
                },
                "color_value1": {
                    "meta_properties": []
                },
                "color_value2": {
                    "meta_properties": []
                },
                "rgbArray": {
                    "meta_properties": []
                },
                "powerSave": {
                    "meta_properties": []
                },
            },
            "functions": {
                "hueToRgbPowerSave": {
                    "params_name": ["h"]
                },
                "hsvToRgb": {
                    "params_name": ["h", "s", "v"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Slider",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGIcon": {
            "properties": {
                "asynchronous": {
                    "meta_properties": []
                },
                "autoTransform": {
                    "meta_properties": []
                },
                "cache": {
                    "meta_properties": []
                },
                "fillMode": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "mipmap": {
                    "meta_properties": []
                },
                "mirror": {
                    "meta_properties": []
                },
                "paintedHeight": {
                    "meta_properties": []
                },
                "paintedWidth": {
                    "meta_properties": []
                },
                "progress": {
                    "meta_properties": []
                },
                "smooth": {
                    "meta_properties": []
                },
                "source": {
                    "meta_properties": []
                },
                "sourceSize": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGInfoBox": {
            "properties": {
                "textColor": {
                    "meta_properties": []
                },
                "invalidTextColor": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "boxBorderColor": {
                    "meta_properties": []
                },
                "boxBorderWidth": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "placeHolderText": {
                    "meta_properties": []
                },
                "readOnly": {
                    "meta_properties": []
                },
                "boxColor": {
                    "meta_properties": []
                },
                "unit": {
                    "meta_properties": []
                },
                "textPadding": {
                    "meta_properties": []
                },
                "validator": {
                    "meta_properties": []
                },
                "acceptableInput": {
                    "meta_properties": []
                },
                "boxFont": {
                    "meta_properties": []
                },
                "unitFont": {
                    "meta_properties": []
                },
                "unitHorizontalAlignment": {
                    "meta_properties": []
                },
                "unitOverrideWidth": {
                    "meta_properties": []
                },
                "boxObject": {
                    "meta_properties": []
                },
                "infoTextObject": {
                    "meta_properties": []
                },
                "mouseAreaObject": {
                    "meta_properties": []
                },
                "placeHolderObject": {
                    "meta_properties": []
                },
                "unitObject": {
                    "meta_properties": []
                }
            },
            "functions": {
                "selectAll": {
                    "params_name": []
                },
            },
            "signals": {
                "accepted": {
                    "params_name": ["text"]
                },
                "editingFinished": {
                    "params_name": ["text"]
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGRadioButton": {
            "properties": {
                "buttonContainer": {
                    "meta_properties": []
                },
                "radioSize": {
                    "meta_properties": []
                },
                "radioColor": {
                    "meta_properties": []
                },
                "index": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "alignment": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "RadioButton",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGRGBSlider": {
            "properties": {
                "rgbArray": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "color_value": {
                    "meta_properties": []
                },
            },
            "functions": {
                "hToRgb": {
                    "params_name": ["value"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Slider",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGSlider": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "mirror": {
                    "meta_properties": []
                },
                "handleSize": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                },
                "from": {
                    "meta_properties": []
                },
                "to": {
                    "meta_properties": []
                },
                "horizontal": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
                "showTickmarks": {
                    "meta_properties": []
                },
                "showLabels": {
                    "meta_properties": []
                },
                "showInputBox": {
                    "meta_properties": []
                },
                "showToolTip": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "live": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "snapMode": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "grooveColor": {
                    "meta_properties": []
                },
                "fillColor": {
                    "meta_properties": []
                },
                "slider": {
                    "meta_properties": []
                },
                "inputBox": {
                    "meta_properties": []
                },
                "fromText": {
                    "meta_properties": []
                },
                "toText": {
                    "meta_properties": []
                },
                "tickmarkRepeater": {
                    "meta_properties": []
                },
                "inputBoxWidth": {
                    "meta_properties": []
                },
                "toolTip": {
                    "meta_properties": []
                },
                "toolTipText": {
                    "meta_properties": []
                },
                "toolTipBackground": {
                    "meta_properties": []
                },
                "validatorObject": {
                    "meta_properties": []
                },
                "handleObject": {
                    "meta_properties": []
                },
            },
            "functions": {
                "userSetValue": {
                    "params_name": ["value"]
                },
                "increase": {
                    "params_name": []
                },
                "decrease": {
                    "params_name": []
                },
                "valueAt": {
                    "params_name": ["position"]
                },
            },
            "signals": {
                "userSet": {
                    "params_name": ["value"]
                },
                "moved": {
                    "params_name": []
                },
            },
            "inherits": "GridLayout",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGSpinBox": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "SpinBox",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGStatusLight": {
            "properties": {
                "status": {
                    "meta_properties": []
                },
                "customColor": {
                    "meta_properties": []
                },
                "flatStyle": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGStatusLogBox": {
            "properties": {
                "title": {
                    "meta_properties": []
                },
                "titleTextColor": {
                    "meta_properties": []
                },
                "titleBoxColor": {
                    "meta_properties": []
                },
                "titleBoxBorderColor": {
                    "meta_properties": []
                },
                "statusTextColor": {
                    "meta_properties": []
                },
                "statusBoxColor": {
                    "meta_properties": []
                },
                "statusBoxBorderColor": {
                    "meta_properties": []
                },
                "showMessageIds": {
                    "meta_properties": []
                },
                "model": {
                    "meta_properties": []
                },
                "filterRole": {
                    "meta_properties": []
                },
                "copyRole": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "scrollToEnd": {
                    "meta_properties": []
                },
                "listView": {
                    "meta_properties": []
                },
                "listViewMouse": {
                    "meta_properties": []
                },
                "delegate": {
                    "meta_properties": []
                },
                "filterEnabled": {
                    "meta_properties": []
                },
                "copyEnabled": {
                    "meta_properties": []
                },
                "filterModel": {
                    "meta_properties": []
                },
            },
            "functions": {
                "onFilter": {
                    "params_name": ["listElement"]
                },
                "copySelectionTest": {
                    "params_name": ["index"]
                },
                "append": {
                    "params_name": ["message"]
                },
                "remove": {
                    "params_name": ["id"]
                },
                "updateMessageAtID": {
                    "params_name": ["message", "id"]
                },
                "clear": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Rectangle",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGSubmitInfoBox": {
            "properties": {
                "text": {
                    "meta_properties": []
                },
                "infoBoxObject": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "textPadding": {
                    "meta_properties": []
                },
                "invalidTextColor": {
                    "meta_properties": []
                },
                "boxColor": {
                    "meta_properties": []
                },
                "boxBorderColor": {
                    "meta_properties": []
                },
                "boxBorderWidth": {
                    "meta_properties": []
                },
                "unit": {
                    "meta_properties": []
                },
                "readOnly": {
                    "meta_properties": []
                },
                "validator": {
                    "meta_properties": []
                },
                "placeholderText": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "buttonText": {
                    "meta_properties": []
                },
                "buttonImplicitWidth": {
                    "meta_properties": []
                },
                "floatValue": {
                    "meta_properties": []
                },
                "intValue": {
                    "meta_properties": []
                },
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "appliedString": {
                    "meta_properties": []
                },
                "infoBoxHeight": {
                    "meta_properties": []
                },
            },
            "functions": {
                "forceActiveFocus": {
                    "params_name": []
                },
                "selectAll": {
                    "params_name": []
                },
                "deselect": {
                    "params_name": []
                },
            },
            "signals": {
                "accepted": {
                    "params_name": ["text"]
                },
                "editingFinished": {
                    "params_name": ["text"]
                },
            },
            "inherits": "RowLayout",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGSwitch": {
            "properties": {
                "fontSizeMultiplier": {
                    "meta_properties": []
                },
                "handleColor": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "labelIsInside": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": []
                },
                "checked": {
                    "meta_properties": []
                },
                "checkedLabel": {
                    "meta_properties": []
                },
                "uncheckedLabel": {
                    "meta_properties": []
                },
                "grooveFillColor": {
                    "meta_properties": []
                },
                "grooveColor": {
                    "meta_properties": []
                },
            },
            "functions": {
                "colorMod": {
                    "params_name": ["color", "factor"]
                },
            },
            "signals": {
                "released": {
                    "params_name": []
                },
                "canceled": {
                    "params_name": []
                },
                "clicked": {
                    "params_name": []
                },
                "toggled": {
                    "params_name": []
                },
                "press": {
                    "params_name": []
                },
                "pressAndHold": {
                    "params_name": []
                },
            },
            "inherits": "RowLayout",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGTextField": {
            "properties": {
                "isValid": {
                    "meta_properties": []
                },
                "activeEditing": {
                    "meta_properties": []
                },
                "validationReady": {
                    "meta_properties": []
                },
                "timerIsRunning": {
                    "meta_properties": []
                },
                "isValidAffectsBackground": {
                    "meta_properties": []
                },
                "leftIconColor": {
                    "meta_properties": []
                },
                "leftIconSource": {
                    "meta_properties": []
                },
                "darkMode": {
                    "meta_properties": []
                },
                "showCursorPosition": {
                    "meta_properties": []
                },
                "showClearButton": {
                    "meta_properties": []
                },
                "passwordMode": {
                    "meta_properties": []
                },
                "busyIndicatorRunning": {
                    "meta_properties": []
                },
                "contextMenuEnabled": {
                    "meta_properties": []
                },
                "suggestionListModel": {
                    "meta_properties": []
                },
                "suggestionListDelegate": {
                    "meta_properties": []
                },
                "suggestionModelTextRole": {
                    "meta_properties": []
                },
                "suggestionPosition": {
                    "meta_properties": []
                },
                "suggestionEmptyModelText": {
                    "meta_properties": []
                },
                "suggestionHeaderText": {
                    "meta_properties": []
                },
                "suggestionCloseOnDown": {
                    "meta_properties": []
                },
                "suggestionOpenWithAnyKey": {
                    "meta_properties": []
                },
                "suggestionMaxHeight": {
                    "meta_properties": []
                },
                "suggestionDelegateNumbering": {
                    "meta_properties": []
                },
                "suggestionDelegateRemovable": {
                    "meta_properties": []
                },
                "suggestionDelegateTextWrap": {
                    "meta_properties": []
                },
                "suggestionPopup": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "suggestionsDelegateSelected": {
                    "params_name": ["index"]
                },
                "suggestionDelegateRemoveRequested": {
                    "params_name": ["index"]
                },
            },
            "inherits": "TextField",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGUserSettings": {
            "properties": {
                "classId": {
                    "meta_properties": []
                },
                "user": {
                    "meta_properties": []
                },
            },
            "functions": {
                "writeFile": {
                    "params_name": ["fileName", "data", "subdirectory"]
                },
                "readFile": {
                    "params_name": ["fileName", "subdirectory"]
                },
                "listFilesInDirectory": {
                    "params_name": ["subdirectory"]
                },
                "deleteFile": {
                    "params_name": ["fileName", "subdirectory"]
                },
                "renameFile": {
                    "params_name": ["origFileName", "newFileName", "subdirectory"]
                },
            },
            "signals": {
                "classIdChanged": {
                    "params_name": ["id"]
                },
                "userChanged": {
                    "params_name": ["user"]
                },
            },
            "inherits": "QtObject",
            "source": "tech.strata.commoncpp 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Slider": {
            "properties": {
                "from": {
                    "meta_properties": []
                },
                "handle": {
                    "meta_properties": []
                },
                "horizontal": {
                    "meta_properties": []
                },
                "implicitHandleHeight": {
                    "meta_properties": []
                },
                "implicitHandleWidth": {
                    "meta_properties": []
                },
                "live": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "pressed": {
                    "meta_properties": []
                },
                "snapMode": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "to": {
                    "meta_properties": []
                },
                "touchDragThreshold": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
            },
            "functions": {
                "decrease": {
                    "params_name": []
                },
                "increase": {
                    "params_name": []
                },
                "valueAt": {
                    "params_name": ["position"]
                },
            },
            "signals": {
                "moved": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SpinBox": {
            "properties": {
                "displayText": {
                    "meta_properties": []
                },
                "down": {
                    "meta_properties": [
                        "pressed: ",
                        "indicator: ",
                        "hovered: ",
                        "implicitIndicatorWidth: ",
                        "implicitIndicatorHeight: ",
                    ]
                },
                "editable": {
                    "meta_properties": []
                },
                "from": {
                    "meta_properties": []
                },
                "inputMethodComposing": {
                    "meta_properties": [],
                },
                "inputMethodHints": {
                    "meta_properties": []
                },
                "stepSize": {
                    "meta_properties": []
                },
                "textFromValue": {
                    "meta_properties": []
                },
                "to": {
                    "meta_properties": []
                },
                "up": {
                    "meta_properties": [
                        "pressed: ",
                        "indicator: ",
                        "hovered: ",
                        "implicitIndicatorWidth: ",
                        "implicitIndicatorHeight: ",
                    ]
                },
                "validator": {
                    "meta_properties": []
                },
                "value": {
                    "meta_properties": []
                },
                "valueFromText": {
                    "meta_properties": []
                },
                "wrap": {
                    "meta_properties": []
                }
            },
            "functions": {
                "decrease": {
                    "params_name": []
                },
                "increase": {
                    "params_name": []
                },
            },
            "signals": {
                "valueModified": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SplitView": {
            "properties": {
                "handleDelegate": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "resizing": {
                    "meta_properties": []
                },
            },
            "functions": {
                "addItem": {
                    "params_name": ["item"]
                },
                "removeItem": {
                    "params_name": ["item"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Stack": {
            "properties": {
                "index": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
                "view": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "Source",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "StackLayout": {
            "properties": {
                "count": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Layouts",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "StackView": {
            "properties": {
                "busy": {
                    "meta_properties": []
                },
                "currentItem": {
                    "meta_properties": []
                },
                "depth": {
                    "meta_properties": []
                },
                "empty": {
                    "meta_properties": []
                },
                "initialItem": {
                    "meta_properties": []
                },
                "popEnter": {
                    "meta_properties": []
                },
                "popExit": {
                    "meta_properties": []
                },
                "pushEnter": {
                    "meta_properties": []
                },
                "pushExit": {
                    "meta_properties": []
                },
                "replaceEnter": {
                    "meta_properties": []
                },
                "replaceExit": {
                    "meta_properties": []
                },
                "index": {
                    "meta_properties": []
                },
                "status": {
                    "meta_properties": []
                },
                "view": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                }
            },
            "functions": {
                "clear": {
                    "params_name": ["transition"]
                },
                "find": {
                    "params_name": ["callback", "behavior"]
                },
                "get": {
                    "params_name": ["index", "behavior"]
                },
                "pop": {
                    "params_name": ["item", "operation"]
                },
                "push": {
                    "params_name": ["item", "properties", "operation"]
                },
                "replace": {
                    "params_name": ["target", "item", "properties", "operation"]
                },
            },
            "signals": {
                "activated": {
                    "params_name": []
                },
                "activating": {
                    "params_name": []
                },
                "deactivated": {
                    "params_name": []
                },
                "deactivatting": {
                    "params_name": []
                },
                "removed": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "State": {
            "properties": {
                "changes": {
                    "meta_properties": []
                },
                "extend": {
                    "meta_properties": []
                },
                "name": {
                    "meta_properties": []
                },
                "when": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "StatusBar": {
            "properties": {
                "contentItem": {
                    "meta_properties": []
                },
                "style": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "StatusIndicator": {
            "properties": {
                "active": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "Extras",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Switch": {
            "properties": {
                "position": {
                    "meta_properties": []
                },
                "visualPosition": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Tab": {
            "properties": {
                "title": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Loader",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TabBar": {
            "properties": {
                "contentHeight": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "index": {
                    "meta_properties": []
                },
                "position": {
                    "meta_properties": []
                },
                "tabBar": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TabButton": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TabView": {
            "properties": {
                "contentItem": {
                    "meta_properties": []
                },
                "count": {
                    "meta_properties": []
                },
                "currentIndex": {
                    "meta_properties": []
                },
                "frameVisible": {
                    "meta_properties": []
                },
                "tabPosition": {
                    "meta_properties": []
                },
                "tabsVisible": {
                    "meta_properties": []
                },
            },
            "functions": {
                "addTab": {
                    "params_name": ["title", "component"]
                },
                "getTab": {
                    "params_name": ["index"]
                },
                "insertTab": {
                    "params_name": ["index", "title", "component"]
                },
                "moveTab": {
                    "params_name": ["from", "to"]
                },
                "removeTab": {
                    "params_name": ["index"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Item",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Text": {
            "properties": {
                "advance": {
                    "meta_properties": []
                },
                "baseUrl": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "clip": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "effectiveHorizontalAlignment": {
                    "meta_properties": []
                },
                "elide": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": [
                        "bold: ",
                        "capitalization: ",
                        "family: ",
                        "hintingPreference: ",
                        "italic: ",
                        "kerning: ",
                        "letterSpacing: ",
                        "pixelSize: ",
                        "pointSize: ",
                        "preferShaping: ",
                        "strikeout: ",
                        "styleName: ",
                        "underline: ",
                        "weight: ",
                        "wordSpacing: ",
                    ]
                },
                "fontSizeMode": {
                    "meta_properties": []
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "hoveredLink": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "lineCount": {
                    "meta_properties": []
                },
                "lineHeight": {
                    "meta_properties": []
                },
                "lineHeightMode": {
                    "meta_properties": []
                },
                "linkColor": {
                    "meta_properties": []
                },
                "maximumLineCount": {
                    "meta_properties": []
                },
                "minimumPixelSize": {
                    "meta_properties": []
                },
                "minimumPointSize": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "renderType": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "style": {
                    "meta_properties": []
                },
                "styleColor": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "textFormat": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "truncated": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                },
                "wrapMode": {
                    "meta_properties": []
                },
            },
            "functions": {
                "forceLayout": {
                    "params_name": []
                },
                "linkAt": {
                    "params_name": ["x", "y"]
                },
            },
            "signals": {
                "lineLaidOut": {
                    "params_name": ["line"]
                },
                "linkActivated": {
                    "params_name": ["link"]
                },
                "linkHovered": {
                    "params_name": ["link"]
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TextArea": {
            "properties": {
                "background": {
                    "meta_properties": []
                },
                "bottomInset": {
                    "meta_properties": []
                },
                "focusReason": {
                    "meta_properties": []
                },
                "hoverEnabled": {
                    "meta_properties": []
                },
                "hovered": {
                    "meta_properties": []
                },
                "implicitBackgroundHeight": {
                    "meta_properties": []
                },
                "implicitBackgroundWidth": {
                    "meta_properties": []
                },
                "leftInset": {
                    "meta_properties": []
                },
                "palette": {
                    "meta_properties": []
                },
                "placeholderText": {
                    "meta_properties": []
                },
                "placeholderTextColor": {
                    "meta_properties": []
                },
                "rightInset": {
                    "meta_properties": []
                },
                "topInset": {
                    "meta_properties": []
                },
                "flickable": {
                    "meta_properties": []
                }
            },
            "functions": {
                "append": {
                    "params_name": ["text"]
                },
                "copy": {
                    "params_name": []
                },
                "cut": {
                    "params_name": []
                },
                "deselect": {
                    "params_name": []
                },
                "getFormattedText": {
                    "params_name": ["start", "end"]
                },
                "getText": {
                    "params_name": ["start", "end"]
                },
                "insert": {
                    "params_name": ["position", "text"]
                },
                "isRightToLeft": {
                    "params_name": ["start", "end"]
                },
                "moveCursorSelection": {
                    "params_name": ["position", "mode"]
                },
                "paste": {
                    "params_name": []
                },
                "positionAt": {
                    "params_name": ["x", "y"]
                },
                "positionToRectangle": {
                    "params_name": ["position"]
                },
                "redo": {
                    "params_name": []
                },
                "remove": {
                    "params_name": ["start", "end"]
                },
                "select": {
                    "params_name": ["start", "end"]
                },
                "selectAll": {
                    "params_name": []
                },
                "selectWord": {
                    "params_name": []
                },
                "undo": {
                    "params_name": []
                },

            },
            "signals": {
                "editingFinished": {
                    "params_name": []
                },
                "linkActivated": {
                    "params_name": ["link"]
                },
                "linkHovered": {
                    "params_name": ["link"]
                },
            },
            "inherits": "TextEdit",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TextEdit": {
            "properties": {
                "activeFocusOnPress": {
                    "meta_properties": []
                },
                "baseUrl": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "canPaste": {
                    "meta_properties": []
                },
                "canRedo": {
                    "meta_properties": []
                },
                "canUndo": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "cursorDelegate": {
                    "meta_properties": []
                },
                "cursorPosition": {
                    "meta_properties": []
                },
                "cursorRectangle": {
                    "meta_properties": []
                },
                "cursorVisible": {
                    "meta_properties": []
                },
                "effectiveHorizontalAlignment": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": [
                        "bold: ",
                        "capitalization: ",
                        "family: ",
                        "hintingPreference: ",
                        "italic: ",
                        "kerning: ",
                        "letterSpacing: ",
                        "pixelSize: ",
                        "pointSize: ",
                        "preferShaping: ",
                        "strikeout: ",
                        "styleName: ",
                        "underline: ",
                        "weight: ",
                        "wordSpacing: ",
                    ]
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "hoveredLink": {
                    "meta_properties": []
                },
                "inputMethodComposing": {
                    "meta_properties": []
                },
                "inputMethodHints": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "length": {
                    "meta_properties": []
                },
                "lineCount": {
                    "meta_properties": []
                },
                "mouseSelectionMode": {
                    "meta_properties": []
                },
                "overwriteMode": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "persistentSelection": {
                    "meta_properties": []
                },
                "preeditText": {
                    "meta_properties": []
                },
                "readOnly": {
                    "meta_properties": []
                },
                "renderType": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "selectByKeyboard": {
                    "meta_properties": []
                },
                "selectByMouse": {
                    "meta_properties": []
                },
                "selectedText": {
                    "meta_properties": []
                },
                "selectedTextColor": {
                    "meta_properties": []
                },
                "selectionColor": {
                    "meta_properties": []
                },
                "selectionEnd": {
                    "meta_properties": []
                },
                "selectionStart": {
                    "meta_properties": []
                },
                "tabStopDistance": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "textDocument": {
                    "meta_properties": []
                },
                "textFormat": {
                    "meta_properties": []
                },
                "textMargin": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                },
                "wrapMode": {
                    "meta_properties": []
                }
            },
            "functions": {
                "append": {
                    "params_name": ["text"]
                },
                "clear": {
                    "params_name": []
                },
                "copy": {
                    "params_name": []
                },
                "cut": {
                    "params_name": []
                },
                "deselect": {
                    "params_name": []
                },
                "getFormattedText": {
                    "params_name": ["start", "end"]
                },
                "getText": {
                    "params_name": ["start", "end"]
                },
                "insert": {
                    "params_name": ["position", "text"]
                },
                "isRightToLeft": {
                    "params_name": ["start", "end"]
                },
                "linkAt": {
                    "params_name": ["x", "y"]
                },
                "moveCursorSelection": {
                    "params_name": ["position", "mode"]
                },
                "paste": {
                    "params_name": []
                },
                "positionAt": {
                    "params_name": ["x", "y"]
                },
                "positionToRectangle": {
                    "params_name": ["position"]
                },
                "redo": {
                    "params_name": []
                },
                "remove": {
                    "params_name": ["start", "end"]
                },
                "select": {
                    "params_name": ["start", "end"]
                },
                "selectAll": {
                    "params_name": []
                },
                "selectWord": {
                    "params_name": []
                },
                "undo": {
                    "params_name": []
                },
            },
            "signals": {
                "editingFinished": {
                    "params_name": []
                },
                "linkActivated": {
                    "params_name": ["link"]
                },
                "linkHovered": {
                    "params_name": ["link"]
                },
            },
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TextField": {
            "properties": {
                "background": {
                    "meta_properties": []
                },
                "bottomInset": {
                    "meta_properties": []
                },
                "focusReason": {
                    "meta_properties": []
                },
                "hoverEnabled": {
                    "meta_properties": []
                },
                "hovered": {
                    "meta_properties": []
                },
                "implicitBackgroundHeight": {
                    "meta_properties": []
                },
                "implicitBackgroundWidth": {
                    "meta_properties": []
                },
                "leftInset": {
                    "meta_properties": []
                },
                "palette": {
                    "meta_properties": []
                },
                "placeholderText": {
                    "meta_properties": []
                },
                "placeholderTextColor": {
                    "meta_properties": []
                },
                "rightInset": {
                    "meta_properties": []
                },
                "topInset": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "pressAndHold": {
                    "params_name": ["event"]
                },
                "pressed": {
                    "params_name": ["event"]
                },
                "released": {
                    "params_name": ["event"]
                },
            },
            "inherits": "TextInput",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TextInput": {
            "properties": {
                "acceptableInput": {
                    "meta_properties": []
                },
                "activeFocusOnPress": {
                    "meta_properties": []
                },
                "autoScroll": {
                    "meta_properties": []
                },
                "bottomPadding": {
                    "meta_properties": []
                },
                "canPaste": {
                    "meta_properties": []
                },
                "canRedo": {
                    "meta_properties": []
                },
                "canUndo": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "contentHeight": {
                    "meta_properties": []
                },
                "contentWidth": {
                    "meta_properties": []
                },
                "cursorDelegate": {
                    "meta_properties": []
                },
                "cursorPosition": {
                    "meta_properties": []
                },
                "cursorRectangle": {
                    "meta_properties": []
                },
                "cursorVisible": {
                    "meta_properties": []
                },
                "effectiveHorizontalAlignment": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": [
                        "bold: ",
                        "capitalization: ",
                        "family: ",
                        "hintingPreference: ",
                        "italic: ",
                        "kerning: ",
                        "letterSpacing: ",
                        "pixelSize: ",
                        "pointSize: ",
                        "preferShaping: ",
                        "strikeout: ",
                        "styleName: ",
                        "underline: ",
                        "weight: ",
                        "wordSpacing: ",
                    ]
                },
                "horizontalAlignment": {
                    "meta_properties": []
                },
                "inputMask": {
                    "meta_properties": []
                },
                "inputMethodComposing": {
                    "meta_properties": []
                },
                "inputMethodHints": {
                    "meta_properties": []
                },
                "leftPadding": {
                    "meta_properties": []
                },
                "length": {
                    "meta_properties": []
                },
                "maximumLength": {
                    "meta_properties": []
                },
                "mouseSelectionMode": {
                    "meta_properties": []
                },
                "overwriteMode": {
                    "meta_properties": []
                },
                "padding": {
                    "meta_properties": []
                },
                "passwordCharacter": {
                    "meta_properties": []
                },
                "passwordMaskDelay": {
                    "meta_properties": []
                },
                "persistentSelection": {
                    "meta_properties": []
                },
                "preeditText": {
                    "meta_properties": []
                },
                "readOnly": {
                    "meta_properties": []
                },
                "renderType": {
                    "meta_properties": []
                },
                "rightPadding": {
                    "meta_properties": []
                },
                "selectByMouse": {
                    "meta_properties": []
                },
                "selectedText": {
                    "meta_properties": []
                },
                "selectedTextColor": {
                    "meta_properties": []
                },
                "selectionColor": {
                    "meta_properties": []
                },
                "selectionEnd": {
                    "meta_properties": []
                },
                "selectionStart": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "topPadding": {
                    "meta_properties": []
                },
                "validator": {
                    "meta_properties": []
                },
                "verticalAlignment": {
                    "meta_properties": []
                },
                "wrapMode": {
                    "meta_properties": []
                },
            },
            "functions": {
                "clear": {
                    "params_name": []
                },
                "copy": {
                    "params_name": []
                },
                "cut": {
                    "params_name": []
                },
                "deselect": {
                    "params_name": []
                },
                "ensureVisible": {
                    "params_name": ["position"]
                },
                "getText": {
                    "params_name": ["start", "end"]
                },
                "insert": {
                    "params_name": ["position", "text"]
                },
                "isRightToLeft": {
                    "params_name": ["start", "end"]
                },
                "moveCursorSelection": {
                    "params_name": ["position", "mode"]
                },
                "paste": {
                    "params_name": []
                },
                "positionAt": {
                    "params_name": ["x", "y", "position"]
                },
                "positionToRectangle": {
                    "params_name": ["pos"]
                },
                "redo": {
                    "params_name": []
                },
                "remove": {
                    "params_name": ["start", "end"]
                },
                "select": {
                    "params_name": ["start", "end"]
                },
                "selectAll": {
                    "params_name": []
                },
                "selectWord": {
                    "params_name": []
                },
                "undo": {
                    "params_name": []
                },
            },
            "signals": {
                "accepted": {
                    "params_name": []
                },
                "editingFinished": {
                    "params_name": []
                },
                "textEdited": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "TextMetrics": {
            "properties": {
                "advanceWidth": {
                    "meta_properties": []
                },
                "boundingRect": {
                    "meta_properties": []
                },
                "elide": {
                    "meta_properties": []
                },
                "elideWidth": {
                    "meta_properties": []
                },
                "elidedText": {
                    "meta_properties": []
                },
                "font": {
                    "meta_properties": []
                },
                "height": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "tightBoundingRect": {
                    "meta_properties": []
                },
                "width": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Timer": {
            "properties": {
                "interval": {
                    "meta_properties": []
                },
                "repeat": {
                    "meta_properties": []
                },
                "running": {
                    "meta_properties": []
                },
                "triggeredOnStart": {
                    "meta_properties": []
                },
            },
            "functions": {
                "restart": {
                    "params_name": []
                },
                "start": {
                    "params_name": []
                },
                "stop": {
                    "params_name": []
                },
            },
            "signals": {
                "triggered": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToggleButton": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Button",
            "source": "Extras",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToolBar": {
            "properties": {
                "position": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToolButton": {
            "properties": {
                "property": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Button",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToolSeparator": {
            "properties": {
                "horizontal": {
                    "meta_properties": []
                },
                "orientation": {
                    "meta_properties": []
                },
                "vertical": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToolTip": {
            "properties": {
                "delay": {
                    "meta_properties": []
                },
                "text": {
                    "meta_properties": []
                },
                "timeout": {
                    "meta_properties": []
                },
                "toolTip": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                },
            },
            "functions": {
                "hide": {
                    "params_name": []
                },
                "show": {
                    "params_name": ["text", "timeout"]
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "Popup",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "Transition": {
            "properties": {
                "animations": {
                    "meta_properties": []
                },
                "enabled": {
                    "meta_properties": []
                },
                "from": {
                    "meta_properties": []
                },
                "reversible": {
                    "meta_properties": []
                },
                "running": {
                    "meta_properties": []
                },
                "to": {
                    "meta_properties": []
                },
            },
            "functions": {
                "function": {
                    "params_name": []
                },
            },
            "signals": {
                "signal": {
                    "params_name": []
                },
            },
            "inherits": "",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "UIBase": {
            "properties": {
                "columnCount": {
                    "meta_properties": []
                },
                "rowCount": {
                    "meta_properties": []
                },
                "columnSize": {
                    "meta_properties": []
                },
                "rowSize": {
                    "meta_properties": []
                }
            },
            "functions": {
                "function": {
                    "param_names": []
                }
            },
            "signals": {
                "signal": {
                    "param_names:": []
                }
            },
            "inherits": "Item",
            "source": "tech.strata.sglayout 1.0",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "Window": {
            "properties": {
                "active": {
                    "meta_properties": []
                },
                "activeFocusItem": {
                    "meta_properties": []
                },
                "color": {
                    "meta_properties": []
                },
                "contentItem": {
                    "meta_properties": []
                },
                "contentOrientation": {
                    "meta_properties": []
                },
                "data": {
                    "meta_properties": []
                },
                "flags": {
                    "meta_properties": []
                },
                "maximumHeight": {
                    "meta_properties": []
                },
                "maximumWidth": {
                    "meta_properties": []
                },
                "minimumHeight": {
                    "meta_properties": []
                },
                "minimumWidth": {
                    "meta_properties": []
                },
                "modality": {
                    "meta_properties": []
                },
                "opacity": {
                    "meta_properties": []
                },
                "screen": {
                    "meta_properties": []
                },
                "title": {
                    "meta_properties": []
                },
                "visibility": {
                    "meta_properties": []
                },
                "visible": {
                    "meta_properties": []
                },
                "width": {
                    "meta_properties": []
                },
                "x": {
                    "meta_properties": []
                },
                "y": {
                    "meta_properties": []
                }
            },
            "functions": {
                "alert": {
                    "params_name": ["msec"]
                },
                "close": {
                    "params_name": []
                },
                "hide": {
                    "params_name": []
                },
                "lower": {
                    "params_name": []
                },
                "raise": {
                    "params_name": []
                },
                "requestActivate": {
                    "params_name": []
                },
                "show": {
                    "params_name": []
                },
                "showFullScreen": {
                    "params_name": []
                },
                "showMaximized": {
                    "params_name": []
                },
                "showMinimized": {
                    "params_name": []
                },
                "showNormal": {
                    "params_name": []
                },
            },
            "signals": {
                "closing": {
                    "params_name": ["close"]
                },
            },
            "inherits": "",
            "source": "Window",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
    },
    "custom_properties": {
        "JSON": [
            "parse()",
            "stringify()",
        ],
        "console": [
            "log()",
            "info()",
            "warn()",
            "error()",
            "debug()",
        ],
        "Number": [
            "fromLocaleString()",
            "toLocaleCurrencyString()",
            "toLocaleString()",
        ],
        "Object": [
            "freeze()",
            "hasOwnProperty()",
            "entries()",
            "values()",
            "keys()",
        ],
        "String": [
            "arg()",
        ],
    },
    "import_statements": {
        "QtQuick": {
            "ver": [
                "2.0",
                "2.1",
                "2.2",
                "2.3",
                "2.4",
                "2.5",
                "2.6",
                "2.7",
                "2.8",
                "2.9",
                "2.10",
                "2.11",
                "2.12",
            ],
            "subTypes": {
                "Controls": {
                    "ver": [
                        "2.0",
                        "2.1",
                        "2.2",
                        "2.3",
                        "2.4",
                        "2.5",
                        "2.12",
                    ]
                },
                "Dialogs": {
                    "ver": [
                        "1.0",
                        "1.1",
                        "1.2",
                    ]
                },
                "Layouts": {
                    "ver": [
                        "1.0",
                        "1.1",
                        "1.2",
                        "1.3",
                        "1.12",
                    ]
                },
                "Window": {
                    "ver": [
                        "2.0",
                        "2.1",
                        "2.2",
                        "2.3",
                        "2.10",
                        "2.11",
                        "2.12",
                    ]
                }
            }
        },
        "QtQml": {
            "ver": [
                "2.0",
                "2.1",
                "2.2",
                "2.3",
                "2.12",
            ],
            "subTypes": {
                "Models": {
                    "ver": [
                        "2.1",
                        "2.2",
                        "2.3",
                        "2.11",
                        "2.12",
                    ]
                }
            }
        },
        "tech.strata.sgwidgets": {
            "ver": [
                "0.9",
                "1.0",
            ]
        },
        "tech.strata.commoncpp": {
            "ver": [
                "1.0",
            ]
        },
        "tech.strata.fonts": {
            "ver": [
                "1.0",
            ]
        },
        "tech.strata.theme": {
            "ver": [
                "1.0",
            ]
        },
        "tech.strata.sglayout": {
            "ver": [
                "1.0"
            ]
        }
    }
}