# Запуск сервера

## 1) Запуск txAdmin

```powershell
.\scripts\start-txadmin.ps1
```

## 2) Настройка в txAdmin

1) Откройте ссылку/код в консоли.
2) Вставьте ключ из **Keymaster**: https://keymaster.fivem.net
3) Выберите рецепт: **Local file** → `recipes/qbcore.yaml`
4) Укажите доступы к БД из `docker/.env`
5) Нажмите **Run Recipe**

## 3) Подключение из FiveM

- **Direct Connect**: `localhost:30120`
- Либо найдите сервер в списке (если включена видимость)
