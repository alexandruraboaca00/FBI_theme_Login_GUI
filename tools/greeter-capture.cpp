// Test-only instrumentation. Never installed with the theme.
#include <QCoreApplication>
#include <QGuiApplication>
#include <QQuickView>
#include <QQuickItem>
#include <QTimer>
#include <QImage>
#include <QFile>
#include <QTextStream>
#include <QQmlContext>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QScreen>

static bool qmlFailure = false;
static void testLogger(QtMsgType type, const QMessageLogContext &, const QString &message)
{
    fprintf(stderr, "%s\n", qPrintable(message));
    if ((type == QtWarningMsg || type == QtCriticalMsg || type == QtFatalMsg) &&
        (message.contains(".qml:") || message.contains("Fallback to embedded theme")))
        qmlFailure = true;
}

static void beginCapture()
{
    // Refuse to instrument any process other than an explicit test-mode greeter.
    if (!QCoreApplication::arguments().contains("--test-mode") ||
        qEnvironmentVariableIsEmpty("SDDM_CAPTURE_PATH")) return;
    qInstallMessageHandler(testLogger);
    QTimer::singleShot(500, qApp, [] {
        QList<QQuickView *> views;
        for (auto *window : QGuiApplication::topLevelWindows()) {
            auto *view = qobject_cast<QQuickView *>(window);
            if (!view) continue;
            if (!view->rootObject() || view->rootObject()->objectName() != "federalTheme") {
                fprintf(stderr, "CAPTURE ERROR: theme absent or SDDM fallback\n");
                QCoreApplication::exit(2);
                return;
            }
            views.append(view);
            if (qEnvironmentVariable("SDDM_CAPTURE_DEMO") == "1" && view->rootObject()->property("interactive").toBool()) {
                // Only fictitious data; never submit credentials or power operations.
                view->rootObject()->findChild<QObject *>("username")->setProperty("text", "evan.tanner");
                view->rootObject()->findChild<QObject *>("password")->setProperty("text", "demo-only");
            }
        }
        if (views.isEmpty()) {
            fprintf(stderr, "CAPTURE ERROR: no QQuickView\n");
            QCoreApplication::exit(4);
            return;
        }
        const int frameCount = qBound(1, qEnvironmentVariableIntValue("SDDM_CAPTURE_FRAMES"), 90);
        if (frameCount > 1) {
            // Optional real frame sequence for reviewing motion, still test-mode only.
            auto *timer = new QTimer(qApp);
            timer->setInterval(100);
            QObject::connect(timer, &QTimer::timeout, qApp,
                [views, timer, frameCount, frame = 0, ok = true]() mutable {
                    for (auto *view : views) {
                        if (!view->rootObject()->property("interactive").toBool()) continue;
                        QString path = qEnvironmentVariable("SDDM_CAPTURE_PATH");
                        path.replace(".png", QString("-frame-%1.png").arg(frame, 3, 10, QChar('0')));
                        const QImage image = view->grabWindow();
                        ok &= !image.isNull() && image.save(path);
                    }
                    if (++frame >= frameCount) {
                        timer->stop();
                        fprintf(stderr, "CAPTURE FRAMES %d %s\n", frame, ok ? "OK" : "FAILED");
                        QCoreApplication::exit(ok && !qmlFailure ? 0 : 3);
                    }
                });
            timer->start();
            return;
        }
        QTimer::singleShot(800, qApp, [views] {
            QJsonArray results;
            bool allOk = !qmlFailure;
            int interactiveViews = 0;
            for (auto *view : views) {
                const bool interactive = view->rootObject()->property("interactive").toBool();
                if (interactive) ++interactiveViews;
                QString path = qEnvironmentVariable("SDDM_CAPTURE_PATH");
                if (!interactive) path.replace(".png", "-secondary.png");
                const QImage image = view->grabWindow();
                const bool ok = !image.isNull() && image.save(path);
                allOk &= ok;
                const auto sessions = view->rootContext()->contextProperty("sessionModel").value<QObject *>();
                const auto users = view->rootContext()->contextProperty("userModel").value<QObject *>();
                results.append(QJsonObject{{"width", image.width()}, {"height", image.height()},
                    {"interactive", interactive}, {"screen", view->screen()->name()},
                    {"sessions", sessions->property("count").toInt()}, {"users", users->property("count").toInt()},
                    {"canvasScale", view->rootObject()->property("canvasScale").toDouble()},
                    {"devicePixelRatio", view->devicePixelRatio()}, {"file", path}});
                fprintf(stderr, "CAPTURE %s %dx%d\n", ok ? "OK" : "FAILED", image.width(), image.height());
            }
            QFile report(qEnvironmentVariable("SDDM_CAPTURE_PATH") + ".json");
            if (!report.open(QIODevice::WriteOnly) || report.write(QJsonDocument(results).toJson()) < 0)
                allOk = false;
            QCoreApplication::exit(allOk && interactiveViews == 1 ? 0 : 3);
        });
    });
}
Q_COREAPP_STARTUP_FUNCTION(beginCapture)
