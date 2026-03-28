--  E-COMMERCE — Script DQL (Queries / Consultas)
--  SELECT, WHERE, atributos derivados, ORDER BY, HAVING, JOINs

USE ecommerce;

-- BLOCO 1 — Recuperações simples (SELECT Statement)
-- Pergunta 1: Quais são todos os produtos cadastrados?
SELECT
    idProduct,
    Pname        AS nome_produto,
    category     AS categoria,
    rating       AS avaliacao,
    size         AS tamanho
FROM product;

-- Pergunta 2: Quais são todos os pedidos e seus status?
SELECT
    idOrder        AS id_pedido,
    orderStatus    AS status,
    orderDescription AS descricao,
    sendValue      AS frete,
    paymentCash    AS pagamento_a_vista
FROM orders;

-- Pergunta 3: Quais entregas já foram realizadas?
SELECT
    idDelivery     AS id_entrega,
    idOrder        AS id_pedido,
    deliveryStatus AS status_entrega,
    trackingCode   AS codigo_rastreio
FROM delivery
WHERE deliveryStatus = 'Entregue';

-- Pergunta 4: Quais clientes são pessoa física?
SELECT
    c.idClient     AS id_cliente,
    pf.Fname       AS nome,
    pf.Lname       AS sobrenome,
    pf.CPF
FROM clients c
JOIN client_pf pf ON c.idClient = pf.idClient
WHERE c.clientType = 'PF';

-- Pergunta 5: Quais clientes são pessoa jurídica?
SELECT
    c.idClient     AS id_cliente,
    pj.SocialName  AS razao_social,
    pj.CNPJ
FROM clients c
JOIN client_pj pj ON c.idClient = pj.idClient
WHERE c.clientType = 'PJ';

-- BLOCO 2 — Filtros (WHERE Statement)
-- Pergunta 6: Quais produtos são classificados para crianças?
SELECT
    Pname    AS produto,
    category AS categoria,
    rating   AS avaliacao
FROM product
WHERE classification_kids = TRUE;

-- Pergunta 7: Quais pedidos estão em processamento ou confirmados?
SELECT
    idOrder       AS id_pedido,
    orderStatus   AS status,
    sendValue     AS frete
FROM orders
WHERE orderStatus IN ('Em processamento', 'Confirmado');

-- Pergunta 8: Quais produtos têm avaliação acima de 4.3?
SELECT
    Pname    AS produto,
    category AS categoria,
    rating   AS avaliacao
FROM product
WHERE rating > 4.3
ORDER BY rating DESC;

-- Pergunta 9: Quais entregas estão pendentes ou em transporte?
SELECT
    d.idDelivery     AS id_entrega,
    d.trackingCode   AS rastreio,
    d.deliveryStatus AS status,
    o.orderDescription AS descricao_pedido
FROM delivery d
JOIN orders o ON d.idOrder = o.idOrder
WHERE d.deliveryStatus IN ('Pendente', 'Em transporte');

-- Pergunta 10: Quais fornecedores têm CNPJ cadastrado?
SELECT
    SocialName AS fornecedor,
    CNPJ,
    contact    AS contato
FROM supplier
WHERE CNPJ IS NOT NULL;

-- BLOCO 3 — Atributos derivados (expressões calculadas)
-- Pergunta 11: Qual o valor total de cada pedido (frete + produtos)?
SELECT
    o.idOrder                                          AS id_pedido,
    o.orderDescription                                 AS descricao,
    o.sendValue                                        AS frete,
    SUM(p.rating * po.poQuantity)                      AS score_total,   -- derivado ilustrativo
    COUNT(po.idPOproduct)                              AS qtd_itens,
    o.sendValue + COUNT(po.idPOproduct) * 10           AS estimativa_valor_total  -- derivado
FROM orders o
JOIN productOrder po ON o.idOrder = po.idPOorder
JOIN product p       ON po.idPOproduct = p.idProduct
GROUP BY o.idOrder, o.orderDescription, o.sendValue;

