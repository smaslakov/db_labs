# Описание сущностей базы данных

## Список сущностей (14 основных таблиц)

1. **users** - Пользователи системы
2. **roles** - Роли пользователей
3. **permissions** - Разрешения системы
4. **role_permissions** - Связь ролей и разрешений (MTM)
5. **user_sessions** - Сессии пользователей
6. **audit_logs** - Журнал действий пользователей
7. **clients** - Клиенты студии
8. **projects** - Проекты
9. **project_members** - Участники проектов (MTM)
10. **tasks** - Задачи
11. **task_statuses** - Статусы задач
12. **time_entries** - Учет рабочего времени
13. **invoices** - Счета для клиентов
14. **payments** - Платежи по счетам

## Детальное описание сущностей

### 1. users (Пользователи)
**Описание**: Хранит информацию о всех пользователях системы

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор пользователя |
| username | VARCHAR(50) | UNIQUE, NOT NULL | Логин пользователя |
| email | VARCHAR(100) | UNIQUE, NOT NULL | Электронная почта |
| password_hash | VARCHAR(255) | NOT NULL | Хеш пароля |
| first_name | VARCHAR(50) | NOT NULL | Имя |
| last_name | VARCHAR(50) | NOT NULL | Фамилия |
| role_id | INTEGER | NOT NULL, FK → roles.id | Роль пользователя |
| hourly_rate | DECIMAL(10,2) | DEFAULT 0 | Ставка за час работы |
| is_active | BOOLEAN | DEFAULT TRUE | Активен ли пользователь |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |

**Связи**:
- 1:N с projects (как менеджер проекта)
- N:M с projects через project_members
- 1:N с tasks (как исполнитель)
- 1:N с time_entries
- 1:N с audit_logs

### 2. roles (Роли)
**Описание**: Определяет роли пользователей в системе

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор роли |
| name | VARCHAR(50) | UNIQUE, NOT NULL | Название роли |
| description | TEXT | | Описание роли |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |

**Связи**:
- 1:N с users
- N:M с permissions через role_permissions

### 3. permissions (Разрешения)
**Описание**: Определяет различные разрешения в системе

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор разрешения |
| name | VARCHAR(100) | UNIQUE, NOT NULL | Название разрешения |
| description | TEXT | | Описание разрешения |
| resource | VARCHAR(50) | NOT NULL | Ресурс (users, projects, tasks и т.д.) |
| action | VARCHAR(20) | NOT NULL | Действие (create, read, update, delete) |

**Связи**:
- N:M с roles через role_permissions

### 4. role_permissions (Связь ролей и разрешений)
**Описание**: Промежуточная таблица для связи ролей и разрешений

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор |
| role_id | INTEGER | NOT NULL, FK → roles.id | ID роли |
| permission_id | INTEGER | NOT NULL, FK → permissions.id | ID разрешения |
| granted_at | TIMESTAMP | DEFAULT NOW() | Дата предоставления разрешения |

**Связи**:
- N:1 с roles
- N:1 с permissions

### 5. user_sessions (Сессии пользователей)
**Описание**: Управление сессиями пользователей

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор сессии |
| user_id | INTEGER | NOT NULL, FK → users.id | ID пользователя |
| session_token | VARCHAR(255) | UNIQUE, NOT NULL | Токен сессии |
| ip_address | INET | | IP-адрес пользователя |
| user_agent | TEXT | | Информация о браузере |
| created_at | TIMESTAMP | DEFAULT NOW() | Время создания сессии |
| expires_at | TIMESTAMP | NOT NULL | Время истечения сессии |
| is_active | BOOLEAN | DEFAULT TRUE | Активна ли сессия |

**Связи**:
- N:1 с users

### 6. audit_logs (Журнал действий)
**Описание**: Ведение журнала всех важных действий в системе

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор записи |
| user_id | INTEGER | FK → users.id | ID пользователя (может быть NULL для системных действий) |
| action | VARCHAR(50) | NOT NULL | Тип действия |
| resource_type | VARCHAR(50) | NOT NULL | Тип ресурса |
| resource_id | INTEGER | | ID ресурса |
| old_values | JSONB | | Старые значения (для UPDATE) |
| new_values | JSONB | | Новые значения |
| ip_address | INET | | IP-адрес |
| user_agent | TEXT | | Информация о браузере |
| created_at | TIMESTAMP | DEFAULT NOW() | Время действия |

**Связи**:
- N:1 с users

