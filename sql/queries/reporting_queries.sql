-- =====================================================
-- Reporting Queries for IT Studio Portfolio Management System
-- Description: Advanced queries for reporting and analytics
-- Author: [Your Name]
-- Date: 2024
-- =====================================================

-- =====================================================
-- PROJECT REPORTING
-- =====================================================

-- Project profitability analysis
SELECT 
    p.id,
    p.name,
    p.status,
    c.company_name as client,
    p.estimated_budget,
    p.actual_cost,
    (p.estimated_budget - p.actual_cost) as profit_margin,
    CASE 
        WHEN p.estimated_budget > 0 THEN 
            ROUND(((p.estimated_budget - p.actual_cost) / p.estimated_budget * 100), 2)
        ELSE 0 
    END as profit_percentage,
    p.estimated_hours,
    p.actual_hours,
    CASE 
        WHEN p.estimated_hours > 0 THEN 
            ROUND((p.actual_hours::numeric / p.estimated_hours * 100), 2)
        ELSE 0 
    END as hours_efficiency_pct
FROM projects p
JOIN clients c ON p.client_id = c.id
ORDER BY profit_percentage DESC;

-- Project timeline analysis
SELECT 
    p.id,
    p.name,
    p.start_date,
    p.end_date,
    p.actual_end_date,
    CASE 
        WHEN p.actual_end_date IS NOT NULL THEN 
            p.actual_end_date - p.end_date
        WHEN p.end_date IS NOT NULL THEN 
            CURRENT_DATE - p.end_date
        ELSE NULL
    END as days_variance,
    CASE 
        WHEN p.actual_end_date IS NOT NULL AND p.end_date IS NOT NULL THEN
            CASE 
                WHEN p.actual_end_date <= p.end_date THEN 'On Time'
                ELSE 'Delayed'
            END
        WHEN p.end_date IS NOT NULL AND CURRENT_DATE > p.end_date AND p.status != 'completed' THEN 'Overdue'
        ELSE 'In Progress'
    END as timeline_status
FROM projects p
ORDER BY 
    CASE 
        WHEN p.end_date IS NOT NULL AND CURRENT_DATE > p.end_date AND p.status != 'completed' THEN 1
        ELSE 2
    END,
    p.end_date;

-- =====================================================
-- TEAM PERFORMANCE REPORTING
-- =====================================================

-- Developer productivity report
SELECT 
    u.id,
    CONCAT(u.first_name, ' ', u.last_name) as developer_name,
    u.hourly_rate,
    COUNT(DISTINCT t.id) as total_tasks,
    COUNT(DISTINCT CASE WHEN ts.is_final = TRUE THEN t.id END) as completed_tasks,
    ROUND(
        COUNT(DISTINCT CASE WHEN ts.is_final = TRUE THEN t.id END)::numeric / 
        NULLIF(COUNT(DISTINCT t.id), 0) * 100, 2
    ) as completion_rate_pct,
    SUM(te.hours) as total_hours_logged,
    SUM(te.hours * te.hourly_rate) as total_revenue_generated,
    COUNT(DISTINCT t.project_id) as projects_worked_on,
    AVG(t.actual_hours) as avg_hours_per_task
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_user_id
LEFT JOIN task_statuses ts ON t.status_id = ts.id
LEFT JOIN time_entries te ON t.id = te.task_id AND te.user_id = u.id
WHERE u.role_id = 3 AND u.is_active = TRUE  -- Developers only
GROUP BY u.id, u.first_name, u.last_name, u.hourly_rate
ORDER BY total_revenue_generated DESC NULLS LAST;

-- Team workload distribution
SELECT 
    u.id,
    CONCAT(u.first_name, ' ', u.last_name) as team_member,
    r.name as role,
    COUNT(DISTINCT CASE WHEN ts.is_final = FALSE THEN t.id END) as active_tasks,
    SUM(CASE WHEN ts.is_final = FALSE THEN t.estimated_hours ELSE 0 END) as estimated_hours_remaining,
    COUNT(DISTINCT t.project_id) as active_projects,
    COALESCE(recent_activity.last_activity, 'No recent activity') as last_activity_date
FROM users u
JOIN roles r ON u.role_id = r.id
LEFT JOIN tasks t ON u.id = t.assigned_user_id
LEFT JOIN task_statuses ts ON t.status_id = ts.id
LEFT JOIN (
    SELECT user_id, MAX(start_time)::date as last_activity
    FROM time_entries 
    WHERE start_time >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY user_id
) recent_activity ON u.id = recent_activity.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.first_name, u.last_name, r.name, recent_activity.last_activity
ORDER BY active_tasks DESC, estimated_hours_remaining DESC;

