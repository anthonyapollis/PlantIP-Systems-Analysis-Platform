-- ============================================================================
-- Synthetic sample data — fictional cultivars, growers, and transactions only.
-- No real organisation, grower, or financial data is represented.
-- ============================================================================
SET search_path TO plant_ip;

INSERT INTO cultivars (cultivar_name, species, plant_type, ip_owner, release_status, registered_on) VALUES
('Sunrise Gold', 'Prunus persica', 'tree', 'Horizon Genetics Ltd', 'released', '2019-03-14'),
('Velvet Blush', 'Vitis vinifera', 'vine', 'Cape Cultivar Trust', 'released', '2021-07-02'),
('Amber Frost', 'Prunus persica', 'tree', 'Horizon Genetics Ltd', 'candidate', NULL),
('Golden Ridge', 'Malus domestica', 'tree', 'Ridge Orchard Co.', 'released', '2017-11-20');

INSERT INTO stakeholders (stakeholder_name, stakeholder_type, region, contact_email) VALUES
('Greenfield Orchards', 'grower', 'Western Cape', 'admin@greenfieldorchards.example'),
('Sunvalley Nurseries', 'nursery', 'Limpopo', 'orders@sunvalleynurseries.example'),
('Horizon Genetics Ltd', 'licensor', 'Western Cape', 'licensing@horizongenetics.example'),
('Blue River Farms', 'grower', 'Mpumalanga', 'contact@blueriverfarms.example');

INSERT INTO licences (cultivar_id, stakeholder_id, licence_type, start_date, end_date, status) VALUES
(1, 1, 'production', '2020-01-01', '2030-01-01', 'active'),
(2, 4, 'production', '2022-02-15', '2032-02-15', 'active'),
(4, 1, 'propagation', '2018-06-01', '2028-06-01', 'active');

INSERT INTO blocks (cultivar_id, stakeholder_id, block_type, block_status, planted_on, area_hectares) VALUES
(1, 1, 'production', 'active', '2020-08-10', 12.5),
(2, 4, 'production', 'active', '2022-09-01', 8.0),
(1, 3, 'nucleus', 'active', '2019-04-01', 0.5),
(4, 1, 'mother', 'quarantined', '2021-01-15', 1.2);

INSERT INTO pathology_tests (block_id, test_date, test_type, result) VALUES
(3, '2024-02-10', 'virus indexing', 'clear'),
(4, '2024-03-05', 'virus indexing', 'pending');

INSERT INTO royalty_contracts (licence_id, royalty_rate, calculation_basis, currency) VALUES
(1, 2.5000, 'per_tree', 'ZAR'),
(2, 0.0350, 'percent_of_sale', 'ZAR');

INSERT INTO royalty_transactions (contract_id, period_start, period_end, volume, amount_due, amount_paid, payment_status) VALUES
(1, '2024-01-01', '2024-03-31', 4200, 10500.00, 10500.00, 'paid'),
(2, '2024-01-01', '2024-03-31', 185000, 6475.00, 0.00, 'outstanding');

INSERT INTO nursery_orders (cultivar_id, stakeholder_id, order_date, quantity, order_status) VALUES
(1, 2, '2024-05-01', 1500, 'fulfilled'),
(2, 2, '2024-06-10', 800, 'pending');

INSERT INTO import_export_permits (cultivar_id, direction, country, issued_on, expires_on, permit_status) VALUES
(3, 'import', 'Netherlands', '2024-01-20', '2025-01-20', 'active');

INSERT INTO quarantine_records (permit_id, block_id, start_date, end_date, clearance_status) VALUES
(1, 4, '2024-01-25', NULL, 'in_progress');
