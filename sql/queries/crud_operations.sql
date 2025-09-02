-- =====================================================
-- CRUD Operations for IT Studio Portfolio Management System
-- Description: Basic Create, Read, Update, Delete operations for all entities
-- Author: [Your Name]
-- Date: 2024
-- =====================================================

-- =====================================================
-- USERS CRUD OPERATIONS
-- =====================================================

-- CREATE: Add new user
-- Example: Create a new developer
INSERT INTO users (username, email, password_hash, first_name, last_name, role_id, hourly_rate)
VALUES ('newdev', 'newdev@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 
        'Alex', 'Thompson', 3, 72.00);

-- READ: Get all active users with their roles
SELECT u.id, u.username, u.email, u.first_name, u.last_name, u.hourly_rate,
       r.name as role_name, u.created_at
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.is_active = TRUE
ORDER BY u.created_at DESC;

-- READ: Get user by ID with detailed information
SELECT u.*, r.name as role_name, r.description as role_description
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.id = 1;

-- READ: Get users by role
SELECT u.id, u.username, CONCAT(u.first_name, ' ', u.last_name) as full_name, u.email
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Developer' AND u.is_active = TRUE;

-- UPDATE: Update user information
UPDATE users 
SET first_name = 'Alexander', 
    last_name = 'Thompson-Smith', 
    hourly_rate = 75.00,
    updated_at = NOW()
WHERE username = 'newdev';

-- UPDATE: Change user role
UPDATE users 
SET role_id = 2, -- Change to Project Manager
    updated_at = NOW()
WHERE id = 8;

-- DELETE: Soft delete user (deactivate)
UPDATE users 
SET is_active = FALSE, 
    updated_at = NOW()
WHERE id = 8;

-- DELETE: Hard delete user (use with caution!)
-- DELETE FROM users WHERE id = 8;

-- =====================================================
-- CLIENTS CRUD OPERATIONS
-- =====================================================

-- CREATE: Add new client
INSERT INTO clients (company_name, contact_person, email, phone, address, website)
VALUES ('NewTech Solutions', 'Robert Johnson', 'robert@newtech.com', '+1-555-0199', 
        '999 Innovation Drive, Boston, MA 02101', 'https://newtech.com');

-- READ: Get all active clients
SELECT id, company_name, contact_person, email, phone, created_at
FROM clients
WHERE is_active = TRUE
ORDER BY company_name;

-- READ: Get client with their projects
SELECT c.*, 
       COUNT(p.id) as projects_count,
       SUM(p.estimated_budget) as total_estimated_budget,
       SUM(p.actual_cost) as total_actual_cost
FROM clients c
LEFT JOIN projects p ON c.id = p.client_id
WHERE c.id = 1
GROUP BY c.id;

-- UPDATE: Update client information
UPDATE clients 
SET contact_person = 'Robert J. Johnson',
    phone = '+1-555-0200',
    updated_at = NOW()
WHERE email = 'robert@newtech.com';

-- DELETE: Soft delete client
UPDATE clients 
SET is_active = FALSE,
    updated_at = NOW()
WHERE id = 6;

-- =====================================================
-- PROJECTS CRUD OPERATIONS
-- =====================================================

-- CREATE: Add new project
INSERT INTO projects (name, description, client_id, manager_id, status, priority, 
                     estimated_budget, estimated_hours, start_date, end_date)
VALUES ('Customer Portal', 'Self-service customer portal with account management', 
        1, 2, 'planning', 'medium', 95000.00, 500, '2024-04-01', '2024-08-31');

-- READ: Get all projects with client and manager info
SELECT p.id, p.name, p.status, p.priority, p.estimated_budget, p.actual_cost,
       c.company_name as client_name,
       CONCAT(u.first_name, ' ', u.last_name) as manager_name,
       p.start_date, p.end_date
FROM projects p
JOIN clients c ON p.client_id = c.id
JOIN users u ON p.manager_id = u.id
ORDER BY p.created_at DESC;

-- READ: Get project details with team members
SELECT p.*, c.company_name as client_name,
       CONCAT(m.first_name, ' ', m.last_name) as manager_name,
       COUNT(DISTINCT pm.user_id) as team_size,
       COUNT(DISTINCT t.id) as tasks_count,
       COUNT(DISTINCT CASE WHEN ts.is_final = TRUE THEN t.id END) as completed_tasks
FROM projects p
JOIN clients c ON p.client_id = c.id
JOIN users m ON p.manager_id = m.id
LEFT JOIN project_members pm ON p.id = pm.project_id AND pm.is_active = TRUE
LEFT JOIN tasks t ON p.id = t.project_id
LEFT JOIN task_statuses ts ON t.status_id = ts.id
WHERE p.id = 1
GROUP BY p.id, c.company_name, m.first_name, m.last_name;

-- UPDATE: Update project status and budget
UPDATE projects 
SET status = 'active',
    actual_cost = 15000.00,
    updated_at = NOW()
