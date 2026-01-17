-- Zapytania Biznesowe

-- Średnia cena zakupu i marża na produktach
SELECT
    p.produkt_id,
    p.nazwa,
    p.cena_netto AS cena_sprzedazy_netto,
    ROUND(AVG(pd.cena_zakupu_netto), 2) AS sr_cena_zakupu_netto,
    ROUND((p.cena_netto - AVG(pd.cena_zakupu_netto)), 2) AS marza_na_sztuce
FROM produkt p
    JOIN pozycja_dostawy pd ON p.produkt_id = pd.produkt_id
GROUP BY p.produkt_id, p.nazwa, p.cena_netto
ORDER BY marza_na_sztuce DESC;


-- Łączna wartość dostaw od każdego dostawcy
SELECT
    ds.dostawca_id,
    ds.nazwa_firmy,
    SUM(d.wartosc_netto) AS laczna_wartosc_dostaw
FROM dostawa d
    JOIN dostawca ds ON d.dostawca_id = ds.dostawca_id
GROUP BY ds.dostawca_id, ds.nazwa_firmy
ORDER BY laczna_wartosc_dostaw DESC;


-- Obrót produktów danej marki np. Bosch
SELECT
    p.marka,
    p.nazwa,
    SUM(ps.ilosc) AS sprzedana_ilosc,
    SUM(ps.ilosc * p.cena_netto) AS obrot_netto
FROM pozycja_sprzedazy ps
    JOIN produkt p ON ps.produkt_id = p.produkt_id
WHERE p.marka = 'Bosch'   
GROUP BY p.marka, p.nazwa
ORDER BY obrot_netto DESC;


-- Sprzedana ilość przedmiotu w podziale na kategorie
SELECT
    pr.kategoria,
    SUM(ps.ilosc) AS sprzedana_ilosc
FROM pozycja_sprzedazy ps
    JOIN produkt pr ON ps.produkt_id = pr.produkt_id
GROUP BY pr.kategoria
ORDER BY sprzedana_ilosc DESC;


-- Produkty których jest mało na stanie
SELECT
    produkt_id,
    nazwa,
    ilosc_magazyn
FROM produkt
WHERE ilosc_magazyn < 15
ORDER BY ilosc_magazyn ASC;


-- Pracownicy z najdłuższym stażem
SELECT
    pracownik_id,
    imie || ' ' || nazwisko AS pracownik,
    data_zatrudnienia,
    EXTRACT(YEAR FROM age(CURRENT_DATE, data_zatrudnienia)) AS lata_stazu
FROM pracownik
ORDER BY data_zatrudnienia;


-- Ranking sprzedaży wśród pracowników
SELECT
    p.pracownik_id,
    (p.imie || ' ' || p.nazwisko) AS pracownik,
    SUM(wcs.wartosc_calkowita_netto) AS wartosc_sprzedazy
FROM sprzedaz s
    JOIN pracownik p ON s.pracownik_id = p.pracownik_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
GROUP BY p.pracownik_id, p.imie, p.nazwisko
ORDER BY wartosc_sprzedazy DESC;


-- Wykaz sumy sprzedaży podzielonej na całe miesiące
SELECT
    EXTRACT(YEAR FROM ps.data) AS rok,
    EXTRACT(MONTH FROM ps.data) AS miesiac,
    SUM(wcs.wartosc_calkowita_netto) AS sprzedaz_miesieczna_netto
FROM sprzedaz s
    JOIN pozycja_sprzedazy ps ON s.sprzedaz_id = ps.sprzedaz_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
GROUP BY EXTRACT(YEAR FROM ps.data), EXTRACT(MONTH FROM ps.data)
ORDER BY rok, miesiac;


-- Sprzedaż na dzień w podanym zakresie dat np. cały styczeń 2024
SELECT
    ps.data,
    SUM(wcs.wartosc_calkowita_netto) AS wartosc_netto_dnia
FROM sprzedaz s
    JOIN pozycja_sprzedazy ps ON s.sprzedaz_id = ps.sprzedaz_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
WHERE ps.data BETWEEN DATE '2024-01-01' AND DATE '2024-01-31'
GROUP BY ps.data
ORDER BY ps.data;


-- Wykaz produktów które nigdy się nie sprzedały
SELECT 
    p.produkt_id, 
    p.nazwa, 
    p.ilosc_magazyn,
    ps.produkt_id
FROM produkt p
    LEFT JOIN pozycja_sprzedazy ps ON p.produkt_id = ps.produkt_id
WHERE ps.produkt_id IS NULL;


-- Wykaz pracowników i ich pensje zestawione z ogólną średnią pensją
SELECT p.imie, p.nazwisko, p.stanowisko, p.data_zatrudnienia, p.pensja, ROUND(AVG(pensja) OVER(), 2) as srednia_pensja 
FROM pracownik p;


