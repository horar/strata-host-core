/* 
    This File contains portions of snippets.json that exists in https://github.com/ThomasVogelpohl/vsc-qml-snippets/blob/master/snippets/snippets.json
    This File is the base for mapping the auto complete, For CVC purposes this files auto complete will be limited in the number of QtQuick Objects but 
    detailed in the properties

    If we need to add more QtQuick Objects the format will be
    "<QtType>": {
        "properties":{
            "property":{
                "meta_propeties":[]
            },
        },
        "functions": [],
        "signals": [],
        "inherits": "",
        "source" : ""
    },
*/

const QtTypeJson = {
    "Abstract3DSeries": {
        "properties": {
            "property": {
                "meta_propeties": []
            },
        },
        "functions": [],
        "signals": [],
        "inherits": "",
        "source": ""
    },
    "AbstractActionInput": {
        "properties": {
            "property": {
                "meta_propeties": []
            },
        },
        "functions": [],
        "signals": [],
        "inherits": "",
        "source": ""
    },
    "AbstractAnimation": {
        "properties": {
            "property": {
                "meta_propeties": []
            },
        },
        "functions": [],
        "signals": [],
        "inherits": "",
        "source": ""
    },
    "AbstractAxis": {
        "properties": {
            "property": {
                "meta_propeties": []
            },
        },
        "functions": [],
        "signals": [],
        "inherits": "",
        "source": ""
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
            "childAt(real x, real y)",
            "bool contains(point point)",
            "forceActiveFocus(Qt::FocusReason reason)",
            "forceActiveFocus()",
            "bool grabToImage(callback, targetSize)",
            "object mapFromGlobal(real x, real y)",
            "object mapFromItem(Item item, rect r)",
            "object mapFromItem(Item item, real x, real y, real width, real height)",
            "object mapFromItem(Item item, real x, real y)",
            "object mapFromItem(Item item, point p)",
            "object mapToGlobal(real x, real y)",
            "object mapToItem(Item item, rect r)",
            "object mapToItem(Item item, real x, real y, real width, real height)",
            "object mapToItem(Item item, real x, real y)",
            "object mapToItem(Item item, point p)",
            "nextItemInFocusChain(bool forward)",
        ],
        "signals": [],
        "inherits": null,
        "source": "",
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
            "append(string text)",
            "clear()",
            "copy()",
            "cut()",
            "deselect()",
            "getFormattedText(int start, int end)",
            "getText(int start, int end)",
            "insert(int position, string text)",
            "isRightToLeft(int start, int end)",
            "linkAt(real x, real y)",
            "moveCursorSelection(int position, SelectionMode mode = TextEdit.SelectCharacters)",
            "paste()",
            "positionAt(int x, int y)",
            "positionToRectangle(position)",
            "redo()",
            "remove(int start, int end)",
            "select(int start, int end)",
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
        "Object": [
            "freeze()",
            "hasOwnProperty()",
            "entries()",
            "values()",
            "keys()",
        ],
        "property": [
            "alias",
            "real",
            "string",
            "url",
            "double",
            "int",
            "bool",
            "color",
            "var",
            "coordinate",
            "date",
            "default",
            "enumeration",
            "size",
            "point",
            "list",
            "vector2d",
            "vector3d",
            "rect",
            "palette"
        ],
        "signal": []
    }
}

const SGWidgetsTypeJson = {

}


