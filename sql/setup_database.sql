-- =====================================================
-- Database Setup Script
-- Description: Complete database setup for IT Studio Portfolio Management System
-- Author: [Your Name]
-- Date: 2024
-- Usage: psql -d your_database_name -f setup_database.sql
-- =====================================================

\echo '=============================================='
\echo 'IT Studio Portfolio Management System Setup'
\echo '=============================================='
\echo ''

-- Set client encoding and other settings
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

\echo 'Step 1: Creating tables...'
\i migrations/001_create_tables.sql

\echo ''
\echo 'Step 2: Adding constraints and indexes...'
\i migrations/002_create_constraints.sql

\echo ''
\echo 'Step 3: Inserting test data...'
\i migrations/003_insert_test_data.sql

\echo ''
\echo '=============================================='
\echo 'Database setup completed successfully!'
\echo '=============================================='

-- Show final statistics
\echo ''
\echo 'Database Statistics:'
SELECT 
    'Tables created:' as metric,
    COUNT(*) as value
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'

UNION ALL

SELECT 
    'Views created:' as metric,
    COUNT(*) as value
FROM information_schema.views 
WHERE table_schema = 'public'

UNION ALL

SELECT 
    'Indexes created:' as metric,
    COUNT(*) as value
FROM pg_indexes 
WHERE schemaname = 'public'

UNION ALL

SELECT 
    'Foreign keys:' as metric,
    COUNT(*) as value
FROM information_schema.table_constraints 
WHERE constraint_schema = 'public' AND constraint_type = 'FOREIGN KEY';

\echo ''
\echo 'Sample data summary:'
SELECT 
    'Users' as table_name, COUNT(*) as records FROM users
UNION ALL
SELECT 'Clients', COUNT(*) FROM clients
UNION ALL
SELECT 'Projects', COUNT(*) FROM projects
UNION ALL
SELECT 'Tasks', COUNT(*) FROM tasks
UNION ALL
SELECT 'Time Entries', COUNT(*) FROM time_entries
UNION ALL
SELECT 'Invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments;

\echo ''
\echo 'You can now run queries from the queries/ directory:'
\echo '  \\i queries/crud_operations.sql'
\echo '  \\i queries/reporting_queries.sql'
\echo ''
\echo 'To connect as different users, use the test credentials:'
\echo '  Username: admin, Password: password123 (Administrator)'
\echo '  Username: manager1, Password: password123 (Project Manager)'
\echo '  Username: dev1, Password: password123 (Developer)'
