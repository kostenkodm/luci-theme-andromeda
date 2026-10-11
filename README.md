# Andromeda

Компактная тема LuCI для OpenWrt на основе [Alpha](https://github.com/derisamedia/luci-theme-alpha).

- На компьютере левая панель всегда видна, все группы меню раскрыты.
- При ширине до 768 px панель открывается кнопкой меню; группы остаются раскрытыми.
- Уменьшены отступы, заголовки, строки таблиц и формы.
- Пакет, ресурсы и конфигурация называются `andromeda`; Alpha можно оставить установленной.
- Дополнительная панель ярлыков отключена по умолчанию. Настройки доступны в `/etc/config/andromeda`; приложение настроек Alpha не требуется.

## Сборка

Поместите репозиторий в `package/luci-theme-andromeda` исходного дерева или SDK OpenWrt:

```sh
make defconfig
make package/luci-theme-andromeda/compile V=s
```

В репозитории также сохранены workflows сборки IPK и APK. Их запуск и совместимость с конкретной прошивкой требуют проверки в соответствующем SDK.

## Включение на роутере

Установите собранный пакет через `opkg install /tmp/luci-theme-andromeda*.ipk` или `apk add --allow-untrusted /tmp/luci-theme-andromeda*.apk`, в зависимости от прошивки. Затем выберите Andromeda в System → System → Language and Style либо выполните:

```sh
uci set luci.main.mediaurlbase='/luci-static/andromeda'
uci commit luci
```

Обновите страницу браузера с очисткой кеша. Для возврата выберите прежнюю тему в настройках LuCI.

## Происхождение и лицензия

Исходная тема: derisamedia/luci-theme-alpha. Авторские уведомления сохранены в исходниках; лицензия Apache-2.0 находится в LICENSE. Andromeda меняет навигацию, плотность интерфейса и имена пакета/ресурсов. В репозитории есть Lua и ucode шаблоны, унаследованные от Alpha; проверка на реальном роутере пока не выполнена.

Скриншоты `ss*.png` и `mobileview*.png` унаследованы от Alpha и не показывают изменения Andromeda.