-- Pergunta 12: Qual o nome completo dos clientes PF?
SELECT
    pf.idClient                                                 AS id_cliente,
    CONCAT(pf.Fname, ' ', COALESCE(pf.Minit, ''), ' ', pf.Lname) AS nome_completo,  -- derivado
    pf.CPF
FROM client_pf pf;

-- Pergunta 13: Qual a situação do estoque (nível: baixo, médio ou alto)?
SELECT
    storageLocation              AS local,
    quantity                     AS quantidade,
    CASE
        WHEN quantity < 20  THEN 'Baixo'
        WHEN quantity < 80  THEN 'Médio'
        ELSE                     'Alto'
    END                          AS nivel_estoque    -- atributo derivado
FROM productStorage;

-- Pergunta 14: Qual o desconto simulado (5%) sobre o frete de cada pedido?
SELECT
    idOrder                        AS id_pedido,
    orderDescription               AS descricao,
    sendValue                      AS frete_original,
    ROUND(sendValue * 0.05, 2)     AS desconto_5pct,         -- derivado
    ROUND(sendValue * 0.95, 2)     AS frete_com_desconto     -- derivado
FROM orders;

-- BLOCO 4 — Ordenações (ORDER BY)
-- Pergunta 15: Quais produtos têm maior avaliação? (do melhor ao pior)
SELECT
    Pname    AS produto,
    category AS categoria,
    rating   AS avaliacao
FROM product
ORDER BY rating DESC;

-- Pergunta 16: Quais pedidos têm maior frete? (do maior para o menor)
SELECT
    idOrder          AS id_pedido,
    orderDescription AS descricao,
    orderStatus      AS status,
    sendValue        AS frete
FROM orders
ORDER BY sendValue DESC;

-- Pergunta 17: Lista de clientes PF em ordem alfabética
SELECT
    pf.Fname  AS nome,
    pf.Lname  AS sobrenome,
    c.Address AS endereco
FROM client_pf pf
JOIN clients c ON pf.idClient = c.idClient
ORDER BY pf.Lname ASC, pf.Fname ASC;

-- Pergunta 18: Fornecedores ordenados pelo nome
SELECT
    SocialName AS fornecedor,
    CNPJ,
    contact    AS contato
FROM supplier
ORDER BY SocialName ASC;

-- BLOCO 5 — Agrupamentos com HAVING
-- Pergunta 19: Quantos pedidos foram feitos por cada cliente?
--              (mostrar apenas clientes com mais de 0 pedidos)
SELECT
    c.idClient                                              AS id_cliente,
    COALESCE(pf.Fname, pj.SocialName)                       AS nome_cliente,
    c.clientType                                            AS tipo,
    COUNT(o.idOrder)                                        AS total_pedidos
FROM clients c
LEFT JOIN client_pf pf ON c.idClient = pf.idClient
LEFT JOIN client_pj pj ON c.idClient = pj.idClient
LEFT JOIN orders o     ON c.idClient = o.idOrderClient
GROUP BY c.idClient, nome_cliente, c.clientType
HAVING COUNT(o.idOrder) > 0
ORDER BY total_pedidos DESC;

-- Pergunta 20: Quais categorias de produto têm avaliação média acima de 4.2?
SELECT
    category          AS categoria,
    COUNT(*)          AS qtd_produtos,
    ROUND(AVG(rating), 2) AS avaliacao_media
FROM product
GROUP BY category
HAVING AVG(rating) > 4.2
ORDER BY avaliacao_media DESC;

-- Pergunta 21: Quais fornecedores fornecem mais de 1 produto?
SELECT
    s.SocialName          AS fornecedor,
    COUNT(ps.idPsProduct) AS qtd_produtos_fornecidos,
    SUM(ps.quantity)      AS quantidade_total
FROM supplier s
JOIN productSupplier ps ON s.idSupplier = ps.idPsSupplier
GROUP BY s.idSupplier, s.SocialName
HAVING COUNT(ps.idPsProduct) > 1
ORDER BY qtd_produtos_fornecidos DESC;

-- Pergunta 22: Quais pedidos têm mais de 1 item?
SELECT
    o.idOrder            AS id_pedido,
    o.orderDescription   AS descricao,
    COUNT(po.idPOproduct) AS qtd_itens
