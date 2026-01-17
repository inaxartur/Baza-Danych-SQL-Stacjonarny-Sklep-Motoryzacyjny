CREATE TABLE produkt (
    produkt_id INTEGER PRIMARY KEY,
    nazwa VARCHAR(50) UNIQUE NOT NULL,
    kategoria VARCHAR(50),
    marka VARCHAR(50),
    cena_netto DECIMAL NOT NULL,
    ilosc_magazyn INTEGER
);

CREATE TABLE klient (
  klient_id INTEGER PRIMARY KEY,
  imie VARCHAR(50),
  nazwisko VARCHAR(50),
  telefon VARCHAR(15),
  czy_firma BOOLEAN,
  nazwa_firmy VARCHAR(100),
  nip VARCHAR(10),
  adres VARCHAR(50),

  CHECK (
        (czy_firma = false
            AND imie IS NOT NULL
            AND nazwisko IS NOT NULL
        )
        OR
        (czy_firma = true
            AND nazwa_firmy IS NOT NULL
            AND nip IS NOT NULL
        )
    )
);

CREATE TABLE pracownik (
    pracownik_id INTEGER PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    stanowisko VARCHAR(50) NOT NULL,
    data_zatrudnienia DATE NOT NULL,
    telefon VARCHAR(15) NOT NULL,
    pensja DECIMAL NOT NULL
);

CREATE TABLE sprzedaz (
    sprzedaz_id INTEGER PRIMARY KEY,
    klient_id INTEGER REFERENCES klient,
    pracownik_id INTEGER REFERENCES pracownik NOT NULL,
);

CREATE TABLE pozycja_sprzedazy (
    pozycja_sprzedazy_id INTEGER PRIMARY KEY,
    sprzedaz_id INTEGER REFERENCES sprzedaz NOT NULL,
    produkt_id INTEGER REFERENCES produkt NOT NULL,
    ilosc INTEGER NOT NULL,
    data DATE NOT NULL
);

CREATE TABLE dostawa (
    dostawa_id INTEGER PRIMARY KEY,
    dostawca_id INTEGER REFERENCES dostawca,
    data DATE NOT NULL,
    wartosc_dostawy_netto DECIMAL
);

CREATE TABLE pozycja_dostawy (
    pozycja_dostawy_id INTEGER PRIMARY KEY,
    dostawa_id INTEGER REFERENCES dostawa NOT NULL,
    produkt_id INTEGER REFERENCES produkt NOT NULL,
    ilosc INTEGER NOT NULL,
    cena_zakupu_netto DECIMAL NOT NULL
);

CREATE TABLE dostawca (
    dostawca_id INTEGER PRIMARY KEY,
    nazwa_firmy VARCHAR(100) NOT NULL,
    telefon VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    nip VARCHAR(10) NOT NULL,
    adres VARCHAR(100) NOT NULL
);