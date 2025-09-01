# Инфологическая модель базы данных

## Схема базы данных

Выше представлена ER-диаграмма ненормализованной схемы базы данных для системы управления портфелем заказов IT-студии.

## Описание связей

### Основные связи между сущностями:

#### 1. Управление пользователями и ролями
- **users ← roles** (N:1): Каждый пользователь имеет одну роль
- **roles ← role_permissions → permissions** (N:M): Роли связаны с разрешениями через промежуточную таблицу
- **users → user_sessions** (1:N): Пользователь может иметь несколько активных сессий
- **users → audit_logs** (1:N): Пользователь создает множество записей в журнале

#### 2. Управление проектами
- **clients → projects** (1:N): Клиент может заказать несколько проектов
- **users → projects** (1:N): Пользователь-менеджер может управлять несколькими проектами
- **users ← project_members → projects** (N:M): Пользователи могут участвовать в нескольких проектах, проект может включать нескольких участников

#### 3. Управление задачами
- **projects → tasks** (1:N): Проект содержит множество задач
- **task_statuses → tasks** (1:N): Статус может быть у множества задач
- **users → tasks** (1:N): Пользователь может быть назначен на несколько задач
- **users → tasks** (1:N): Пользователь может создать несколько задач (created_by)
- **tasks → tasks** (1:N): Задача может иметь подзадачи (самосвязь)

#### 4. Учет времени
- **users → time_entries** (1:N): Пользователь может иметь множество записей времени
- **tasks → time_entries** (1:N): Задача может иметь множество записей времени

#### 5. Финансовое управление
- **clients → invoices** (1:N): Клиент может получить несколько счетов
- **projects → invoices** (1:N): Проект может иметь несколько счетов
- **invoices → payments** (1:N): Счет может быть оплачен несколькими платежами

## Особенности ненормализованной схемы

В данной схеме присутствуют следующие особенности, которые будут устранены при нормализации:

### 1. Дублирование данных
- **hourly_rate** хранится как в таблице `users`, так и дублируется в `time_entries`
- **actual_hours** рассчитывается и хранится как в `tasks`, так и в `projects`
- **total_amount**, `tax_amount` в `invoices` могут быть рассчитаны на основе других полей

### 2. Составные атрибуты
- **address** в таблице `clients` содержит составную информацию (улица, город, страна)
- **user_agent** может содержать составную информацию о браузере и ОС

### 3. Многозначные атрибуты
- **notes** в различных таблицах могут содержать структурированную информацию
- **old_values** и **new_values** в `audit_logs` содержат JSON с различными полями

### 4. Транзитивные зависимости
- **tax_amount** зависит от **subtotal** и **tax_rate**
- **total_amount** зависит от **subtotal** и **tax_amount**
- **actual_cost** в проектах зависит от суммы всех связанных записей времени

## Обоснование количества сущностей

Система содержит **14 основных сущностей**, что превышает минимальное требование в 10 таблиц:

1. **users** - основная сущность пользователей
2. **roles** - роли пользователей
3. **permissions** - разрешения системы
4. **role_permissions** - связующая таблица (содержит дополнительную информацию: granted_at)
5. **user_sessions** - управление сессиями
6. **audit_logs** - журналирование действий
7. **clients** - клиенты студии
8. **projects** - проекты
9. **project_members** - участники проектов (содержит дополнительную информацию: role_in_project, joined_at, left_at)
10. **task_statuses** - справочник статусов задач
11. **tasks** - задачи проектов
12. **time_entries** - учет рабочего времени
13. **invoices** - счета для клиентов
14. **payments** - платежи по счетам

## Присутствие всех типов связей

### 1. Один-к-одному (1:1)
Хотя в схеме нет явных связей 1:1, можно выделить потенциальные:
- Текущая активная сессия пользователя (ограничением можно сделать только одну активную сессию)

### 2. Один-ко-многим (1:N)
- clients → projects
- users → projects (как менеджер)
- projects → tasks
- task_statuses → tasks
- users → tasks (как исполнитель)
- users → time_entries
- tasks → time_entries
- clients → invoices
- invoices → payments
- roles → users
- И многие другие

### 3. Многие-ко-многим (N:M)
- **users ← project_members → projects**: Пользователи участвуют в проектах
- **roles ← role_permissions → permissions**: Роли имеют разрешения

### 4. Самосвязь (рекурсивная)
- **tasks → tasks**: Родительские задачи и подзадачи (parent_task_id)

## Индексы для оптимизации

Для эффективной работы с данной схемой рекомендуется создать следующие индексы:

```sql
-- Основные индексы для поиска
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_projects_client_id ON projects(client_id);
CREATE INDEX idx_projects_manager_id ON projects(manager_id);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_assigned_user_id ON tasks(assigned_user_id);
CREATE INDEX idx_time_entries_user_id ON time_entries(user_id);
CREATE INDEX idx_time_entries_task_id ON time_entries(task_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Составные индексы для сложных запросов
CREATE INDEX idx_time_entries_user_task ON time_entries(user_id, task_id);
CREATE INDEX idx_project_members_project_user ON project_members(project_id, user_id);
```

Данная схема обеспечивает полную функциональность системы управления проектами IT-студии и готова для дальнейшей нормализации в рамках второй лабораторной работы.
