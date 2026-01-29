-- ========================================
-- SCHEMA CREATION
-- ========================================
-- We create a dedicated schema for all transformation tables. 
-- This separates raw data from cleaned, modeled data.
create schema if not exists transformation;

-- ========================================
-- SCHEMA FOR ANALYTICS
-- ========================================
-- Create a separate schema for analytics outputs and views
create schema if not exists analytics;
