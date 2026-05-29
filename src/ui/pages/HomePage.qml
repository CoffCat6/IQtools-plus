// src/ui/pages/HomePage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    required property QtObject viewModel
    property var navigateTo: function(index) {}

    objectName: "homePage"

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: root.width
            spacing: root.theme.spacingLG

            // ── 搜索框 ─────────────────────────────────────────────────
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                implicitHeight: 56

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: root.theme.spacingMD

                    Text {
                        text: "🔍"
                        font.pixelSize: 18
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: qsTr("搜索功能、设置、页面…")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase

                        background: Rectangle {
                            radius: root.theme.radiusMD
                            color: "transparent"
                        }

                        onAccepted: {
                            console.log("[HomePage] Search:", searchField.text)
                        }
                    }
                }
            }

            // ── 欢迎标语 ─────────────────────────────────────────────
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                implicitHeight: 120

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.theme.spacingSM

                    Text {
                        text: root.viewModel.welcomeMessage
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize2XL
                        font.weight: root.theme.fontWeightBold
                    }

                    Text {
                        text: qsTr("选择功能开始使用，或使用上方搜索框快速定位。")
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // ── 快捷功能 ─────────────────────────────────────────────
            Text {
                text: qsTr("快捷功能")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: root.theme.spacingMD
                rowSpacing: root.theme.spacingMD

                // 翻译
                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "🌐"
                    title: qsTr("翻译")
                    description: qsTr("多引擎翻译、语言切换")
                    onClicked: root.navigateTo(1)
                }

                // 剪贴板
                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "📋"
                    title: qsTr("剪贴板")
                    description: qsTr("历史记录、搜索过滤")
                    onClicked: root.navigateTo(2)
                }

                // 截图
                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "📷"
                    title: qsTr("截图")
                    description: qsTr("区域截图、延时截图")
                    onClicked: root.navigateTo(3)
                }

                // 待办
                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "✓"
                    title: qsTr("待办")
                    description: qsTr("任务管理与工作计划")
                    onClicked: root.navigateTo(4)
                }
            }

            // ── 实用工具 ─────────────────────────────────────────────
            Text {
                text: qsTr("实用工具")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: root.theme.spacingMD
                rowSpacing: root.theme.spacingMD

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "🔢"
                    title: qsTr("计算器")
                    description: qsTr("科学计算、单位换算")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "🎨"
                    title: qsTr("颜色拾取")
                    description: qsTr("屏幕取色、色值转换")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "{}"
                    title: qsTr("JSON 工具")
                    description: qsTr("格式化、校验、树形预览")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "🔐"
                    title: qsTr("编码转换")
                    description: qsTr("Base64、URL 编解码")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "🔑"
                    title: qsTr("密码生成")
                    description: qsTr("强度可选、一键复制")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "📄"
                    title: qsTr("OCR 识别")
                    description: qsTr("图片文字识别")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "▦"
                    title: qsTr("二维码")
                    description: qsTr("生成与识别二维码")
                    comingSoon: true
                }

                ShortcutCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    icon: "📝"
                    title: qsTr("Markdown")
                    description: qsTr("编写与实时渲染")
                    comingSoon: true
                }
            }

            // ── 系统信息 ─────────────────────────────────────────────
            Text {
                text: qsTr("系统信息")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.spacingLG

                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: root.theme.spacingSM

                        Text {
                            text: qsTr("当前版本")
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                            font.weight: root.theme.fontWeightSemibold
                        }

                        Text {
                            text: root.viewModel.appVersion
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeLG
                            font.weight: root.theme.fontWeightSemibold
                        }
                    }
                }

                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: root.theme.spacingSM

                        Text {
                            text: qsTr("构建信息")
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                            font.weight: root.theme.fontWeightSemibold
                        }

                        Text {
                            text: root.viewModel.buildDate
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeLG
                            font.weight: root.theme.fontWeightSemibold
                        }
                    }
                }

                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: root.theme.spacingSM

                        Text {
                            text: qsTr("功能总数")
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                            font.weight: root.theme.fontWeightSemibold
                        }

                        Text {
                            text: qsTr("4 个页面 · 8 个工具")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeLG
                            font.weight: root.theme.fontWeightSemibold
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
