// src/ui/components/NavigationItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    required property QtObject theme
    required property string title
    required property string badgeText
    required property int pageIndex
    required property int currentIndex
    property bool collapsed: false
    property bool hasNotification: false

    signal triggered(int pageIndex)

    implicitHeight: 44
    focus: true
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: title

    readonly property bool selected: currentIndex === pageIndex

    // 背景高亮
    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: theme.spacingXS
        anchors.rightMargin: theme.spacingXS
        radius: theme.radiusMD
        color: root.selected
               ? theme.primarySoftColor
               : (mouseArea.containsMouse ? theme.surfaceColor : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: theme.durationShort
            }
        }
    }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: theme.radiusMD + 2
        color: "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: theme.focusRing
    }

    // 左侧选中指示条
    Rectangle {
        visible: root.selected
        width: 3
        height: parent.height * 0.4
        anchors.left: parent.left
        anchors.leftMargin: theme.spacingXS
        anchors.verticalCenter: parent.verticalCenter
        radius: 1.5
        color: theme.primaryColor

        Behavior on opacity {
            NumberAnimation {
                duration: theme.durationShort
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: theme.spacingXS
        anchors.rightMargin: theme.spacingXS

        // 折叠态：badge 完全居中
        Rectangle {
            visible: root.collapsed
            width: 32
            height: 32
            radius: theme.radiusMD
            anchors.centerIn: parent
            color: root.selected ? theme.primaryColor : theme.surfaceColor

            Text {
                anchors.centerIn: parent
                text: root.badgeText
                color: root.selected ? theme.textOnPrimary : theme.textSecondary
                font.family: theme.fontFamily
                font.pixelSize: theme.fontSizeSM
                font.weight: theme.fontWeightBold
            }
        }

        // Notification dot (collapsed mode)
        Rectangle {
            visible: root.collapsed && root.hasNotification && !root.selected
            width: 8
            height: 8
            radius: 4
            color: theme.errorColor
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 4
            anchors.rightMargin: 2
        }

        // 展开态：左对齐 RowLayout
        RowLayout {
            visible: !root.collapsed
            anchors.fill: parent
            anchors.leftMargin: theme.spacingMD
            anchors.rightMargin: theme.spacingMD
            spacing: theme.spacingMD

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: theme.radiusMD
                color: root.selected ? theme.primaryColor : theme.surfaceColor

                Text {
                    anchors.centerIn: parent
                    text: root.badgeText
                    color: root.selected ? theme.textOnPrimary : theme.textSecondary
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSizeSM
                    font.weight: theme.fontWeightBold
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.selected ? theme.primaryColor : theme.textPrimary
                font.family: theme.fontFamily
                font.pixelSize: theme.fontSizeBase
                font.weight: root.selected ? theme.fontWeightSemibold : theme.fontWeightMedium
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            // Notification dot (expanded mode)
            Rectangle {
                visible: root.hasNotification && !root.selected
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: theme.errorColor
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered(root.pageIndex)
        onPressed: root.forceActiveFocus()
    }

    ToolTip.visible: root.collapsed && mouseArea.containsMouse
    ToolTip.text: root.title
    ToolTip.delay: 400

    Keys.onReturnPressed: root.triggered(root.pageIndex)
    Keys.onEnterPressed: root.triggered(root.pageIndex)
    Keys.onSpacePressed: root.triggered(root.pageIndex)
}