-- Pokaz pracowników którzy zarabiają więcej niż średnia pensja na ich stanowisku
WITH pensje AS (
    SELECT p.imie, p.nazwisko, p.stanowisko, p.data_zatrudnienia, p.pensja, ROUND(AVG(pensja) OVER(PARTITION BY stanowisko), 2) AS srednia_pensja
    FROM pracownik p
)
SELECT *
FROM pensje
WHERE pensja > srednia_pensja;


-- Top 5 najlepiej sprzedających się produktów
SELECT
    p.produkt_id,
    p.nazwa,
    SUM(ps.ilosc) AS laczna_sprzedaz
FROM pozycja_sprzedazy ps
    JOIN produkt p ON p.produkt_id = ps.produkt_id
GROUP BY p.produkt_id, p.nazwa
ORDER BY laczna_sprzedaz DESC
LIMIT 5;


-- Produkty o najniższej rotacji
SELECT
    p.produkt_id,
    p.nazwa,
    COALESCE(SUM(ps.ilosc), 0) AS sprzedana_ilosc
FROM produkt p
    LEFT JOIN pozycja_sprzedazy ps ON p.produkt_id = ps.produkt_id
GROUP BY p.produkt_id, p.nazwa
HAVING COALESCE(SUM(ps.ilosc), 0) < 10
ORDER BY sprzedana_ilosc ASC;


-- Klienci generujący największy obrót
SELECT
    k.klient_id,
    k.imie || ' ' || k.nazwisko AS klient,
    SUM(wcs.wartosc_calkowita_netto) AS obrot_klienta
FROM klient k
    JOIN sprzedaz s ON k.klient_id = s.klient_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
GROUP BY k.klient_id, klient
ORDER BY obrot_klienta DESC;


-- Podział sprzedaży na klientów firmowych i indywidualnych
SELECT
    CASE 
        WHEN k.czy_firma = true THEN 'Firma'
        ELSE 'Osoba prywatna'
    END AS typ_klienta,
    SUM(wcs.wartosc_calkowita_netto) AS laczny_obrot
FROM klient k
    JOIN sprzedaz s ON k.klient_id = s.klient_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
GROUP BY typ_klienta;


-- Średnia wartość sprzedaży na pracownika
SELECT
    p.pracownik_id,
    p.imie || ' ' || p.nazwisko AS pracownik,
    ROUND(AVG(wcs.wartosc_calkowita_netto), 2) AS srednia_sprzedaz
FROM sprzedaz s
    JOIN pracownik p ON s.pracownik_id = p.pracownik_id
    JOIN wartosc_calk_sprzedazy wcs ON s.sprzedaz_id = wcs.sprzedaz_id
GROUP BY p.pracownik_id, pracownik;


-- Ranking dostawców według średniej wartości dostawy
SELECT
    ds.nazwa_firmy,
    ROUND(AVG(d.wartosc_netto), 2) AS srednia_dostawa
FROM dostawca ds
    JOIN dostawa d ON ds.dostawca_id = d.dostawca_id
GROUP BY ds.nazwa_firmy
ORDER BY srednia_dostawa DESC;


-- Produkty tańsze niż średnia cena
WITH produkty AS (
    SELECT p.produkt_id, p.nazwa, p.kategoria, p.marka, p.cena_netto, ROUND(AVG(cena_netto) OVER(), 2) as srednia_cena_rynkowa
    FROM produkt p
    )
SELECT p.*
FROM produkty p
WHERE cena_netto < srednia_cena_rynkowa


-- Produkty zestawione ze średnią ceną netto spośród kategorii przedmiotu
WITH produkty AS (
    SELECT p.produkt_id, p.nazwa, p.kategoria, p.marka, p.cena_netto, ROUND(AVG(cena_netto) OVER(), 2) as srednia_cena_rynkowa
    FROM produkt p
    )
SELECT p.*,
ROUND(AVG(cena_netto) OVER(PARTITION BY kategoria), 2) as srednia_cena_netto_kategorii 
FROM produkty p


-- Udział procentowy kategorii w całej sprzedaży
SELECT
    p.kategoria,
    ROUND(
        SUM(ps.ilosc * p.cena_netto) / SUM(SUM(ps.ilosc * p.cena_netto)) OVER () * 100, 2
    ) AS procent_sprzedazy
FROM pozycja_sprzedazy ps
    JOIN produkt p ON ps.produkt_id = p.produkt_id
GROUP BY p.kategoria
ORDER BY procent_sprzedazy DESC;

-- Wykaz 3 najlepiej zarabiających osób wśród stanowisk
WITH ranking AS (
    SELECT
        p.*,
        DENSE_RANK() OVER(PARTITION BY stanowisko ORDER BY pensja DESC) AS pozycja
    FROM pracownik p
)
SELECT *
FROM ranking
WHERE pozycja <= 3
ORDER BY stanowisko, pozycja;