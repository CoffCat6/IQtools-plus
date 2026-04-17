//src/viewmodels/HomeViewModel.h

#pragma once

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QString>


class HomeViewModel final : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QString welcomeMessage READ welcomeMessage NOTIFY
                 welcomeMessageChanged FINAL)

  Q_PROPERTY(QString appVersion READ appVersion NOTIFY appVersionChanged FINAL)

  Q_PROPERTY(QString buildDate READ buildDate NOTIFY buildDateChanged FINAL)
 public:
  explicit HomeViewModel(QObject* parent = nullptr);
  ~HomeViewModel() override = default;

  [[nodiscard]] QString welcomeMessage() const noexcept;
  [[nodiscard]] QString appVersion() const noexcept;
  [[nodiscard]] QString buildDate() const noexcept;

 signals:
  void welcomeMessageChanged();
  void appVersionChanged();
  void buildDateChanged();

 private:
  QString m_welcomeMessage;
  QString m_appVersion;
  QString m_buildDate;
};