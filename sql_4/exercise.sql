-- zad 1
/* A) Jaka jest korelacja między kwotą rekompensaty oryginalnej i
kwotą rekompensaty, dla języka? */

select jezyk,
       corr(kwota_rekompensaty, kwota_rekompensaty_oryginalna) as wsp_korelacji
from wnioski
group by jezyk;

/* B) zrobić zestawienie w którym wylistujemy wszystkie wnioski wraz
   z informacją o kraju, opłatą za usługę wyrażoną kwotowo (nie procentowo) i
   informacją jaki % średniej
   opłaty w danym kraju ta opłata stanowi */

select w.id, w.kod_kraju,
       kwota_rekompensaty * oplata_za_usluge_procent / 100::numeric as kwota_uslugi,
       avg(kwota_rekompensaty * oplata_za_usluge_procent / 100::numeric)
           over (partition by w.kod_kraju) as srednia_dla_kraju,
       (kwota_rekompensaty * oplata_za_usluge_procent / 100) / (avg(kwota_rekompensaty * oplata_za_usluge_procent / 100::numeric)
           over (partition by w.kod_kraju)) * 100::numeric as procent_ze_sredniej_w_kraju
from wnioski w
group by w.id;

/* C) dla odrzuconych wniosków dla których mamy dokumenty w bazie, zrobić zestawienie
id dokumentu, id_wniosku data otrzymania oraz różnica czasu od otrzymania
pierwszego dokumentu w ramach danego wniosku (pierwszy otrzymany dokument
oczywiście będzie miał różnicę 0) */

select d.id,
       d.id_wniosku,
       d.data_otrzymania,
       row_number() over (partition by d.id_wniosku) kolejnosc_d_dla_w,
       d.data_otrzymania - first_value(d.data_otrzymania) over
           (partition by d.id_wniosku order by d.data_otrzymania) as roznica
from dokumenty d
left join wnioski w on d.id_wniosku = w.id
where w.stan_wniosku like 'odrzuc%'
order by d.id_wniosku;

/* D) Dla wniosków z polski zrobić zestawienie wniosków, stanu_wniosku, kwoty
rekompensaty oraz informację czy ta kwota mieście się w 95% przedziale ufności kwot
rekompensaty dla danego stanu wniosku (zakładamy że 95% przedział ufności to
przedział (avg - 2SD, avg + 2SD) */

select w.id,
       w.kod_kraju,
       w.stan_wniosku,
       w.kwota_rekompensaty,
       avg(kwota_rekompensaty) over (partition by w.stan_wniosku) as srednia,
       stddev(kwota_rekompensaty) over (partition by w.stan_wniosku) as sd,
       w.kwota_rekompensaty >= avg(kwota_rekompensaty)
           over (partition by w.stan_wniosku) - 2*stddev(kwota_rekompensaty)
               over (partition by w.stan_wniosku)
           and w.kwota_rekompensaty <= avg(kwota_rekompensaty)
               over (partition by w.stan_wniosku) + 2*stddev(kwota_rekompensaty)
                   over (partition by w.stan_wniosku)
           as jest_w_przedziale
from wnioski w
where w.kod_kraju ilike 'pl'
order by w.id;

--zad 2
/* Loty mogą być krajowe, regionalne - w ramach jednego kontynentu oraz między
kontynentalne ( patrz tabela: o_trasy). Chcemy zrobić zestawienie, w którym dla każdego
takiego rodzaju lotów będziemy mieli liczbę wniosków oraz współczynnik wypłat (liczba
wypłaconych do wszystkich wniosków) w ujęciu rocznym. Dodaj również YoY dla współczynnika wypłat
Uwaga: należy wykluczyć wnioski o statusie nowym, z 2015 roku oraz takie z błędnym
identyfikatorem podróży. Bliski wschód dla uproszczenia traktujemy jako osobny kontynent */

with loty as (
select kod_polaczenia,
       case when wylot_kod_kraju = przylot_kod_kraju then 'krajowe'
            when wylot_kod_regionu = przylot_kod_regionu then 'regionalne'
            else 'miedzy_kontynentalne' end as rodzaj_lotu
from o_trasy),

     lp_wnioski_dla_rodzaju_lotu as (
         select lt.rodzaj_lotu,
                w.stan_wniosku,
                w.data_utworzenia
         from wnioski w
        inner join podroze p on w.id = p.id_wniosku
        inner join szczegoly_podrozy sp on p.id = sp.id_podrozy
        inner join loty lt on lt.kod_polaczenia = sp.identyfikator_podrozy
         where stan_wniosku != 'nowy' and
               sp.identyfikator_podrozy != '%----' and
               extract(year from w.data_utworzenia) != '2015'
         )

--select * from lp_wnioski_dla_rodzaju_lotu;

select lwdrl.rodzaj_lotu,
       count (*) as lp,
       extract(year from lwdrl.data_utworzenia) as rok,
       count(case when lwdrl.stan_wniosku = 'wyplacony' then true end)/count(*)::numeric as wspolczynnik,
       (count(case when lwdrl.stan_wniosku = 'wyplacony' then true end)/count(*)::numeric -
        lag(count(case when lwdrl.stan_wniosku ='wyplacony' then true end)/count(*)::numeric)
            over(partition by lwdrl.rodzaj_lotu))/
        lag(count(case when lwdrl.stan_wniosku ='wyplacony' then true end)/count(*)::numeric)
            over(partition by lwdrl.rodzaj_lotu)::numeric as YoY
from lp_wnioski_dla_rodzaju_lotu as lwdrl
group by 1,3;
