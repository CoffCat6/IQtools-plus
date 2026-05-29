// src/ui/pages/ClipboardPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "clipboardPage"

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: root.width
            spacing: root.theme.spacingLG

            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 96

                RowLayout {
                    spacing: root.theme.spacingMD

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: qsTr("搜索剪贴板历史…")

                        background: Rectangle {
                            radius: root.theme.radiusMD
                            color: root.theme.backgroundColor
                        }
                    }

                    ComboBox {
                        Layout.preferredWidth: 140
                        model: [qsTr("全部"), qsTr("文本"), qsTr("图片"), qsTr("文件")]
                    }

                    Button {
                        text: qsTr("清空")
                    }
                }
            }

            Text {
                text: qsTr("历史记录")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            // 剪贴板历史列表
            Repeater {
                model: 20

                delegate: Rectangle {
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    radius: root.theme.radiusMD
                    color: index === 0 ? root.theme.primarySoftColor : root.theme.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.theme.spacingMD
                        spacing: root.theme.spacingMD

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: root.theme.radiusMD
                            color: root.theme.backgroundColor

                            Text {
                                anchors.centerIn: parent
                                text: ["文", "图", "文", "文", "图", "文", "文", "图", "文", "文", "文", "图", "文", "文", "图", "文", "文", "文", "图", "文"][index]
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                                font.weight: root.theme.fontWeightBold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: ["https://github.com/example/repo", "截图_20240115_143022.png", "const handleClick = () => { ... }", "SELECT * FROM users WHERE id = 1", "background-image: url('bg.jpg')", "git commit -m 'feat: add new feature'", "npm install @anthropic-ai/sdk", "logo_final_v2.psd", "import React from 'react';", "docker-compose up -d", "ssh user@192.168.1.100", "photo_20240115.jpg", "print('Hello, World!')", "curl -X POST https://api.example.com", "meeting_notes.md", "export PATH=$PATH:/usr/local/bin", "design_mockup.fig", "pip install pandas numpy", "chmod +x deploy.sh", ".env.production"][index]
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.theme.fontWeightMedium
                                elide: Text.ElideRight
                            }

                            Text {
                                text: ["链接", "图片", "代码", "数据库", "样式", "命令", "包管理", "文件", "代码", "容器", "网络", "图片", "代码", "API", "文档", "环境", "设计", "Python", "脚本", "配置"][index] + " · " + ["14:30", "14:28", "14:15", "13:50", "13:45", "13:30", "13:15", "12:50", "12:30", "12:15", "11:50", "11:30", "11:15", "10:50", "10:30", "10:15", "09:50", "09:30", "09:15", "08:50"][index]
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                                elide: Text.ElideRight
                            }
                        }

                        // 复制按钮
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: root.theme.radiusSM
                            color: root.theme.backgroundColor

                            Text {
                                anchors.centerIn: parent
                                text: "📋"
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }

            // 底部间距
            Item {
                Layout.preferredHeight: root.theme.spacingMD
            }
        }
    }
}