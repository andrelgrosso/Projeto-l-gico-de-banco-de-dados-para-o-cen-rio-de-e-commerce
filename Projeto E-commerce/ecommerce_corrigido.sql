--  E-COMMERCE — Script SQL Ajustado 

-- DROP DATABASE IF EXISTS ecommerce;
CREATE DATABASE ecommerce;
USE ecommerce;
-- FASE 1 — Tabelas base (sem dependências externas)

-- 1. clients
--    Apenas id e tipo aqui. Dados pessoais ficam em client_pf
--    e client_pj (padrão supertype/subtype).
CREATE TABLE clients (
    idClient   INT          AUTO_INCREMENT PRIMARY KEY,
    clientType ENUM('PF','PJ') NOT NULL,
    Address    VARCHAR(255),
    contact    CHAR(11)
);

-- 2. product
CREATE TABLE product (
    idProduct          INT           AUTO_INCREMENT PRIMARY KEY,
    Pname              VARCHAR(255)  NOT NULL,
    classification_kids BOOLEAN      DEFAULT FALSE,
    category           ENUM('Eletrônico','Vestimenta','Brinquedos','Alimentos','Móveis') NOT NULL,
    rating             DECIMAL(3,1)  DEFAULT 0.0,   -- era "avaliação float" (acento + tipo errado)
    size               VARCHAR(10)
);

-- 3. productStorage
CREATE TABLE productStorage (
    idProdStorage   INT          AUTO_INCREMENT PRIMARY KEY,
    storageLocation VARCHAR(255),
    quantity        INT          DEFAULT 0
);

-- 4. supplier
CREATE TABLE supplier (
    idSupplier INT          AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ       CHAR(14)     NOT NULL,   -- 14 dígitos sem máscara (era char(15))
    contact    CHAR(11)     NOT NULL,
    CONSTRAINT unique_supplier UNIQUE (CNPJ)
);

-- 5. seller
--    CORREÇÕES:
--      · CPF char(11)  (era char(9) — truncava dados)
--      · unique_cpf_seller aponta para CPF (era CNPJ — bug crítico)
CREATE TABLE seller (
    idSeller   INT          AUTO_INCREMENT PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    AbstName   VARCHAR(255),
    CNPJ       CHAR(14),
    CPF        CHAR(11),               -- corrigido: era char(9)
    location   VARCHAR(255),
    contact    CHAR(11)     NOT NULL,
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ),
    CONSTRAINT unique_cpf_seller  UNIQUE (CPF)  -- corrigido: era UNIQUE(CNPJ)
);