-- =====================================================
-- TIME TRACKING REPORTING
-- =====================================================

-- Monthly time tracking summary
SELECT 
    DATE_TRUNC('month', te.start_time) as month,
    COUNT(DISTINCT te.user_id) as active_users,
    SUM(te.hours) as total_hours,
    SUM(te.hours * te.hourly_rate) as total_cost,
    AVG(te.hourly_rate) as avg_hourly_rate,
    COUNT(DISTINCT t.project_id) as projects_worked_on
FROM time_entries te
JOIN tasks t ON te.task_id = t.id
WHERE te.start_time >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', te.start_time)
ORDER BY month DESC;

-- Daily productivity tracking
SELECT 
    DATE(te.start_time) as work_date,
    EXTRACT(dow FROM te.start_time) as day_of_week,  -- 0=Sunday, 6=Saturday
    COUNT(DISTINCT te.user_id) as active_users,
    SUM(te.hours) as total_hours,
    AVG(te.hours) as avg_hours_per_entry,
    COUNT(*) as total_entries
FROM time_entries te
WHERE te.start_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(te.start_time), EXTRACT(dow FROM te.start_time)
ORDER BY work_date DESC;

-- Time distribution by project
SELECT 
    p.name as project_name,
    c.company_name as client_name,
    SUM(te.hours) as total_hours,
    SUM(te.hours * te.hourly_rate) as total_cost,
    COUNT(DISTINCT te.user_id) as team_members,
    AVG(te.hourly_rate) as avg_hourly_rate,
    MIN(te.start_time) as first_logged_time,
    MAX(te.start_time) as last_logged_time
FROM time_entries te
JOIN tasks t ON te.task_id = t.id
JOIN projects p ON t.project_id = p.id
JOIN clients c ON p.client_id = c.id
GROUP BY p.id, p.name, c.company_name
ORDER BY total_hours DESC;

-- =====================================================
-- FINANCIAL REPORTING
-- =====================================================

-- Revenue analysis by client
SELECT 
    c.id,
    c.company_name,
    COUNT(DISTINCT p.id) as total_projects,
    SUM(p.estimated_budget) as total_estimated_revenue,
    SUM(p.actual_cost) as total_actual_cost,
    SUM(i.total_amount) as total_invoiced,
    COALESCE(SUM(pay.amount), 0) as total_paid,
    (SUM(i.total_amount) - COALESCE(SUM(pay.amount), 0)) as outstanding_balance,
    CASE 
        WHEN SUM(i.total_amount) > 0 THEN
            ROUND(COALESCE(SUM(pay.amount), 0) / SUM(i.total_amount) * 100, 2)
        ELSE 0
    END as payment_rate_pct
FROM clients c
LEFT JOIN projects p ON c.id = p.client_id
LEFT JOIN invoices i ON c.id = i.client_id
LEFT JOIN payments pay ON i.id = pay.invoice_id
GROUP BY c.id, c.company_name
ORDER BY total_paid DESC NULLS LAST;

-- Monthly revenue tracking
SELECT 
    DATE_TRUNC('month', i.issue_date) as month,
    COUNT(*) as invoices_issued,
    SUM(i.total_amount) as total_invoiced,
    SUM(CASE WHEN i.status = 'paid' THEN i.total_amount ELSE 0 END) as total_paid,
    SUM(CASE WHEN i.status = 'overdue' THEN i.total_amount ELSE 0 END) as overdue_amount,
    ROUND(
        SUM(CASE WHEN i.status = 'paid' THEN i.total_amount ELSE 0 END) / 
        NULLIF(SUM(i.total_amount), 0) * 100, 2
    ) as collection_rate_pct
FROM invoices i
WHERE i.issue_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', i.issue_date)
ORDER BY month DESC;

-- Overdue invoices report
SELECT 
    i.id,
    i.invoice_number,
    c.company_name as client_name,
    i.issue_date,
    i.due_date,
    i.total_amount,
    CURRENT_DATE - i.due_date as days_overdue,
    COALESCE(SUM(p.amount), 0) as amount_paid,
    i.total_amount - COALESCE(SUM(p.amount), 0) as balance_due
