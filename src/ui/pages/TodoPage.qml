// src/ui/pages/TodoPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

AppPage {
    id: root

    property QtObject toast: null
    objectName: "todoPage"

    property var todoItems: [
        { title: "完成项目文档编写", priority: "高", deadline: "今天截止", done: true },
        { title: "修复登录页面样式问题", priority: "中", deadline: "明天截止", done: true },
        { title: "添加单元测试", priority: "低", deadline: "本周截止", done: true },
        { title: "代码审查 PR #42", priority: "高", deadline: "下周截止", done: true },
        { title: "更新依赖版本", priority: "中", deadline: "今天截止", done: true },
        { title: "优化数据库查询", priority: "高", deadline: "明天截止", done: false },
        { title: "设计新功能原型", priority: "中", deadline: "本周截止", done: false },
        { title: "部署测试环境", priority: "低", deadline: "下周截止", done: false },
        { title: "处理用户反馈", priority: "高", deadline: "今天截止", done: false },
        { title: "编写 API 文档", priority: "中", deadline: "明天截止", done: false },
        { title: "重构支付模块", priority: "高", deadline: "本周截止", done: false },
        { title: "添加日志监控", priority: "中", deadline: "下周截止", done: false },
        { title: "修复移动端适配", priority: "低", deadline: "今天截止", done: false },
        { title: "性能优化", priority: "高", deadline: "明天截止", done: false },
        { title: "准备演示材料", priority: "中", deadline: "本周截止", done: false }
    ]

    // Header card
    SoftCard {
        theme: root.theme
        Layout.fillWidth: true
        Layout.preferredHeight: 100

        Text {
            text: qsTr("待办事项")
            color: root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.h2Size
            font.weight: root.theme.h2Weight
        }

        Text {
            text: qsTr("管理您的任务和待办事项，提高工作效率。")
            color: root.theme.textSecondary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeBase
            wrapMode: Text.WordWrap
        }
    }

    // Progress summary
    SoftCard {
        theme: root.theme
        Layout.fillWidth: true
        Layout.preferredHeight: 48

        RowLayout {
            anchors.fill: parent
            anchors.margins: root.theme.spacingMD
            spacing: root.theme.spacingSM

            Text {
                text: qsTr("已完成 %1 / %2").arg(5).arg(15)
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                font.weight: root.theme.fontWeightSemibold
            }

            Item { Layout.fillWidth: true }

            Text {
                text: qsTr("进度 %1%").arg(Math.round(5/15 * 100))
                color: root.theme.successColor
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                font.weight: root.theme.fontWeightBold
            }
        }
    }

    // Todo list
    Repeater {
        model: root.todoItems

        delegate: SoftCard {
            required property int index
            required property var modelData

            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            RowLayout {
                anchors.fill: parent
                anchors.margins: root.theme.spacingMD
                spacing: root.theme.spacingMD

                AppCheckbox {
                    theme: root.theme
                    checked: modelData.done
                    onToggled: function(checked) {
                        if (root.toast) {
                            root.toast.show(
                                checked ? qsTr('"%1" 已完成').arg(modelData.title)
                                        : qsTr('"%1" 已取消完成').arg(modelData.title),
                                "info"
                            )
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: modelData.title
                        color: modelData.done ? root.theme.textTertiary : root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        font.weight: root.theme.fontWeightMedium
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        spacing: root.theme.spacingSM
                        Text {
                            text: modelData.priority + qsTr("优先级")
                            color: modelData.priority === "高" ? root.theme.errorColor
                                   : (modelData.priority === "中" ? root.theme.warningColor
                                                                  : root.theme.textTertiary)
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                            font.weight: root.theme.fontWeightSemibold
                        }
                        Text {
                            text: "· " + modelData.deadline
                            color: root.theme.textTertiary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                        }
                    }
                }
            }
        }
    }

    Item { Layout.preferredHeight: root.theme.spacingMD }
}
