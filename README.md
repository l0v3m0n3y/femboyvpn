# femboyvpn 🌐✨


**femboyvpn** — это легковесный асинхронный Swift API-клиент для взаимодействия с сервисом `femboyvpn.connecto.lol`. Библиотека поддерживает полноценную работу с сессиями, авторизацией через Email и Telegram, управление тарифами, транзакциями и профилем пользователя.

Полностью написана на Swift с использованием современного синтаксиса `async/await`. Автоматически управляет сессионными Cookies и заголовками `x-csrf-token`.

---

## ✨ Особенности
- 🔐 Полный цикл авторизации (Email + Верификация / Telegram Auth).
- 💳 Работа с биллингом: получение тарифов, расчет стоимости подписки (`quotes`), создание платежей.
- 👥 Поддержка реферальной системы и личного кабинета.
- 🌐 Совместимость с **iOS**, **macOS** и **Linux** (благодаря адаптивному импорту `FoundationNetworking`).
- 🔄 Автоматический менеджмент сессии (сохранение кук и токенов между запросами внутри инстанса класса).

---

## 📦 Установка

### Swift Package Manager (SPM)

Чтобы интегрировать библиотеку в свой проект, добавьте её как зависимость в ваш `Package.swift`:

```swift
dependencies: [
        .package(url: "https://github.com/l0v3m0n3y/femboyvpn", branch: "main"),
    ]
```

Или в Xcode: **File ➔ Add Packages...** и вставьте URL репозитория.

---

## 🚀 Быстрый старт (Quick Start)

```swift
import Foundation
import femboyvpn

let femboy = femboyVpn()

do {
    // 1. Получаем актуальные публичные тарифы
    let tariffs = try await femboy.getTarifs()
    print("Доступные тарифы: \(tariffs)")
    
    // 2. Авторизуемся в системе
    let loginResponse = try await femboy.login(email: "user@example.com", password: "securepassword")
    print("Вход выполнен успешно: \(loginResponse)")
    
    // 3. Запрашиваем информацию о текущем пользователе
    let profile = try await femboy.getMe()
    print("Ваш профиль: \(profile)")
    
} catch {
    print("Произошла ошибка: \(error.localizedDescription)")
}
```

---

## 🛠 Доступные методы API

Класс `femboyVpn` предоставляет следующие публичные методы для работы:

### Авторизация и профиль
* `login(email:password:)` — вход по почте (автоматически сохраняет CSRF-токен).
* `getCode(email:password:)` — запрос кода подтверждения при регистрации.
* `register(email:code:)` — подтверждение регистрации кодом из письма.
* `logout()` — завершение сессии с очисткой Cookies и токенов безопасности.
* `getMe()` / `getAccountInfo()` / `getSessionInfo()` — получение детальных данных аккаунта и сессии.

### Авторизация через Telegram
* `loginByTelegramLink()` — инициация входа через Telegram.
* `checkTelegramAuth(flow:)` — проверка статуса авторизации по идентификатору `flow`.
* `finishTelegramAuth(flow:)` — завершение авторизации.

### Подписки и платежи
* `getTarifs()` — получение списка доступных тарифов сервиса.
* `getQuoteForBuy(months:devices:)` — расчёт стоимости подписки на определенное количество месяцев и устройств.
* `confirmBuy(quoteId:)` — подтверждение покупки на основании сформированного `quoteId`.
* `startPayments(amount:method:)` — создание транзакции на оплату.
* `getPaymentMethods()` — список доступных платежных шлюзов.
* `getTransactions()` — история операций кошелька.

### Управление аккаунтом
* `changePassword(password:)` — обновление текущего пароля.
* `requestCodeForChangeEmail()` — запуск процедуры смены Email.
* `confirmCodeForChangeEmail(id:code:)` — валидация кода для смены почты.
* `changeEmail(id:email:)` — привязка нового адреса электронной почты.
* `getMyReferrals()` — список приглашенных пользователей и статистика по реферальной программе.

---

## 🤝 Вклад в развитие (Contributing)
Пулл-реквесты приветствуются! Если вы нашли баг или хотите добавить типизированные модели данных (заменить `Any` на `Decodable` структуры для ответов сервера), пожалуйста, создайте Issue или Fork-версию репозитория и оформите PR.

## 📄 Лицензия
Проект распространяется под лицензией MIT.
