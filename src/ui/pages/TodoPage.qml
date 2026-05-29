// src/ui/pages/TodoPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "TodoPage"

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: root.width
            spacing: root.theme.spacingLG

            // 顶部提示卡片
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                implicitHeight: 120

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.theme.spacingSM

                    Text {
                        text: qsTr("待办事项")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize2XL
                        font.weight: root.theme.fontWeightBold
                    }

                    Text {
                        text: qsTr("管理您的任务和待办事项，提高工作效率。")
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // 示例待办列表
            Repeater {
                model: 15

                delegate: SoftCard {
                    required property int index

                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.theme.spacingMD
                        spacing: root.theme.spacingMD

                        // 复选框占位
                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 4
                            color: root.theme.surfaceColor
                            border.width: 2
                            border.color: root.theme.dividerColor

                            Text {
                                anchors.centerIn: parent
                                text: index < 5 ? "✓" : ""
                                color: root.theme.primaryColor
                                font.pixelSize: 14
                            }
                        }

                        // 任务内容
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: ["完成项目文档编写", "修复登录页面样式问题", "添加单元测试", "代码审查 PR #42", "更新依赖版本", "优化数据库查询", "设计新功能原型", "部署测试环境", "处理用户反馈", "编写 API 文档", "重构支付模块", "添加日志监控", "修复移动端适配", "性能优化", "准备演示材料"][index]
                                color: index < 5 ? root.theme.textTertiary : root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.theme.fontWeightMedium
                            }

                            Text {
                                text: ["高优先级", "中优先级", "低优先级", "高优先级", "中优先级"][index % 5] + " · " + ["今天截止", "明天截止", "本周截止", "下周截止"][index % 4]
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
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
