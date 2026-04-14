# QML 开发主题规范 —— Soft UI 风格

> 版本：v1.0.0 | 设计风格：Soft UI（柔和界面风格）| 更新日期：2025-04  
> 基于：《ToolBox 应用 — 团队开发技术规范文档》v1.0.0

---

## 目录

1. [主题概述](#1-主题概述)
2. [设计哲学](#2-设计哲学)
3. [设计代币系统](#3-设计代币系统)
4. [色彩规范](#4-色彩规范)
5. [排版规范](#5-排版规范)
6. [间距与布局](#6-间距与布局)
7. [圆角与阴影](#7-圆角与阴影)
8. [动画与交互](#8-动画与交互)
9. [组件规范](#9-组件规范)
10. [页面布局模式](#10-页面布局模式)
11. [暗黑模式](#11-暗黑模式)
12. [禁止模式](#12-禁止模式)
13. [最佳实践](#13-最佳实践)
14. [代码示例](#14-代码示例)
15. [可访问性](#15-可访问性)

---

## 1. 主题概述

### 1.1 设计目标

Soft UI 是一种**温和友好**的界面风格，强调：

- **柔和性**：圆润的边角、柔和的阴影、低饱和度的配色
- **亲和力**：消除用户紧张感，营造放松、愉悦的视觉体验
- **易用性**：清晰的视觉层级、直观的交互反馈
- **现代感**：简洁的设计、微妙的动画、精致的细节

### 1.2 适用场景

✅ **推荐使用**：
- 消费类应用（工具、生活服务）
- 创意类产品（设计、内容创作）
- 社交应用
- 生产力工具（如 ToolBox）

❌ **不推荐使用**：
- 高强度数据分析工具
- 金融交易平台
- 军事/工业控制系统

### 1.3 核心原则

| 原则 | 说明 |
|------|------|
| 圆润优先 | 所有可见元素优先使用圆角 |
| 阴影叠加 | 用阴影表达层级，而非边框 |
| 低饱和度 | 避免鲜艳纯色，采用柔和色调 |
| 白空间 | 充足的白空间让界面透气 |
| 微妙动画 | 动画应该补充而非主导交互 |
| 无边框 | 禁止硬边框，全部用阴影 |

---

## 2. 设计哲学

### 2.1 Soft UI vs. 其他风格

```
┌─────────────────┬──────────────┬──────────────┬──────────────┐
│    特性         │  Soft UI     │  Flat Design │  Material    │
├─────────────────┼──────────────┼──────────────┼──────────────┤
│ 边框            │ ❌ 禁止      │ ❌ 禁止      │ ✅ 可选      │
│ 阴影            │ ✅ 柔和      │ ❌ 禁止      │ ✅ 分层      │
│ 边角            │ ✅ 圆润      │ ✅ 直角      │ ✅ 圆角      │
│ 配色            │ 低饱和度     │ 高对比度     │ 高饱和度     │
│ 动画            │ 微妙流畅     │ 最小化       │ 强调反馈     │
│ 目标用户        │ 消费/创意    │ 现代/极简    │ 专业/系统    │
└─────────────────┴──────────────┴──────────────┴──────────────┘
```

### 2.2 设计原则详解

#### 原则一：友好感优先

用户第一眼的感受决定了产品的第一印象。

```qml
// ❌ 错误：硬邦邦、不友好
Rectangle {
    color: "#000000"
    border.color: "#333333"
    border.width: 2
    radius: 0
}

// ✅ 正确：柔和、友好
Rectangle {
    color: "#FFFFFF"
    radius: 24
    
    shadow {
        color: "#000000"
        opacity: 0.1
        blur: 16
        yOffset: 4
    }
}
```

#### 原则二：层级通过阴影表达

不使用边框表达分离，而是用阴影表达元素深度。

```
背景 → 卡片 → 浮动按钮
深度递进，用阴影强化
```

#### 原则三：白空间是设计的一部分

充足的留白让界面呼吸，避免压抑感。

```
推荐间距：24px / 32px / 48px
避免间距：2px / 4px / 8px
```

---

## 3. 设计代币系统

### 3.1 核心代币

```qml
// src/ui/theme/SoftUITokens.qml

pragma Singleton
import QtQuick

QtObject {
    // ── 色彩代币 ────────────────────────────────────────────────────────
    readonly property color colorPrimaryBase:     "#5B63F5"
    readonly property color colorPrimaryLight:    "#E8EBFD"
    readonly property color colorPrimaryDark:     "#3D42B5"
    
    readonly property color colorSuccessBase:     "#2DA44E"
    readonly property color colorSuccessLight:    "#D3F9D8"
    readonly property color colorErrorBase:       "#DC3545"
    readonly property color colorErrorLight:      "#FFE7EB"
    readonly property color colorWarningBase:     "#F59E0B"
    readonly property color colorWarningLight:    "#FEF3C7"
    
    readonly property color colorNeutralWhite:    "#FFFFFF"
    readonly property color colorNeutral50:       "#F9FAFB"
    readonly property color colorNeutral100:      "#F3F4F6"
    readonly property color colorNeutral200:      "#E5E7EB"
    readonly property color colorNeutral400:      "#9CA3AF"
    readonly property color colorNeutral600:      "#4B5563"
    readonly property color colorNeutral900:      "#111827"
    
    // ── 间距代币 ────────────────────────────────────────────────────────
    readonly property int spacingXS:  4
    readonly property int spacingSM:  8
    readonly property int spacingMD:  16
    readonly property int spacingLG:  24
    readonly property int spacingXL:  32
    readonly property int spacing2XL: 48
    readonly property int spacing3XL: 64
    
    // ── 圆角代币 ────────────────────────────────────────────────────────
    readonly property int radiusNone:    0
    readonly property int radiusSM:      8
    readonly property int radiusMD:      12
    readonly property int radiusLG:      16
    readonly property int radiusXL:      24
    readonly property int radiusFull:    9999  // 完全圆形
    
    // ── 字体代币 ────────────────────────────────────────────────────────
    readonly property int fontSizeXS:   11
    readonly property int fontSizeSM:   12
    readonly property int fontSizeBase: 14
    readonly property int fontSizeLG:   16
    readonly property int fontSizeXL:   18
    readonly property int fontSize2XL:  20
    readonly property int fontSize3XL:  24
    readonly property int fontSize4XL:  32
    readonly property int fontSize5XL:  40
    
    readonly property int fontWeightLight:   300
    readonly property int fontWeightNormal:  400
    readonly property int fontWeightMedium:  500
    readonly property int fontWeightSemibold: 600
    readonly property int fontWeightBold:    700
    
    // ── 阴影代币 ────────────────────────────────────────────────────────
    readonly property var shadowXS: ({
        color: colorNeutral900,
        opacity: 0.05,
        blur: 4,
        offset: { x: 0, y: 1 }
    })
    
    readonly property var shadowSM: ({
        color: colorNeutral900,
        opacity: 0.1,
        blur: 8,
        offset: { x: 0, y: 2 }
    })
    
    readonly property var shadowMD: ({
        color: colorNeutral900,
        opacity: 0.12,
        blur: 16,
        offset: { x: 0, y: 4 }
    })
    
    readonly property var shadowLG: ({
        color: colorNeutral900,
        opacity: 0.14,
        blur: 24,
        offset: { x: 0, y: 8 }
    })
    
    readonly property var shadowXL: ({
        color: colorNeutral900,
        opacity: 0.16,
        blur: 32,
        offset: { x: 0, y: 12 }
    })
    
    // ── 动画代币 ────────────────────────────────────────────────────────
    readonly property int durationShort:  150
    readonly property int durationBase:   300
    readonly property int durationLong:   500
    
    readonly property string easingStandard: "Easing.OutCubic"
}
```

### 3.2 代币使用示例

```qml
// 使用代币定义组件样式

Rectangle {
    width: 200
    height: 80
    color: SoftUITokens.colorNeutralWhite
    radius: SoftUITokens.radiusLG
    
    shadow.color: SoftUITokens.shadowMD.color
    shadow.opacity: SoftUITokens.shadowMD.opacity
    shadow.blur: SoftUITokens.shadowMD.blur
    shadow.yOffset: SoftUITokens.shadowMD.offset.y
    
    Text {
        color: SoftUITokens.colorNeutral900
        font.pixelSize: SoftUITokens.fontSizeBase
        font.weight: SoftUITokens.fontWeightMedium
    }
}
```

---

## 4. 色彩规范

### 4.1 色彩体系

Soft UI 采用**低饱和度、高明度**的色彩体系。

```
饱和度范围：15% ~ 50%（避免纯色）
明度范围：45% ~ 95%（避免过暗）
```

### 4.2 浅色模式调色板

```
┌─────────────────────────────────────────────────┐
│ 背景色                                          │
│ #F9FAFB (Neutral 50)  ← 主背景                  │
│ #FFFFFF (White)       ← 卡片/表面               │
├─────────────────────────────────────────────────┤
│ 主色系                                          │
│ #5B63F5 (Primary)     ← 主品牌色               │
│ #3D42B5 (Primary Dark) ← 悬停状态              │
│ #E8EBFD (Primary Light) ← 背景/禁用            │
├─────────────────────────────────────────────────┤
│ 文字色                                          │
│ #111827 (Neutral 900) ← 主文字                 │
│ #4B5563 (Neutral 600) ← 次级文字               │
│ #9CA3AF (Neutral 400) ← 占位符/禁用            │
├─────────────────────────────────────────────────┤
│ 状态色                                          │
│ #2DA44E (Success)     ← 成功                   │
│ #DC3545 (Error)       ← 错误                   │
│ #F59E0B (Warning)     ← 警告                   │
│ #17A2B8 (Info)        ← 信息                   │
└─────────────────────────────────────────────────┘
```

### 4.3 暗黑模式调色板

```
┌─────────────────────────────────────────────────┐
│ 背景色（反转）                                  │
│ #0F172A (Dark Base)   ← 主背景                  │
│ #1E293B (Dark Surface) ← 卡片/表面             │
├─────────────────────────────────────────────────┤
│ 主色系（更亮）                                  │
│ #818CF8 (Primary)     ← 主品牌色               │
│ #6366F1 (Primary Dark) ← 悬停状态              │
│ #312E81 (Primary Dark BG) ← 背景               │
├─────────────────────────────────────────────────┤
│ 文字色（反转）                                  │
│ #F9FAFB (Light)       ← 主文字                 │
│ #CBD5E1 (Light Gray)  ← 次级文字               │
│ #64748B (Gray)        ← 占位符/禁用            │
├─────────────────────────────────────────────────┤
│ 状态色（调整明度）                              │
│ #4ADE80 (Success)     ← 成功                   │
│ #F87171 (Error)       ← 错误                   │
│ #FACC15 (Warning)     ← 警告                   │
│ #38BDF8 (Info)        ← 信息                   │
└─────────────────────────────────────────────────┘
```

### 4.4 颜色不透明度指南

```qml
// 阴影色不透明度
shadow.opacity: 0.05    // 最轻，hover 效果
shadow.opacity: 0.10    // 轻，卡片阴影
shadow.opacity: 0.15    // 中等，重点卡片
shadow.opacity: 0.20    // 深，模态对话框

// 禁用状态不透明度
opacity: 0.5            // 禁用按钮
opacity: 0.4            // 禁用输入框

// 覆盖层不透明度
opacity: 0.5            // 模态遮罩
opacity: 0.8            // 加深遮罩
```

---

## 5. 排版规范

### 5.1 字体选择

```qml
// 推荐字体栈
property font fontFamily: Qt.font({
    family: "SF Pro Display, -apple-system, BlinkMacSystemFont, "
            "Segoe UI, Roboto, Helvetica Neue, Arial, sans-serif",
    styleName: "Regular"
})

// 字体优先级
// 1. SF Pro Display (macOS)
// 2. Segoe UI (Windows)
// 3. Roboto (Linux)
// 4. Fallback 系统字体
```

### 5.2 字体规格

```
┌─────────────────┬──────────┬────────┬──────────┐
│ 用途            │ 尺寸     │ 权重   │ 行高     │
├─────────────────┼──────────┼────────┼──────────┤
│ Hero 标题       │ 40px     │ 700    │ 48px     │
│ 页面标题 (H1)   │ 32px     │ 700    │ 40px     │
│ 小标题 (H2)     │ 24px     │ 600    │ 32px     │
│ 副标题 (H3)     │ 20px     │ 600    │ 28px     │
│ 段落标题 (H4)   │ 18px     │ 500    │ 24px     │
│ 正文            │ 14px     │ 400    │ 22px     │
│ 辅助文字        │ 12px     │ 400    │ 18px     │
│ 标注 (Caption)  │ 11px     │ 400    │ 16px     │
│ 按钮文字        │ 14px     │ 500    │ 20px     │
│ 标签            │ 12px     │ 500    │ 18px     │
└─────────────────┴──────────┴────────┴──────────┘
```

### 5.3 文本样式

```qml
// src/ui/theme/TextStyles.qml

TextMetrics {
    id: styleHero
    font.pixelSize: 40
    font.weight: 700
    lineHeight: 1.2
}

TextMetrics {
    id: styleHeading1
    font.pixelSize: 32
    font.weight: 700
    lineHeight: 1.25
}

TextMetrics {
    id: styleBody
    font.pixelSize: 14
    font.weight: 400
    lineHeight: 1.5
}
```

---

## 6. 间距与布局

### 6.1 间距规范

```
间距梯度：4 → 8 → 16 → 24 → 32 → 48 → 64

推荐用法：
- 元素间距：16px 或 24px
- 容器内边距：24px 或 32px
- 章节间距：48px 或 64px
- 极小间距（只在特殊情况）：4px 或 8px
```

### 6.2 布局标准

```qml
// 容器内边距标准
ColumnLayout {
    anchors.margins: 24  // 推荐
    spacing: 16          // 元素间距
}

// 卡片内边距
Rectangle {
    anchors.margins: 24  // 边距
    
    ColumnLayout {
        spacing: 16      // 内部间距
    }
}

// 页面级容器
Rectangle {
    anchors.topMargin: 32
    anchors.leftMargin: 24
    anchors.rightMargin: 24
    anchors.bottomMargin: 32
}
```

### 6.3 栅格系统

```
基数：8px
栅格倍数：8 / 16 / 24 / 32 / 40 / 48 / 56 / 64

所有尺寸必须是 8 的倍数。

✅ 正确：32px, 48px, 120px
❌ 错误：30px, 45px, 118px
```

---

## 7. 圆角与阴影

### 7.1 圆角规范

```qml
// 圆角分类
radius: 8       // 小元素（小按钮、输入框）
radius: 12      // 中等元素（卡片、模态）
radius: 16      // 较大元素（面板、对话框）
radius: 24      // 大元素（页面容器）
radius: 9999    // 完全圆形（头像、圆形按钮）

// Soft UI 原则：圆角越大，给人感觉越友好
```

### 7.2 阴影规范

```qml
// 阴影层级系统

// Level 1: 最轻（hover 效果）
drop {
    color: "#000000"
    opacity: 0.05
    blur: 4
    yOffset: 1
}

// Level 2: 轻（卡片默认）
drop {
    color: "#000000"
    opacity: 0.10
    blur: 8
    yOffset: 2
}

// Level 3: 中等（卡片 hover）
drop {
    color: "#000000"
    opacity: 0.12
    blur: 16
    yOffset: 4
}

// Level 4: 深（浮动面板、模态）
drop {
    color: "#000000"
    opacity: 0.14
    blur: 24
    yOffset: 8
}

// Level 5: 最深（浮动菜单、提示框）
drop {
    color: "#000000"
    opacity: 0.16
    blur: 32
    yOffset: 12
}
```

### 7.3 禁止模式

```qml
// ❌ 错误：硬边框
Rectangle {
    border.color: "#000000"
    border.width: 2
    radius: 0
}

// ✅ 正确：柔和阴影 + 圆角
Rectangle {
    radius: 16
    drop {
        color: "#000000"
        opacity: 0.10
        blur: 8
        yOffset: 2
    }
}
```

---

## 8. 动画与交互

### 8.1 动画时长

```qml
// 微交互动画（150-300ms）
Behavior on color {
    ColorAnimation { duration: 200 }
}

// 页面转换（300-500ms）
Behavior on x {
    NumberAnimation { duration: 400 }
}

// 长流程动画（500ms+，谨慎使用）
Behavior on scale {
    NumberAnimation { duration: 600 }
}
```

### 8.2 缓动曲线

```qml
// 推荐缓动
Easing.OutCubic      // 标准缓出，推荐使用
Easing.OutQuad       // 较快缓出
Easing.InOutCubic    // 缓入缓出，页面转换

// 禁止缓动
Easing.Linear        // 机械感强
Easing.InBounce      // 过于夸张
Easing.OutBounce     // 过于夸张
```

### 8.3 交互反馈

```qml
// 按钮悬停效果（浮起）
MouseArea {
    hoverEnabled: true
    
    onEntered: {
        button.scale = 1.02
        button.drop.yOffset = 8
    }
    
    onExited: {
        button.scale = 1.0
        button.drop.yOffset = 2
    }
}

// 按下效果（压低）
onPressed: button.scale = 0.98

// 点击涟漪效果
Rectangle {
    id: ripple
    opacity: 0
    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }
    
    onClicked: {
        ripple.opacity = 1
        timer.start()
    }
    
    Timer {
        id: timer
        interval: 300
        onTriggered: ripple.opacity = 0
    }
}
```

---

## 9. 组件规范

### 9.1 按钮组件

```qml
// src/ui/components/Button.qml

import QtQuick
import QtQuick.Controls

Button {
    id: root
    
    property color accentColor: SoftUITokens.colorPrimaryBase
    property int buttonSize: 40  // small/medium/large
    
    // ── 默认样式 ────────────────────────────────────
    background: Rectangle {
        implicitWidth: 120
        implicitHeight: root.buttonSize
        color: root.accentColor
        radius: SoftUITokens.radiusLG
        
        drop {
            color: root.accentColor
            opacity: 0.2
            blur: 12
            yOffset: 4
        }
        
        // Hover 效果
        Behavior on drop.yOffset {
            NumberAnimation { duration: 200 }
        }
    }
    
    contentItem: Text {
        text: root.text
        color: SoftUITokens.colorNeutralWhite
        font.pixelSize: SoftUITokens.fontSizeBase
        font.weight: SoftUITokens.fontWeightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    // 状态响应
    states: [
        State {
            name: "hovered"
            when: root.hovered
            PropertyChanges {
                target: root.background
                color: SoftUITokens.colorPrimaryDark
            }
        },
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges {
                target: root.background
                drop.yOffset: 2
            }
        },
        State {
            name: "disabled"
            when: !root.enabled
            PropertyChanges {
                target: root
                opacity: 0.5
            }
        }
    ]
}
```

### 9.2 卡片组件

```qml
// src/ui/components/Card.qml

Rectangle {
    id: root
    
    property bool hoverable: true
    property int elevation: 1  // 1-5
    
    color: SoftUITokens.colorNeutralWhite
    radius: SoftUITokens.radiusLG
    
    // 阴影根据 elevation 调整
    drop {
        color: SoftUITokens.shadowMD.color
        opacity: SoftUITokens.shadowMD.opacity
        blur: SoftUITokens.shadowMD.blur
        yOffset: SoftUITokens.shadowMD.offset.y
    }
    
    // Hover 效果（可选）
    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.hoverable
        
        onEntered: {
            elevationBehavior.to = 3
        }
        onExited: {
            elevationBehavior.to = root.elevation
        }
    }
    
    Behavior on drop.blur {
        NumberAnimation {
            id: elevationBehavior
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
}
```

### 9.3 输入框组件

```qml
// src/ui/components/TextField.qml

TextField {
    id: root
    
    background: Rectangle {
        implicitWidth: 240
        implicitHeight: 44
        color: SoftUITokens.colorNeutral50
        radius: SoftUITokens.radiusMD
        
        border.width: 0  // Soft UI：无边框
        
        drop {
            color: SoftUITokens.shadowXS.color
            opacity: SoftUITokens.shadowXS.opacity
            blur: SoftUITokens.shadowXS.blur
        }
        
        // Focus 效果：加重阴影
        Behavior on drop.blur {
            NumberAnimation { duration: 200 }
        }
    }
    
    color: SoftUITokens.colorNeutral900
    font.pixelSize: SoftUITokens.fontSizeBase
    placeholderText: "输入内容..."
    placeholderTextColor: SoftUITokens.colorNeutral400
    
    // 获得焦点时加重阴影
    onActiveFocusChanged: {
        if (activeFocus) {
            background.drop.blur = 16
            background.drop.opacity = 0.12
        } else {
            background.drop.blur = 4
            background.drop.opacity = 0.05
        }
    }
}
```

---

## 10. 页面布局模式

### 10.1 单栏布局

```qml
// ToolBox 典型页面：单栏布局

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 24
    spacing: 24
    
    // 页面标题
    Text {
        text: "翻译"
        font.pixelSize: SoftUITokens.fontSize3XL
        font.weight: SoftUITokens.fontWeightBold
        color: SoftUITokens.colorNeutral900
    }
    
    // 主要内容卡片
    Card {
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16
            
            Text {
                text: "源文本"
                font.pixelSize: SoftUITokens.fontSizeBase
                color: SoftUITokens.colorNeutral600
            }
            
            TextField {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
    
    Item { Layout.fillHeight: true }
    
    // 底部操作栏
    RowLayout {
        Layout.fillWidth: true
        spacing: 16
        
        Button {
            text: "翻译"
            Layout.fillWidth: true
        }
    }
}
```

### 10.2 双栏布局（左导航）

```qml
// ToolBox 主页面：左侧导航 + 右侧内容

RowLayout {
    anchors.fill: parent
    spacing: 0
    
    // 左侧导航栏
    Rectangle {
        Layout.preferredWidth: 240
        Layout.fillHeight: true
        color: SoftUITokens.colorNeutral50
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            NavItem {
                icon: "qrc:/icons/translate.svg"
                text: "翻译"
                checked: true
            }
            
            NavItem {
                icon: "qrc:/icons/clipboard.svg"
                text: "剪贴板"
            }
            
            NavItem {
                icon: "qrc:/icons/screenshot.svg"
                text: "截图"
            }
            
            Item { Layout.fillHeight: true }
        }
    }
    
    // 右侧内容区
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: SoftUITokens.colorNeutralWhite
        
        TranslatePage {
            anchors.fill: parent
        }
    }
}
```

---

## 11. 暗黑模式

### 11.1 暗黑模式适配

```qml
// src/ui/theme/ThemeManager.qml

Item {
    id: root
    
    property bool isDarkMode: false
    
    // 颜色通过暗黑模式自动适配
    readonly property color backgroundColor: 
        isDarkMode ? "#0F172A" : "#F9FAFB"
    
    readonly property color surfaceColor:
        isDarkMode ? "#1E293B" : "#FFFFFF"
    
    readonly property color textPrimary:
        isDarkMode ? "#F9FAFB" : "#111827"
    
    readonly property color textSecondary:
        isDarkMode ? "#CBD5E1" : "#4B5563"
}
```

### 11.2 过渡动画

```qml
// 主题切换时的平滑过渡

Behavior on backgroundColor {
    ColorAnimation { duration: 300 }
}

Behavior on textPrimary {
    ColorAnimation { duration: 300 }
}

// 立即切换主题
function switchTheme(dark) {
    isDarkMode = dark
    // 300ms 内平滑过渡
}
```

---

## 12. 禁止模式

### 12.1 明确禁止的设计元素

```qml
// ❌ 禁止项一：硬边框
Rectangle {
    border.color: "#000000"
    border.width: 1
    // 原因：与 Soft UI 风格冲突，显得生硬
}

// ❌ 禁止项二：零圆角
Rectangle {
    radius: 0
    // 原因：失去柔和感，显得尖锐
}

// ❌ 禁止项三：纯黑色 #000000
Rectangle {
    color: "#000000"
    // 原因：过于深沉，建议用 #111827 或 #1E293B
}

// ❌ 禁止项四：高饱和度纯色
Rectangle {
    color: "#FF0000"  // 纯红
    // 原因：过于鲜艳刺眼，建议用 #DC3545
}

// ❌ 禁止项五：无模糊的阴影
drop {
    color: "#000000"
    opacity: 0.3
    blur: 0  // 硬阴影，禁止
    yOffset: 2
}

// ❌ 禁止项六：元素间距过小
ColumnLayout {
    spacing: 4  // 太紧凑
    // 建议最小 16px
}

// ❌ 禁止项七：多层重边框
Rectangle {
    border.width: 2
    border.color: "#333333"
    
    Rectangle {
        border.width: 1
        border.color: "#666666"
    }
}
```

### 12.2 反模式识别

| 特征 | 判断 | 建议 |
|------|------|------|
| 边框宽度 > 1px | ❌ 禁止 | 使用阴影替代 |
| 圆角 = 0 | ❌ 禁止 | 最小 8px |
| 纯黑色 #000000 | ❌ 禁止 | 用 #111827 |
| 间距 < 8px | ⚠️ 谨慎 | 除特殊情况 |
| 饱和度 > 60% | ❌ 禁止 | 降低饱和度 |
| 阴影 blur = 0 | ❌ 禁止 | 最小 4px |

---

## 13. 最佳实践

### 13.1 通用最佳实践

```
1️⃣  优先使用代币
   不要硬编码颜色、间距、圆角
   始终从 SoftUITokens 中选取

2️⃣  保持白空间
   充足的留白 > 紧凑的布局
   推荐间距：24px 或更大

3️⃣  阴影表达层级
   用阴影深度区分前后关系
   禁止使用边框分离

4️⃣  圆角优先
   所有可见元素 radius ≥ 8px
   完全圆形用 radius: 9999

5️⃣  微妙动画
   动画应补充交互，而非主导
   推荐时长：150-400ms

6️⃣  低对比度文字
   避免纯黑文字
   使用 colorNeutral900 或 600

7️⃣  响应式设计
   确保在不同屏幕尺寸上正确显示
   使用相对尺寸而非绝对值

8️⃣  可访问性
   足够的颜色对比度（最小 4.5:1）
   清晰的焦点指示
```

### 13.2 组件设计最佳实践

```qml
// ✅ 推荐：完整的 Soft UI 组件

Rectangle {
    id: softButton
    
    // 1. 使用代币
    radius: SoftUITokens.radiusLG
    color: SoftUITokens.colorPrimaryBase
    
    // 2. 柔和阴影
    drop {
        color: SoftUITokens.shadowMD.color
        opacity: SoftUITokens.shadowMD.opacity
        blur: SoftUITokens.shadowMD.blur
        yOffset: SoftUITokens.shadowMD.offset.y
    }
    
    // 3. 间距标准
    anchors.margins: SoftUITokens.spacingLG
    
    // 4. 微妙动画
    Behavior on scale {
        NumberAnimation {
            duration: SoftUITokens.durationShort
            easing.type: Easing.OutCubic
        }
    }
    
    // 5. 交互反馈
    MouseArea {
        hoverEnabled: true
        onEntered: parent.scale = 1.02
        onExited: parent.scale = 1.0
    }
}
```

---

## 14. 代码示例

### 14.1 完整页面示例

```qml
// src/ui/pages/SoftUIShowcase.qml

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

Rectangle {
    color: SoftUITokens.colorNeutral50
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SoftUITokens.spacingLG
        spacing: SoftUITokens.spacingLG
        
        // ── 页面标题 ────────────────────────────────────
        Text {
            text: "Soft UI 设计展示"
            font.pixelSize: SoftUITokens.fontSize3XL
            font.weight: SoftUITokens.fontWeightBold
            color: SoftUITokens.colorNeutral900
        }
        
        // ── 卡片展示 ────────────────────────────────────
        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SoftUITokens.spacingLG
                spacing: SoftUITokens.spacingMD
                
                Text {
                    text: "柔和的卡片设计"
                    font.pixelSize: SoftUITokens.fontSizeLG
                    font.weight: SoftUITokens.fontWeightMedium
                    color: SoftUITokens.colorNeutral900
                }
                
                Text {
                    text: "圆润的边角 + 柔和的阴影 = 友好的感受"
                    font.pixelSize: SoftUITokens.fontSizeBase
                    color: SoftUITokens.colorNeutral600
                    wrapMode: Text.Wrap
                }
            }
        }
        
        // ── 按钮展示 ────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: SoftUITokens.spacingMD
            
            Button {
                text: "主按钮"
                Layout.fillWidth: true
            }
            
            Button {
                text: "次按钮"
                Layout.fillWidth: true
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
```

### 14.2 主题切换示例

```qml
// 主题切换按钮

IconButton {
    icon: "qrc:/icons/moon.svg"
    onClicked: {
        ThemeManager.isDarkMode = !ThemeManager.isDarkMode
    }
}

// 所有使用 ThemeManager 颜色的组件自动更新
Rectangle {
    color: ThemeManager.backgroundColor
    
    Behavior on color {
        ColorAnimation { duration: 300 }
    }
}
```

---

## 15. 可访问性

### 15.1 颜色对比度

```
WCAG AA 标准（最小 4.5:1）：

✅ 合格：
   #111827 (text) on #FFFFFF (bg) = 13.4:1
   #4B5563 (text) on #F9FAFB (bg) = 7.2:1

❌ 不合格：
   #9CA3AF (text) on #F9FAFB (bg) = 1.9:1
```

### 15.2 焦点指示

```qml
// ✅ 清晰的焦点指示

Rectangle {
    focus: true
    
    // 获得焦点时加重阴影或添加额外边框样式
    Rectangle {
        visible: parent.focus
        anchors.fill: parent
        border.color: SoftUITokens.colorPrimaryBase
        border.width: 2
        radius: parent.radius + 2
        color: "transparent"
    }
}
```

### 15.3 键盘导航

```qml
// 支持完整的键盘导航

Button {
    Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            clicked()
            event.accepted = true
        }
    }
}
```

---

## 快速参考

### 核心原则（5 条）

1. ✨ **圆角优先** - radius ≥ 8px
2. 🎨 **低饱和度** - 避免纯色，用柔和色
3. 📐 **阴影表层** - drop shadow 替代边框
4. 🎯 **白空间充足** - 间距 ≥ 16px
5. ⚡ **微妙动画** - 150-400ms，缓出

### 禁止清单

- ❌ 硬边框 (border-width > 0)
- ❌ 零圆角 (radius: 0)
- ❌ 纯黑色 (#000000)
- ❌ 硬阴影 (blur: 0)
- ❌ 紧凑间距 (spacing < 8px)
- ❌ 高饱和纯色 (#FF0000 等)

### 设计代币速查

```
色彩：colorPrimaryBase, colorNeutral50 等
间距：spacingMD (16px), spacingLG (24px)
圆角：radiusLG (16px), radiusXL (24px)
阴影：shadowMD, shadowLG
字体：fontSize3XL, fontWeightBold
动画：durationShort (150ms)
```

---

## 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0.0 | 2025-04 | 初版发布，Soft UI 完整规范 |

---

*本文档遵循《ToolBox 应用 — 团队开发技术规范文档》v1.0.0，采用 Soft UI 设计风格*  
*所有 QML 组件应严格遵循本规范，维持一致的视觉体验*