WHERE id = 6;

-- UPDATE: Close project
UPDATE projects 
SET status = 'completed',
    actual_end_date = CURRENT_DATE,
    updated_at = NOW()
WHERE id = 5;

-- DELETE: Delete project (this will cascade to related tasks)
-- DELETE FROM projects WHERE id = 6;

-- =====================================================
-- TASKS CRUD OPERATIONS
-- =====================================================

-- CREATE: Add new task
INSERT INTO tasks (project_id, title, description, status_id, assigned_user_id, 
                  created_by_user_id, priority, estimated_hours, due_date)
VALUES (1, 'Implement shopping cart', 'Create shopping cart functionality with session storage',
        1, 5, 2, 'high', 20, '2024-03-30 17:00:00');

-- READ: Get all tasks with project and assignee info
SELECT t.id, t.title, t.priority, t.estimated_hours, t.actual_hours, t.completion_percentage,
       p.name as project_name,
       ts.name as status_name, ts.color as status_color,
       CONCAT(u.first_name, ' ', u.last_name) as assigned_to,
       t.due_date, t.created_at
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_statuses ts ON t.status_id = ts.id
LEFT JOIN users u ON t.assigned_user_id = u.id
ORDER BY t.due_date ASC NULLS LAST, t.priority DESC;

-- READ: Get tasks assigned to specific user
SELECT t.id, t.title, p.name as project_name, ts.name as status, 
       t.due_date, t.completion_percentage
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_statuses ts ON t.status_id = ts.id
WHERE t.assigned_user_id = 4 AND ts.is_final = FALSE
ORDER BY t.due_date ASC NULLS LAST;

-- READ: Get task hierarchy (parent tasks with subtasks)
WITH RECURSIVE task_hierarchy AS (
    -- Base case: parent tasks (no parent_task_id)
    SELECT id, title, parent_task_id, 0 as level, ARRAY[id] as path
    FROM tasks 
    WHERE parent_task_id IS NULL AND project_id = 1
    
    UNION ALL
    
    -- Recursive case: subtasks
    SELECT t.id, t.title, t.parent_task_id, th.level + 1, th.path || t.id
    FROM tasks t
    JOIN task_hierarchy th ON t.parent_task_id = th.id
)
SELECT id, REPEAT('  ', level) || title as indented_title, level
FROM task_hierarchy
ORDER BY path;

-- UPDATE: Update task progress
UPDATE tasks 
SET completion_percentage = 75,
    actual_hours = 15,
    updated_at = NOW()
WHERE id = 3;

-- UPDATE: Complete task
UPDATE tasks 
SET status_id = (SELECT id FROM task_statuses WHERE name = 'Completed'),
    completion_percentage = 100,
    completed_at = NOW(),
    updated_at = NOW()
WHERE id = 18;

-- UPDATE: Reassign task
UPDATE tasks 
SET assigned_user_id = 6,
    updated_at = NOW()
WHERE id = 5;

-- DELETE: Delete task
-- DELETE FROM tasks WHERE id = 18;

-- =====================================================
-- TIME ENTRIES CRUD OPERATIONS
-- =====================================================

-- CREATE: Log time entry
INSERT INTO time_entries (user_id, task_id, start_time, end_time, hours, description, hourly_rate)
VALUES (4, 3, '2024-03-01 09:00:00', '2024-03-01 13:00:00', 4.0, 
        'Continued work on JWT authentication - added refresh token logic', 65.00);

-- READ: Get time entries for a user
SELECT te.id, te.start_time, te.end_time, te.hours, te.description,
       t.title as task_title, p.name as project_name,
       te.hourly_rate, (te.hours * te.hourly_rate) as cost
FROM time_entries te
JOIN tasks t ON te.task_id = t.id
JOIN projects p ON t.project_id = p.id
WHERE te.user_id = 4
ORDER BY te.start_time DESC;

-- READ: Get time entries for a project
SELECT te.id, te.start_time, te.hours, te.description,
       CONCAT(u.first_name, ' ', u.last_name) as user_name,
       t.title as task_title,
       (te.hours * te.hourly_rate) as cost
FROM time_entries te
JOIN users u ON te.user_id = u.id
JOIN tasks t ON te.task_id = t.id
WHERE t.project_id = 1
ORDER BY te.start_time DESC;

-- READ: Get daily time summary for user
SELECT DATE(te.start_time) as work_date,
       SUM(te.hours) as total_hours,
       SUM(te.hours * te.hourly_rate) as total_cost,
       COUNT(*) as entries_count
FROM time_entries te
WHERE te.user_id = 4 
  AND te.start_time >= '2024-01-01'
  AND te.start_time < '2024-02-01'
GROUP BY DATE(te.start_time)
ORDER BY work_date;

-- UPDATE: Update time entry
UPDATE time_entries 
SET end_time = '2024-03-01 14:00:00',
    hours = 5.0,
    description = 'JWT authentication with refresh tokens - completed implementation',
    updated_at = NOW()