### 7. clients (Клиенты)
**Описание**: Информация о клиентах студии

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор клиента |
| company_name | VARCHAR(100) | NOT NULL | Название компании |
| contact_person | VARCHAR(100) | NOT NULL | Контактное лицо |
| email | VARCHAR(100) | UNIQUE, NOT NULL | Электронная почта |
| phone | VARCHAR(20) | | Телефон |
| address | TEXT | | Адрес |
| website | VARCHAR(255) | | Веб-сайт |
| tax_id | VARCHAR(50) | | Налоговый номер |
| notes | TEXT | | Заметки о клиенте |
| is_active | BOOLEAN | DEFAULT TRUE | Активен ли клиент |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |

**Связи**:
- 1:N с projects
- 1:N с invoices

### 8. projects (Проекты)
**Описание**: Проекты, выполняемые студией

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор проекта |
| name | VARCHAR(150) | NOT NULL | Название проекта |
| description | TEXT | | Описание проекта |
| client_id | INTEGER | NOT NULL, FK → clients.id | ID клиента |
| manager_id | INTEGER | NOT NULL, FK → users.id | ID менеджера проекта |
| status | VARCHAR(20) | DEFAULT 'planning' | Статус проекта |
| priority | VARCHAR(10) | DEFAULT 'medium' | Приоритет (low, medium, high, critical) |
| estimated_budget | DECIMAL(12,2) | | Планируемый бюджет |
| actual_cost | DECIMAL(12,2) | DEFAULT 0 | Фактические затраты |
| estimated_hours | INTEGER | | Планируемые часы |
| actual_hours | INTEGER | DEFAULT 0 | Фактические часы |
| start_date | DATE | NOT NULL | Дата начала |
| end_date | DATE | | Планируемая дата окончания |
| actual_end_date | DATE | | Фактическая дата окончания |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |

**Связи**:
- N:1 с clients
- N:1 с users (менеджер)
- N:M с users через project_members
- 1:N с tasks
- 1:N с invoices

### 9. project_members (Участники проектов)
**Описание**: Связь между пользователями и проектами

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор |
| project_id | INTEGER | NOT NULL, FK → projects.id | ID проекта |
| user_id | INTEGER | NOT NULL, FK → users.id | ID пользователя |
| role_in_project | VARCHAR(50) | NOT NULL | Роль в проекте |
| joined_at | TIMESTAMP | DEFAULT NOW() | Дата присоединения |
| left_at | TIMESTAMP | | Дата выхода из проекта |
| is_active | BOOLEAN | DEFAULT TRUE | Активен ли участник |

**Связи**:
- N:1 с projects
- N:1 с users

### 10. tasks (Задачи)
**Описание**: Задачи в рамках проектов

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор задачи |
| project_id | INTEGER | NOT NULL, FK → projects.id | ID проекта |
| title | VARCHAR(200) | NOT NULL | Название задачи |
| description | TEXT | | Описание задачи |
| status_id | INTEGER | NOT NULL, FK → task_statuses.id | ID статуса |
| assigned_user_id | INTEGER | FK → users.id | ID исполнителя |
| created_by_user_id | INTEGER | NOT NULL, FK → users.id | ID создателя задачи |
| priority | VARCHAR(10) | DEFAULT 'medium' | Приоритет |
| estimated_hours | INTEGER | | Планируемые часы |
| actual_hours | INTEGER | DEFAULT 0 | Фактические часы |
| due_date | TIMESTAMP | | Срок выполнения |
| parent_task_id | INTEGER | FK → tasks.id | Родительская задача (для подзадач) |
| completion_percentage | INTEGER | DEFAULT 0 | Процент выполнения |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |
| completed_at | TIMESTAMP | | Дата завершения |

**Связи**:
- N:1 с projects
- N:1 с task_statuses
- N:1 с users (исполнитель)
- N:1 с users (создатель)
- 1:N с tasks (подзадачи)
- 1:N с time_entries

### 11. task_statuses (Статусы задач)
**Описание**: Возможные статусы задач

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор статуса |
| name | VARCHAR(50) | UNIQUE, NOT NULL | Название статуса |
| description | TEXT | | Описание статуса |
| color | VARCHAR(7) | | Цвет для отображения (HEX) |
| is_final | BOOLEAN | DEFAULT FALSE | Является ли статус финальным |
| sort_order | INTEGER | DEFAULT 0 | Порядок сортировки |

**Связи**:
- 1:N с tasks