FROM invoices i
JOIN clients c ON i.client_id = c.id
LEFT JOIN payments p ON i.id = p.invoice_id
WHERE i.due_date < CURRENT_DATE 
  AND i.status NOT IN ('paid', 'cancelled')
GROUP BY i.id, i.invoice_number, c.company_name, i.issue_date, i.due_date, i.total_amount
HAVING i.total_amount - COALESCE(SUM(p.amount), 0) > 0
ORDER BY days_overdue DESC;

-- =====================================================
-- OPERATIONAL REPORTING
-- =====================================================

-- Task completion trends
SELECT 
    DATE_TRUNC('week', t.completed_at) as week,
    COUNT(*) as tasks_completed,
    AVG(t.actual_hours) as avg_hours_per_task,
    SUM(t.actual_hours) as total_hours,
    COUNT(DISTINCT t.assigned_user_id) as developers_involved
FROM tasks t
JOIN task_statuses ts ON t.status_id = ts.id
WHERE ts.name = 'Completed' 
  AND t.completed_at >= CURRENT_DATE - INTERVAL '12 weeks'
GROUP BY DATE_TRUNC('week', t.completed_at)
ORDER BY week DESC;

-- Project status distribution
SELECT 
    p.status,
    COUNT(*) as project_count,
    SUM(p.estimated_budget) as total_estimated_budget,
    SUM(p.actual_cost) as total_actual_cost,
    AVG(p.actual_hours) as avg_actual_hours,
    ROUND(AVG(
        CASE 
            WHEN p.estimated_hours > 0 THEN 
                (p.actual_hours::numeric / p.estimated_hours * 100)
            ELSE NULL 
        END
    ), 2) as avg_hours_efficiency
FROM projects p
GROUP BY p.status
ORDER BY 
    CASE p.status 
        WHEN 'active' THEN 1 
        WHEN 'planning' THEN 2 
        WHEN 'testing' THEN 3 
        WHEN 'completed' THEN 4 
        WHEN 'cancelled' THEN 5 
        ELSE 6 
    END;

-- System usage statistics
SELECT 
    'Active Users' as metric,
    COUNT(*) as value
FROM users WHERE is_active = TRUE

UNION ALL

SELECT 
    'Active Projects',
    COUNT(*)
FROM projects WHERE status IN ('planning', 'active', 'testing')

UNION ALL

SELECT 
    'Pending Tasks',
    COUNT(*)
FROM tasks t
JOIN task_statuses ts ON t.status_id = ts.id
WHERE ts.is_final = FALSE

UNION ALL

SELECT 
    'Hours Logged This Month',
    COALESCE(SUM(hours), 0)::integer
FROM time_entries 
WHERE start_time >= DATE_TRUNC('month', CURRENT_DATE)

UNION ALL

SELECT 
    'Revenue This Month',
    COALESCE(SUM(total_amount), 0)::integer
FROM invoices 
WHERE issue_date >= DATE_TRUNC('month', CURRENT_DATE)

UNION ALL

SELECT 
    'Outstanding Invoices',
    COUNT(*)
FROM invoices 
WHERE status NOT IN ('paid', 'cancelled');

-- =====================================================
-- ADVANCED ANALYTICS
-- =====================================================

-- Project complexity analysis
WITH project_metrics AS (
    SELECT 
        p.id,
        p.name,
        COUNT(DISTINCT pm.user_id) as team_size,
        COUNT(t.id) as total_tasks,
        COUNT(DISTINCT CASE WHEN t.parent_task_id IS NULL THEN t.id END) as parent_tasks,
        COUNT(DISTINCT CASE WHEN t.parent_task_id IS NOT NULL THEN t.id END) as subtasks,
        AVG(t.estimated_hours) as avg_task_hours,
        STDDEV(t.estimated_hours) as task_hours_stddev
    FROM projects p
    LEFT JOIN project_members pm ON p.id = pm.project_id AND pm.is_active = TRUE
    LEFT JOIN tasks t ON p.id = t.project_id
    GROUP BY p.id, p.name
)
SELECT 
    pm.*,
    CASE 
        WHEN pm.team_size <= 2 AND pm.total_tasks <= 10 THEN 'Simple'
        WHEN pm.team_size <= 5 AND pm.total_tasks <= 50 THEN 'Medium'
        ELSE 'Complex'
    END as complexity_level
FROM project_metrics pm
WHERE pm.total_tasks > 0
ORDER BY pm.total_tasks DESC, pm.team_size DESC;

-- Success message
SELECT 'Reporting queries ready to use!' as status;
