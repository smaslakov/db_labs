-- =====================================================
-- Migration 002: Create Constraints and Indexes
-- Description: Add foreign keys, constraints, and indexes
-- Author: [Your Name]
-- Date: 2024
-- =====================================================

-- =====================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Users table foreign keys
ALTER TABLE users 
ADD CONSTRAINT fk_users_role_id 
FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT;

-- Projects table foreign keys
ALTER TABLE projects 
ADD CONSTRAINT fk_projects_client_id 
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT;

ALTER TABLE projects 
ADD CONSTRAINT fk_projects_manager_id 
FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE RESTRICT;

-- Tasks table foreign keys
ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_project_id 
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_status_id 
FOREIGN KEY (status_id) REFERENCES task_statuses(id) ON DELETE RESTRICT;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_assigned_user_id 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_created_by_user_id 
FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE RESTRICT;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_parent_task_id 
FOREIGN KEY (parent_task_id) REFERENCES tasks(id) ON DELETE CASCADE;

-- Role permissions table foreign keys
ALTER TABLE role_permissions 
ADD CONSTRAINT fk_role_permissions_role_id 
FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;

ALTER TABLE role_permissions 
ADD CONSTRAINT fk_role_permissions_permission_id 
FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE;

-- Project members table foreign keys
ALTER TABLE project_members 
ADD CONSTRAINT fk_project_members_project_id 
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE project_members 
ADD CONSTRAINT fk_project_members_user_id 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- User sessions table foreign keys
ALTER TABLE user_sessions 
ADD CONSTRAINT fk_user_sessions_user_id 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Audit logs table foreign keys
ALTER TABLE audit_logs 
ADD CONSTRAINT fk_audit_logs_user_id 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

-- Time entries table foreign keys
ALTER TABLE time_entries 
ADD CONSTRAINT fk_time_entries_user_id 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE time_entries 
ADD CONSTRAINT fk_time_entries_task_id 
FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE;

-- Invoices table foreign keys
ALTER TABLE invoices 
ADD CONSTRAINT fk_invoices_client_id 
FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT;

ALTER TABLE invoices 
ADD CONSTRAINT fk_invoices_project_id 
FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;

-- Payments table foreign keys
ALTER TABLE payments 
ADD CONSTRAINT fk_payments_invoice_id 
FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE;

-- =====================================================
-- CHECK CONSTRAINTS
-- =====================================================

-- Projects constraints
ALTER TABLE projects 
ADD CONSTRAINT chk_projects_status 
CHECK (status IN ('planning', 'active', 'testing', 'completed', 'cancelled'));

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_priority 
CHECK (priority IN ('low', 'medium', 'high', 'critical'));

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_budget_positive 
CHECK (estimated_budget IS NULL OR estimated_budget >= 0);

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_actual_cost_positive 
CHECK (actual_cost >= 0);

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_hours_positive 
CHECK (estimated_hours IS NULL OR estimated_hours > 0);

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_actual_hours_positive 
CHECK (actual_hours >= 0);

ALTER TABLE projects 
ADD CONSTRAINT chk_projects_dates 
CHECK (end_date IS NULL OR end_date >= start_date);

-- Tasks constraints
ALTER TABLE tasks 
ADD CONSTRAINT chk_tasks_priority 
CHECK (priority IN ('low', 'medium', 'high', 'critical'));

ALTER TABLE tasks 
ADD CONSTRAINT chk_tasks_completion_percentage 
CHECK (completion_percentage >= 0 AND completion_percentage <= 100);

ALTER TABLE tasks 
ADD CONSTRAINT chk_tasks_estimated_hours_positive 
CHECK (estimated_hours IS NULL OR estimated_hours > 0);

ALTER TABLE tasks 
ADD CONSTRAINT chk_tasks_actual_hours_positive 
CHECK (actual_hours >= 0);

-- Users constraints
ALTER TABLE users 
ADD CONSTRAINT chk_users_hourly_rate_positive 
CHECK (hourly_rate >= 0);

ALTER TABLE users 
ADD CONSTRAINT chk_users_email_format 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Clients constraints
ALTER TABLE clients 
ADD CONSTRAINT chk_clients_email_format 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Time entries constraints
ALTER TABLE time_entries 
ADD CONSTRAINT chk_time_entries_hours_positive 
CHECK (hours IS NULL OR hours > 0);

