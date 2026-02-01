# Portable MariaDB для Windows (без установки)

Эта инструкция добавляет portable-версию MariaDB, которая запускается прямо из папки проекта.

## Шаг 1. Setup (скачать и подготовить)

```powershell
.\scripts\setup-mariadb-portable.ps1
```

Что делает скрипт:
- Скачивает Windows x64 ZIP MariaDB (по умолчанию LTS 11.4).
- Распаковывает в `runtime/mariadb/`.
- Инициализирует `runtime/mariadb-data/`.
- Генерирует `runtime/mariadb/my.ini`.

## Шаг 2. Start (запустить)

```powershell
.\scripts\start-mariadb.ps1
```

Скрипт:
- Запускает `mariadbd.exe` в отдельном процессе.
- Ждет доступности порта 3306.
- Создает `runtime/mariadb.env` (если его еще нет).
- Создает БД `qbcore` и пользователя `qbcore`.

Если root-пароль оставлен пустым (по умолчанию), это допустимо для локальной разработки, но рекомендуется задать пароль позже.

## Шаг 3. Check (проверка)

```powershell
.\scripts\doctor-db.ps1
```

Проверяет:
- свободен ли порт 3306;
- статус процесса по PID;
- последние 30 строк лога `runtime/logs/mariadb.err`.

Проверка подключения:

```powershell
runtime\mariadb\bin\mariadb.exe -h 127.0.0.1 -P 3306 -u qbcore -p qbcore
```

## Шаг 4. Stop (остановить)

```powershell
.\scripts\stop-mariadb.ps1
```

## Troubleshooting

### Порт 3306 занят
- Закройте другой MySQL/MariaDB сервер или смените порт.
- Чтобы сменить порт, отредактируйте `runtime/mariadb/my.ini`:
  - `port=3306` → `port=3307`
- После изменения перезапустите MariaDB.

### Антивирус блокирует запуск
- Добавьте папку проекта в исключения антивируса.

### Нет прав на запись
- Запускайте PowerShell от имени пользователя с правами записи в папку проекта.
