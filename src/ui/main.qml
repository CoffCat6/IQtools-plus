import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    width: 1280
    height: 800
    visible: true
    title: qsTr("IQtoolsPlus")
    color: "#f5f7fb"

    header: ToolBar {
        contentHeight: 52

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Label {
                text: qsTr("IQtoolsPlus")
                font.pixelSize: 20
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Project skeleton initialized")
                color: "#52606d"
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Directory structure and CMake skeleton are ready")
            font.pixelSize: 28
            font.bold: true
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Next step: implement screenshot, clipboard, translation, and plugin modules.")
            color: "#52606d"
        }
    }
}
