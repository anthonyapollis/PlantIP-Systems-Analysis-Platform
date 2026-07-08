-- ============================================================================
-- Plant Variety IP & Royalty Licensing Management Platform
-- Target: PostgreSQL 15+
-- Purpose: Migration target schema for a legacy MS Access IP-management
--          system used by plant variety rights / licensing organisations.
-- Author:  Anthony Apollis (systems & business analysis portfolio piece)
-- Note:    Entirely synthetic schema and sample data. No real organisation,
--          grower, cultivar, or financial data is represented.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS plant_ip;
SET search_path TO plant_ip;

-- ---------------------------------------------------------------------------
-- 1. Cultivar / Plant Master Data
-- ---------------------------------------------------------------------------
CREATE TABLE cultivars (
    cultivar_id      SERIAL PRIMARY KEY,
    cultivar_name    VARCHAR(120) NOT NULL,
    species          VARCHAR(120) NOT NULL,
    plant_type       VARCHAR(40)  NOT NULL,       -- tree, vine, ornamental, etc.
    ip_owner         VARCHAR(150),
    release_status   VARCHAR(30)  NOT NULL DEFAULT 'candidate',  -- candidate, released, withdrawn
    registered_on    DATE,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 2. Stakeholders (growers, licensors, nurseries, customers)
-- ---------------------------------------------------------------------------
CREATE TABLE stakeholders (
    stakeholder_id   SERIAL PRIMARY KEY,
    stakeholder_name VARCHAR(150) NOT NULL,
    stakeholder_type VARCHAR(30)  NOT NULL,       -- grower, licensor, nursery, customer
    region           VARCHAR(80),
    contact_email    VARCHAR(150),
    active           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------------
-- 3. Licences (IP licensing agreements)
-- ---------------------------------------------------------------------------
CREATE TABLE licences (
    licence_id       SERIAL PRIMARY KEY,
    cultivar_id      INT NOT NULL REFERENCES cultivars(cultivar_id),
    stakeholder_id   INT NOT NULL REFERENCES stakeholders(stakeholder_id),
    licence_type     VARCHAR(40)  NOT NULL,       -- production, propagation, exclusive
    start_date       DATE NOT NULL,
    end_date         DATE,
    status           VARCHAR(20)  NOT NULL DEFAULT 'active'      -- active, expired, terminated
);

-- ---------------------------------------------------------------------------
-- 4. Block / Field Management (nucleus, foundation, mother, production blocks)
-- ---------------------------------------------------------------------------
CREATE TABLE blocks (
    block_id         SERIAL PRIMARY KEY,
    cultivar_id      INT NOT NULL REFERENCES cultivars(cultivar_id),
    stakeholder_id   INT NOT NULL REFERENCES stakeholders(stakeholder_id),
    block_type       VARCHAR(30)  NOT NULL,       -- nucleus, foundation, mother, production
    block_status     VARCHAR(20)  NOT NULL DEFAULT 'active',      -- active, quarantined, removed
    planted_on       DATE,
    area_hectares    NUMERIC(8,2)
);

-- ---------------------------------------------------------------------------
-- 5. Pathology / Virus Testing
-- ---------------------------------------------------------------------------
CREATE TABLE pathology_tests (
    test_id          SERIAL PRIMARY KEY,
    block_id         INT NOT NULL REFERENCES blocks(block_id),
    test_date        DATE NOT NULL,
    test_type        VARCHAR(60) NOT NULL,        -- virus indexing, elimination, screening
    result           VARCHAR(20) NOT NULL,        -- clear, positive, pending
    notes            TEXT
);

-- ---------------------------------------------------------------------------
-- 6. Royalty Contracts and Transactions
-- ---------------------------------------------------------------------------
CREATE TABLE royalty_contracts (
    contract_id      SERIAL PRIMARY KEY,
    licence_id       INT NOT NULL REFERENCES licences(licence_id),
    royalty_rate     NUMERIC(6,4) NOT NULL,       -- e.g. per-unit or % of sale
    calculation_basis VARCHAR(30) NOT NULL,       -- per_tree, per_kg, percent_of_sale
    currency         CHAR(3) NOT NULL DEFAULT 'ZAR'
);

CREATE TABLE royalty_transactions (
    transaction_id   SERIAL PRIMARY KEY,
    contract_id      INT NOT NULL REFERENCES royalty_contracts(contract_id),
    period_start     DATE NOT NULL,
    period_end       DATE NOT NULL,
    volume           NUMERIC(12,2) NOT NULL,
    amount_due       NUMERIC(12,2) NOT NULL,
    amount_paid      NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_status   VARCHAR(20) NOT NULL DEFAULT 'outstanding'  -- outstanding, paid, overdue
);

-- ---------------------------------------------------------------------------
-- 7. Nursery Orders
-- ---------------------------------------------------------------------------
CREATE TABLE nursery_orders (
    order_id         SERIAL PRIMARY KEY,
    cultivar_id      INT NOT NULL REFERENCES cultivars(cultivar_id),
    stakeholder_id   INT NOT NULL REFERENCES stakeholders(stakeholder_id),
    order_date       DATE NOT NULL,
    quantity         INT NOT NULL,
    order_status     VARCHAR(20) NOT NULL DEFAULT 'pending'      -- pending, fulfilled, cancelled
);

-- ---------------------------------------------------------------------------
-- 8. Import / Export Permits and Quarantine
-- ---------------------------------------------------------------------------
CREATE TABLE import_export_permits (
    permit_id        SERIAL PRIMARY KEY,
    cultivar_id      INT NOT NULL REFERENCES cultivars(cultivar_id),
    direction        VARCHAR(10) NOT NULL,        -- import, export
    country          VARCHAR(80) NOT NULL,
    issued_on        DATE,
    expires_on       DATE,
    permit_status    VARCHAR(20) NOT NULL DEFAULT 'pending'
);

CREATE TABLE quarantine_records (
    quarantine_id    SERIAL PRIMARY KEY,
    permit_id        INT REFERENCES import_export_permits(permit_id),
    block_id         INT REFERENCES blocks(block_id),
    start_date       DATE NOT NULL,
    end_date         DATE,
    clearance_status VARCHAR(20) NOT NULL DEFAULT 'in_progress'  -- in_progress, cleared, failed
);

-- ---------------------------------------------------------------------------
-- Indexes supporting the reporting workloads identified during the
-- business process review (royalty reconciliation, block status tracking)
-- ---------------------------------------------------------------------------
CREATE INDEX idx_licences_cultivar ON licences(cultivar_id);
CREATE INDEX idx_blocks_cultivar ON blocks(cultivar_id);
CREATE INDEX idx_royalty_txn_status ON royalty_transactions(payment_status);
CREATE INDEX idx_permits_status ON import_export_permits(permit_status);
