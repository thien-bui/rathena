-- Root access to mariadb
sudo mariadb -u root

-- Access mariadb container
docker exec -it rathena_db /bin/bash


-- Dump schema
mariadb-dump -u ragnarok -pragnarok --no-data ragnarok > ragnarok_schema.sql

-- Dump db to backupfile
mariadb-dump -u ragnarok -pragnarok --all-databases > "ragnarokdb_$(date +"%s").sql"

-- Copy from remote host over ssh
scp pi@NanoPi-R4S:~/projects/ragnarokdb_1751637713.sql .

-- Copy backup to host
docker cp rathena_db:<<backup_name>> .

-- Restore backup
mariadb -u ragnarok -pragnarok < ragnarokdb_1751638109.sql

-- Grant access to ragnarok if needed
GRANT ALL ON ragnarok_pre.* TO ragnarok@localhost IDENTIFIED BY "ragnarok";


-- Repair tables after power outage
mariadbcheck -u ragnarok -pragnarok --auto-repair --all-databases


-- Query dupls
SELECT idbr.name_english, idbr2.name_english, sub.* FROM 
(
    SELECT nameid, account_id, count(nameid) as count FROM storage GROUP BY nameid, account_id
) as sub
LEFT JOIN item_db_re idbr on idbr.id = sub.nameid
LEFT JOIN item_db2_re idbr2 on idbr2.id = sub.nameid
where sub.count > 20;

-- Delete equip dups
DELETE FROM storage
WHERE id IN (
    SELECT id FROM (
            SELECT
                *,
                ROW_NUMBER() OVER(PARTITION BY nameid, account_id ORDER BY nameid) as RN
            FROM
                storage
            WHERE card0 = 0
                AND card1 = 0
                AND card2 = 0
                AND card3 = 0
                AND refine = 0
        ) AS CTE
    WHERE CTE.RN > 2
);

DELETE FROM storage
WHERE id IN (
    SELECT id FROM (
            SELECT
                *,
                ROW_NUMBER() OVER(PARTITION BY nameid, account_id ORDER BY nameid) as RN
            FROM
                storage
            WHERE card0 = 0
                AND card1 = 0
                AND card2 = 0
                AND card3 = 0
                AND refine = 0
        ) AS CTE
    WHERE CTE.RN > 2
    AND nameid = 1443
);