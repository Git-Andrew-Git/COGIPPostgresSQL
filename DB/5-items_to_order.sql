CREATE TABLE public.items_to_order(
	id serial NOT NULL,
	item_id integer NOT NULL,
	quantity integer NOT NULL,
	date_update integer NOT NULL
);

ALTER TABLE ONLY public.items_to_order ADD CONSTRAINT items_to_order_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.items_to_order ADD CONSTRAINT items_to_order_fk FOREIGN KEY (item_id) REFERENCES public.item(id);
