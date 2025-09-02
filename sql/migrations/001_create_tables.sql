-- =====================================================
-- Migration 001: Create Tables
-- Description: Create all tables for IT Studio Portfolio Management System
-- Author: [Your Name]
-- Date: 2024
-- =====================================================

-- Enable UUID extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- REFERENCE TABLES (created first to avoid FK issues)
-- =====================================================

-- Table: roles
-- Description: User roles in the system
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table: permissions  
-- Description: System permissions
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL
);

-- Table: task_statuses
-- Description: Possible task statuses
CREATE TABLE task_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    color VARCHAR(7), -- HEX color code
    is_final BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0
);

-- =====================================================
-- MAIN ENTITY TABLES
-- =====================================================

-- Table: users
-- Description: System users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role_id INTEGER NOT NULL,
    hourly_rate DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: clients
-- Description: Studio clients
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    website VARCHAR(255),
    tax_id VARCHAR(50),
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: projects
-- Description: Studio projects
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    client_id INTEGER NOT NULL,
    manager_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'planning',
    priority VARCHAR(10) DEFAULT 'medium',
    estimated_budget DECIMAL(12,2),
    actual_cost DECIMAL(12,2) DEFAULT 0,
    estimated_hours INTEGER,
    actual_hours INTEGER DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE,
    actual_end_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: tasks
-- Description: Project tasks
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status_id INTEGER NOT NULL,
    assigned_user_id INTEGER,
    created_by_user_id INTEGER NOT NULL,
    priority VARCHAR(10) DEFAULT 'medium',
    estimated_hours INTEGER,
    actual_hours INTEGER DEFAULT 0,
    due_date TIMESTAMP,
    parent_task_id INTEGER, -- Self-reference for subtasks
    completion_percentage INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- =====================================================
-- JUNCTION/RELATIONSHIP TABLES
-- =====================================================

-- Table: role_permissions
-- Description: Many-to-many relationship between roles and permissions
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    granted_at TIMESTAMP DEFAULT NOW()
);

-- Table: project_members
-- Description: Many-to-many relationship between users and projects
CREATE TABLE project_members (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    role_in_project VARCHAR(50) NOT NULL,
    joined_at TIMESTAMP DEFAULT NOW(),
    left_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- OPERATIONAL TABLES
-- =====================================================

-- Table: user_sessions
-- Description: User session management
CREATE TABLE user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Table: audit_logs
-- Description: System audit log
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER, -- Can be NULL for system actions
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table: time_entries
-- Description: Time tracking entries
CREATE TABLE time_entries (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    hours DECIMAL(5,2), -- Calculated automatically
    description TEXT,
    is_billable BOOLEAN DEFAULT TRUE,
    hourly_rate DECIMAL(10,2), -- From user profile
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FINANCIAL TABLES
-- =====================================================

-- Table: invoices
-- Description: Client invoices
CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    client_id INTEGER NOT NULL,
    project_id INTEGER, -- Can be NULL for general invoices
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'draft',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Table: payments
-- Description: Invoice payments
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: user_details
-- Description: Users with role information
CREATE VIEW user_details AS
SELECT 
    u.id,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    u.hourly_rate,
    u.is_active,
    r.name as role_name,
    r.description as role_description,
    u.created_at,
    u.updated_at
FROM users u
JOIN roles r ON u.role_id = r.id;

-- View: project_overview
-- Description: Projects with client and manager information
CREATE VIEW project_overview AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.status,
    p.priority,
    p.estimated_budget,
    p.actual_cost,
    p.estimated_hours,
    p.actual_hours,
    p.start_date,
    p.end_date,
    p.actual_end_date,
    c.company_name as client_name,
    c.contact_person as client_contact,
    CONCAT(u.first_name, ' ', u.last_name) as manager_name,
    u.email as manager_email,
    p.created_at,
    p.updated_at
FROM projects p
JOIN clients c ON p.client_id = c.id
JOIN users u ON p.manager_id = u.id;

-- View: task_details
-- Description: Tasks with status and assignment information
CREATE VIEW task_details AS
SELECT 
    t.id,
    t.title,
    t.description,
    t.priority,
    t.estimated_hours,
    t.actual_hours,
    t.completion_percentage,
    t.due_date,
    ts.name as status_name,
    ts.color as status_color,
    ts.is_final as status_is_final,
    p.name as project_name,
    CONCAT(assigned.first_name, ' ', assigned.last_name) as assigned_to,
    CONCAT(creator.first_name, ' ', creator.last_name) as created_by,
    t.created_at,
    t.updated_at,
    t.completed_at
FROM tasks t
JOIN task_statuses ts ON t.status_id = ts.id
JOIN projects p ON t.project_id = p.id
LEFT JOIN users assigned ON t.assigned_user_id = assigned.id
JOIN users creator ON t.created_by_user_id = creator.id;

-- Success message
SELECT 'Tables created successfully!' as status;
