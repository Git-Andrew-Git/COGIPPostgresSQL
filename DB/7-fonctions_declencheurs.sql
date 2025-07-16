--1 Message avant un « INSERT »

CREATE OR REPLACE FUNCTION display_message_on_supplier_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	RAISE NOTICE '"Un ajout de fournisseur va être fait. Le nouveau fournisseur est %', NEW.name;
	RETURN NEW;
END;$$;


--2 Message après un « UPDATE »

CREATE OR REPLACE FUNCTION display_message_on_supplier_update()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	RAISE NOTICE 'the old entry: %, changed into new one: %', OLD, NEW;
	RETURN NEW;
END;$$;


--3 Empêcher la suppression de l’administrateur principal
CREATE OR REPLACE FUNCTION check_user_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF OLD.ROLE = 'MAIN_ADMIN' THEN
	RAISE EXCEPTION 'impossible de supprimer l`''utilisateur %, Il s''agit de
l''administrateur principal.', OLD.id;
	ELSE RAISE NOTICE 'o7';
	END IF;
	RETURN NEW;
END;$$;

--4 Empêcher la suppression des commandes non livrées
CREATE OR REPLACE FUNCTION check_orderline_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF OLD.delivered_quantity < OLD.ordered_quantity THEN
	RAISE EXCEPTION 'impossible to delete the entry with order_id: % and item_id: %, where the delivery is not finished', OLD.order_id, OLD.item_id;
	ELSE 
	RAISE NOTICE 'o7';
	END IF;
	RETURN OLD;
END;$$;

--5 Modification des articles à commander
CREATE OR REPLACE FUNCTION mis_a_jour_articles()
RETURNS TRIGGER
LANGUAGE plpgSQL
AS $$
BEGIN
	IF NEW.stock < 0 THEN RAISE EXCEPTION 'stock with the id of: % can not be negative', NEW.id;
	END IF;
	IF NEW.stock <= NEW.stock_alert THEN
	INSERT INTO items_to_order (item_id, quantity, date_update)
	VALUES (NEW.id, NEW.yearly_consumption, EXTRACT(EPOCH FROM NOW())::INTEGER);
	END IF;

	RETURN NEW;
END;$$;

--6 audit
CREATE OR REPLACE FUNCTION item_audit_f()
RETURNS TRIGGER
LANGUAGE plpgSQL
AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN INSERT INTO item_audit SELECT 'D', now(), user, NEW.*;
	ELSEIF (TG_OP = 'UPDATE') THEN INSERT INTO item_audit SELECT 'U', now(), USER, NEW.*;
	ELSEIF (TG_OP = 'INSERT') THEN INSERT INTO item_audit SELECT 'I', now(), USER, NEW.*;
	END IF;
	RETURN NULL;
END;$$;