FROM orders o
JOIN productOrder po ON o.idOrder = po.idPOorder
GROUP BY o.idOrder, o.orderDescription
HAVING COUNT(po.idPOproduct) > 1;

-- BLOCO 6 — Junções entre tabelas (JOINs)
-- Pergunta 23: Relação de nomes dos fornecedores e nomes dos produtos que fornecem
SELECT
    s.SocialName  AS fornecedor,
    p.Pname       AS produto,
    p.category    AS categoria,
    ps.quantity   AS quantidade_fornecida
FROM supplier s
JOIN productSupplier ps ON s.idSupplier = ps.idPsSupplier
JOIN product p          ON ps.idPsProduct = p.idProduct
ORDER BY s.SocialName, p.Pname;

-- Pergunta 24: Relação de produtos, fornecedores e estoques
SELECT
    p.Pname             AS produto,
    p.category          AS categoria,
    s.SocialName        AS fornecedor,
    ps.quantity         AS qtd_fornecida,
    pst.storageLocation AS local_estoque,
    pst.quantity        AS qtd_em_estoque,
    sl.location         AS corredor
FROM product p
JOIN productSupplier ps  ON p.idProduct  = ps.idPsProduct
JOIN supplier s          ON ps.idPsSupplier = s.idSupplier
JOIN storageLocation sl  ON p.idProduct  = sl.idLproduct
JOIN productStorage pst  ON sl.idLstorage = pst.idProdStorage
ORDER BY p.Pname;

-- Pergunta 25: Algum vendedor também é fornecedor?
--             (cruza CNPJ e nome entre as tabelas seller e supplier)
SELECT
    se.SocialName AS vendedor,
    su.SocialName AS fornecedor,
    se.CNPJ       AS cnpj_coincidente
FROM seller se
JOIN supplier su ON se.CNPJ = su.CNPJ
WHERE se.CNPJ IS NOT NULL;

-- Pergunta 26: Visão completa do pedido — cliente, itens, entrega e rastreio
SELECT
    o.idOrder                                           AS id_pedido,
    COALESCE(pf.Fname, pj.SocialName)                   AS cliente,
    c.clientType                                        AS tipo_cliente,
    p.Pname                                             AS produto,
    po.poQuantity                                       AS quantidade,
    po.poStatus                                         AS disponibilidade,
    o.orderStatus                                       AS status_pedido,
    d.deliveryStatus                                    AS status_entrega,
    d.trackingCode                                      AS rastreio
FROM orders o
JOIN clients c          ON o.idOrderClient  = c.idClient
LEFT JOIN client_pf pf  ON c.idClient       = pf.idClient
LEFT JOIN client_pj pj  ON c.idClient       = pj.idClient
JOIN productOrder po    ON o.idOrder        = po.idPOorder
JOIN product p          ON po.idPOproduct   = p.idProduct
LEFT JOIN delivery d    ON o.idOrder        = d.idOrder
ORDER BY o.idOrder, p.Pname;

-- Pergunta 27: Quais formas de pagamento cada cliente utiliza?
SELECT
    COALESCE(pf.Fname, pj.SocialName) AS cliente,
    c.clientType                      AS tipo,
    py.typePayment                    AS forma_pagamento,
    py.limitAvailable                 AS limite
FROM clients c
LEFT JOIN client_pf pf ON c.idClient  = pf.idClient
LEFT JOIN client_pj pj ON c.idClient  = pj.idClient
JOIN payments py       ON c.idClient  = py.idClient
ORDER BY cliente, py.typePayment;

-- Pergunta 28: Quais produtos são vendidos por quais sellers?
SELECT
    se.SocialName   AS vendedor,
    p.Pname         AS produto,
    p.category      AS categoria,
    ps.prodQuantity AS quantidade_disponivel
FROM seller se
JOIN productSeller ps ON se.idSeller   = ps.idPSeller
JOIN product p        ON ps.idPproduct = p.idProduct
ORDER BY se.SocialName, p.Pname;

-- FIM DO SCRIPT
