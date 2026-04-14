// src/main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QDebug>

#include "viewmodels/AppShellViewModel.h"

int main(int argc, char* argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName(QStringLiteral("IQtoolsPlus"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("iqtools.plus"));
    QCoreApplication::setApplicationName(QStringLiteral("IQtools Plus"));

    // Use Basic style so our custom Soft UI visuals are not heavily overridden.
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QQmlApplicationEngine engine;

    AppShellViewModel appShellViewModel;

    engine.setInitialProperties({
        {QStringLiteral("viewModel"), QVariant::fromValue(&appShellViewModel)}
    });

    const QUrl mainQmlUrl(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            qCritical() << "[main] Failed to create root QML object";
            QCoreApplication::exit(EXIT_FAILURE);
        },
        Qt::QueuedConnection);

    engine.load(mainQmlUrl);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "[main] No root QML object loaded";
        return EXIT_FAILURE;
    }

    qInfo() << "[main] Application started successfully";
    return app.exec();
}