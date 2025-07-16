CREATE FUNCTION format_date(date date, separator varchar)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN to_char(date, 'DD' || separator || 'MM' || separator || 'YYYY');
END;
$$;


--1. Analysez le code de la fonction et essayez de comprendre chacun de ses
--éléments
-- SELECT format_date('2023-02-01', '/');

--2. Utilisez la nouvelle fonction dans une requête permettant d’afficher toutes les
--commandes avec un tiret (‘-‘) utilisé en tant que séparateur
-- SELECT format_date(last_delivery_date, '-') FROM order_line WHERE line_number >= 3;

--3. Analysez et testez le code, comment est effectuée l’affectation de la variable
--« items_count » ?
--La fonction doit afficher et retourner le nombre d’articles total en base de données. Elle utilisera
--une requête SQL pour récupérer le nombre d’articles
CREATE FUNCTION get_items_count()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
items_count integer;
time_now time = now();
BEGIN
	SELECT count(id)
	INTO items_count
	FROM item;

	RAISE NOTICE '% articles à %', items_count, time_now;
	RETURN items_count;
END;
$$;

-- SELECT get_items_count();

--4. Implémentez une fonction qui répond au besoin COUNT_ITEMS_TO_ORDER
--La fonction doit afficher (via un message « notice) et retourner le nombre d’articles pour lesquels la
--valeur du stock est inférieure au stock d’alerte
CREATE FUNCTION count_items_to_order()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
nomb_article integer = -1;
BEGIN
	SELECT count(stock_alert - stock) INTO nomb_article FROM item HAVING (stock_alert - stock) < 0;
	
	RAISE NOTICE 'Le nombre d’articles pour lesquels la
	valeur du stock est inférieure au stock d’alerte %', nomb_article;
	RETURN nomb_article;
END;
$$;

-- SELECT count_items_to_order();

-- 5. BEST_SUPPLIER
--La fonction doit afficher le nom du fournisseur pour lequel il y a le plus eu de commandes
--effectuées (le plus d’enregistrements dans la table « order ») et retourner son identifiant.
CREATE FUNCTION BEST_SUPPLIER()
RETURNS integer
 LANGUAGE plpgsql
AS $$
DECLARE
id_fournisseur integer = -1;
name_fournisseur varchar = '';
BEGIN

	SELECT s.name, o.supplier_id INTO name_fournisseur, id_fournisseur
    FROM "order" o
    JOIN public.supplier s ON o.supplier_id = s.id
    GROUP BY s.name, o.supplier_id
    ORDER BY COUNT(o.id) DESC
    LIMIT 1;

RAISE NOTICE 'l’identifiant du fournisseur pour lequel il y a le plus eu de commandes: %, %', id_fournisseur, name_fournisseur;
RETURN id_fournisseur;
END;
$$;

-- SELECT BEST_SUPPLIER();


--SELECT s.name, o.supplier_id
--    FROM "order" o
--    JOIN public.supplier s ON o.supplier_id = s.id
--    GROUP BY s.name, o.supplier_id
--    ORDER BY COUNT(o.id) DESC
--    LIMIT 1;


--SELECT o.supplier_id
--FROM "order" o
--JOIN public.supplier s ON o.supplier_id = s.id
--GROUP BY s.name, o.supplier_id
--HAVING COUNT(o.supplier_id) = (
--    SELECT MAX(order_count)
--    FROM (
--        SELECT COUNT(o.supplier_id) AS order_count
--        FROM "order"
--        GROUP BY o.supplier_id
--    ) AS counts
--);