-- FASE 2 — Subtipos de cliente (dependem de clients)
-- 6. client_pf  — pessoa física
CREATE TABLE client_pf (
    idClient INT          PRIMARY KEY,
    Fname    VARCHAR(50)  NOT NULL,    -- era varchar(10) — muito curto
    Minit    CHAR(3),
    Lname    VARCHAR(100) NOT NULL,    -- era varchar(20) — muito curto
    CPF      CHAR(11)     NOT NULL,
    CONSTRAINT unique_cpf_pf UNIQUE (CPF),
    CONSTRAINT fk_client_pf
        FOREIGN KEY (idClient) REFERENCES clients(idClient)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 7. client_pj  — pessoa jurídica
CREATE TABLE client_pj (
    idClient   INT          PRIMARY KEY,
    SocialName VARCHAR(255) NOT NULL,
    CNPJ       CHAR(14)     NOT NULL,  -- padronizado para 14
    CONSTRAINT unique_cnpj_pj UNIQUE (CNPJ),
    CONSTRAINT fk_client_pj
        FOREIGN KEY (idClient) REFERENCES clients(idClient)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- FASE 3 — Tabelas que dependem de clients
-- 8. payments
--    CORREÇÃO: FK declarada aqui no CREATE (antes só existia
--    via ALTER posterior, o que causava erros de ordem).
-- -------------------------------------------------------------
CREATE TABLE payments (
    idClient       INT,
    idPayment      INT,
    typePayment    ENUM('Boleto','Cartão','Dois cartões'),
    limitAvailable DECIMAL(10,2),                 -- era float
    PRIMARY KEY (idClient, idPayment),
    CONSTRAINT fk_payments_client
        FOREIGN KEY (idClient) REFERENCES clients(idClient)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 9. orders
--    CORREÇÃO: typo no nome da constraint corrigido
--    (fk_ordes_client → fk_orders_client).
--    ON DELETE SET NULL adicionado explicitamente.
CREATE TABLE orders (
    idOrder          INT           AUTO_INCREMENT PRIMARY KEY,
    idOrderClient    INT,
    orderStatus      ENUM('Cancelado','Confirmado','Em processamento') DEFAULT 'Em processamento',
    orderDescription VARCHAR(255),
    sendValue        DECIMAL(10,2) DEFAULT 10.00,  -- era float
    paymentCash      BOOLEAN       DEFAULT FALSE,
    CONSTRAINT fk_orders_client
        FOREIGN KEY (idOrderClient) REFERENCES clients(idClient)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- FASE 4 — Tabelas que dependem de orders / product / seller
-- 10. delivery  (tabela nova)
CREATE TABLE delivery (
    idDelivery     INT         AUTO_INCREMENT PRIMARY KEY,
    idOrder        INT         NOT NULL,
    deliveryStatus ENUM('Pendente','Em transporte','Entregue','Cancelada') DEFAULT 'Pendente',
    trackingCode   VARCHAR(50),
    CONSTRAINT fk_delivery_order
        FOREIGN KEY (idOrder) REFERENCES orders(idOrder)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- 11. productOrder
CREATE TABLE productOrder (
    idPOproduct INT,
    idPOorder   INT,
    poQuantity  INT  DEFAULT 1,
    poStatus    ENUM('Disponível','Sem estoque') DEFAULT 'Disponível',
    PRIMARY KEY (idPOproduct, idPOorder),
    CONSTRAINT fk_productorder_product
        FOREIGN KEY (idPOproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_productorder_order
        FOREIGN KEY (idPOorder)   REFERENCES orders(idOrder)
);

-- 12. productSeller
CREATE TABLE productSeller (
    idPSeller    INT,
    idPproduct   INT,
    prodQuantity INT DEFAULT 1,
    PRIMARY KEY (idPSeller, idPproduct),
    CONSTRAINT fk_productseller_seller
        FOREIGN KEY (idPSeller)  REFERENCES seller(idSeller),
    CONSTRAINT fk_productseller_product
        FOREIGN KEY (idPproduct) REFERENCES product(idProduct)
);

-- 13. storageLocation
CREATE TABLE storageLocation (
    idLproduct INT,
    idLstorage INT,
    location   VARCHAR(255) NOT NULL,
    PRIMARY KEY (idLproduct, idLstorage),
    CONSTRAINT fk_storagelocation_product
        FOREIGN KEY (idLproduct) REFERENCES product(idProduct),
    CONSTRAINT fk_storagelocation_storage
        FOREIGN KEY (idLstorage) REFERENCES productStorage(idProdStorage)
);

-- 14. productSupplier
CREATE TABLE productSupplier (
    idPsSupplier INT,
    idPsProduct  INT,
    quantity     INT NOT NULL,
    PRIMARY KEY (idPsSupplier, idPsProduct),
    CONSTRAINT fk_productsupplier_supplier
        FOREIGN KEY (idPsSupplier) REFERENCES supplier(idSupplier),
    CONSTRAINT fk_productsupplier_product
        FOREIGN KEY (idPsProduct)  REFERENCES product(idProduct)
);

-- FASE 5 — Índices para performance
-- orders: buscas por status e por cliente são frequentes
CREATE INDEX idx_orders_status ON orders(orderStatus);
CREATE INDEX idx_orders_client ON orders(idOrderClient);

-- delivery: filtros por pedido + status
CREATE INDEX idx_delivery_order_status ON delivery(idOrder, deliveryStatus);

-- tabelas associativas: segunda coluna da PK precisa de índice
-- para JOINs eficientes no MySQL/InnoDB
CREATE INDEX idx_productorder_order      ON productOrder(idPOorder);
CREATE INDEX idx_productseller_product   ON productSeller(idPproduct);
CREATE INDEX idx_storagelocation_storage ON storageLocation(idLstorage);
CREATE INDEX idx_productsupplier_product ON productSupplier(idPsProduct);

-- FIM DO SCRIPT
