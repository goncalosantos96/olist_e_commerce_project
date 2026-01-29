-- ========================================
-- DIMENSION: PRODUCTS
-- ========================================

-- Create product dimension.
-- Assign surrogate keys and map product categories to broader groups for easier analysis.
create table transformation.dim_products (
	product_sk INTEGER,
	id TEXT,
	category TEXT,
	weight_g INTEGER,
	length_cm INTEGER,
	height_cm INTEGER,
	width_cm INTEGER,
	primary key(product_sk)
);

-- Insert into dim_products
-- Categorization groups reduce granularity and standardize analysis categories.
insert into transformation.dim_products
select
	row_number() over(order by product_id) as product_sk,
	product_id as id,
	case 
		-- Group multiple product categories into business-relevant buckets
		when product_category_name in (
			'cama_mesa_banho','casa_construcao','casa_conforto','casa_conforto_2',
			'moveis_quarto','moveis_sala','moveis_escritorio','moveis_decoracao',
			'moveis_colchao_e_estofado','moveis_cozinha_area_de_servico_jantar_e_jardim',
			'utilidades_domesticas','la_cuisine','portateis_casa_forno_e_cafe',
			'portateis_cozinha_e_preparadores_de_alimentos','ferramentas_jardim',
			'construcao_ferramentas_construcao','construcao_ferramentas_ferramentas',
			'construcao_ferramentas_iluminacao','construcao_ferramentas_jardim',
			'construcao_ferramentas_seguranca','sinalizacao_e_seguranca','climatizacao'
		) then 'House & Construction'
		when product_category_name in ('eletronicos','audio','cine_foto','pcs','pc_gamer','informatica_acessorios','tablets_impressao_imagem','consoles_games','telefonia','telefonia_fixa') then 'Electronics & Technology'
		when product_category_name in ('fashion_roupa_feminina','fashion_roupa_masculina','fashion_roupa_infanto_juvenil','fashion_underwear_e_moda_praia','fashion_esporte','fashion_calcados','fashion_bolsas_e_acessorios','malas_acessorios','relogios_presentes') then 'Clothes & Accessories'
		when product_category_name in ('alimentos','alimentos_bebidas','bebidas') then 'Food & Drinks'
		when product_category_name in ('beleza_saude','perfumaria','fraldas_higiene') then 'Cosmetics & Hygiene'
		when product_category_name in ('livros_importados','livros_tecnicos','livros_interesse_geral','papelaria') then 'Books & Education'
		when product_category_name in ('musica','instrumentos_musicais','cds_dvds_musicais','dvds_blu_ray','brinquedos','artes','artes_e_artesanato','cool_stuff') then 'Entertainment & Culture'
		when product_category_name = 'bebes' then 'Babys'
		when product_category_name = 'pet_shop' then 'Pets'
		when product_category_name = 'automotivo' then 'Automobiles'
		when product_category_name in ('industria_comercio_e_negocios','agro_industria_e_comercio') then 'Industry'
		when product_category_name in ('artigos_de_natal','artigos_de_festas','flores','seguros_e_servicos','market_place') then 'Miscellaneous'
		else 'Others'
	end as category,
	product_weight_g as weight_g,
	product_length_cm as length_cm,
	product_height_cm as height_cm,
	product_width_cm as width_cm
from olist_products;
