-- =====================================================
-- Migration 003: Insert Test Data
-- Description: Insert test data for all tables
-- Author: [Your Name]
-- Date: 2024
-- =====================================================

-- =====================================================
-- REFERENCE DATA (must be inserted first)
-- =====================================================

-- Insert roles
INSERT INTO roles (name, description) VALUES 
('Administrator', 'Full system access with all permissions'),
('Project Manager', 'Manages projects, clients, and team assignments'),
('Developer', 'Works on assigned tasks and logs time'),
('Client', 'Views project status and communicates with team');

-- Insert permissions
INSERT INTO permissions (name, description, resource, action) VALUES 
-- User permissions
('users_create', 'Create new users', 'users', 'create'),
('users_read', 'View user information', 'users', 'read'),
('users_update', 'Update user information', 'users', 'update'),
('users_delete', 'Delete users', 'users', 'delete'),

-- Project permissions
('projects_create', 'Create new projects', 'projects', 'create'),
('projects_read', 'View project information', 'projects', 'read'),
('projects_update', 'Update project information', 'projects', 'update'),
('projects_delete', 'Delete projects', 'projects', 'delete'),

-- Task permissions
('tasks_create', 'Create new tasks', 'tasks', 'create'),
('tasks_read', 'View task information', 'tasks', 'read'),
('tasks_update', 'Update task information', 'tasks', 'update'),
('tasks_delete', 'Delete tasks', 'tasks', 'delete'),

-- Client permissions
('clients_create', 'Create new clients', 'clients', 'create'),
('clients_read', 'View client information', 'clients', 'read'),
('clients_update', 'Update client information', 'clients', 'update'),
('clients_delete', 'Delete clients', 'clients', 'delete'),

-- Time tracking permissions
('time_create', 'Log time entries', 'time_entries', 'create'),
('time_read', 'View time entries', 'time_entries', 'read'),
('time_update', 'Update time entries', 'time_entries', 'update'),
('time_delete', 'Delete time entries', 'time_entries', 'delete'),

-- Financial permissions
('invoices_create', 'Create invoices', 'invoices', 'create'),
('invoices_read', 'View invoices', 'invoices', 'read'),
('invoices_update', 'Update invoices', 'invoices', 'update'),
('invoices_delete', 'Delete invoices', 'invoices', 'delete');

-- Insert task statuses
INSERT INTO task_statuses (name, description, color, is_final, sort_order) VALUES 
('New', 'Newly created task', '#6c757d', FALSE, 1),
('In Progress', 'Task is being worked on', '#007bff', FALSE, 2),
('Review', 'Task is under review', '#ffc107', FALSE, 3),
('Testing', 'Task is being tested', '#17a2b8', FALSE, 4),
('Completed', 'Task is completed successfully', '#28a745', TRUE, 5),
('Rejected', 'Task was rejected and needs rework', '#dc3545', TRUE, 6),
('On Hold', 'Task is temporarily paused', '#6f42c1', FALSE, 7);

-- =====================================================
-- ASSIGN PERMISSIONS TO ROLES
-- =====================================================

-- Administrator gets all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, p.id FROM permissions p;

-- Project Manager gets most permissions except user management
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, p.id FROM permissions p 
WHERE p.resource IN ('projects', 'tasks', 'clients', 'time_entries', 'invoices')
   OR (p.resource = 'users' AND p.action = 'read');

-- Developer gets limited permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, p.id FROM permissions p 
WHERE (p.resource = 'tasks' AND p.action IN ('read', 'update'))
   OR (p.resource = 'time_entries' AND p.action IN ('create', 'read', 'update'))
   OR (p.resource = 'projects' AND p.action = 'read');

-- Client gets read-only permissions for their projects
INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, p.id FROM permissions p 
WHERE p.resource IN ('projects', 'tasks', 'invoices') AND p.action = 'read';

-- =====================================================
-- MAIN ENTITY DATA
-- =====================================================

