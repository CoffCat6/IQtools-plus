// src/ui/components/AppButton.qml
import QtQuick
import QtQuick.Controls
import "../theme"

Item {
    id: root

    required property QtObject theme
    property string text: ""
    property string type: "primary"   // primary | secondary | text | danger
    property string size: "md"        // sm | md | lg
    property bool loading: false
    property bool disabled: false
    property alias isHovered: mouseArea.containsMouse
    property bool fullWidth: false

    signal clicked()

    readonly property bool interactive: !disabled && !loading
    implicitWidth: {
        const sizeMap = { "sm": 120, "md": 160, "lg": 200 };
        return fullWidth ? 240 : (sizeMap[size] || 160);
    }
    implicitHeight: {
        const sizeMap = { "sm": 32, "md": 40, "lg": 48 };
        return sizeMap[size] || 40;
    }

    Accessible.role: Accessible.Button
    Accessible.name: text

    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: {
            const sizeMap = { "sm": theme.radiusSM, "md": theme.radiusMD, "lg": theme.radiusLG };
            return sizeMap[root.size];
        }
        border.width: root.type === "secondary" ? 1 : 0
        border.color: root.type === "secondary" ? theme.dividerColor
                      : (root.type === "danger" ? theme.errorColor : "transparent")

        color: {
            if (!root.interactive) return theme.disabledBackground;
            const isHover = mouseArea.containsMouse;
            switch (root.type) {
            case "primary":
                return isHover ? theme.primaryHoverColor : theme.primaryColor;
            case "danger":
                return isHover ? Qt.darker(theme.errorColor, 1.1) : theme.errorColor;
            case "secondary":
                return isHover ? theme.hoverOverlay : "transparent";
            case "text":
                return isHover ? theme.hoverOverlay : "transparent";
            default:
                return theme.primaryColor;
            }
        }

        Behavior on color { ColorAnimation { duration: theme.durationShort } }
    }

    // focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: bgRect.radius + 2
        color: "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: theme.focusRing
        z: 2
    }

    Row {
        anchors.centerIn: parent
        spacing: theme.spacingSM

        BusyIndicator {
            id: spinner
            visible: root.loading
            running: root.loading
            width: {
                const sizeMap = { "sm": 14, "md": 16, "lg": 20 };
                return sizeMap[root.size];
            }
            height: width
            anchors.verticalCenter: parent.verticalCenter
            palette.dark: root.type === "primary" || root.type === "danger"
                          ? theme.textOnPrimary : theme.textPrimary
        }

        Text {
            id: btnLabel
            text: root.text
            color: {
                if (!root.interactive) return theme.disabledText;
                switch (root.type) {
                case "primary":
                case "danger":
                    return theme.textOnPrimary;
                case "secondary":
                    return theme.primaryColor;
                case "text":
                    return theme.primaryColor;
                default:
                    return theme.textOnPrimary;
                }
            }
            font.family: theme.fontFamily
            font.pixelSize: {
                const sizeMap = { "sm": theme.fontSizeSM, "md": theme.fontSizeBase, "lg": theme.fontSizeLG };
                return sizeMap[root.size];
            }
            font.weight: theme.fontWeightSemibold
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        onClicked: {
            if (root.interactive) root.clicked();
        }
    }

    Keys.onReturnPressed: { if (root.interactive) root.clicked(); }
    Keys.onEnterPressed: { if (root.interactive) root.clicked(); }
    Keys.onSpacePressed: { if (root.interactive) root.clicked(); }

    // Loading placeholder scale animation
    function pressAnimation() {
        scaleAnimation.start();
    }
    ScaleAnimator on scale {
        id: scaleAnimation
        from: 1.0; to: 0.96
        duration: theme.durationShort
        running: false
        onFinished: root.scale = 1.0
    }
}
