-- Stworzenie nowej tabeli
CREATE TABLE log_sprzedazy (
    log_id SERIAL PRIMARY KEY,
    sprzedaz_id INTEGER NOT NULL,
    data_logu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacja VARCHAR(50),
    uzytkownik VARCHAR(50)
);

DROP TABLE log_sprzedazy;

-- Stworzenie nowego użytkownika i nadanie mu praw
CREATE USER analityk WITH PASSWORD 'analityk123';

GRANT SELECT ON
    sprzedaz,
    pozycja_sprzedazy,
    produkt,
    klient,
    pracownik,
    dostawa,
    dostawca,
    pozycja_dostawy
TO analityk;

-- Dodanie nowego produktu
INSERT INTO produkt (
    produkt_id,
    nazwa,
    kategoria,
    marka,
    cena_netto,
    ilosc_magazyn
)
VALUES (
    31,
    'Czujnik ciśnienia TPMS',
    'Elektryka',
    'Bosch',
    219.00,
    60
);


-- Aktualizacja stanu magazynowego po dostawie
UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn + 40
WHERE produkt_id = 3;

-- Usunięcie klienta który nie dokonał żadnego kupna
DELETE FROM klient
WHERE klient_id = 50
AND klient_id NOT IN (
    SELECT klient_id FROM sprzedaz
);


-- Zwrot towaru zapisany w logu
BEGIN;

UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn + (SELECT ilosc FROM pozycja_sprzedazy WHERE sprzedaz_id = 16 AND produkt_id = 7)
WHERE produkt_id = 7;

UPDATE pozycja_sprzedazy
SET ilosc = 0
WHERE sprzedaz_id = 16 AND produkt_id = 7;

INSERT INTO log_sprzedazy (sprzedaz_id, operacja, uzytkownik)
VALUES (16, 'Zwrot towaru', 'Sprzedawca');

COMMIT;


-- Przywrocenie stanu sprzed zwrotu
BEGIN;

UPDATE pozycja_sprzedazy
SET ilosc = 6
WHERE sprzedaz_id = 16 AND produkt_id = 7;

UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn - 6
WHERE produkt_id = 7;

COMMIT;

SELECT ilosc FROM pozycja_sprzedazy WHERE sprzedaz_id = 16 AND produkt_id = 7;
SELECT ilosc_magazyn FROM produkt WHERE produkt_id = 7;
SELECT * FROM log_sprzedazy;

-- Zmniejszenie stanu magazynowego po sprzedaży
BEGIN;

UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn - 3
WHERE produkt_id = 1;

INSERT INTO pozycja_sprzedazy (
    pozycja_sprzedazy_id,
    sprzedaz_id,
    produkt_id,
    ilosc,
    data
)
VALUES (
    31,
    31,
    1,
    3,
    CURRENT_DATE
);

COMMIT;