### 12. time_entries (Учет времени)
**Описание**: Учет рабочего времени по задачам

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор записи |
| user_id | INTEGER | NOT NULL, FK → users.id | ID пользователя |
| task_id | INTEGER | NOT NULL, FK → tasks.id | ID задачи |
| start_time | TIMESTAMP | NOT NULL | Время начала работы |
| end_time | TIMESTAMP | | Время окончания работы |
| hours | DECIMAL(5,2) | | Количество часов (рассчитывается автоматически) |
| description | TEXT | | Описание выполненной работы |
| is_billable | BOOLEAN | DEFAULT TRUE | Оплачиваемые ли часы |
| hourly_rate | DECIMAL(10,2) | | Ставка за час (берется из профиля пользователя) |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания записи |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |

**Связи**:
- N:1 с users
- N:1 с tasks

### 13. invoices (Счета)
**Описание**: Счета, выставляемые клиентам

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор счета |
| invoice_number | VARCHAR(50) | UNIQUE, NOT NULL | Номер счета |
| client_id | INTEGER | NOT NULL, FK → clients.id | ID клиента |
| project_id | INTEGER | FK → projects.id | ID проекта (может быть NULL для общих счетов) |
| issue_date | DATE | NOT NULL | Дата выставления |
| due_date | DATE | NOT NULL | Срок оплаты |
| subtotal | DECIMAL(12,2) | NOT NULL | Сумма без НДС |
| tax_rate | DECIMAL(5,2) | DEFAULT 0 | Ставка НДС |
| tax_amount | DECIMAL(12,2) | DEFAULT 0 | Сумма НДС |
| total_amount | DECIMAL(12,2) | NOT NULL | Итоговая сумма |
| status | VARCHAR(20) | DEFAULT 'draft' | Статус счета |
| notes | TEXT | | Примечания |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания |
| updated_at | TIMESTAMP | DEFAULT NOW() | Дата последнего обновления |

**Связи**:
- N:1 с clients
- N:1 с projects
- 1:N с payments

### 14. payments (Платежи)
**Описание**: Платежи по счетам

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| id | SERIAL | PRIMARY KEY | Уникальный идентификатор платежа |
| invoice_id | INTEGER | NOT NULL, FK → invoices.id | ID счета |
| amount | DECIMAL(12,2) | NOT NULL | Сумма платежа |
| payment_date | DATE | NOT NULL | Дата платежа |
| payment_method | VARCHAR(50) | NOT NULL | Способ оплаты |
| transaction_id | VARCHAR(100) | | ID транзакции |
| notes | TEXT | | Примечания |
| created_at | TIMESTAMP | DEFAULT NOW() | Дата создания записи |

**Связи**:
- N:1 с invoices

## Типы связей в базе данных

### Один-к-одному (1:1)
- **users ↔ user_sessions** (текущая активная сессия)

### Один-ко-многим (1:N)
- **roles → users** (одна роль у многих пользователей)
- **users → projects** (один менеджер для многих проектов)
- **clients → projects** (один клиент может иметь много проектов)
- **projects → tasks** (один проект содержит много задач)
- **task_statuses → tasks** (один статус у многих задач)
- **users → tasks** (один исполнитель для многих задач)
- **tasks → time_entries** (одна задача имеет много записей времени)
- **users → time_entries** (один пользователь делает много записей времени)
- **clients → invoices** (один клиент может иметь много счетов)
- **projects → invoices** (один проект может иметь много счетов)
- **invoices → payments** (один счет может иметь много платежей)
- **users → audit_logs** (один пользователь создает много записей в логе)

### Многие-ко-многим (N:M)
- **roles ↔ permissions** через role_permissions
- **users ↔ projects** через project_members (пользователи могут участвовать в нескольких проектах)

### Самосвязь
- **tasks → tasks** (родительская задача - подзадачи)

## Ограничения и индексы

### Основные ограничения:
- **PRIMARY KEY** для всех таблиц
- **FOREIGN KEY** для поддержания ссылочной целостности
- **UNIQUE** для уникальных полей (email, username, invoice_number)
- **NOT NULL** для обязательных полей
- **CHECK** ограничения для валидации данных (например, priority IN ('low', 'medium', 'high', 'critical'))

### Рекомендуемые индексы:
- **users**: username, email
- **projects**: client_id, manager_id, status
- **tasks**: project_id, assigned_user_id, status_id
- **time_entries**: user_id, task_id, start_time
- **audit_logs**: user_id, action, created_at
- **invoices**: client_id, invoice_number
- **payments**: invoice_id, payment_date
