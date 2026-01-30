# Локальная установка (Windows)

## 1) Клонирование репозитория

```powershell
git clone <ВАШ_РЕПОЗИТОРИЙ>
cd mymp
```

## 2) Подготовка env для БД

```powershell
Copy-Item docker/.env.example docker/.env
notepad docker/.env
```

## 3) Проверка зависимостей

```powershell
.\scripts\check-prereqs.ps1
```

## 4) Запуск базы данных

```powershell
.\scripts\start-db.ps1
```

## 5) Установка FXServer

```powershell
.\scripts\setup.ps1
```

## Club mode (no reboot)

Этот режим запускается без Docker Desktop и без 7-Zip.

1) Убедитесь, что есть интернет и Git.
2) Запустите установку FXServer (используется встроенный Expand-Archive):

```powershell
.\scripts\setup.ps1
```

3) Запускайте txAdmin без БД:

```powershell
.\scripts\start-txadmin.ps1
```
