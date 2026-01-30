# Troubleshooting

## Порт 3306 занят
- Остановите другой MySQL/MariaDB
- Проверьте Docker Desktop и контейнер `mymp-db`

## БД не стартует
- Проверьте `docker/.env` (пароли и имя БД)
- Посмотрите логи: `docker compose -f docker/compose.yml logs -f`

## Нет ключа Keymaster
- Зарегистрируйтесь и создайте ключ: https://keymaster.fivem.net

## Firewall блокирует
- Разрешите входящие соединения для `FXServer.exe`
- Проверьте, что порт 30120 открыт локально
