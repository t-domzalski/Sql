create table kierowcy (
  id_kierowcy integer primary key,
  imie varchar(50) not null,
  nazwisko varchar(50) not null,
  srednia_ocena float(1)
);


create table samochody (
  id_samochody integer primary key,
  nr_rejestracyjny varchar(7) not null,
  dystans integer not null,
  data_przegladu date not null,
  ilosc_miejsc integer not null,
  marka varchar(50) not null,
  model varchar(50) not null
);


create table przejazdy (
  id_przejazdy integer primary key,
  id_kierowcy integer not null,
  id_samochody integer not null,
  czas integer not null,
  dystans integer not null,
  koszt float(2) not null,
  napiwek float(2),
  foreign key (id_kierowcy) references kierowcy,
  foreign key (id_samochody) references samochody
);


create table kierowcy_samochody
(
  id_kierowcy integer,
  id_samochody integer,
  foreign key(id_kierowcy) references kierowcy,
  foreign key(id_samochody) references samochody
);


insert into kierowcy (id_kierowcy, imie, nazwisko, srednia_ocena)  values
(1, 'Jan', 'Kowalski', 4.7),
(2, 'Sławomir', 'Brzęczyszczykiewicz', 3.5)
;

insert into samochody (id_samochody, nr_rejestracyjny, dystans, data_przegladu, ilosc_miejsc, marka, model) values
(1, 'GD 1234', 34567, '2019-01-01', 5, 'opel', 'kadet'),
(2, 'GD 4321', 56789, '2019-02-02', 7, 'volkswagen', 'sharan')
;

insert into przejazdy (id_przejazdy, id_kierowcy, id_samochody, czas, dystans, koszt, napiwek) values
(1, 1, 2, 12, 4, 32.55, 1.30),
(2, 2, 1, 2, 5, 12.49, 5.80)
;

insert into kierowcy_samochody (id_kierowcy, id_samochody) values
(1, 1),
(1, 2),
(2, 1),
(2, 2)
;