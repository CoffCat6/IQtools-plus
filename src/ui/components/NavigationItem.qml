// src/ui/components/NavigationItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property QtObject theme
    required property string title
    required property string badgeText
    required property int pageIndex
    required property int currentIndex
    property bool collapsed: false

    signal triggered(int pageIndex)

    implicitHeight: 44
    focus: true
    Accessible.role: Accessible.Button
    Accessible.name: title

    readonly property bool selected: currentIndex === pageIndex

    // 背景高亮
    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: root.theme.spacingXS
        anchors.rightMargin: root.theme.spacingXS
        radius: root.theme.radiusMD
        color: root.selected
               ? root.theme.primarySoftColor
               : (mouseArea.containsMouse ? root.theme.surfaceColor : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: root.theme.durationShort
            }
        }
    }

    // 左侧选中指示条
    Rectangle {
        visible: root.selected
        width: 3
        height: parent.height * 0.4
        anchors.left: parent.left
        anchors.leftMargin: root.theme.spacingXS
        anchors.verticalCenter: parent.verticalCenter
        radius: 1.5
        color: root.theme.primaryColor

        Behavior on opacity {
            NumberAnimation {
                duration: root.theme.durationShort
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: root.theme.spacingXS
        anchors.rightMargin: root.theme.spacingXS

        // 折叠态：badge 完全居中
        // 展开态：左对齐 RowLayout
        Rectangle {
            visible: root.collapsed
            width: 32
            height: 32
            radius: root.theme.radiusMD
            anchors.centerIn: parent
            color: root.selected ? root.theme.primaryColor : root.theme.surfaceColor

            Text {
                anchors.centerIn: parent
                text: root.badgeText
                color: root.selected ? "#FFFFFF" : root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeSM
                font.weight: root.theme.fontWeightBold
            }
        }

        RowLayout {
            visible: !root.collapsed
            anchors.fill: parent
            anchors.leftMargin: root.theme.spacingMD
            anchors.rightMargin: root.theme.spacingMD
            spacing: root.theme.spacingMD

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: root.theme.radiusMD
                color: root.selected ? root.theme.primaryColor : root.theme.surfaceColor

                Text {
                    anchors.centerIn: parent
                    text: root.badgeText
                    color: root.selected ? "#FFFFFF" : root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightBold
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.selected ? root.theme.primaryColor : root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                font.weight: root.selected ? root.theme.fontWeightSemibold : root.theme.fontWeightMedium
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered(root.pageIndex)
    }

    ToolTip.visible: root.collapsed && mouseArea.containsMouse
    ToolTip.text: root.title
    ToolTip.delay: 400

    Keys.onReturnPressed: root.triggered(root.pageIndex)
    Keys.onEnterPressed: root.triggered(root.pageIndex)
    Keys.onSpacePressed: root.triggered(root.pageIndex)
}