WHERE id = (SELECT MAX(id) FROM time_entries);

-- DELETE: Delete time entry
-- DELETE FROM time_entries WHERE id = 15;

-- =====================================================
-- INVOICES CRUD OPERATIONS
-- =====================================================

-- CREATE: Create new invoice
INSERT INTO invoices (invoice_number, client_id, project_id, issue_date, due_date, 
                     subtotal, tax_rate, tax_amount, total_amount, status)
VALUES ('INV-2024-005', 1, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days',
        12000.00, 10.00, 1200.00, 13200.00, 'draft');

-- READ: Get all invoices with client info
SELECT i.id, i.invoice_number, i.issue_date, i.due_date, i.total_amount, i.status,
       c.company_name as client_name,
       p.name as project_name
FROM invoices i
JOIN clients c ON i.client_id = c.id
LEFT JOIN projects p ON i.project_id = p.id
ORDER BY i.issue_date DESC;

-- READ: Get invoice with payment history
SELECT i.*, c.company_name,
       COALESCE(SUM(pay.amount), 0) as paid_amount,
       (i.total_amount - COALESCE(SUM(pay.amount), 0)) as balance_due
FROM invoices i
JOIN clients c ON i.client_id = c.id
LEFT JOIN payments pay ON i.id = pay.invoice_id
WHERE i.id = 1
GROUP BY i.id, c.company_name;

-- UPDATE: Update invoice status
UPDATE invoices 
SET status = 'sent',
    updated_at = NOW()
WHERE invoice_number = 'INV-2024-005';

-- DELETE: Delete invoice
-- DELETE FROM invoices WHERE id = 5;

-- =====================================================
-- PAYMENTS CRUD OPERATIONS
-- =====================================================

-- CREATE: Record payment
INSERT INTO payments (invoice_id, amount, payment_date, payment_method, transaction_id, notes)
VALUES (5, 13200.00, CURRENT_DATE, 'Bank Transfer', 'TXN-005-2024', 'Full payment received');

-- READ: Get all payments
SELECT p.id, p.amount, p.payment_date, p.payment_method, p.transaction_id,
       i.invoice_number, c.company_name
FROM payments p
JOIN invoices i ON p.invoice_id = i.id
JOIN clients c ON i.client_id = c.id
ORDER BY p.payment_date DESC;

-- UPDATE: Update payment information
UPDATE payments 
SET notes = 'Full payment received via wire transfer'
WHERE transaction_id = 'TXN-005-2024';

-- DELETE: Delete payment
-- DELETE FROM payments WHERE id = 5;

-- =====================================================
-- COMPLEX READ OPERATIONS
-- =====================================================

-- Get project dashboard summary
SELECT p.id, p.name, p.status, p.priority,
       p.estimated_budget, p.actual_cost,
       p.estimated_hours, p.actual_hours,
       ROUND((p.actual_hours::numeric / NULLIF(p.estimated_hours, 0)) * 100, 2) as hours_completion_pct,
       ROUND((p.actual_cost / NULLIF(p.estimated_budget, 0)) * 100, 2) as budget_completion_pct,
       c.company_name as client_name,
       COUNT(DISTINCT t.id) as total_tasks,
       COUNT(DISTINCT CASE WHEN ts.is_final = TRUE THEN t.id END) as completed_tasks
FROM projects p
JOIN clients c ON p.client_id = c.id
LEFT JOIN tasks t ON p.id = t.project_id
LEFT JOIN task_statuses ts ON t.status_id = ts.id
GROUP BY p.id, c.company_name
ORDER BY p.created_at DESC;

-- Get user workload summary
SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) as full_name,
       COUNT(DISTINCT t.id) as active_tasks,
       SUM(t.estimated_hours) as estimated_hours,
       SUM(t.actual_hours) as actual_hours,
       COUNT(DISTINCT t.project_id) as projects_count
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_user_id
LEFT JOIN task_statuses ts ON t.status_id = ts.id
WHERE u.role_id = 3 AND u.is_active = TRUE AND (ts.is_final = FALSE OR ts.is_final IS NULL)
GROUP BY u.id, u.first_name, u.last_name
ORDER BY active_tasks DESC;

-- Get overdue tasks
SELECT t.id, t.title, t.due_date,
       p.name as project_name,
       CONCAT(u.first_name, ' ', u.last_name) as assigned_to,
       ts.name as status,
       EXTRACT(days FROM (CURRENT_TIMESTAMP - t.due_date)) as days_overdue
FROM tasks t
JOIN projects p ON t.project_id = p.id
LEFT JOIN users u ON t.assigned_user_id = u.id
JOIN task_statuses ts ON t.status_id = ts.id
WHERE t.due_date < CURRENT_TIMESTAMP AND ts.is_final = FALSE
ORDER BY t.due_date ASC;

-- Success message
SELECT 'CRUD operations examples completed!' as status;
