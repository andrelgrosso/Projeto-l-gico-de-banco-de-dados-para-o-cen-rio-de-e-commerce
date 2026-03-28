--  E-COMMERCE — Script DML (INSERT)
--  Compatível com ecommerce_corrigido.sql

USE ecommerce;

-- 1. clients  (supertype — apenas tipo e endereço)
INSERT INTO clients (clientType, Address, contact) VALUES
('PF', 'Rua das Flores, 100 - Joinville',        '47999990001'),
('PF', 'Av. Brasil, 500 - Curitiba',              '41988880002'),
('PJ', 'Rua Industrial, 2000 - São Paulo',        '11977770003'),
('PJ', 'Av. Central, 1500 - Florianópolis',       '48966660004');

-- 2. client_pf  (pessoa física — idClient 1 e 2)
INSERT INTO client_pf (idClient, Fname, Minit, Lname, CPF) VALUES
(1, 'Carlos',  'A', 'Silva', '12345678901'),
(2, 'Mariana', 'B', 'Souza', '98765432100');

-- 3. client_pj  (pessoa jurídica — idClient 3 e 4)
INSERT INTO client_pj (idClient, SocialName, CNPJ) VALUES
(3, 'Tech Solutions LTDA', '11222333000199'),
(4, 'Comercial Alpha SA',  '99888777000155');

-- 4. product
--    CORREÇÃO: coluna renomeada de "avaliação" para "rating"
INSERT INTO product (Pname, classification_kids, category, rating, size) VALUES
('Notebook',  FALSE, 'Eletrônico',  4.5, 'Médio'),
('Camisa',    FALSE, 'Vestimenta',  4.2, 'G'),
('Boneca',    TRUE,  'Brinquedos',  4.8, 'Pequeno'),
('Sofá',      FALSE, 'Móveis',      4.1, 'Grande');

-- 5. supplier
--    CORREÇÃO: CNPJ ajustado para 14 dígitos (sem máscara)
INSERT INTO supplier (SocialName, CNPJ, contact) VALUES
('Fornecedor Tech', '11122233344455', '47999990000'),
('Fornecedor Moda', '66677788899900', '41988887777');

-- 6. seller
INSERT INTO seller (SocialName, AbstName, CNPJ, CPF, location, contact) VALUES
('Loja Eletrônicos SP',  'EletroSP',  '22233344400001', NULL,          'São Paulo - SP',    '11988880001'),
('Moda & Cia',           'ModaCia',   NULL,             '55544433322', 'Curitiba - PR',     '41977770002'),
('Brinquedos do Sul',    'BriSul',    '33344455500002', NULL,          'Florianópolis - SC','48966660003');

-- 7. productStorage
INSERT INTO productStorage (storageLocation, quantity) VALUES
('Centro de Distribuição SC', 100),
('Centro de Distribuição PR',  50);

-- 8. payments
--    FK fk_payments_client já declarada no CREATE TABLE
INSERT INTO payments (idClient, idPayment, typePayment, limitAvailable) VALUES
(1, 1, 'Cartão',      5000.00),
(1, 2, 'Boleto',      3000.00),
(2, 1, 'Cartão',      2000.00),
(3, 1, 'Dois cartões',15000.00);

-- 9. orders
INSERT INTO orders (idOrderClient, orderStatus, orderDescription, sendValue, paymentCash) VALUES
(1, 'Confirmado',        'Compra de notebook',  15.00, FALSE),
(2, 'Em processamento',  'Compra de roupas',    10.00, TRUE),
(3, 'Confirmado',        'Compra corporativa',  20.00, FALSE);

-- 10. delivery  (depende de orders)
INSERT INTO delivery (idOrder, deliveryStatus, trackingCode) VALUES
(1, 'Em transporte', 'BR123456789'),
(2, 'Pendente',      'BR987654321'),
(3, 'Entregue',      'BR456789123');

-- 11. productOrder  (depende de product e orders)
INSERT INTO productOrder (idPOproduct, idPOorder, poQuantity, poStatus) VALUES
(1, 1, 1, 'Disponível'),
(2, 2, 2, 'Disponível'),
(3, 2, 1, 'Disponível'),
(4, 3, 5, 'Disponível');

-- 12. productSeller  (depende de seller e product)
INSERT INTO productSeller (idPSeller, idPproduct, prodQuantity) VALUES
(1, 1, 10),   -- Loja Eletrônicos SP vende Notebook
(1, 4, 5),    -- Loja Eletrônicos SP vende Sofá
(2, 2, 30),   -- Moda & Cia vende Camisa
(3, 3, 20);   -- Brinquedos do Sul vende Boneca

-- 13. storageLocation  (depende de product e productStorage)
INSERT INTO storageLocation (idLproduct, idLstorage, location) VALUES
(1, 1, 'Corredor A'),
(2, 2, 'Corredor B'),
(3, 1, 'Corredor C'),
(4, 2, 'Corredor D');

-- 14. productSupplier  (depende de supplier e product)
INSERT INTO productSupplier (idPsSupplier, idPsProduct, quantity) VALUES
(1, 1, 30),   -- Fornecedor Tech fornece Notebook
(1, 4, 10),   -- Fornecedor Tech fornece Sofá
(2, 2, 40),   -- Fornecedor Moda fornece Camisa
(2, 3, 20);   -- Fornecedor Moda fornece Boneca

-- FIM DO SCRIPT 