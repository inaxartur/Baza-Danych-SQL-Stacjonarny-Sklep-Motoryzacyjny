Baza Danych Sklepu Motoryzacyjnego


1. Celem jest zapewnienie łatwego i uporządkowanego zarządzania sprzedażą, stanem magazynowym.

Zastosowania biznesowe:
   * Przechowywanie informacji o częściach samochodowych ( nazwa, cena, marka, kompatybilność z danymi modelami samochodów ).
   * Monitorowanie stanu magazynowego produktów.
   * Przechowywanie danych klientów ( firm / stałych klientów ).
   * Rejestrowanie sprzedaży oraz analiza jej historii.
   * Rejestracja pracowników.
   * Powiązanie transakcji z danym pracownikiem.
   * Historia zamówień i dostaw.


   2.  Projekt bazy danych i diagram ER:

      1. Encje i atrybuty:

         1. Produkt:
         * nazwa
         * kategoria
         * marka
         * cena_netto
         * ilość_magazyn

            1. Klient:
            * imię
            * nazwisko
            * telefon
            * nip
            * adres

               1. Pracownik:
               * imię
               * nazwisko
               * stanowisko
               * data_zatrudnienia
               * telefon







                  1. Sprzedaż:
                  * produkt
                  * ilość
                  * data_sprzedaży
                  * imię_klienta
                  * nazwisko_klienta
                  * imię_pracownika
                  * nazwisko_pracownika
                  * wartość_netto

                     1. Dostawa:
                     * nazwa dostawcy
                     * numer dostawy
                     * nip
                     * telefon
                     * data
                     * produkt
                     * ilość
                     * wartość_netto


                     2. Relacje:
                     1. Klient  -  1..*  -  Sprzedaż
                     2. Pracownik - 1..* - Sprzedaż
                     3. Produkt - 1..* - Sprzedaż
                     4. Produkt - 1..* -Dostawa


                     3. Normalizacja i określenie kluczy:

                        1. Produkt:
                        * produkt_id ( PK )
                        * nazwa
                        * kategoria
                        * marka
                        * cena_netto
                        * ilość_magazyn

                           1. Klient:
                           * klient_id ( PK )
                           * imię
                           * nazwisko
                           * telefon
                           * czy_firma
                           * nazwa_firmy
                           * nip
                           * adres




                           2. Pracownik:
                           * pracownik_id ( PK )
                           * imię
                           * nazwisko
                           * stanowisko
                           * data_zatrudnienia
                           * telefon


                           3. Sprzedaż:
                           * sprzedaż_id ( PK )
                           * klient_id ( FK )
                           * pracownik_id ( FK ) 


                           4. Pozycja sprzedaży:
                           * pozycja_sprzedaży_id ( PK )
                           * sprzedaż_id ( FK )
                           * produkt_id ( FK )
                           * ilość
                           * data


                           5. Dostawa:
                           * dostawa_id ( PK )
                           * dostawca_id ( FK ) 
                           * data
                           * wartość_dostawy_netto

                              1. Pozycja dostawy:
                              * pozycja_dostawy_id ( PK )
                              * dostawa_id ( FK ) 
                              * produkt_id ( FK )
                              * ilość
                              * cena_zakupu_netto

                                 1. Dostawca:
                                 * dostawca_id ( PK )
                                 * nazwa_firmy
                                 * telefon
                                 * e-mail
                                 * nip
                                 * adres




                                    1. Diagram ER:


  

Relacje: 


                                    * klient - 1..* - sprzedaż 
                                    * pracownik - 1..* - sprzedaż 
                                    * sprzedaż - 1..* - pozycja_sprzedaży 
                                    * produkt - 1..* - pozycja_sprzedaży 
                                    * dostawca - 1..* - dostawa 
                                    * dostawa - 1..* - pozycja_dostawy 
                                    * produkt - 1..* - pozycja_dostawy


                                    3. Scenariusz analityczny 
                                    1. Celem analizy jest nagradzanie najlepszych pracowników, 
                                    4. Scenariusz administracyjny


                                    2. Cel scenariusza
Celem scenariusza administracyjnego jest zaprezentowanie podstawowych operacji administracyjnych w systemie sprzedażowo-magazynowym, obejmujących tworzenie struktur danych, zarządzanie użytkownikami oraz modyfikację zestawów danych.
                                    3. Utworzenie nowej tabeli
Administrator tworzy tabelę rejestrującą operacje sprzedażowe w celach kontrolnych.


CREATE TABLE log_sprzedazy (
    log_id SERIAL PRIMARY KEY,
    sprzedaz_id INTEGER NOT NULL,
    data_logu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacja VARCHAR(50),
    uzytkownik VARCHAR(50)
);


                                    4. Utworzenie nowego użytkownika
Tworzony jest użytkownik przeznaczony do analiz danych z ograniczonymi uprawnieniami.


CREATE USER analityk WITH PASSWORD 'analityk123';







                                    5. Nadanie uprawnień
Użytkownik analityk otrzymuje wyłącznie dostęp do odczytu danych.


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


                                    6. Dodanie nowego zestawu danych
Dodanie nowego produktu do oferty.


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


                                    7. Aktualizacja danych
Aktualizacja stanu magazynowego po dostawie.


UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn + 40
WHERE produkt_id = 3;


                                    8. Usunięcie danych
Usunięcie klienta, który nie dokonał żadnego zakupu


DELETE FROM klient
WHERE klient_id = 50
AND klient_id NOT IN (
    SELECT klient_id FROM sprzedaz
);


                                    9. Przykład użycia transakcji do aktualizacji danych oraz dodania nowego zestawu danych
Przykład przedstawia realizację sprzedaży, w której następuje zmniejszenie stanu magazynowego produktu. Operacja jest wykonywana w ramach transakcji w celu zachowania spójności danych.
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

                                    10. Przykład użycia nowo utworzonej tabeli log_sprzedazy
Przykład przedstawia wykorzystanie tabeli log_sprzedazy w celu zapisania informacji o dokonaniu zwrotu towaru. Operacja została wykonana w transakcji w celu zachowania spójności danych
BEGIN;


UPDATE produkt
SET ilosc_magazyn = ilosc_magazyn + (SELECT ilosc FROM pozycja_sprzedazy WHERE sprzedaz_id = 16 AND produkt_id = 7)
Where produkt_id = 7;


UPDATE pozycja_sprzedazy
SET ilosc = 0
WHERE sprzedaz_id = 16 AND produkt_id = 7;


INSERT INTO log_sprzedazy (sprzedaz_id, operacja, uzytkownik)
VALUES (16, ‘Zwrot towaru’, ‘Sprzedawca’);


COMMIT;
