// src/ui/theme/Theme.qml
import QtQuick

QtObject {
    id: root

    // ── Theme State ──────────────────────────────────────────────────────
    property bool isDark: false

    // ── Typography ───────────────────────────────────────────────────────
    readonly property string fontFamily: Qt.platform.os === "windows" ? "Segoe UI" : (Qt.platform.os === "osx" ? "SF Pro Display" : "Noto Sans")

    readonly property int fontSizeXS: 11
    readonly property int fontSizeSM: 12
    readonly property int fontSizeBase: 14
    readonly property int fontSizeLG: 16
    readonly property int fontSizeXL: 18
    readonly property int fontSize2XL: 20
    readonly property int fontSize3XL: 24
    readonly property int fontSize4XL: 32

    readonly property int fontWeightNormal: 400
    readonly property int fontWeightMedium: 500
    readonly property int fontWeightSemibold: 600
    readonly property int fontWeightBold: 700

    // ── Spacing ──────────────────────────────────────────────────────────
    readonly property int spacingXS: 4
    readonly property int spacingSM: 8
    readonly property int spacingMD: 16
    readonly property int spacingLG: 24
    readonly property int spacingXL: 32
    readonly property int spacing2XL: 48

    // ── Radius ───────────────────────────────────────────────────────────
    readonly property int radiusSM: 8
    readonly property int radiusMD: 12
    readonly property int radiusLG: 16
    readonly property int radiusXL: 24
    readonly property int radiusFull: 9999

    // ── Duration ─────────────────────────────────────────────────────────
    readonly property int durationShort: 150
    readonly property int durationBase: 250
    readonly property int durationLong: 350

    // ── Colors: Light / Dark ─────────────────────────────────────────────
    readonly property color backgroundColor: isDark ? "#0F172A" : "#F9FAFB"
    readonly property color surfaceColor: isDark ? "#1E293B" : "#FFFFFF"
    readonly property color elevatedSurfaceColor: isDark ? "#243246" : "#FFFFFF"
    readonly property color sidebarColor: isDark ? "#162133" : "#F3F4F6"
    readonly property color dividerColor: isDark ? "#334155" : "#E5E7EB"

    readonly property color textPrimary: isDark ? "#F8FAFC" : "#111827"
    readonly property color textSecondary: isDark ? "#CBD5E1" : "#4B5563"
    readonly property color textTertiary: isDark ? "#94A3B8" : "#9CA3AF"

    readonly property color primaryColor: isDark ? "#818CF8" : "#5B63F5"
    readonly property color primaryHoverColor: isDark ? "#6366F1" : "#3D42B5"
    readonly property color primarySoftColor: isDark ? "#312E81" : "#E8EBFD"

    readonly property color successColor: isDark ? "#4ADE80" : "#2DA44E"
    readonly property color warningColor: isDark ? "#FACC15" : "#F59E0B"
    readonly property color errorColor: isDark ? "#F87171" : "#DC3545"

    readonly property color shadowColor: isDark ? "#000000" : "#111827"

    function shadow(level) {
        switch (level) {
        case 1:
            return isDark ? "#28000000" : "#100F172A";
        case 2:
            return isDark ? "#38000000" : "#160F172A";
        case 3:
            return isDark ? "#50000000" : "#1D0F172A";
        default:
            return isDark ? "#28000000" : "#100F172A";
        }
    }

    function pageTitle(pageIndex) {
        switch (pageIndex) {
        case 0:
            return qsTr("翻译");
        case 1:
            return qsTr("剪贴板");
        case 2:
            return qsTr("截图");
        default:
            return qsTr("IQtools Plus");
        }
    }

    function pageSubtitle(pageIndex) {
        switch (pageIndex) {
        case 0:
            return qsTr("多引擎翻译、语言切换与结果展示");
        case 1:
            return qsTr("历史记录、搜索过滤与常用项管理");
        case 2:
            return qsTr("区域截图、延时截图与后续标注入口");
        default:
            return qsTr("高质量桌面效率工具箱");
        }
    }
}
