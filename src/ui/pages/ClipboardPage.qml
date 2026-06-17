// src/ui/pages/ClipboardPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

AppPage {
    id: root

    property QtObject toast: null
    objectName: "clipboardPage"

    property string filterText: ""
    property int filterType: 0  // 0=全部, 1=文本, 2=图片, 3=文件

    AppConfirmDialog {
        id: clearConfirmDialog
        theme: root.theme
        parent: root
    }

    // Filter bar
    SoftCard {
        theme: root.theme
        Layout.fillWidth: true
        Layout.preferredHeight: 80

        RowLayout {
            anchors.fill: parent
            anchors.margins: root.theme.spacingMD
            spacing: root.theme.spacingMD

            TextField {
                Layout.fillWidth: true
                placeholderText: qsTr("搜索剪贴板历史…")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase

                background: Rectangle {
                    radius: root.theme.radiusMD
                    color: root.theme.backgroundColor
                }

                onTextChanged: root.filterText = text
            }

            AppComboBox {
                theme: root.theme
                Layout.preferredWidth: 120
                model: [qsTr("全部"), qsTr("文本"), qsTr("图片"), qsTr("文件")]
                currentIndex: root.filterType

                onActivated: function(index) {
                    root.filterType = index
                }
            }

            AppButton {
                theme: root.theme
                text: qsTr("清空")
                type: "danger"
                size: "sm"
                onClicked: {
                    clearConfirmDialog.openDialog(
                        qsTr("清空剪贴板"),
                        qsTr("确定要清空所有剪贴板历史记录吗？此操作不可恢复。"),
                        function() {
                            if (root.toast) root.toast.show(qsTr("剪贴板已清空"), "success")
                        }
                    )
                }
            }
        }
    }

    Text {
        text: qsTr("历史记录 (%1条)").arg(20)
        color: root.theme.textPrimary
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.h3Size
        font.weight: root.theme.h3Weight
    }

    // Empty state
    SoftCard {
        theme: root.theme
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        visible: false  // show when list is empty

        ColumnLayout {
            anchors.centerIn: parent
            spacing: root.theme.spacingMD

            Text {
                text: "\uD83D\uDCCB"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: qsTr("剪贴板为空")
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: qsTr("复制的文本、图片等内容将显示在这里")
                color: root.theme.textTertiary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Clipboard history list
    Repeater {
        model: 20

        delegate: AppListItem {
            required property int index

            theme: root.theme
            highlighted: index === 0

            iconText: ["文", "图", "文", "文", "图", "文", "文", "图", "文", "文",
                       "文", "图", "文", "文", "图", "文", "文", "文", "图", "文"][index]
            title: ["https://github.com/example/repo", "截图_20240115_143022.png",
                    "const handleClick = () => { ... }", "SELECT * FROM users WHERE id = 1",
                    "background-image: url('bg.jpg')", "git commit -m 'feat: add new feature'",
                    "npm install @anthropic-ai/sdk", "logo_final_v2.psd",
                    "import React from 'react';", "docker-compose up -d",
                    "ssh user@192.168.1.100", "photo_20240115.jpg",
                    "print('Hello, World!')", "curl -X POST https://api.example.com",
                    "meeting_notes.md", "export PATH=$PATH:/usr/local/bin",
                    "design_mockup.fig", "pip install pandas numpy",
                    "chmod +x deploy.sh", ".env.production"][index]
            subtitle: ["链接", "图片", "代码", "数据库", "样式", "命令", "包管理", "文件",
                       "代码", "容器", "网络", "图片", "代码", "API", "文档", "环境",
                       "设计", "Python", "脚本", "配置"][index]
            trailingText: ["14:30", "14:28", "14:15", "13:50", "13:45", "13:30",
                          "13:15", "12:50", "12:30", "12:15", "11:50", "11:30",
                          "11:15", "10:50", "10:30", "10:15", "09:50", "09:30",
                          "09:15", "08:50"][index]
            showCopyButton: true

            onClicked: {
                if (root.toast) root.toast.show(qsTr("已复制到剪贴板"), "success")
            }
            onCopyRequested: {
                if (root.toast) root.toast.show(qsTr("内容已复制"), "success")
            }
        }
    }

    Item { Layout.preferredHeight: root.theme.spacingMD }
}