--6. SATISFACTION_STRING
--Objectif de la fonction :
--Il y a dans la table « supplier », une colonne nommée « satisfaction_index » prenant une valeur de
--1 à 10 ou Null.
--Cet indice est mis à jour selon le bon vouloir de l’utilisateur (ceci via une interface graphique).
--La fonction « satisfaction_string » devra pouvoir être utilisée pour retrouver une chaîne de caractère
--représentant l’indice de satisfaction.
--Ci-dessous la correspondance entre un indice et la chaîne de caractères correspondante :
--• Indice = Null, 'Sans commentaire'
--• Indice = 1 ou 2, 'Mauvais'
--• Indice = 3 ou 4, 'Passable'
--• Indice = 5 ou 6, 'Moyen'
--• Indice = 7 ou 8, 'Bon'
--• Indice = 9 ou 10, 'Excellent'
CREATE FUNCTION SATISFACTION_STRING(satisfaction_index_f integer)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
Indice1 varchar = 'Sans commentaire';
Indice2 varchar = 'Mauvais';
Indice3 varchar = 'Passable';
Indice4 varchar = 'Moyen';
Indice5 varchar = 'Bon';
Indice6 varchar = 'Excellent';
BEGIN
	IF satisfaction_index_f IS NULL THEN RAISE NOTICE '%', Indice1;  RETURN Indice1;
	ELSIF satisfaction_index_f>=1 AND satisfaction_index_f<3 THEN RAISE NOTICE '%', Indice2;  RETURN Indice2;
	ELSIF satisfaction_index_f>=3 AND satisfaction_index_f<5 THEN RAISE NOTICE '%', Indice3;  RETURN Indice3;
	ELSIF satisfaction_index_f>=5 AND satisfaction_index_f<7 THEN RAISE NOTICE '%', Indice4;  RETURN Indice4;
	ELSIF satisfaction_index_f>=7 AND satisfaction_index_f<9 THEN RAISE NOTICE '%', Indice5;  RETURN Indice5;
	ELSIF satisfaction_index_f>=9 AND satisfaction_index_f<11 THEN RAISE NOTICE '%', Indice6;  RETURN Indice6;
	ELSE RAISE NOTICE 'give NULL or from 1 to 10';
	END IF;
END;
$$;

-- SELECT satisfaction_string(11);

CREATE FUNCTION SATISFACTION_STRING_case(satisfaction_index_f integer)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
Indice1 varchar = 'Sans commentaire';
Indice2 varchar = 'Mauvais';
Indice3 varchar = 'Passable';
Indice4 varchar = 'Moyen';
Indice5 varchar = 'Bon';
Indice6 varchar = 'Excellent';
BEGIN
	CASE
		WHEN satisfaction_index_f IS NULL THEN RAISE NOTICE '%', Indice1;  RETURN Indice1;
		WHEN satisfaction_index_f>=1 AND satisfaction_index_f<3 THEN RAISE NOTICE '%', Indice2;  RETURN Indice2;
		WHEN satisfaction_index_f>=3 AND satisfaction_index_f<5 THEN RAISE NOTICE '%', Indice3;  RETURN Indice3;
		WHEN satisfaction_index_f>=5 AND satisfaction_index_f<7 THEN RAISE NOTICE '%', Indice4;  RETURN Indice4;
		WHEN satisfaction_index_f>=7 AND satisfaction_index_f<9 THEN RAISE NOTICE '%', Indice5;  RETURN Indice5;
		WHEN satisfaction_index_f>=9 AND satisfaction_index_f<11 THEN RAISE NOTICE '%', Indice6;  RETURN Indice6;
		ELSE RAISE NOTICE 'give NULL or from 1 to 10';
	END CASE;
END;
$$;

-- SELECT satisfaction_string_case(11);


--6. ADD_DAYS

--« add_days » devra prendre en paramètre une date et un nombre de jours et retourner une
--nouvelle date incrémentée du nombre de jours.
CREATE OR REPLACE FUNCTION ADD_DAYS(date_to_modify date, days_to_add integer)
RETURNS date
LANGUAGE plpgsql
AS $$
DECLARE
	result date;
BEGIN
	result := date_to_modify + days_to_add;

	RAISE NOTICE 'initial date i % changed into %', date_to_modify, result;  
	RETURN result;
