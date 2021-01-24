create database sacramentorealestate;

select count(*) from sacramentorealestatetransactions

--zad2_a

select min(price) from sacramentorealestatetransactions;

--zad2_b

select max(price) from sacramentorealestatetransactions;

--zad2_c

select count(*)
    from sacramentorealestatetransactions
    where type = 'Residential';

--zad2_d

select round(avg(price),2)
    from sacramentorealestatetransactions
    where city = 'SACRAMENTO';

--zad2_e

select max(sq__ft)
    from sacramentorealestatetransactions
    where city = 'RIO LINDA';

--zad3_a

select id, kwota_rekompensaty
    from wnioski
    where kwota_rekompensaty != 250
        and kwota_rekompensaty != 400
        and kwota_rekompensaty != 600;

--zad3_b

select count(kwota_rekompensaty)
    from wnioski
    where kwota_rekompensaty != 250
        and kwota_rekompensaty != 400
        and kwota_rekompensaty != 600;

--zad4_a

select date_part('year', data_utworzenia), partner, count(1)
    from wnioski
    group by (1,2);

--zad4_b

select round(count(case when stan_wniosku like 'odrzucony%' then 1 end)/
      count(*) ::numeric *100,2) as wnioski_odrzucone
    from wnioski;

--zad4_c

select avg(kwota_rekompensaty)::integer as srednia,
       date_part('year', data_utworzenia), partner, count(*)
    from wnioski
    where stan_wniosku like 'odrzucony%'
    group by (2,3)
    order by 2;

--zad4_d

select avg(
        abs(
          date_part('day',
                date_trunc('day', analiza_prawna.data_wyslania_sad) - date_trunc('day', analiza_prawna.data_odp_sad)
              )
            )
          )
from analiza_prawna;

