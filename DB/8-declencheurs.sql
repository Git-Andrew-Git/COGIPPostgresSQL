CREATE TRIGGER before_update_supplier
BEFORE INSERT
ON public.supplier
FOR EACH ROW
EXECUTE FUNCTION display_message_on_supplier_insert();

CREATE TRIGGER after_update_supplier
AFTER UPDATE
ON public.supplier
FOR EACH ROW
EXECUTE FUNCTION display_message_on_supplier_update();

CREATE TRIGGER before_delete_exception
BEFORE DELETE
ON public."USER"
FOR EACH ROW
EXECUTE FUNCTION check_user_delete();

CREATE TRIGGER before_delete_entry_on_orderline
BEFORE DELETE
ON public.order_line
FOR EACH ROW
EXECUTE FUNCTION check_orderline_delete();

CREATE TRIGGER before_insert_into_items_to_order
BEFORE UPDATE
ON public.item
FOR EACH ROW
EXECUTE FUNCTION mis_a_jour_articles();

CREATE TRIGGER after_update_items_to_order
AFTER UPDATE
ON public.item
FOR EACH ROW
EXECUTE FUNCTION  item_audit_f();