ALTER TABLE time_entries 
ADD CONSTRAINT chk_time_entries_hourly_rate_positive 
CHECK (hourly_rate IS NULL OR hourly_rate >= 0);

ALTER TABLE time_entries 
ADD CONSTRAINT chk_time_entries_time_order 
CHECK (end_time IS NULL OR end_time > start_time);

-- Invoices constraints
ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_status 
CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled'));

ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_subtotal_positive 
CHECK (subtotal >= 0);

ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_tax_rate_valid 
CHECK (tax_rate >= 0 AND tax_rate <= 100);

ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_tax_amount_positive 
CHECK (tax_amount >= 0);

ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_total_amount_positive 
CHECK (total_amount >= 0);

ALTER TABLE invoices 
ADD CONSTRAINT chk_invoices_dates 
CHECK (due_date >= issue_date);

-- Payments constraints
ALTER TABLE payments 
ADD CONSTRAINT chk_payments_amount_positive 
CHECK (amount > 0);

-- Task statuses constraints
ALTER TABLE task_statuses 
ADD CONSTRAINT chk_task_statuses_color_format 
CHECK (color IS NULL OR color ~* '^#[0-9A-Fa-f]{6}$');

-- =====================================================
-- UNIQUE CONSTRAINTS
-- =====================================================

-- Ensure unique role-permission combinations
ALTER TABLE role_permissions 
ADD CONSTRAINT uk_role_permissions_role_permission 
UNIQUE (role_id, permission_id);

-- Ensure unique project-user combinations (one active membership per project)
ALTER TABLE project_members 
ADD CONSTRAINT uk_project_members_project_user 
UNIQUE (project_id, user_id);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users table indexes
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Projects table indexes
CREATE INDEX idx_projects_client_id ON projects(client_id);
CREATE INDEX idx_projects_manager_id ON projects(manager_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_priority ON projects(priority);
CREATE INDEX idx_projects_start_date ON projects(start_date);
CREATE INDEX idx_projects_end_date ON projects(end_date);
CREATE INDEX idx_projects_dates ON projects(start_date, end_date);

-- Tasks table indexes
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_status_id ON tasks(status_id);
CREATE INDEX idx_tasks_assigned_user_id ON tasks(assigned_user_id);
CREATE INDEX idx_tasks_created_by_user_id ON tasks(created_by_user_id);
CREATE INDEX idx_tasks_parent_task_id ON tasks(parent_task_id);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_completion_percentage ON tasks(completion_percentage);

-- Time entries table indexes
CREATE INDEX idx_time_entries_user_id ON time_entries(user_id);
CREATE INDEX idx_time_entries_task_id ON time_entries(task_id);
CREATE INDEX idx_time_entries_start_time ON time_entries(start_time);
CREATE INDEX idx_time_entries_user_task ON time_entries(user_id, task_id);
CREATE INDEX idx_time_entries_billable ON time_entries(is_billable);

-- Audit logs table indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource_type ON audit_logs(resource_type);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- User sessions table indexes
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_user_sessions_active ON user_sessions(is_active);

-- Project members table indexes
CREATE INDEX idx_project_members_project_id ON project_members(project_id);
CREATE INDEX idx_project_members_user_id ON project_members(user_id);
CREATE INDEX idx_project_members_active ON project_members(is_active);

-- Role permissions table indexes
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

-- Clients table indexes
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_clients_company_name ON clients(company_name);
CREATE INDEX idx_clients_is_active ON clients(is_active);

-- Invoices table indexes
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_project_id ON invoices(project_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_issue_date ON invoices(issue_date);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_dates ON invoices(issue_date, due_date);

-- Payments table indexes
CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
CREATE INDEX idx_payments_payment_method ON payments(payment_method);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- Permissions table indexes
CREATE INDEX idx_permissions_resource_action ON permissions(resource, action);
CREATE INDEX idx_permissions_resource ON permissions(resource);

-- Task statuses table indexes
CREATE INDEX idx_task_statuses_sort_order ON task_statuses(sort_order);
CREATE INDEX idx_task_statuses_is_final ON task_statuses(is_final);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at 
    BEFORE UPDATE ON clients 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON projects 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at 
    BEFORE UPDATE ON tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_entries_updated_at 
    BEFORE UPDATE ON time_entries 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Success message
SELECT 'Constraints, indexes, and triggers created successfully!' as status;
