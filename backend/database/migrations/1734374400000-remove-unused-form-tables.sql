-- Migration to remove unused/duplicate form tables
-- The old form system tables are being replaced by the dynamic form system

-- Drop dependent tables first (foreign key constraints)
DROP TABLE IF EXISTS form_response_values CASCADE;
DROP TABLE IF EXISTS form_responses CASCADE;
DROP TABLE IF EXISTS form_fields CASCADE;
DROP TABLE IF EXISTS field_attributes CASCADE;
DROP TABLE IF EXISTS fields CASCADE;
DROP TABLE IF EXISTS field_types CASCADE;
DROP TABLE IF EXISTS services CASCADE;

-- Note: departments table is still used for department authentication system
-- so we're not dropping it

-- The following tables are kept (new dynamic form system):
-- forms
-- form_sections  
-- dynamic_form_fields
-- form_submissions
-- departments (used for department auth)
