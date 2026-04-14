// src/viewmodels/TranslateViewModel.h
#pragma once

#include <QtQml/qqmlregistration.h>

#include <QElapsedTimer>
#include <QObject>
#include <QString>
#include <QStringList>

/**
 * @brief Translate page ViewModel.
 * 中文说明：
 * - 当前阶段为 UI 骨架版 ViewModel
 * - 属性与未来真实服务接口保持兼容
 * - 底层先使用 mock 逻辑，便于主界面联调
 */
class TranslateViewModel final : public QObject {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(QString sourceText READ sourceText WRITE setSourceText NOTIFY
                 sourceTextChanged FINAL)

  Q_PROPERTY(QString resultText READ resultText NOTIFY resultTextChanged FINAL)

  Q_PROPERTY(bool translating READ translating NOTIFY translatingChanged FINAL)

  Q_PROPERTY(QString fromLanguage READ fromLanguage WRITE setFromLanguage NOTIFY
                 fromLanguageChanged FINAL)

  Q_PROPERTY(QString toLanguage READ toLanguage WRITE setToLanguage NOTIFY
                 toLanguageChanged FINAL)

  Q_PROPERTY(
      QStringList supportedLanguages READ supportedLanguages CONSTANT FINAL)

  Q_PROPERTY(QString currentEngine READ currentEngine WRITE setCurrentEngine
                 NOTIFY currentEngineChanged FINAL)

  Q_PROPERTY(QStringList availableEngines READ availableEngines CONSTANT FINAL)

  Q_PROPERTY(
      QString errorMessage READ errorMessage NOTIFY errorMessageChanged FINAL)

  Q_PROPERTY(
      QString latencyInfo READ latencyInfo NOTIFY latencyInfoChanged FINAL)

  Q_PROPERTY(
      double cacheHitRate READ cacheHitRate NOTIFY cacheHitRateChanged FINAL)

 public:
  explicit TranslateViewModel(QObject* parent = nullptr);
  ~TranslateViewModel() override = default;

  [[nodiscard]] QString sourceText() const noexcept;
  [[nodiscard]] QString resultText() const noexcept;
  [[nodiscard]] bool translating() const noexcept;
  [[nodiscard]] QString fromLanguage() const noexcept;
  [[nodiscard]] QString toLanguage() const noexcept;
  [[nodiscard]] QStringList supportedLanguages() const;
  [[nodiscard]] QString currentEngine() const noexcept;
  [[nodiscard]] QStringList availableEngines() const;
  [[nodiscard]] QString errorMessage() const noexcept;
  [[nodiscard]] QString latencyInfo() const noexcept;
  [[nodiscard]] double cacheHitRate() const noexcept;

  void setSourceText(const QString& text);
  void setFromLanguage(const QString& language);
  void setToLanguage(const QString& language);
  void setCurrentEngine(const QString& engineId);

 public slots:
  Q_INVOKABLE void translate();
  Q_INVOKABLE void clear();
  Q_INVOKABLE void copyResult();
  Q_INVOKABLE void switchLanguages();

 signals:
  void sourceTextChanged();
  void resultTextChanged();
  void translatingChanged();
  void fromLanguageChanged();
  void toLanguageChanged();
  void currentEngineChanged();
  void errorMessageChanged();
  void latencyInfoChanged();
  void cacheHitRateChanged();

  void translateSucceeded(const QString& result);
  void translateFailed(const QString& reason);

 private:
  void setResultText(const QString& text);
  void setErrorMessage(const QString& message);
  void setTranslating(bool value);
  void setLatencyInfo(const QString& info);
  void setCacheHitRate(double value);

  QString m_sourceText;
  QString m_resultText;
  QString m_fromLanguage{QStringLiteral("auto")};
  QString m_toLanguage{QStringLiteral("zh-CN")};
  QString m_currentEngine{QStringLiteral("mock-local")};
  QString m_errorMessage;
  QString m_latencyInfo{QStringLiteral("-- ms")};
  bool m_translating{false};
  double m_cacheHitRate{0.0};
};