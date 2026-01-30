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
