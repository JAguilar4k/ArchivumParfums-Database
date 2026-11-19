DO $$
DECLARE
    database_name text;
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'archivum_owner' AND rolcanlogin AND NOT rolsuper AND NOT rolbypassrls
    ) THEN
        RAISE EXCEPTION 'archivum_owner must be able to log in without bypassing RLS';
    END IF;

    IF NOT EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'archivum_app' AND rolcanlogin
            AND NOT rolsuper AND NOT rolcreatedb AND NOT rolcreaterole AND NOT rolbypassrls
    ) OR pg_has_role('archivum_app', 'archivum_owner', 'MEMBER') THEN
        RAISE EXCEPTION 'archivum_app must be able to log in without elevated privileges';
    END IF;

    FOREACH database_name IN ARRAY ARRAY['archivum_hexagonal', 'archivum_hexagonal_testing'] LOOP
        IF NOT EXISTS (
            SELECT FROM pg_database
            WHERE datname = database_name AND pg_get_userbyid(datdba) = 'archivum_owner'
        ) THEN
            RAISE EXCEPTION 'archivum_owner must own %', database_name;
        END IF;

        IF NOT has_database_privilege('archivum_app', database_name, 'CONNECT')
            OR has_database_privilege('archivum_app', database_name, 'CREATE')
            OR has_database_privilege('archivum_app', database_name, 'TEMPORARY') THEN
            RAISE EXCEPTION 'archivum_app must have only CONNECT on %', database_name;
        END IF;

        IF EXISTS (
            SELECT FROM pg_database
            CROSS JOIN LATERAL aclexplode(datacl) AS permission
            WHERE datname = database_name AND permission.grantee = 0
        ) THEN
            RAISE EXCEPTION 'PUBLIC must not have privileges on %', database_name;
        END IF;
    END LOOP;
END;
$$;
