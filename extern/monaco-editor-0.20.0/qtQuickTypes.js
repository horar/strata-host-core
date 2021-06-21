/* 
    This File contains portions of snippets.json that exists in https://github.com/ThomasVogelpohl/vsc-qml-snippets/blob/master/snippets/snippets.json
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties

    If we need to add more QtQuick Objects the format will be
    "<QtType>": {
        "properties":{
            "property":{
                "meta_properties":[]
            },
        },
        "functions": [],
        "signals": [],
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
            "functions": [
                "toggle()",
            ],
            "signals": [
                "canceled()",
                "clicked()",
                "doubleClicked()",
                "pressAndHold()",
                "pressed()",
                "released()",
                "toggled()",
            ],
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
            "functions": [
                "toggle()",
                "trigger()",
            ],
            "signals": [
                "toggled()",
                "triggered()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
            "inherits": "AbstractButton",
            "source": "",
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
            "functions": [
                "cancelRequestAnimationFrame()",
                "getContext()",
                "isImageError()",
                "isImageLoaded()",
                "isImageLoading()",
                "loadImage()",
                "markDirty()",
                "requestAnimationFrame()",
                "requestPaint()",
                "save()",
                "toDataURL()",
                "unloadImage()",
            ],
            "signals": [
                "imageLoaded()",
                "paint()",
                "painted()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "forceLayout()",
            ],
            "signals": [
                "positioningComplete()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "decrementCurrentIndex()",
                "find()",
                "incrementCurrentIndex()",
                "selectAll()",
                "textAt()",
            ],
            "signals": [
                "accepted()",
                "activated()",
                "highlighted()",
            ],
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
            "functions": [
                "createObject()",
                "errorString()",
                "incubateObject()",
            ],
            "signals": [
                "completed()",
                "destruction()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "accept()",
                "done()",
                "reject()",
                "standardButton()",
            ],
            "signals": [
                "accepted()",
                "applied()",
                "discarded()",
                "helpRequested()",
                "rejected()",
                "reset()",
            ],
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
            "functions": [
                "close()",
                "open()",
            ],
            "signals": [],
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
            "functions": [
                "cancelFlick()",
                "flick()",
                "resizeContent()",
                "returnToBounds()",
            ],
            "signals": [
                "flickEnded()",
                "flickStarted()",
                "movementEnded()",
                "movementStarted()",
            ],
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
            "functions": [
                "forceLayout()"
            ],
            "signals": [
                "positioningComplete()"
            ],
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
            "functions": [
                "forceLayout()"
            ],
            "signals": [
                "positioningComplete()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "childAt()",
                "contains()",
                "forceActiveFocus()",
                "forceActiveFocus()",
                "grabToImage()",
                "mapFromGlobal()",
                "mapFromItem()",
                "mapFromItem()",
                "mapFromItem()",
                "mapFromItem()",
                "mapToGlobal()",
                "mapToItem()",
                "mapToItem()",
                "mapToItem()",
                "mapToItem()",
                "nextItemInFocusChain()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [
                "asteriskPressed()",
                "backPressed()",
                "backtabPressed()",
                "callPressed()",
                "cancelPressed()",
                "context1Pressed()",
                "context2Pressed()",
                "context3Pressed()",
                "context4Pressed()",
                "deletePressed()",
                "digit0Pressed()",
                "digit1Pressed()",
                "digit2Pressed()",
                "digit3Pressed()",
                "digit4Pressed()",
                "digit5Pressed()",
                "digit6Pressed()",
                "digit7Pressed()",
                "digit8Pressed()",
                "digit9Pressed()",
                "downPressed()",
                "enterPressed()",
                "escapePressed()",
                "flipPressed()",
                "hangupPressed()",
                "leftPressed()",
                "menuPressed()",
                "noPressed()",
                "pressed()",
                "released()",
                "returnPressed()",
                "rightPressed()",
                "selectPressed()",
                "shortcutOverride()",
                "spacePressed()",
                "tabPressed()",
                "upPressed()",
                "volumeDownPressed()",
                "volumeUpPressed()",
                "yesPressed()",

            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
                "checkable": {
                    "meta_properties": []
                },
                "textColor": {
                    "meta_properties": []
                },
                "color": {
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
                }
            },
            "functions": [],
            "signals": [
                "clicked()"
            ],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "Item",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": false,
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
            "nonInstantiable": false,
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": ["activated()"],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [
                "createCurve()",
                "curve()",
                "shiftXAxis()",
                "shiftYAxis()",
                "removeCurve()",
                "update()",
            ],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": ["clicked()"],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [
                "accepted()",
                "editingFinished()"
            ],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [
                "userSet()",
                "moved()"
            ],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [
                "released()",
                "canceled()",
                "clicked()",
                "toggled()",
                "press()",
                "pressAndHold()",
            ],
            "inherits": "LayoutContainer",
            "source": "",
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
            "functions": [],
            "signals": [],
            "inherits": "LayoutContainer",
            "source": "",
            "nonInstantiable": false,
            "isVisualWidget": true,
        },
        "ListElement": {
            "properties": {
                "property": {
                    "meta_properties": []
                },
            },
            "functions": [],
            "signals": [],
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
            "functions": [
                "append()",
                "clear()",
                "get()",
                "insert()",
                "move()",
                "remove()",
                "set()",
                "setProperty()",
                "sync()",
            ],
            "signals": [],
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
            "functions": [
                "decrementCurrentIndex()",
                "forceLayout()",
                "incrementCurrentIndex()",
                "indexAt()",
                "itemAt()",
                "positionViewAtBeginning()",
                "positionViewAtEnd()",
                "positionViewAtIndex()",
            ],
            "signals": [
                "add()",
                "remove()"
            ],
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
            "functions": [
                "setSource()"
            ],
            "signals": [
                "loaded()"
            ],
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
            "functions": [
                "actionAt()",
                "addAction()",
                "addItem()",
                "addMenu()",
                "dismiss()",
                "insertAction()",
                "insertItem()",
                "insertMenu()",
                "itemAt()",
                "menuAt()",
                "moveItem()",
                "popup()",
                "removeAction()",
                "removeItem()",
                "removeMenu()",
                "takeAction()",
                "takeItem()",
                "takeMenu()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [
                "triggered()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [
                "canceled()",
                "clicked()",
                "doubleClicked()",
                "entered()",
                "exited()",
                "positionChanged()",
                "pressAndHold()",
                "pressed()",
                "released()",
                "wheel()"
            ],
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
            "functions": [],
            "signals": [
                "pressed()",
                "released()",
            ],
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
            "functions": [
                "close()",
                "forceActiveFocus()",
                "open()",
            ],
            "signals": [
                "aboutToHide()",
                "aboutToShow()",
                "closed()",
                "opened()",
            ],
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
            "functions": [
                "atob()",
                "binding()",
                "btoa()",
                "callLater()",
                "colorEqual()",
                "createComponent()",
                "createQmlObject()",
                "darker()",
                "exit()",
                "font()",
                "fontFamilies()",
                "formatDate()",
                "formatDateTime()",
                "formatTime()",
                "hsla()",
                "hsva()",
                "include()",
                "isQtObject()",
                "lighter()",
                "locale()",
                "md5()",
                "matrix4x4()",
                "openUrlExteranlly()",
                "point()",
                "qsTr()",
                "qsTrId()",
                "qsTrIdNoOp()",
                "qsTranslate()",
                "qsTranslateNoOp()",
                "quanternion()",
                "quit()",
                "rect()",
                "resolvedUrl()",
                "rgba()",
                "size()",
                "tint()",
                "vector2d()",
                "vector3d()",
                "vector4d()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
            "inherits": "AbstractButton",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "itemAt()"
            ],
            "signals": [
                "itemAdded()",
                "itemRemoved()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "forceLayout()"
            ],
            "signals": [
                "positioningComplete()"
            ],
            "inherits": "Item",
            "source": ""
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
            "functions": [],
            "signals": [],
            "inherits": "item",
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "decrease()",
                "increase()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "setValue()",
                "value()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "clearAnchors()",
                "setAnchors()"
            ],
            "signals": [
                "clicked()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "isChecked()"
            ],
            "signals": [
                "clicked()"
            ],
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
            "functions": ["lerpColor()"],
            "signals": [],
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
            "functions": [
                "findWidth()",
                "colorMod()",
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "hueToRgbPowerSave()",
                "hsvToRgb()",
            ],
            "signals": [],
            "inherits": "Slider",
            "source": "tech.strata.sgwidgets 1.0",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "SGIcon": {
            "properties": {
                "aynchronous": {
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "selectAll()"
            ],
            "signals": [
                "accepted()",
                "editingFinished()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": ["hToRgb()"],
            "signals": [],
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
            "functions": [
                "userSetValue()",
                "increase()",
                "decrease()",
                "valueAt()",
            ],
            "signals": [
                "userSet()",
                "moved()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "onFilter()",
                "copySelectionTest()",
                "append()",
                "remove()",
                "updateMessageAtID()",
                "clear()",
            ],
            "signals": [],
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
            "functions": [
                "forceActiveFocus()",
                "selectAll()",
                "deselect()",
            ],
            "signals": [
                "accepted()",
                "editingFinished()",
            ],
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
            "functions": [
                "colorMod()"
            ],
            "signals": [
                "released()",
                "canceled()",
                "clicked()",
                "toggled()",
                "press()",
                "pressAndHold()",
            ],
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
                "showCursorPosition":  {
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
            "functions": [],
            "signals": [
                "suggestionsDelegateSelected()",
                "suggestionDelegateRemoveRequested()",
            ],
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
            "functions": [
                "writeFile()",
                "readFile()",
                "listFilesInDirectory()",
                "deleteFile()",
                "renameFile()",
            ],
            "signals": [
                "classIdChanged()",
                "userChanged()"
            ],
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
            "functions": [
                "decrease()",
                "increase()",
                "valueAt()"
            ],
            "signals": [
                "moved()"
            ],
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
            "functions": [
                "decrease()",
                "increase()"
            ],
            "signals": [
                "valueModified()"
            ],
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
            "functions": [
                "addItem()",
                "removeItem()"
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "clear()",
                "find()",
                "get()",
                "pop()",
                "push()",
                "replace()",
            ],
            "signals": [
                "activated()",
                "activating()",
                "deactivated()",
                "deactivatting()",
                "removed()",
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "addTab()",
                "getTab()",
                "insertTab()",
                "moveTab()",
                "removeTab()",
            ],
            "signals": [],
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
            "functions": [
                "forceLayout()",
                "linkAt()",
            ],
            "signals": [
                "lineLaidOut()",
                "linkActivated()",
                "linkHovered()",
            ],
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
            "functions": [],
            "signals": [
                "pressAndHold()",
                "pressed()",
                "released()",
            ],
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
            "functions": [
                "append()",
                "clear()",
                "copy()",
                "cut()",
                "deselect()",
                "getFormattedText()",
                "getText()",
                "insert()",
                "isRightToLeft()",
                "linkAt()",
                "moveCursorSelection()",
                "paste()",
                "positionAt()",
                "positionToRectangle()",
                "redo()",
                "remove()",
                "select()",
                "selectAll()",
                "selectWord()",
                "undo()",
            ],
            "signals": [
                "editingFinished()",
                "linkActivated(string link)",
                "linkHovered(string link)",
            ],
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
            "functions": [],
            "signals": [
                "pressAndHold()",
                "pressed()",
                "released()",
            ],
            "inherits": "TextInputs",
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
            "functions": [
                "clear()",
                "copy()",
                "cut()",
                "deselect()",
                "ensureVisible()",
                "getText()",
                "insert()",
                "isRightToLeft()",
                "moveCursorSelection()",
                "paste()",
                "positionAt()",
                "positionToRectangle()",
                "redo()",
                "remove()",
                "select()",
                "selectAll()",
                "undo()",
            ],
            "signals": [
                "accepted()",
                "editingFinished()",
                "textEdited()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "restart()",
                "start()",
                "stop()"
            ],
            "signals": [
                "triggered()"
            ],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
            "inherits": "Control",
            "source": "Controls",
            "nonInstantiable": false,
            "isVisualWidget": false,
        },
        "ToolButton": {
            "properties": {
                "property":{
                    "meta_properties": []
                }
            },
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [
                "hide()",
                "show()"
            ],
            "signals": [],
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
            "functions": [],
            "signals": [],
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
            "functions": [],
            "signals": [],
            "inherits": "Item",
            "source": "",
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
            "functions": [
                "alert()",
                "close()",
                "hide()",
                "lower()",
                "raise()",
                "requestActivate()",
                "show()",
                "showFullScreen()",
                "showMaximized()",
                "showMinimized()",
                "showNormal()",
            ],
            "signals": [
                "closing()"
            ],
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
    },"property": []
}