/*
    Abstract3DSeries
    AbstractActionInput
    AbstractAnimation
    AbstractAxis
    AbstractAxis3D
    AbstractAxisInput
    AbstractBarSeries
    AbstractButton
    AbstractClipAnimator
    AbstractClipBlendNode
    AbstractDataProxy
    AbstractGraph3D
    AbstractInputHandler3D
    AbstractPhysicalDevice
    AbstractRayCaster
    AbstractSeries
    AbstractSkeleton
    AbstractTextureImage
    Accelerometer
    AccelerometerReading
    Accessible
    Action: QtQuickControls
    Action: Qt3D
    Action: QtQuickControls1
    ActionGroup
    ActionInput
    AdditiveClipBlend
    Address
    Affector
    Age
    AlphaCoverage
    AlphaTest
    Altimeter
    AltimeterReading
    AmbientLightReading
    AmbientLightSensor
    AmbientTemperatureReading
    AmbientTemperatureSensor
    AnalogAxisInput
    AnchorAnimation
    AnchorChanges
    AngleDirection
    AnimatedImage
    AnimatedSprite
    Animation
    AnimationController: QtQuick
    AnimationController: Qt3D
    AnimationGroup
    Animator
    ApplicationWindow: QtQuickControls
    ApplicationWindow: QtQuickControls1
    ApplicationWindowStyle
    AreaSeries
    Armature
    AttenuationModelInverse
    AttenuationModelLinear
    Attractor
    Attribute
    Audio
    AudioCategory
    AudioEngine
    AudioListener
    AudioSample
    AuthenticationDialogRequest
    Axis
    AxisAccumulator
    AxisSetting

B
    BackspaceKey
    Bar3DSeries
    BarCategoryAxis
    BarDataProxy
    Bars3D
    BarSeries
    BarSet
    BaseKey
    Behavior
    Binding
    Blend
    BlendedClipAnimator
    BlendEquation
    BlendEquationArguments
    BlitFramebuffer
    BluetoothDiscoveryModel
    BluetoothService
    BluetoothSocket
    BorderImage
    BorderImageMesh
    BoxPlotSeries
    BoxSet
    BrightnessContrast
    Buffer
    BusyIndicator: QtQuickControls
    BusyIndicator: QtQuickControls1
    BusyIndicatorStyle
    Button: QtQuickControls
    Button: QtQuickControls1
    ButtonAxisInput
    ButtonGroup
    ButtonStyle

C
    Calendar
    CalendarStyle
    Camera: QtMultimedia
    Camera: Qt3D
    Camera3D
    CameraCapabilities
    CameraCapture
    CameraExposure
    CameraFlash
    CameraFocus
    CameraImageProcessing
    CameraLens
    CameraRecorder
    CameraSelector
    CandlestickSeries
    CandlestickSet
    Canvas
    Canvas3D
    Canvas3DAbstractObject
    Canvas3DActiveInfo
    Canvas3DBuffer
    Canvas3DContextAttributes
    Canvas3DFrameBuffer
    Canvas3DProgram
    Canvas3DRenderBuffer
    Canvas3DShader
    Canvas3DShaderPrecisionFormat
    Canvas3DTexture
    Canvas3DTextureProvider
    Canvas3DUniformLocation
    CanvasGradient
    CanvasImageData
    CanvasPixelArray
    Category
    CategoryAxis
    CategoryAxis3D
    CategoryModel
    CategoryRange
    ChangeLanguageKey
    ChartView
    CheckBox: QtQuickControls
    CheckBoxStyle
    CheckDelegate
    CircularGauge
    CircularGaugeStyle
    ClearBuffers
    ClipAnimator
    ClipBlendValue
    ClipPlane
    CloseEvent
    ColorAnimation
    ColorDialog
    ColorDialogRequest
    ColorGradient
    ColorGradientStop
    Colorize
    ColorMask
    ColorOverlay
    Column
    ColumnLayout
    ComboBox: QtQuickControls
    ComboBoxStyle
    Compass
    CompassReading
    Component
    Component3D
    ComputeCommand
    ConeGeometry
    ConeMesh
    ConicalGradient: QtGraphicalEffects
    ConicalGradient: QtQuick
    Connections
    ContactDetail
    ContactDetails
    Container
    Context2D
    Context3D
    ContextMenuRequest
    Control
    coordinate
    CoordinateAnimation
    CuboidGeometry
    CuboidMesh
    CullFace
    CumulativeDirection
    Custom3DItem
    Custom3DLabel
    Custom3DVolume
    CustomParticle
    CylinderGeometry
    CylinderMesh

D
    Date
    date
    DateTimeAxis
    DelayButton: QtQuickControls
    DelayButton: QtQuickExtras
    DelayButtonStyle
    DelegateChoice
    DelegateChooser
    DelegateModel
    DelegateModelGroup
    DepthTest
    Desaturate
    Dial: QtQuickControls
    Dial: QtQuickExtras
    Dialog: QtQuickControls
    Dialog: QtQuickDialogs
    DialogButtonBox
    DialStyle
    DiffuseMapMaterial
    DiffuseSpecularMapMaterial
    DiffuseSpecularMaterial
    Direction
    DirectionalBlur
    DirectionalLight
    DispatchCompute
    Displace
    DistanceReading
    DistanceSensor
    Dithering
    double
    DoubleValidator
    Drag
    DragEvent
    DragHandler
    Drawer
    DropArea
    DropShadow
    DwmFeatures
    DynamicParameter

E
    EditorialModel
    Effect
    EllipseShape
    Emitter
    EnterKey: QtQuick
    EnterKey: QtVirtualKeyboard
    EnterKeyAction
    Entity
    EntityLoader
    enumeration
    EnvironmentLight
    EventConnection
    EventPoint
    EventTouchPoint
    ExclusiveGroup
    ExtendedAttributes
    ExtrudedTextGeometry
    ExtrudedTextMesh

F
    FastBlur
    FileDialog
    FileDialogRequest
    FillerKey
    FilterKey
    FinalState
    FirstPersonCameraController
    Flickable
    Flipable
    Flow
    FocusScope
    FolderListModel
    font
    FontDialog
    FontLoader
    FontMetrics
    FormValidationMessageRequest
    ForwardRenderer
    Frame
    FrameAction
    FrameGraphNode
    Friction
    FrontFace
    FrustumCulling
    FullScreenRequest

G
    Gamepad
    GamepadManager
    GammaAdjust
    Gauge
    GaugeStyle
    GaussianBlur
    geocircle
    GeocodeModel
    Geometry
    GeometryRenderer
    geopath
    geopolygon
    georectangle
    geoshape
    GestureEvent
    Glow
    GLStateDumpExt
    GoochMaterial
    Gradient
    GradientStop
    GraphicsApiFilter
    GraphicsInfo
    Gravity
    Grid
    GridLayout
    GridMesh
    GridView
    GroupBox: QtQuickControls
    GroupBox: QtQuickControls1
    GroupGoal
    Gyroscope
    GyroscopeReading

H
    HandlerPoint
    HandwritingInputPanel
    HandwritingModeKey
    HBarModelMapper
    HBoxPlotModelMapper
    HCandlestickModelMapper
    HeightMapSurfaceDataProxy
    HideKeyboardKey
    HistoryState
    HolsterReading
    HolsterSensor
    HorizontalBarSeries
    HorizontalPercentBarSeries
    HorizontalStackedBarSeries
    HoverHandler
    HPieModelMapper
    HueSaturation
    HumidityReading
    HumiditySensor
    HXYModelMapper

I
    Icon
    Image
    ImageModel
    ImageParticle
    InnerShadow
    InputChord
    InputContext
    InputEngine
    InputHandler3D
    InputMethod
    InputModeKey
    InputPanel
    InputSequence
    InputSettings
    Instantiator
    int
    IntValidator
    InvokedServices
    IRProximityReading
    IRProximitySensor
    Item
    ItemDelegate
    ItemGrabResult
    ItemModelBarDataProxy
    ItemModelScatterDataProxy
    ItemModelSurfaceDataProxy
    ItemParticle
    ItemSelectionModel
    IviApplication
    IviSurface

J
    JavaScriptDialogRequest
    Joint
    JumpList
    JumpListCategory
    JumpListDestination
    JumpListLink
    JumpListSeparator

K
    Key
    KeyboardColumn
    KeyboardDevice
    KeyboardHandler
    KeyboardLayout
    KeyboardLayoutLoader
    KeyboardRow
    KeyboardStyle
    KeyEvent: QtQuick
    KeyEvent: Qt3D
    KeyframeAnimation
    KeyIcon
    KeyNavigation
    KeyPanel
    Keys

L
    Label: QtQuickControls
    Label: QtQuickControls1
    Layer
    LayerFilter
    Layout
    LayoutMirroring
    Legend
    LerpClipBlend
    LevelAdjust
    LevelOfDetail
    LevelOfDetailBoundingSphere
    LevelOfDetailLoader
    LevelOfDetailSwitch
    LidReading
    LidSensor
    Light
    Light3D
    LightReading
    LightSensor
    LinearGradient: QtGraphicalEffects
    LinearGradient: QtQuick
    LineSeries
    LineShape
    LineWidth
    list
    ListElement
    ListModel
    ListView
    Loader
    Locale
    Location
    LoggingCategory
    LogicalDevice
    LogValueAxis
    LogValueAxis3DFormatter

M
    Magnetometer
    MagnetometerReading
    Map
    MapCircle
    MapCircleObject
    MapCopyrightNotice
    MapGestureArea
    MapIconObject
    MapItemGroup
    MapItemView
    MapObjectView
    MapParameter
    MapPinchEvent
    MapPolygon
    MapPolygonObject
    MapPolyline
    MapPolylineObject
    MapQuickItem
    MapRectangle
    MapRoute
    MapRouteObject
    MapType
    Margins
    MaskedBlur
    MaskShape
    Material
    Matrix4x4
    MediaPlayer
    mediaplayer-qml-dynamic
    MemoryBarrier
    Menu: QtQuickControls
    Menu: QtQuickControls1
    MenuBar: QtQuickControls
    MenuBar: QtQuickControls1
    MenuBarItem
    MenuBarStyle
    MenuItem: QtQuickControls
    MenuItem: QtQuickControls1
    MenuSeparator: QtQuickControls
    MenuSeparator: QtQuickControls1
    MenuStyle
    Mesh
    MessageDialog
    MetalRoughMaterial
    ModeKey
    MorphingAnimation
    MorphTarget
    MouseArea
    MouseDevice
    MouseEvent: QtQuick
    MouseEvent: Qt3D
    MouseHandler
    MultiPointHandler
    MultiPointTouchArea
    MultiSampleAntiAliasing

N
    Navigator
    NdefFilter
    NdefMimeRecord
    NdefRecord
    NdefTextRecord
    NdefUriRecord
    NearField
    Node: Qt3D
    Node: QtRemoteObjects
    NodeInstantiator
    NoDepthMask
    NoDraw
    NormalDiffuseMapAlphaMaterial
    NormalDiffuseMapMaterial
    NormalDiffuseSpecularMapMaterial
    Number
    NumberAnimation
    NumberKey

O
    Object3D
    ObjectModel
    ObjectPicker
    OpacityAnimator
    OpacityMask
    OpenGLInfo
    OrbitCameraController
    OrientationReading
    OrientationSensor
    Overlay

P
    Package
    Page
    PageIndicator
    palette
    Pane
    ParallelAnimation
    Parameter
    ParentAnimation
    ParentChange
    Particle
    ParticleGroup
    ParticlePainter
    ParticleSystem
    Path
    PathAngleArc
    PathAnimation
    PathArc
    PathAttribute
    PathCubic
    PathCurve
    PathElement
    PathInterpolator
    PathLine
    PathMove
    PathPercent
    PathQuad
    PathSvg
    PathView
    PauseAnimation
    PercentBarSeries
    PerVertexColorMaterial
    PhongAlphaMaterial
    PhongMaterial
    PickEvent
    PickingSettings
    PickLineEvent
    PickPointEvent
    PickTriangleEvent
    Picture
    PieMenu
    PieMenuStyle
    PieSeries
    PieSlice
    PinchArea
    PinchEvent
    PinchHandler
    Place
    PlaceAttribute
    PlaceSearchModel
    PlaceSearchSuggestionModel
    PlaneGeometry
    PlaneMesh
    Playlist
    PlaylistItem
    PlayVariation
    Plugin
    PluginParameter
    point
    PointDirection
    PointerDevice
    PointerDeviceHandler
    PointerEvent
    PointerHandler
    PointHandler
    PointLight
    PointSize
    PolarChartView
    PolygonOffset
    Popup
    Position
    Positioner
    PositionSource
    PressureReading
    PressureSensor
    Product
    ProgressBar: QtQuickControls
    ProgressBar: QtQuickControls1
    ProgressBarStyle
    PropertyAction
    PropertyAnimation
    PropertyChanges
    ProximityFilter
    ProximityReading
    ProximitySensor

Q
    QAbstractState
    QAbstractTransition
    QmlSensors
    QSignalTransition
    Qt
    QtMultimedia
    QtObject
    QtPositioning
    quaternion
    QuaternionAnimation
    QuotaRequest

R
    RadialBlur
    RadialGradient: QtGraphicalEffects
    RadialGradient: QtQuick
    Radio
    RadioButton: QtQuickControls
    RadioButton: QtQuickControls1
    RadioButtonStyle
    RadioData
    RadioDelegate
    RangeSlider
    Ratings
    RayCaster
    Rectangle
    RectangleShape
    RectangularGlow
    RecursiveBlur
    RegExpValidator
    RegisterProtocolHandlerRequest
    RenderCapture
    RenderCaptureReply
    RenderPass
    RenderPassFilter
    RenderSettings
    RenderState
    RenderStateSet
    RenderSurfaceSelector
    RenderTarget
    RenderTargetOutput
    RenderTargetSelector
    Repeater
    ReviewModel
    Rotation
    RotationAnimation
    RotationAnimator
    RotationReading
    RotationSensor
    RoundButton
    Route
    RouteLeg
    RouteManeuver
    RouteModel
    RouteQuery
    RouteSegment
    Row
    RowLayout

S
    Scale
    ScaleAnimator
    Scatter3D
    Scatter3DSeries
    ScatterDataProxy
    ScatterSeries
    Scene2D
    Scene3D: Qt3D
    Scene3D: QtDataVisualization
    SceneLoader
    ScissorTest
    Screen
    ScreenRayCaster
    ScriptAction
    ScrollBar
    ScrollIndicator
    ScrollView: QtQuickControls
    ScrollView: QtQuickControls1
    ScrollViewStyle
    ScxmlStateMachine
    SeamlessCubemap
    SelectionListItem
    SelectionListModel
    Sensor
    SensorGesture
    SensorReading
    SequentialAnimation
    Settings
    SettingsStore
    ShaderEffect
    ShaderEffectSource
    ShaderProgram
    ShaderProgramBuilder
    Shape: QtQuick
    Shape: QtQuick
    ShapeGradient
    ShapePath
    ShellSurface
    ShellSurfaceItem
    ShiftHandler
    ShiftKey
    Shortcut
    SignalSpy
    SignalTransition
    SinglePointHandler
    size
    Skeleton
    SkeletonLoader
    SkyboxEntity
    Slider: QtQuickControls
    Slider: QtQuickControls1
    SliderStyle
    SmoothedAnimation
    SortPolicy
    Sound
    SoundEffect
    SoundInstance
    SpaceKey
    SphereGeometry
    SphereMesh
    SpinBox: QtQuickControls
    SpinBox: QtQuickControls1
    SpinBoxStyle
    SplineSeries
    SplitView
    SpotLight
    SpringAnimation
    Sprite
    SpriteGoal
    SpriteSequence
    Stack
    StackedBarSeries
    StackLayout
    StackView: QtQuickControls
    StackView: QtQuickControls1
    StackViewDelegate
    State: QtQml
    State: QtQuick
    StateChangeScript
    StateGroup
    StateMachine
    StateMachineLoader
    StatusBar
    StatusBarStyle
    StatusIndicator
    StatusIndicatorStyle
    StencilMask
    StencilOperation
    StencilOperationArguments
    StencilTest
    StencilTestArguments
    Store
    String
    string
    Supplier
    Surface3D
    Surface3DSeries
    SurfaceDataProxy
    SwipeDelegate
    SwipeView
    Switch: QtQuickControls
    Switch: QtQuickControls1
    SwitchDelegate
    SwitchStyle
    SymbolModeKey
    SystemPalette

T
    Tab
    TabBar
    TabButton
    TableView: QtQuick
    TableView: QtQuickControls1
    TableViewColumn
    TableViewStyle
    TabView
    TabViewStyle
    TapHandler
    TapReading
    TapSensor
    TargetDirection
    TaskbarButton
    Technique
    TechniqueFilter
    TestCase
    Text
    Text2DEntity
    TextArea: QtQuickControls
    TextArea: QtQuickControls1
    TextAreaStyle
    TextEdit
    TextField: QtQuickControls
    TextField: QtQuickControls1
    TextFieldStyle
    TextInput
    TextMetrics
    TextureImage: Qt3D
    TextureImage: QtCanvas3D
    TextureImageFactory
    TextureLoader
    Theme3D
    ThemeColor
    ThresholdMask
    ThumbnailToolBar
    ThumbnailToolButton
    TiltReading
    TiltSensor
    TimeoutTransition
    Timer
    ToggleButton
    ToggleButtonStyle
    ToolBar: QtQuickControls
    ToolBar: QtQuickControls1
    ToolBarStyle
    ToolButton: QtQuickControls
    ToolButton: QtQuickControls1
    ToolSeparator
    ToolTip
    Torch
    TorusGeometry
    TorusMesh
    TouchEventSequence
    TouchInputHandler3D
    TouchPoint
    Trace
    TraceCanvas
    TraceInputArea
    TraceInputKey
    TraceInputKeyPanel
    TrailEmitter
    Transaction
    Transform: QtQuick
    Transform: Qt3D
    Transition
    Translate
    TreeView
    TreeViewStyle
    Tumbler: QtQuickControls
    Tumbler: QtQuickExtras
    TumblerColumn
    TumblerStyle
    Turbulence

U
    UniformAnimator
    url
    User

V
    ValueAxis
    ValueAxis3D
    ValueAxis3DFormatter
    var
    variant
    VBarModelMapper
    VBoxPlotModelMapper
    VCandlestickModelMapper
    vector2d
    vector3d
    Vector3dAnimation
    vector4d
    VertexBlendAnimation
    Video
    VideoOutput
    Viewport
    ViewTransition
    VirtualKeyboardSettings
    VPieModelMapper
    VXYModelMapper

W
    Wander
    WavefrontMesh
    WaylandClient
    WaylandCompositor
    WaylandHardwareLayer
    WaylandOutput
    WaylandQuickItem
    WaylandSeat
    WaylandSurface
    WaylandView
    Waypoint
    WebChannel
    WebEngine
    WebEngineAction
    WebEngineCertificateError
    WebEngineDownloadItem
    WebEngineHistory
    WebEngineHistoryListModel
    WebEngineLoadRequest
    WebEngineNavigationRequest
    WebEngineNewViewRequest
    WebEngineProfile
    WebEngineScript
    WebEngineSettings
    WebEngineView
    WebSocket
    WebSocketServer
    WebView
    WebViewLoadRequest
    WheelEvent: QtQuick
    WheelEvent: Qt3D
    Window
    WlShell
    WlShellSurface
    WorkerScript

X
    XAnimator
    XdgDecorationManagerV1
    XdgPopup
    XdgPopupV5
    XdgPopupV6
    XdgShell
    XdgShellV5
    XdgShellV6
    XdgSurface
    XdgSurfaceV5
    XdgSurfaceV6
    XdgToplevel
    XdgToplevelV6
    XmlListModel
    XmlRole
    XYPoint
    XYSeries

Y
    YAnimator

Z
    ZoomBlur
*/