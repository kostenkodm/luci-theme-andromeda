# Andromeda

Компактная тема LuCI на основе [Aurora](https://github.com/eamonxg/luci-theme-aurora) от eamonxg.

- Слева постоянно видна панель навигации; на компьютере все разделы раскрыты.
- Меньше отступы в меню, карточках, таблицах и формах.
- Нейтральный тёмно-серый фон с фиолетовыми акцентами и светлый вариант с оттенком лаванды.
- Компактные карточки интерфейсов с пиктограммами 16 px и кнопки высотой 28 px на компьютере.
- Новый значок Andromeda и имя хоста в шапке вместо названия темы.
- Однотонный фон без обоев на странице входа и в интерфейсе.
- Сохранены светлый, тёмный и системный режимы, поиск по страницам и навигация Aurora.
- На телефоне используется выдвижное меню с обычным раскрытием разделов.

Версия 2.1 использует код Aurora. Название пакета и путь темы — `luci-theme-andromeda` и `/luci-static/andromeda`.

## Установка и обновление

Выполни по SSH **на роутере от root**:

```sh
wget -O /tmp/install-andromeda.sh https://raw.githubusercontent.com/kostenkodm/luci-theme-andromeda/main/install.sh && sh /tmp/install-andromeda.sh
```

Команда подходит и для обновления уже установленной Andromeda. Скрипт скачает готовые ресурсы из этого репозитория, установит и выберет тему. Затем обнови страницу LuCI через **Ctrl+F5**. Перезагрузка роутера не нужна.

Нужен LuCI с ucode-шаблонами (OpenWrt 23.05+). Для Xiaomi Redmi Router AX6S с OpenWrt 25.12.5 используется эта же команда; архитектура процессора для такой установки не важна. На настоящем AX6S тема пока не проверена.

Скрипт устанавливает файлы напрямую, без регистрации пакета в `apk`/`opkg`. Обновление выполняется повторным запуском этой команды. Если раньше была установлена Andromeda на основе Alpha, скрипт обновит активные ресурсы и шаблоны, сохранив конфигурацию и имеющуюся запись о предыдущей теме. Параметры оформления старой версии больше не используются.

Скрипт проверяет исходные файлы до установки и включает тему после копирования всех ресурсов. Исходная тема остаётся доступна для возврата. Перед установкой рекомендуется сохранить обычную резервную копию настроек OpenWrt.

### Вернуть прежнюю тему

```sh
sh /tmp/install-andromeda.sh --restore
```

Если после перезагрузки файла в `/tmp` нет, сначала скачай его:

```sh
wget -O /tmp/install-andromeda.sh https://raw.githubusercontent.com/kostenkodm/luci-theme-andromeda/main/install.sh && sh /tmp/install-andromeda.sh --restore
```

После возврата обнови страницу через Ctrl+F5. Путь прежней темы сохранён в `/etc/andromeda/previous-media`.

### Установка пакетом

В [Releases](https://github.com/kostenkodm/luci-theme-andromeda/releases) выбирай пакет под свою версию OpenWrt:

- OpenWrt 25.12 — файл `.apk`.
- OpenWrt 24.10 — файл `.ipk`.

Скопируй скачанный пакет в `/tmp` на роутере, затем установи соответствующей командой:

```sh
# OpenWrt 25.12; подставь имя скачанного файла
apk add --allow-untrusted /tmp/luci-theme-andromeda-*.apk

# OpenWrt 24.10
opkg install /tmp/luci-theme-andromeda_*.ipk
```

Выбери Andromeda в **Система → Система → Язык и стиль**, либо выполни:

```sh
uci set luci.main.mediaurlbase='/luci-static/andromeda'
uci commit luci
```

Установка пакетом и установка скриптом — альтернативные способы. Файл предыдущей темы для `--restore` создаёт именно скрипт.

## Разработка

Исходные стили и JavaScript находятся в `.dev/src/`, готовые ресурсы — в `htdocs/luci-static/`, шаблоны — в `ucode/template/themes/andromeda/`.

```sh
cd .dev
corepack enable
pnpm install --frozen-lockfile
pnpm build
pnpm test
cd ..
sh tests/install.sh
```

Нужен Node.js 20.19+ или 22.12+ и pnpm из поля `packageManager` в `.dev/package.json`. Для браузерных тестов укажи путь к Chromium/Chrome/Edge в `CHROME_BIN`; в CI используется Chrome. Собранные ресурсы включены в репозиторий, поэтому на роутере Node.js не требуется.

Компактные отступы задаются в `.dev/src/media/_andromeda.css`. Меню — в `.dev/src/resource/menu-andromeda.js`. Палитра задаётся в `.dev/theme-colors.js`: команда `pnpm tokens` и каждая сборка создают `.dev/src/media/_tokens.css`. Для расчёта производных цветов используется движок Aurora из `@eamonxg/luci-theme-tokens/aurora`.

GitHub Actions собирает пакеты с SDK OpenWrt 24.10.4 и 25.12.5. Для ручной сборки запусти workflow **LuCI Theme Andromeda Build & Release**; пакеты будут в артефактах. Теги `v*` также публикуют пакеты в Releases.

## Авторы и лицензия

Основа: [eamonxg/luci-theme-aurora](https://github.com/eamonxg/luci-theme-aurora). Сохранены авторские уведомления Aurora и LuCI Bootstrap. Лицензия: [Apache-2.0](LICENSE).

Дополнительная документация, унаследованная от Aurora, описывает исходную тему; для установки Andromeda используй эту инструкцию.
