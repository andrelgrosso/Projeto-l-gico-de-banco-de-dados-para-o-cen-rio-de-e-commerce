# 🛒 Projeto Lógico de Banco de Dados — E-commerce
 
Projeto desenvolvido como parte do desafio da **DIO (Digital Innovation One)**, com foco na modelagem lógica de um banco de dados relacional para um cenário de e-commerce, incluindo criação do schema (DDL), persistência de dados (DML) e consultas analíticas (DQL).
 
---
 
## 📋 Descrição do Projeto
 
O objetivo é modelar e implementar um banco de dados relacional que represente as principais entidades de um e-commerce, aplicando os conceitos de:
 
- Modelagem conceitual (EER) e lógica (relacional)
- Refinamentos de modelo: herança, relacionamentos N:M, atributos multivalorados
- Criação de schema com constraints (PK, FK, UNIQUE, NOT NULL)
- Persistência de dados de teste
- Consultas SQL complexas cobrindo as principais cláusulas
 
---
 
## 🎯 Refinamentos Aplicados
 
### 1. Cliente PF e PJ
Uma conta pode ser Pessoa Física **ou** Pessoa Jurídica — nunca as duas ao mesmo tempo. Isso foi implementado com o padrão **supertype/subtype**:
 
- `clients` — tabela pai com `clientType ENUM('PF', 'PJ')`
- `client_pf` — dados exclusivos de pessoa física (CPF, nome, sobrenome)
- `client_pj` — dados exclusivos de pessoa jurídica (razão social, CNPJ)
 
Ambas as subtabelas possuem FK com `ON DELETE CASCADE` referenciando `clients`.
 
### 2. Pagamento
Um cliente pode ter **mais de uma forma de pagamento** cadastrada. A tabela `payments` utiliza chave primária composta `(idClient, idPayment)`, permitindo múltiplos registros por cliente com tipos diferentes: `Boleto`, `Cartão` ou `Dois cartões`.
 
### 3. Entrega
Cada pedido possui uma entrega associada com **status de rastreamento** e **código de rastreio**. A tabela `delivery` registra os status: `Pendente`, `Em transporte`, `Entregue` e `Cancelada`.
 
---
 
## 🗂️ Estrutura do Schema
 
### Tabelas e Relacionamentos
 
```
clients (supertype)
├── client_pf       — herança: pessoa física
└── client_pj       — herança: pessoa jurídica
 
orders              — pedidos dos clientes
└── delivery        — entrega vinculada ao pedido
 
product             — catálogo de produtos
├── productOrder    — itens de cada pedido      (N:M orders × product)
├── productSeller   — produtos por vendedor     (N:M seller × product)
├── productSupplier — produtos por fornecedor   (N:M supplier × product)
└── storageLocation — localização no estoque    (N:M product × productStorage)
 
payments            — formas de pagamento do cliente
seller              — vendedores
supplier            — fornecedores
productStorage      — centros de estoque
```
 
### Diagrama de Entidades
 
| Tabela | Chave Primária | Chave(s) Estrangeira(s) |
|---|---|---|
| `clients` | `idClient` | — |
| `client_pf` | `idClient` | `clients.idClient` |
| `client_pj` | `idClient` | `clients.idClient` |
| `product` | `idProduct` | — |
| `productStorage` | `idProdStorage` | — |
| `supplier` | `idSupplier` | — |
| `seller` | `idSeller` | — |
| `payments` | `(idClient, idPayment)` | `clients.idClient` |
| `orders` | `idOrder` | `clients.idClient` |
| `delivery` | `idDelivery` | `orders.idOrder` |
| `productOrder` | `(idPOproduct, idPOorder)` | `product.idProduct`, `orders.idOrder` |
| `productSeller` | `(idPSeller, idPproduct)` | `seller.idSeller`, `product.idProduct` |
| `storageLocation` | `(idLproduct, idLstorage)` | `product.idProduct`, `productStorage.idProdStorage` |
| `productSupplier` | `(idPsSupplier, idPsProduct)` | `supplier.idSupplier`, `product.idProduct` |
 
---
 
## 📁 Arquivos do Projeto
 
| Arquivo | Descrição |
|---|---|
| `ecommerce_corrigido.sql` | DDL — criação do banco, tabelas, constraints e índices |
| `ecommerce_dml.sql` | DML — inserção de dados de teste |
| `ecommerce_dql.sql` | DQL — 28 queries analíticas com perguntas e respostas |
| `README.md` | Documentação do projeto |
 
---
 
## 🔍 Queries SQL — Perguntas Respondidas
 
O arquivo `ecommerce_dql.sql` contém 28 consultas organizadas em 6 blocos:
 
### Bloco 1 — SELECT simples
- Quais são todos os produtos cadastrados?
- Quais são todos os pedidos e seus status?
- Quais entregas já foram realizadas?
- Quais clientes são pessoa física / pessoa jurídica?
 
### Bloco 2 — WHERE (Filtros)
- Quais produtos são classificados para crianças?
- Quais pedidos estão em processamento ou confirmados?
- Quais produtos têm avaliação acima de 4.3?
- Quais entregas estão pendentes ou em transporte?
 
### Bloco 3 — Atributos Derivados
- Qual o valor estimado total de cada pedido?
- Qual o nome completo dos clientes PF? (`CONCAT`)
- Qual o nível do estoque? (`CASE WHEN`: Baixo / Médio / Alto)
- Qual o desconto simulado de 5% sobre o frete?
 
### Bloco 4 — ORDER BY
- Quais produtos têm maior avaliação?
- Quais pedidos têm maior frete?
- Lista de clientes PF em ordem alfabética
- Fornecedores ordenados pelo nome
 
### Bloco 5 — HAVING (Agrupamentos com condição)
- Quantos pedidos foram feitos por cada cliente?
- Quais categorias têm avaliação média acima de 4.2?
- Quais fornecedores fornecem mais de 1 produto?
- Quais pedidos têm mais de 1 item?
 
### Bloco 6 — JOINs (Junções entre tabelas)
- Relação de nomes dos fornecedores e nomes dos produtos
- Relação de produtos, fornecedores e estoques
- Algum vendedor também é fornecedor?
- Visão completa do pedido: cliente, itens, entrega e rastreio
- Quais formas de pagamento cada cliente utiliza?
- Quais produtos são vendidos por quais sellers?
 
---
 
## ⚙️ Como Executar
 
### Pré-requisitos
- MySQL 8.0+ ou MariaDB 10.5+
- Cliente SQL: MySQL Workbench, DBeaver, TablePlus ou CLI
 
### Passo a passo
 
```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/ecommerce-db.git 
cd ecommerce-db
 
# 2. Execute o DDL (criação do schema)
mysql -u root -p < ecommerce_corrigido.sql
 
# 3. Execute o DML (inserção dos dados)
mysql -u root -p ecommerce < ecommerce_dml.sql
 
# 4. Execute as queries de consulta
mysql -u root -p ecommerce < ecommerce_dql.sql
```
 
Ou importe os arquivos diretamente pelo MySQL Workbench na ordem:
1. `ecommerce_corrigido.sql`
2. `ecommerce_dml.sql`
3. `ecommerce_dql.sql`
 
---
 
## 🛠️ Tecnologias
 
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-DDL%20%7C%20DML%20%7C%20DQL-orange)
 
---
 
## 👨‍💻 Autor
 
Desenvolvido como desafio de projeto da trilha **Database Experience** da [DIO — Digital Innovation One](https://www.dio.me).
