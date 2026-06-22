// src/main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>

#include "core/log/Logger.h"
#include "core/log/LogModules.h"
#include "viewmodels/AppShellViewModel.h"

// ── QML 日志桥接：将 Qt 消息（console.log/warn/error）转发到 spdlog ────────
static void qtMessageHandler(QtMsgType type,
                              const QMessageLogContext& ctx,
                              const QString& msg) {
    // 过滤掉 QML 引擎内部的噪声
    const QByteArray utf8 = msg.toUtf8();
    const char* file = ctx.file ? ctx.file : "";

    switch (type) {
        case QtDebugMsg:
            TB_LOG_DEBUG(LogModule::UI, "[QML] {}", utf8.constData());
            break;
        case QtInfoMsg:
            TB_LOG_INFO(LogModule::UI, "[QML] {}", utf8.constData());
            break;
        case QtWarningMsg:
            TB_LOG_WARN(LogModule::UI, "[QML] {} | src={}:{}", utf8.constData(), file, ctx.line);
            break;
        case QtCriticalMsg:
            TB_LOG_ERROR(LogModule::UI, "[QML] {} | src={}:{}", utf8.constData(), file, ctx.line);
            break;
        case QtFatalMsg:
            TB_LOG_CRITICAL(LogModule::UI, "[QML] {} | src={}:{}", utf8.constData(), file, ctx.line);
            break;
    }
}

int main(int argc, char* argv[])
{
    // ── 日志系统初始化（必须最先调用，在 QGuiApplication 之前）──────────────
    {
        Logger::Config logConfig;
        logConfig.logDir        = "logs";
        logConfig.filePattern   = "iqtools_{date}.log";
        logConfig.maxFileSize   = 10 * 1024 * 1024;  // 10 MB
        logConfig.maxFiles      = 7;
        logConfig.consoleOutput = true;
#ifdef NDEBUG
        logConfig.fileLevel    = spdlog::level::info;
        logConfig.consoleLevel = spdlog::level::info;
#else
        logConfig.fileLevel    = spdlog::level::debug;
        logConfig.consoleLevel = spdlog::level::debug;
#endif
        Logger::init(logConfig);
    }

    TB_LOG_INFO(LogModule::App,
        "IQtools Plus starting | version={} git={}",
        IQTOOLS_APP_VERSION, IQTOOLS_GIT_VERSION);

    // ── 安装 QML 日志桥接 ──────────────────────────────────────────────────
    qInstallMessageHandler(qtMessageHandler);

    // ── Qt 应用初始化 ───────────────────────────────────────────────────────
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName(QStringLiteral("IQtoolsPlus"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("iqtools.plus"));
    QCoreApplication::setApplicationName(QStringLiteral("IQtools Plus"));

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    TB_LOG_DEBUG(LogModule::App, "Qt version={} style=Basic", QT_VERSION_STR);

    // ── QML 引擎 ────────────────────────────────────────────────────────────
    QQmlApplicationEngine engine;

    AppShellViewModel appShellViewModel;

    engine.setInitialProperties({
        {QStringLiteral("viewModel"),
         QVariant::fromValue(static_cast<QObject*>(&appShellViewModel))}
    });

    const QUrl mainQmlUrl(QStringLiteral("qrc:/main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            TB_LOG_CRITICAL(LogModule::App, "Failed to create root QML object — exiting.");
            QCoreApplication::exit(EXIT_FAILURE);
        },
        Qt::QueuedConnection);

    engine.load(mainQmlUrl);

    if (engine.rootObjects().isEmpty()) {
        TB_LOG_CRITICAL(LogModule::App, "No root QML object loaded — exiting.");
        Logger::shutdown();
        return EXIT_FAILURE;
    }

    TB_LOG_INFO(LogModule::App, "Application started successfully.");

    const int exitCode = app.exec();

    TB_LOG_INFO(LogModule::App, "Application exiting | code={}", exitCode);
    Logger::shutdown();
    return exitCode;
}
