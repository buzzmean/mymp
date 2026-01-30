# mymp — QBCore + txAdmin (Windows)

Быстрый старт «за 10 минут» на Windows:

```powershell
# 1) Клонируем
 git clone <ВАШ_РЕПОЗИТОРИЙ>
 cd mymp

# 2) Проверяем зависимости
 .\scripts\check-prereqs.ps1

# 3) Запускаем базу
 .\scripts\start-db.ps1

# 4) Устанавливаем FXServer
 .\scripts\setup.ps1

# 5) Запускаем txAdmin
 .\scripts\start-txadmin.ps1
```

Дальше в **txAdmin**:
1) Получите ключ на https://keymaster.fivem.net
2) Выберите рецепт: **Local file** → `recipes/qbcore.yaml`
3) Укажите доступы к БД из `docker/.env`
4) Нажмите **Run Recipe**

## Документация
- [01_prereqs_windows.md](docs/01_prereqs_windows.md)
- [02_setup_local_windows.md](docs/02_setup_local_windows.md)
- [03_run_server.md](docs/03_run_server.md)
- [04_troubleshooting.md](docs/04_troubleshooting.md)
