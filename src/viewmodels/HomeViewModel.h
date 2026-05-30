//src/viewmodels/HomeViewModel.h

#pragma once

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QString>
#include <QTimer>

class HomeViewModel final : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QString welcomeMessage READ welcomeMessage NOTIFY
                 welcomeMessageChanged FINAL)

  Q_PROPERTY(QString appVersion READ appVersion NOTIFY appVersionChanged FINAL)

  Q_PROPERTY(QString buildDate READ buildDate NOTIFY buildDateChanged FINAL)

  Q_PROPERTY(QString totalPagesText READ totalPagesText NOTIFY
                 statisticsChanged FINAL)

  Q_PROPERTY(QString totalToolsText READ totalToolsText NOTIFY
                 statisticsChanged FINAL)

  Q_PROPERTY(QString currentTime READ currentTime NOTIFY currentTimeChanged
                 FINAL)

  Q_PROPERTY(QString currentDate READ currentDate NOTIFY currentDateChanged
                 FINAL)

  Q_PROPERTY(QString weatherText READ weatherText NOTIFY weatherChanged FINAL)

  Q_PROPERTY(QString weatherTemperature READ weatherTemperature NOTIFY
                 weatherChanged FINAL)

  Q_PROPERTY(QString weatherCity READ weatherCity NOTIFY weatherChanged FINAL)

  Q_PROPERTY(QString weatherIcon READ weatherIcon NOTIFY weatherChanged FINAL)

 public:
  explicit HomeViewModel(QObject* parent = nullptr);
  ~HomeViewModel() override = default;

  [[nodiscard]] QString welcomeMessage() const noexcept;
  [[nodiscard]] QString appVersion() const noexcept;
  [[nodiscard]] QString buildDate() const noexcept;
  [[nodiscard]] QString totalPagesText() const noexcept;
  [[nodiscard]] QString totalToolsText() const noexcept;
  [[nodiscard]] QString currentTime() const noexcept;
  [[nodiscard]] QString currentDate() const noexcept;
  [[nodiscard]] QString weatherText() const noexcept;
  [[nodiscard]] QString weatherTemperature() const noexcept;
  [[nodiscard]] QString weatherCity() const noexcept;
  [[nodiscard]] QString weatherIcon() const noexcept;

  Q_INVOKABLE void refreshWelcomeMessage();
  Q_INVOKABLE void refreshWeather(const QString& city);

 signals:
  void welcomeMessageChanged();
  void appVersionChanged();
  void buildDateChanged();
  void statisticsChanged();
  void currentTimeChanged();
  void currentDateChanged();
  void weatherChanged();

 private:
  void updateDateTime();
  QString generateWelcomeMessage() const;

  QString m_welcomeMessage;
  QString m_appVersion;
  QString m_buildDate;
  QString m_currentTime;
  QString m_currentDate;
  QString m_weatherText;
  QString m_weatherTemperature;
  QString m_weatherCity;
  QString m_weatherIcon;
  QTimer m_timer;
};