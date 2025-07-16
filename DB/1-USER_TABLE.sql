-- public."USER" definition

-- Drop table

-- DROP TABLE public."USER";

CREATE TABLE public."USER" (
	id serial4 NOT NULL,
	email varchar NOT NULL,
	last_login timestamp NULL,
	"password" varchar NOT NULL,
	"role" varchar NOT NULL,
	connexion_attempt int4 DEFAULT 0 NOT NULL,
	blocked_account bool DEFAULT false NULL,
	CONSTRAINT newtable_pk PRIMARY KEY (id)
);