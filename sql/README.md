# SQL Scripts for IT Studio Portfolio Management System

## Лабораторная работа №3 - Физическая модель базы данных

Данная папка содержит все SQL скрипты для создания и работы с физической моделью базы данных системы управления портфелем заказов IT-студии.

## Структура файлов

### 📁 migrations/
Миграционные файлы для создания базы данных:
- `001_create_tables.sql` - Создание всех таблиц и представлений
- `002_create_constraints.sql` - Добавление ограничений, индексов и триггеров
- `003_insert_test_data.sql` - Вставка тестовых данных

### 📁 queries/
Готовые SQL запросы:
- `crud_operations.sql` - CRUD операции для всех сущностей
- `reporting_queries.sql` - Сложные запросы для отчетности и аналитики

### 📄 Основные файлы
- `setup_database.sql` - Основной скрипт установки
- `README.md` - Данная инструкция

## Требования

- PostgreSQL 12+ 
- Права на создание таблиц и индексов
- Минимум 100MB свободного места

## Установка

### Вариант 1: Полная установка одной командой
```bash
psql -d your_database_name -f setup_database.sql
```

### Вариант 2: Пошаговая установка
```bash
# 1. Создание таблиц
psql -d your_database_name -f migrations/001_create_tables.sql

# 2. Добавление ограничений
psql -d your_database_name -f migrations/002_create_constraints.sql

# 3. Вставка тестовых данных
psql -d your_database_name -f migrations/003_insert_test_data.sql
```

## Тестовые данные

После установки в базе данных будут созданы:

### Пользователи (пароль для всех: `password123`)
- `admin` - Администратор (John Smith)
- `manager1` - Менеджер проектов (Alice Johnson) 
- `manager2` - Менеджер проектов (Bob Wilson)
- `dev1` - Разработчик (Charlie Brown)
- `dev2` - Разработчик (Diana Davis)
- `dev3` - Разработчик (Eve Miller)
- `dev4` - Разработчик (Frank Garcia)
- `client1` - Клиент (Sarah Connor)

### Клиенты
- TechCorp Solutions
- Digital Innovations Ltd
- StartupXYZ
- Enterprise Global
- LocalBusiness Inc

### Проекты
- E-commerce Platform (активный)
- Mobile App Development (активный)
- Data Analytics Dashboard (планирование)
- Website Redesign (тестирование)
- API Integration (завершен)

### Данные
- 16+ задач с различными статусами
- 15+ записей времени
- 4 счета с платежами
- Полная структура ролей и разрешений

## Примеры использования

### Подключение к базе данных
```bash
psql -d your_database_name -U your_username
```

### Выполнение CRUD операций
```sql
\i queries/crud_operations.sql
```

### Запуск отчетов
```sql
\i queries/reporting_queries.sql
```

### Простые запросы

#### Получить всех активных пользователей
```sql
SELECT id, username, first_name, last_name, email 
FROM users 
WHERE is_active = TRUE;
```

#### Получить активные проекты с клиентами
```sql
SELECT p.name as project, c.company_name as client, p.status
FROM projects p
JOIN clients c ON p.client_id = c.id
WHERE p.status = 'active';
```

#### Получить задачи пользователя
```sql
SELECT t.title, p.name as project, ts.name as status
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_statuses ts ON t.status_id = ts.id
WHERE t.assigned_user_id = 4;  -- Charlie Brown
```

## Структура базы данных

### Основные таблицы (14 штук)
1. **roles** - Роли пользователей
2. **users** - Пользователи системы  
3. **permissions** - Разрешения
4. **role_permissions** - Связь ролей и разрешений
5. **user_sessions** - Сессии пользователей
6. **audit_logs** - Журнал действий
7. **clients** - Клиенты
8. **projects** - Проекты
9. **project_members** - Участники проектов
10. **task_statuses** - Статусы задач
11. **tasks** - Задачи
12. **time_entries** - Учет времени
13. **invoices** - Счета
14. **payments** - Платежи

### Представления (Views)
- **user_details** - Пользователи с ролями
- **project_overview** - Проекты с клиентами и менеджерами
- **task_details** - Задачи с полной информацией

## Ограничения и индексы

### Типы ограничений
- **Primary Keys** - Первичные ключи для всех таблиц
- **Foreign Keys** - Внешние ключи с каскадными операциями
- **Unique Constraints** - Уникальность email, username, invoice_number
- **Check Constraints** - Валидация статусов, приоритетов, процентов
- **Not Null Constraints** - Обязательные поля

### Индексы для производительности
- Индексы на внешние ключи
- Составные индексы для частых запросов
- Индексы на поля фильтрации (status, priority, dates)
- Индексы для полнотекстового поиска

### Триггеры
- Автоматическое обновление `updated_at` полей
- Расчет часов в time_entries при изменении времени

## Команды для демонстрации

### Показать структуру таблицы
```sql
\d users
\d+ projects  -- с дополнительной информацией
```

### Показать все таблицы
```sql
\dt
```

### Показать все индексы
```sql
\di
```

### Показать ограничения таблицы
```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'users';
```

### Статистика по данным
```sql
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes
FROM pg_stat_user_tables
ORDER BY n_tup_ins DESC;
```

## Полезные запросы для демонстрации

### 1. Иерархия задач (рекурсивный запрос)
```sql
WITH RECURSIVE task_hierarchy AS (
    SELECT id, title, parent_task_id, 0 as level
    FROM tasks 
    WHERE parent_task_id IS NULL AND project_id = 1
    
    UNION ALL
    
    SELECT t.id, t.title, t.parent_task_id, th.level + 1
    FROM tasks t
    JOIN task_hierarchy th ON t.parent_task_id = th.id
)
SELECT REPEAT('  ', level) || title as indented_title
FROM task_hierarchy
ORDER BY level, id;
```

### 2. Оконные функции
```sql
SELECT 
    u.first_name || ' ' || u.last_name as developer,
    SUM(te.hours) as total_hours,
    RANK() OVER (ORDER BY SUM(te.hours) DESC) as productivity_rank,
    LAG(SUM(te.hours)) OVER (ORDER BY SUM(te.hours) DESC) as prev_developer_hours
FROM users u
JOIN time_entries te ON u.id = te.user_id
WHERE u.role_id = 3
GROUP BY u.id, u.first_name, u.last_name;
```

### 3. Агрегация с GROUP BY и HAVING
```sql
SELECT 
    p.name,
    COUNT(t.id) as task_count,
    AVG(t.actual_hours) as avg_hours_per_task,
    SUM(te.hours * te.hourly_rate) as total_cost
FROM projects p
JOIN tasks t ON p.id = t.project_id
JOIN time_entries te ON t.id = te.task_id
GROUP BY p.id, p.name
HAVING COUNT(t.id) > 2 AND SUM(te.hours * te.hourly_rate) > 1000
ORDER BY total_cost DESC;
```

## Troubleshooting

### Если возникают ошибки с правами доступа:
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_username;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_username;
```

### Если нужно пересоздать базу:
```sql
-- Удалить все таблицы
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
-- Затем запустить setup_database.sql заново
```

### Проверка целостности данных:
```sql
-- Проверить внешние ключи
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public';
```

## Автор
[Ваше ФИО]  
[Номер группы]  
Лабораторная работа №3 - Физическая модель базы данных