-- Insert users (passwords are hashed versions of 'password123')
INSERT INTO users (username, email, password_hash, first_name, last_name, role_id, hourly_rate) VALUES 
('admin', 'admin@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'John', 'Smith', 1, 0),
('manager1', 'alice@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Alice', 'Johnson', 2, 75.00),
('manager2', 'bob@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Bob', 'Wilson', 2, 80.00),
('dev1', 'charlie@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Charlie', 'Brown', 3, 65.00),
('dev2', 'diana@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Diana', 'Davis', 3, 70.00),
('dev3', 'eve@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Eve', 'Miller', 3, 60.00),
('dev4', 'frank@itstudio.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Frank', 'Garcia', 3, 68.00),
('client1', 'contact@techcorp.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj.0n0jm/EHu', 'Sarah', 'Connor', 4, 0);

-- Insert clients
INSERT INTO clients (company_name, contact_person, email, phone, address, website, tax_id) VALUES 
('TechCorp Solutions', 'Sarah Connor', 'contact@techcorp.com', '+1-555-0101', '123 Tech Street, Silicon Valley, CA 94000', 'https://techcorp.com', 'TC123456789'),
('Digital Innovations Ltd', 'Michael Scott', 'mike@digitalinnovations.com', '+1-555-0102', '456 Innovation Ave, Austin, TX 78701', 'https://digitalinnovations.com', 'DI987654321'),
('StartupXYZ', 'Emma Watson', 'emma@startupxyz.io', '+1-555-0103', '789 Startup Blvd, Seattle, WA 98101', 'https://startupxyz.io', 'SU456789123'),
('Enterprise Global', 'James Bond', 'james@enterprise-global.com', '+1-555-0104', '321 Enterprise Way, New York, NY 10001', 'https://enterprise-global.com', 'EG789123456'),
('LocalBusiness Inc', 'Jane Doe', 'jane@localbusiness.com', '+1-555-0105', '654 Main Street, Denver, CO 80201', 'https://localbusiness.com', 'LB321654987');

-- Insert projects
INSERT INTO projects (name, description, client_id, manager_id, status, priority, estimated_budget, estimated_hours, start_date, end_date) VALUES 
('E-commerce Platform', 'Complete e-commerce solution with payment integration and inventory management', 1, 2, 'active', 'high', 150000.00, 800, '2024-01-15', '2024-06-30'),
('Mobile App Development', 'Cross-platform mobile app for customer engagement', 2, 2, 'active', 'medium', 85000.00, 600, '2024-02-01', '2024-05-15'),
('Data Analytics Dashboard', 'Business intelligence dashboard with real-time reporting', 3, 3, 'planning', 'high', 120000.00, 700, '2024-03-01', '2024-07-31'),
('Website Redesign', 'Complete website overhaul with modern design and SEO optimization', 4, 2, 'testing', 'medium', 45000.00, 300, '2024-01-01', '2024-04-30'),
('API Integration', 'Third-party API integration and documentation', 5, 3, 'completed', 'low', 25000.00, 150, '2023-11-01', '2024-01-31');

-- Insert project members
INSERT INTO project_members (project_id, user_id, role_in_project) VALUES 
-- E-commerce Platform team
(1, 4, 'Lead Developer'),
(1, 5, 'Frontend Developer'),
(1, 6, 'Backend Developer'),
-- Mobile App team
(2, 5, 'Lead Developer'),
(2, 7, 'Mobile Developer'),
-- Data Analytics team
(3, 4, 'Data Engineer'),
(3, 6, 'Backend Developer'),
-- Website Redesign team
(4, 5, 'Frontend Developer'),
(4, 7, 'UI/UX Developer'),
-- API Integration team
(5, 6, 'API Developer');

-- Insert tasks
INSERT INTO tasks (project_id, title, description, status_id, assigned_user_id, created_by_user_id, priority, estimated_hours, due_date) VALUES 
-- E-commerce Platform tasks
(1, 'Set up development environment', 'Configure development servers and databases', 5, 4, 2, 'high', 8, '2024-01-20'),
(1, 'Design database schema', 'Create ERD and implement database structure', 5, 4, 2, 'high', 16, '2024-01-25'),
(1, 'Implement user authentication', 'Create login/logout functionality with JWT tokens', 2, 4, 2, 'high', 24, '2024-02-15'),
(1, 'Build product catalog', 'Create product listing and search functionality', 2, 5, 2, 'medium', 32, '2024-03-01'),
(1, 'Payment gateway integration', 'Integrate Stripe payment processing', 1, 6, 2, 'high', 40, '2024-03-15'),

-- Mobile App tasks
(2, 'UI/UX Design mockups', 'Create wireframes and visual designs', 5, 5, 2, 'high', 20, '2024-02-10'),
(2, 'Set up React Native project', 'Initialize project structure and dependencies', 5, 7, 2, 'medium', 8, '2024-02-15'),
(2, 'Implement navigation', 'Create app navigation and routing', 3, 7, 2, 'medium', 16, '2024-02-28'),
(2, 'User profile functionality', 'Create user registration and profile management', 2, 5, 2, 'medium', 24, '2024-03-20'),

-- Data Analytics tasks
(3, 'Requirements analysis', 'Gather and document business requirements', 2, 4, 3, 'high', 16, '2024-03-15'),
(3, 'Data source integration', 'Connect to various data sources and APIs', 1, 6, 3, 'high', 32, '2024-04-01'),

-- Website Redesign tasks
(4, 'Content audit', 'Review and organize existing website content', 5, 5, 2, 'low', 12, '2024-01-15'),
(4, 'New design implementation', 'Code the new responsive design', 4, 5, 2, 'high', 40, '2024-03-01'),
(4, 'SEO optimization', 'Implement SEO best practices', 3, 7, 2, 'medium', 16, '2024-04-15'),

-- API Integration tasks
(5, 'API documentation review', 'Study third-party API documentation', 5, 6, 3, 'medium', 8, '2023-11-05'),
(5, 'Integration implementation', 'Code the API integration layer', 5, 6, 3, 'high', 32, '2023-12-15'),
(5, 'Testing and debugging', 'Test all API endpoints and fix issues', 5, 6, 3, 'medium', 16, '2024-01-20');

-- Insert some subtasks
INSERT INTO tasks (project_id, title, description, status_id, assigned_user_id, created_by_user_id, priority, estimated_hours, parent_task_id, due_date) VALUES 
(1, 'Create user registration form', 'Frontend form for user registration', 2, 5, 2, 'medium', 8, 3, '2024-02-10'),
(1, 'Implement password validation', 'Add password strength validation', 1, 4, 2, 'low', 4, 3, '2024-02-12');

-- Insert time entries
INSERT INTO time_entries (user_id, task_id, start_time, end_time, hours, description, hourly_rate) VALUES 
-- Charlie's work
(4, 1, '2024-01-15 09:00:00', '2024-01-15 17:00:00', 8.0, 'Set up Docker containers and PostgreSQL database', 65.00),
(4, 2, '2024-01-16 09:00:00', '2024-01-16 13:00:00', 4.0, 'Created initial ERD and started database schema', 65.00),
(4, 2, '2024-01-17 09:00:00', '2024-01-17 17:00:00', 8.0, 'Completed database schema and added constraints', 65.00),
(4, 2, '2024-01-18 09:00:00', '2024-01-18 13:00:00', 4.0, 'Added indexes and optimized queries', 65.00),
(4, 3, '2024-01-22 09:00:00', '2024-01-22 17:00:00', 8.0, 'Implemented JWT authentication service', 65.00),

-- Diana's work
(5, 4, '2024-02-01 09:00:00', '2024-02-01 17:00:00', 8.0, 'Created product listing components', 70.00),
(5, 4, '2024-02-02 09:00:00', '2024-02-02 17:00:00', 8.0, 'Implemented search and filtering functionality', 70.00),
(5, 8, '2024-02-05 09:00:00', '2024-02-05 17:00:00', 8.0, 'Created wireframes and user flow diagrams', 70.00),
(5, 17, '2024-02-06 09:00:00', '2024-02-06 13:00:00', 4.0, 'Built registration form with validation', 70.00),

-- Eve's work
(6, 5, '2024-02-15 10:00:00', '2024-02-15 18:00:00', 8.0, 'Research Stripe API and payment flows', 60.00),
(6, 15, '2024-11-05 09:00:00', '2024-11-05 17:00:00', 8.0, 'Read API documentation and created integration plan', 60.00),
(6, 16, '2023-12-01 09:00:00', '2023-12-01 17:00:00', 8.0, 'Implemented basic API client', 60.00),
(6, 16, '2023-12-02 09:00:00', '2023-12-02 17:00:00', 8.0, 'Added error handling and retry logic', 60.00);

-- Insert invoices
INSERT INTO invoices (invoice_number, client_id, project_id, issue_date, due_date, subtotal, tax_rate, tax_amount, total_amount, status) VALUES 
('INV-2024-001', 1, 1, '2024-02-01', '2024-03-03', 25000.00, 10.00, 2500.00, 27500.00, 'paid'),
('INV-2024-002', 2, 2, '2024-02-15', '2024-03-17', 15000.00, 10.00, 1500.00, 16500.00, 'sent'),
('INV-2024-003', 4, 4, '2024-03-01', '2024-04-01', 18000.00, 10.00, 1800.00, 19800.00, 'draft'),
('INV-2024-004', 5, 5, '2024-01-31', '2024-03-02', 25000.00, 10.00, 2500.00, 27500.00, 'paid');

-- Insert payments
INSERT INTO payments (invoice_id, amount, payment_date, payment_method, transaction_id) VALUES 
(1, 27500.00, '2024-02-28', 'Bank Transfer', 'TXN-001-2024'),
(4, 27500.00, '2024-02-15', 'Credit Card', 'TXN-002-2024');

-- Insert some audit log entries
INSERT INTO audit_logs (user_id, action, resource_type, resource_id, new_values) VALUES 
(1, 'CREATE', 'projects', 1, '{"name": "E-commerce Platform", "status": "planning"}'),
(2, 'UPDATE', 'projects', 1, '{"status": "active"}'),
(2, 'CREATE', 'tasks', 1, '{"title": "Set up development environment", "status_id": 1}'),
(4, 'UPDATE', 'tasks', 1, '{"status_id": 5}'),
(1, 'CREATE', 'users', 4, '{"username": "dev1", "role_id": 3}');

-- Insert user sessions (some active, some expired)
INSERT INTO user_sessions (user_id, session_token, ip_address, user_agent, expires_at, is_active) VALUES 
(1, 'sess_admin_' || generate_random_uuid()::text, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', NOW() + INTERVAL '7 days', TRUE),
(2, 'sess_manager1_' || generate_random_uuid()::text, '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', NOW() + INTERVAL '7 days', TRUE),
(4, 'sess_dev1_' || generate_random_uuid()::text, '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', NOW() + INTERVAL '7 days', TRUE),
(5, 'sess_dev2_expired_' || generate_random_uuid()::text, '192.168.1.103', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', NOW() - INTERVAL '1 day', FALSE);

-- =====================================================
-- UPDATE CALCULATED FIELDS
-- =====================================================

-- Update actual hours in projects based on time entries
UPDATE projects 
SET actual_hours = (
    SELECT COALESCE(SUM(te.hours), 0)
    FROM time_entries te
    JOIN tasks t ON te.task_id = t.id
    WHERE t.project_id = projects.id
);

-- Update actual cost in projects based on time entries
UPDATE projects 
SET actual_cost = (
    SELECT COALESCE(SUM(te.hours * te.hourly_rate), 0)
    FROM time_entries te
    JOIN tasks t ON te.task_id = t.id
    WHERE t.project_id = projects.id
);

-- Update actual hours in tasks based on time entries
UPDATE tasks 
SET actual_hours = (
    SELECT COALESCE(SUM(te.hours), 0)
    FROM time_entries te
    WHERE te.task_id = tasks.id
);

-- Success message
SELECT 'Test data inserted successfully!' as status;

-- Show summary statistics
SELECT 
    'Data Summary' as info,
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM clients) as clients_count,
    (SELECT COUNT(*) FROM projects) as projects_count,
    (SELECT COUNT(*) FROM tasks) as tasks_count,
    (SELECT COUNT(*) FROM time_entries) as time_entries_count,
    (SELECT COUNT(*) FROM invoices) as invoices_count,
    (SELECT COUNT(*) FROM payments) as payments_count;
