

SELECT * FROM zawodnik_w_meczu;

--1 wypisz imie nazwisko i liczbe pkt zawodnika ktory zdobyl najwiecej pkt
SELECT o.imie, o.nazwisko, o.liczba_pkt FROM OsobaP o
INNER JOIN Zawodnik z ON z.Osoba_Id = o.Id_osoby
INNER JOIN Zawodnik_w_meczu zwm ON zwm.Zawodnik_Id = z.Osoba_Id
WHERE zwm.liczba_Pkt = (SELECT MAX(liczba_pkt) FROM zawodnik_w_meczu);

--2 wpisz zawodnikow i ich zdobycze, kiedy grali mecze ponizej sredniej ligi
SELECT o.imie, o.nazwisko, o.liczba_pkt FROM OsobaP o
INNER JOIN Zawodnik z ON z.Osoba_Id = o.Id_osoby
INNER JOIN Zawodnik_w_meczu zwm ON zwm.Zawodnik_Id = z.Osoba_Id
WHERE zwm.Liczba_pkt <	(SELECT AVG(liczba_pkt) FROM zawodnik_w_meczu);

--3 wypisz liste zawodnikow i sume ich zdobyczy, ktore przekraczja sume zdobyczy zawodnika Aleksego Aleksowskiego, posortuj malejaca
SELECT o.imie, o.nazwisko, sum(zwm.liczba_pkt) FROM osobap o
INNER JOIN Zawodnik z ON z.Osoba_Id = o.Id_osoby
INNER JOIN Zawodnik_w_meczu zwm ON zwm.Zawodnik_Id = z.Osoba_Id
GROUP BY o.Imie, o.Nazwisko
HAVING SUM(zwm.liczba_pkt) > (SELECT SUM(zwmw.liczba_pkt) FROM zawodnik_w_meczu zwmw
								INNER JOIN Zawodnik zw ON zw.Osoba_Id = zwmw.Zawodnik_Id
								INNER JOIN OsobaP ow ON ow.Id_osoby = zw.Osoba_Id
								WHERE ow.imie = 'Aleksy' AND ow.nazwisko = 'Aleksowski')
ORDER BY sum(zwm.liczba_pkt) DESC;

--4 wypisz druzyny i ilosc ich zwyciestw jesli wygrali wiecej meczy niz Great Team
SELECT d.Nazwa, count(*) FROM Druzyna d
INNER JOIN Mecz m ON m.KtoraWygrala = d.Id_druzyny
GROUP BY d.nazwa
HAVING count(*) >= (SELECT count(*) FROM Druzyna dw
					INNER JOIN mecz mw ON mw.KtoraWygrala = dw.Id_druzyny
					WHERE dw.Nazwa = 'Great Team')
ORDER BY count(*) DESC;

--5 dla kazdej druzyny wypisz zawodnika ktory zdobyl najwiecej punktow
SELECT o.imie, o.nazwisko, d.Nazwa, zwm.liczba_pkt FROM OsobaP o
INNER JOIN Zawodnik z ON z.osoba_Id = o.id_osoby
INNER JOIN zawodnik_w_druzynie zwd ON zwd.zawodnik_id = z.osoba_id
INNER JOIN Druzyna d ON d.Id_druzyny = zwd.druzyna_id
INNER JOIN zawodnik_w_meczu zwm ON zwm.zawodnik_id = z.osoba_id
WHERE zwm.liczba_pkt = (SELECT max(zwm.liczba_pkt) FROM Zawodnik_w_meczu zwm
					WHERE zwd.zawodnik_id = o.Id_osoby);



go 

--1 procedura 
ALTER PROCEDURE DodajMecz 
@druzyna1 INT, @druzyna2 INT, @sedzia1 INT, @sedzia2 INT, @zwyciezcaId INT,
@zawodnik1 INT, @liczbaPkt1 INT, @zawodnik2 INT, @liczbaPkt2 INT, 
@zawodnik3 INT, @liczbaPkt3 INT, @zawodnik4 INT, @liczbaPkt4 INT,
@zawodnik5 INT, @liczbaPkt5 INT, @zawodnik6 INT, @liczbaPkt6 INT,
@zawodnik7 INT, @liczbaPkt7 INT, @zawodnik8 INT, @liczbaPkt8 INT,
@zawodnik9 INT, @liczbaPkt9 INT, @zawodnik10 INT, @liczbaPkt10 INT
AS
DECLARE @nextId INT, @sumaDruzyna1 INT, @sumaDruzyna2 INT;
BEGIN
	SELECT @nextId = ISNULL(MAX(id_meczu),0) + 1 FROM Mecz;
	INSERT INTO mecz 
	VALUES (@nextId, @druzyna1, @druzyna2, @sedzia1, @sedzia2, GETDATE(), @zwyciezcaId, 0, 0)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik1, @liczbaPkt1)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik2, @liczbaPkt2)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik3, @liczbaPkt3)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik4, @liczbaPkt4)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik5, @liczbaPkt5)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik6, @liczbaPkt6)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik7, @liczbaPkt7)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik8, @liczbaPkt8)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik9, @liczbaPkt9)
	INSERT INTO zawodnik_w_meczu
	VALUES (@nextId, @zawodnik10, @liczbaPkt10)
	SET @sumaDruzyna1 = @liczbaPkt1 + @liczbaPkt2 + @liczbaPkt3 + @liczbaPkt4 + @liczbaPkt5;
	SET @sumaDruzyna2 = @liczbaPkt6 + @liczbaPkt7 + @liczbaPkt8 + @liczbaPkt9 + @liczbaPkt10;
	UPDATE MECZ SET iloscPkt1 = @sumaDruzyna1, iloscPkt2 = @sumaDruzyna2 WHERE id_meczu = @nextId;
END
go

EXEC DodajMecz 1, 2, 17, 16, 1, 2, 7, 3, 15, 4, 23, 5, 8, 19, 18, 6, 9, 7, 6, 8, 17, 9, 4, 10, 6 

--2 procedura
go
CREATE PROCEDURE DodajZawodnika 
@imie VARCHAR(20), @nazwisko VARCHAR(20), @nrKoszulki INT, @pozycja VARCHAR(10), @idDruzyny INT
AS
DECLARE @nextOsobaId INT;
BEGIN
	SELECT @nextOsobaId = ISNULL(MAX(id_osoby),0) + 1 FROM OsobaP;
	INSERT INTO OsobaP 
	VALUES( @nextOsobaId, @imie, @nazwisko)
	INSERT INTO Zawodnik
	VALUES(@nextOsobaId, @nrKoszulki, @pozycja)
	INSERT INTO Zawodnik_w_druzynie
	VALUES(@idDruzyny, @nextOsobaId)
END
go
EXEC DodajZawodnika 'Andrzej', 'Andrzejewski', 77, 'Rozgr', 1 

go
--1 trigger
ALTER TRIGGER Czy5OsobWDruzynie
ON OsobaP
FOR INSERT
AS
DECLARE @ileWDruzynie INT, @idDruzyny INT
SELECT @idDruzyny = Druzyna_id FROM INSERTED;
SELECT @ileWDruzynie = COUNT(*) FROM Zawodnik_w_druzynie WHERE Druzyna_id = @idDruzyny;
IF @ileWDruzynie >= 5 BEGIN
	ROLLBACK
END

SELECT * FROM Zawodnik_w_druzynie;
SELECT * FROM OsobaP;

DELETE FROM OsobaP WHERE id_osoby = 20;

