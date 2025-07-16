--DROP PROCEDURE user_connection(email_p varchar, PASSWORD_p varchar, ROLE_p varchar);
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE OR REPLACE PROCEDURE user_creation(email_p varchar, PASSWORD_p varchar, ROLE_p varchar)
LANGUAGE plpgsql
AS $$
DECLARE
	email_count integer;
	hashed_password varchar;
BEGIN
	IF email_p !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' THEN RAISE EXCEPTION 'wrong email format, %', email_p USING HINT = 'Please check your E-mail format.';
	END IF;
	IF length(PASSWORD_p) < 8 THEN RAISE EXCEPTION 'wrong password format, %', PASSWORD_p USING HINT = 'Password has to have at least 8 characters';
	END IF;
	IF ROLE_p !~ '^(MAIN_ADMIN|ADMIN|COMMON)$' THEN RAISE EXCEPTION 'the role: % does not exist', ROLE_p USING HINT = 'use those MAIN_ADMIN|ADMIN|COMMON';
	END IF;
	SELECT COUNT(*) INTO email_count FROM public."USER" u WHERE u.email = email_p;
	IF email_count > 0 THEN RAISE EXCEPTION '% already exists', email_p;
		ELSE
			hashed_password = encode(digest(PASSWORD_p, 'sha1'), 'hex');
			INSERT INTO public."USER" (email, "password", "role") VALUES (email_p, hashed_password, ROLE_p);
	END IF;
		
	commit;
END;$$;

-- CALL user_creation('1sss@j.c', '012345689', 'MAIN_ADMIN');
