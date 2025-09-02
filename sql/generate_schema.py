#!/usr/bin/env python3
"""
SQL Schema Generator
Generates PostgreSQL DDL from JSON schema definition
"""

import json
import os
from pathlib import Path

def load_schema(json_file):
    """Load schema from JSON file"""
    with open(json_file, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_create_table_sql(table):
    """Generate CREATE TABLE SQL for a single table"""
    sql_lines = []
    table_name = table['name']
    
    # Table header
    sql_lines.append(f"-- Table: {table_name}")
    sql_lines.append(f"-- Description: {table.get('description', '')}")
    sql_lines.append(f"CREATE TABLE {table_name} (")
    
    # Columns
    column_definitions = []
    foreign_keys = []
    
    for column in table['columns']:
        col_def = f"    {column['name']} {column['type']}"
        
        # Add constraints
        if column['constraints']:
            for constraint in column['constraints']:
                if constraint not in ['PRIMARY KEY']:  # Handle PK separately
                    col_def += f" {constraint}"
        
        # Add check constraints
        if 'check_constraint' in column:
            col_def += f" CHECK ({column['check_constraint']})"
        
        column_definitions.append(col_def)
        
        # Collect foreign keys for later
        if 'foreign_key' in column:
            fk = column['foreign_key']
            fk_name = f"fk_{table_name}_{column['name']}"
            fk_def = f"    CONSTRAINT {fk_name} FOREIGN KEY ({column['name']}) REFERENCES {fk['table']}({fk['column']})"
            if 'on_delete' in fk:
                fk_def += f" ON DELETE {fk['on_delete']}"
            foreign_keys.append(fk_def)
    
    # Add primary key
    pk_columns = []
    for column in table['columns']:
        if 'PRIMARY KEY' in column.get('constraints', []):
            pk_columns.append(column['name'])
    
    if pk_columns:
        column_definitions.append(f"    CONSTRAINT pk_{table_name} PRIMARY KEY ({', '.join(pk_columns)})")
    
    # Add unique constraints
    if 'unique_constraints' in table:
        for uk in table['unique_constraints']:
            uk_def = f"    CONSTRAINT {uk['name']} UNIQUE ({', '.join(uk['columns'])})"
            column_definitions.append(uk_def)
    
    # Add foreign keys
    column_definitions.extend(foreign_keys)
    
    # Join all definitions
    sql_lines.append(",\n".join(column_definitions))
    sql_lines.append(");")
    sql_lines.append("")
    
    return "\n".join(sql_lines)

def generate_indexes_sql(table):
    """Generate CREATE INDEX SQL for a table"""
    if 'indexes' not in table:
        return ""
    
    sql_lines = []
    table_name = table['name']
    
    for index in table['indexes']:
        index_name = index['name']
        columns = ', '.join(index['columns'])
        sql_lines.append(f"CREATE INDEX {index_name} ON {table_name} ({columns});")
    
    if sql_lines:
        sql_lines.insert(0, f"-- Indexes for {table_name}")
        sql_lines.append("")
    
    return "\n".join(sql_lines)

def generate_default_data_sql(schema):
    """Generate INSERT statements for default data"""
    if 'default_data' not in schema:
        return ""
    
    sql_lines = ["-- Default data"]
    
    for table_name, records in schema['default_data'].items():
        sql_lines.append(f"\n-- {table_name}")
        
        for record in records:
            columns = list(record.keys())
            values = []
            
            for value in record.values():
                if isinstance(value, str):
                    values.append(f"'{value}'")
                elif isinstance(value, bool):
                    values.append(str(value).upper())
                elif value is None:
                    values.append("NULL")
                else:
                    values.append(str(value))
            
            sql_lines.append(
                f"INSERT INTO {table_name} ({', '.join(columns)}) "
                f"VALUES ({', '.join(values)});"
            )
    
    sql_lines.append("")
    return "\n".join(sql_lines)

def generate_drop_schema_sql(schema):
    """Generate DROP statements (for cleanup)"""
    sql_lines = ["-- Drop existing schema (use with caution!)"]
    
    # Drop tables in reverse order (to handle foreign keys)
    tables = schema['tables']
    for table in reversed(tables):
        sql_lines.append(f"DROP TABLE IF EXISTS {table['name']} CASCADE;")
    
    sql_lines.append("")
    return "\n".join(sql_lines)

def main():
    """Main function"""
    # Get paths
    script_dir = Path(__file__).parent
    json_file = script_dir.parent / "docs" / "database_schema.json"
    output_dir = script_dir
    
    # Load schema
    schema = load_schema(json_file)
    
    # Generate SQL files
    
    # 1. Drop schema (cleanup)
    drop_sql = generate_drop_schema_sql(schema)
    with open(output_dir / "01_drop_schema.sql", 'w', encoding='utf-8') as f:
        f.write(drop_sql)
    
    # 2. Create tables
    create_sql_lines = [
        f"-- Database: {schema['database']['name']}",
        f"-- Description: {schema['database']['description']}",
        f"-- Version: {schema['database']['version']}",
        "",
        "-- Create tables",
        ""
    ]
    
    for table in schema['tables']:
        create_sql_lines.append(generate_create_table_sql(table))
    
    with open(output_dir / "02_create_tables.sql", 'w', encoding='utf-8') as f:
        f.write("\n".join(create_sql_lines))
    
    # 3. Create indexes
    indexes_sql_lines = ["-- Create indexes", ""]
    
    for table in schema['tables']:
        indexes_sql = generate_indexes_sql(table)
        if indexes_sql:
            indexes_sql_lines.append(indexes_sql)
    
    with open(output_dir / "03_create_indexes.sql", 'w', encoding='utf-8') as f:
        f.write("\n".join(indexes_sql_lines))
    
    # 4. Insert default data
    default_data_sql = generate_default_data_sql(schema)
    if default_data_sql:
        with open(output_dir / "04_insert_default_data.sql", 'w', encoding='utf-8') as f:
            f.write(default_data_sql)
    
    # 5. Complete setup script
    setup_sql = f"""-- Complete database setup script
-- Run this script to create the entire database schema

-- Step 1: Drop existing schema (if needed)
\\i 01_drop_schema.sql

-- Step 2: Create tables
\\i 02_create_tables.sql

-- Step 3: Create indexes
\\i 03_create_indexes.sql

-- Step 4: Insert default data
\\i 04_insert_default_data.sql

-- Setup completed successfully!
SELECT 'Database schema created successfully!' as status;
"""
    
    with open(output_dir / "setup_database.sql", 'w', encoding='utf-8') as f:
        f.write(setup_sql)
    
    print("SQL files generated successfully:")
    print("  - 01_drop_schema.sql")
    print("  - 02_create_tables.sql") 
    print("  - 03_create_indexes.sql")
    print("  - 04_insert_default_data.sql")
    print("  - setup_database.sql")
    print("\nTo create the database, run:")
    print("  psql -d your_database -f setup_database.sql")

if __name__ == "__main__":
    main()