END;
$$;

-- SELECT ADD_DAYS('2021-01-15'::date, 10);


--7. COUNT_ITEMS_BY_SUPPLIER 
--L’objectif et de créer une fonction retournant le résultat d’une requête comptant le nombre d’articles
--proposés par un fournisseur.
CREATE OR REPLACE FUNCTION COUNT_ITEMS_BY_SUPPLIER(supplier_id_f integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
	RESULT integer;
	supplier_exists boolean; 
BEGIN
	supplier_exists = exists(SELECT * FROM supplier s WHERE s.id = supplier_id_f);
	IF supplier_exists = false THEN RAISE EXCEPTION 'the supplier, %,  does not exist', supplier_id_f USING HINT = 'Vérifiez l''identifiant du fournisseur.';
	ELSE
		SELECT COUNT(*) INTO result
	    FROM item i JOIN sale_offer so ON i.id = so.item_id
	    WHERE so.supplier_id = supplier_id_f;
		RAISE NOTICE 'le nombre d’articles proposés par une fournisseur: %', RESULT;  
		RETURN result;
	END IF;
end;
$$;


-- select COUNT_ITEMS_BY_SUPPLIER(s.id) from supplier s where s."name" like 'DEPANPAP';
-- select COUNT_ITEMS_BY_SUPPLIER('325');

--8. SALES_REVENUE
--« sales_revenue » devra calculer le chiffre d’affaires d’un fournisseur pour une année donnée en
--paramètre.
create or replace FUNCTION SALES_REVENUE(supplier_id_f int, year_f numeric)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
	result int;
	supplier_exists boolean;
BEGIN
	supplier_exists = exists(SELECT * FROM supplier s WHERE s.id = supplier_id_f);
	IF supplier_exists = false THEN RAISE EXCEPTION 'the supplier, %, does not exist', supplier_id_f USING HINT = 'Vérifiez l''identifiant du fournisseur.';
	ELSE
		SELECT SUM(unit_price*delivered_quantity*1.2) as SALES_REVENUE INTO result FROM order_line ol
		JOIN public."order" o ON ol.order_id = o.id
		JOIN public.supplier s ON o.supplier_id = s.id WHERE s.id = supplier_id_f AND EXTRACT(YEAR FROM o."date") = year_f;
		RETURN result;
	END IF;
END;
$$;

-- SELECT SALES_REVENUE(120, 2021);
-- SELECT SALES_REVENUE(120, 2022);


-- SELECT s.id, 
-- 		EXTRACT(year FROM "date") AS "year", 
-- 		SALES_REVENUE(s.id, EXTRACT(year FROM "date"))
-- FROM SUPPLIER S JOIN "order" o
-- ON o.supplier_id = s.id
-- GROUP BY s.id, EXTRACT(year FROM "date");

--9. GET_ITEMS_STOCK_ALERT 
--« get_items_stock_alert » qui renvoie l’identifiant (id), le
--code article (item_code), le nom (name) et la différence entre le stock d’alerte et le stock réel pour
--tous les articles qui ont leur valeur de stock inférieure à la valeur d’alerte.
-- DROP FUNCTION get_items_stock_alert();
CREATE OR REPLACE FUNCTION get_items_stock_alert()
RETURNS TABLE (
id int,
item_code character(4),
"name" varchar(25),
not_enough_stock int
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN query
	SELECT
	i.id,
	i.item_code,
	i.name,
	(i.stock_alert-i.stock) AS not_enough_stock
FROM
	item i
WHERE
		(i.stock_alert-i.stock) < 0;
END;

$$;

-- SELECT * FROM get_items_stock_alert();

--10. PROCEDURE DE CREATION D’UTILISATEUR
--une procédure (fonction sans type de retour) qui pour objectif d’insérer un
--utilisateur en base de données (permet de sécuriser l’insertion des données).