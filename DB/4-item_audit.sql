CREATE TABLE item_audit(
	op char(1) NOT NULL,
	stamp timestamp NOT NULL,
	user_id varchar NOT NULL,
	item_id int4 NOT NULL,
	item_code bpchar(4) NOT NULL,
	"name" varchar(25) NULL,
	stock_alert int4 NOT NULL,
	stock int4 NOT NULL,
	yearly_consumption int4 NOT NULL,
	unit varchar(15) NULL
);