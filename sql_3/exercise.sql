--zad2
--a

select count(w.id)
from wnioski w
left join podroze p on w.id = p.id_wniosku
left join szczegoly_podrozy sp on p.id = sp.id_podrozy
where date_part('days',(w.data_utworzenia - sp.data_wyjazdu)) > 1000;

--b
--b1

select sum(case when typ_podrozy = 'biznesowy' then liczba_pasazerow end)
from wnioski;

--b2

select count(case when typ_podrozy = 'biznesowy' and kwota_rekompensaty != 0 then 1 end)
from wnioski;

--b3

select sum(case when typ_podrozy = 'biznesowy' then kwota_rekompensaty end)
from wnioski;

--c

select avg(date_part('days',(w.data_utworzenia - sp.data_wyjazdu))) as x_dni
from wnioski w
left join podroze p on w.id = p.id_wniosku
left join szczegoly_podrozy sp on p.id = sp.id_podrozy
where w.typ_podrozy = 'biznesowy';

--d

select extract(year from data_rozpoczecia) rok, count(1) ilosc,
       (count(1) - lag(count(1)) over (order by extract(year from data_rozpoczecia)))
       /lag(count(1)) over (order by extract(year from data_rozpoczecia))::numeric YoY
from analiza_prawna
group by 1;

--e

select
percentile_disc(0.25) within group (order by w.oplata_za_usluge_procent) Q1,
percentile_disc(0.5) within group (order by w.oplata_za_usluge_procent) Q2_mediana,
percentile_disc(0.75) within group (order by w.oplata_za_usluge_procent) Q3
from wnioski w
left join analiza_prawna ap on w.id = ap.id_wniosku;





