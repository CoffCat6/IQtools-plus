// src/ui/theme/Theme.qml
import QtQuick

QtObject {
    id: root

    // ── Theme State ──────────────────────────────────────────────────────
    property bool isDark: false

    // ── Typography Scale ─────────────────────────────────────────────────
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

    // ── Pre-built Typography Styles ──────────────────────────────────────
    // Usage: apply heading1 → Text{ font.pixelSize: theme.h1Size; font.weight: theme.fontWeightBold; ... }
    readonly property int h1Size: 32
    readonly property int h1Weight: 700
    readonly property int h2Size: 24
    readonly property int h2Weight: 700
    readonly property int h3Size: 18
    readonly property int h3Weight: 600
    readonly property int bodySize: 14
    readonly property int bodyWeight: 400
    readonly property int bodySmallSize: 12
    readonly property int bodySmallWeight: 400
    readonly property int captionSize: 11
    readonly property int captionWeight: 400
    readonly property int labelSize: 12
    readonly property int labelWeight: 600

    // ── Spacing ──────────────────────────────────────────────────────────
    readonly property int spacingXS: 4
    readonly property int spacingSM: 8
    readonly property int spacingMD: 16
    readonly property int spacingLG: 24
    readonly property int spacingXL: 32
    readonly property int spacing2XL: 48

    // ── Radius ───────────────────────────────────────────────────────────
    readonly property int radiusNone: 0
    readonly property int radiusSM: 8
    readonly property int radiusMD: 12
    readonly property int radiusLG: 16
    readonly property int radiusXL: 24
    readonly property int radiusFull: 9999

    // ── Duration ─────────────────────────────────────────────────────────
    readonly property int durationShort: 150
    readonly property int durationBase: 250
    readonly property int durationLong: 350

    // ── Colors: Surface ──────────────────────────────────────────────────
    readonly property color backgroundColor: isDark ? "#0F172A" : "#F9FAFB"
    readonly property color surfaceColor: isDark ? "#1E293B" : "#FFFFFF"
    readonly property color elevatedSurfaceColor: isDark ? "#243246" : "#FFFFFF"
    readonly property color sidebarColor: isDark ? "#162133" : "#F3F4F6"
    readonly property color dividerColor: isDark ? "#334155" : "#E5E7EB"
    readonly property color surfaceBorder: isDark ? "#334155" : "#E5E7EB"

    // ── Colors: Text ─────────────────────────────────────────────────────
    readonly property color textPrimary: isDark ? "#F8FAFC" : "#111827"
    readonly property color textSecondary: isDark ? "#CBD5E1" : "#4B5563"
    readonly property color textTertiary: isDark ? "#94A3B8" : "#9CA3AF"
    readonly property color textOnPrimary: "#FFFFFF"
    readonly property color disabledText: isDark ? "#64748B" : "#9CA3AF"

    // ── Colors: Primary ──────────────────────────────────────────────────
    readonly property color primaryColor: isDark ? "#818CF8" : "#5B63F5"
    readonly property color primaryHoverColor: isDark ? "#6366F1" : "#3D42B5"
    readonly property color primarySoftColor: isDark ? "#312E81" : "#E8EBFD"
    readonly property color primaryPressedColor: isDark ? "#4F46E5" : "#2D31A6"

    // ── Colors: Semantic ─────────────────────────────────────────────────
    readonly property color successColor: isDark ? "#4ADE80" : "#2DA44E"
    readonly property color successSoftColor: isDark ? "#1A3A1A" : "#E6F4EA"
    readonly property color warningColor: isDark ? "#FACC15" : "#F59E0B"
    readonly property color warningSoftColor: isDark ? "#3A3510" : "#FEF3C7"
    readonly property color errorColor: isDark ? "#F87171" : "#DC3545"
    readonly property color errorSoftColor: isDark ? "#3A1515" : "#FCE4EC"
    readonly property color infoColor: isDark ? "#60A5FA" : "#3B82F6"
    readonly property color infoSoftColor: isDark ? "#152540" : "#E8F0FE"

    // ── Colors: Interaction ──────────────────────────────────────────────
    readonly property color hoverOverlay: isDark ? "#1AFFFFFF" : "#0A000000"
    readonly property color pressedOverlay: isDark ? "#26FFFFFF" : "#14000000"
    readonly property color focusRing: isDark ? "#60A5FA80" : "#3B82F660"
    readonly property color disabledBackground: isDark ? "#334155" : "#E5E7EB"

    // ── Colors: Shadow ───────────────────────────────────────────────────
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

    // ── Breakpoints ──────────────────────────────────────────────────────
    readonly property int bpCompact: 960
    readonly property int bpMedium: 1280

    function isCompact(width) {
        return width < bpCompact;
    }
    function isMedium(width) {
        return width >= bpCompact && width < bpMedium;
    }
    function isExpanded(width) {
        return width >= bpMedium;
    }
}
