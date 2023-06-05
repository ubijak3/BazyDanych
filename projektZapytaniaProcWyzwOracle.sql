set SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE DodajZawodnika (imie VARCHAR2, nazwisko VARCHAR2, nrKoszulki INT, pozycja VARCHAR2, idDruzyny INT) AS
        nextOsobaId INT;
	BEGIN
		SELECT NVL(MAX(id_osoby),0) + 1 into nextOsobaId FROM OsobaP;
        INSERT INTO OsobaP VALUES(nextOsobaId, imie, nazwisko);
        INSERT INTO Zawodnik VALUES(nextOsobaId, nrKoszulki, pozycja);
        INSERT INTO Zawodnik_w_druzynie VALUES(idDruzyny, nextOsobaId);
	END;
    
SELECT * FROM OsobaP;
EXECUTE DodajZawodnika ('Andrzej', 'Andrzejewski', 77, 'Rozgr', 1)

CREATE OR REPLACE PROCEDURE DodajMecz 
(druzyna1 INT, druzyna2 INT, sedzia1 INT, sedzia2 INT, zwyciezcaId INT,
zawodnik1 INT, liczbaPkt1 INT, zawodnik2 INT, liczbaPkt2 INT, 
zawodnik3 INT, liczbaPkt3 INT, zawodnik4 INT, liczbaPkt4 INT,
zawodnik5 INT, liczbaPkt5 INT, zawodnik6 INT, liczbaPkt6 INT,
zawodnik7 INT, liczbaPkt7 INT, zawodnik8 INT, liczbaPkt8 INT,
zawodnik9 INT, liczbaPkt9 INT, zawodnik10 INT, liczbaPkt10 INT)
AS
nextId INT;
sumaDruzyna1 INT;
sumaDruzyna2 INT;
BEGIN
	SELECT NVL(MAX(id_meczu),0) + 1 INTO nextId FROM Mecz;
	INSERT INTO mecz 
	VALUES (nextId, druzyna1, druzyna2, sedzia1, sedzia2, SYSDATE(), zwyciezcaId, 0, 0);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik1, liczbaPkt1);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik2, liczbaPkt2);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik3, liczbaPkt3);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik4, liczbaPkt4);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik5, liczbaPkt5);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik6, liczbaPkt6);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik7, liczbaPkt7);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik8, liczbaPkt8);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik9, liczbaPkt9);
	INSERT INTO zawodnik_w_meczu
	VALUES (nextId, zawodnik10, liczbaPkt10);
	sumaDruzyna1 := liczbaPkt1 + liczbaPkt2 + liczbaPkt3 + liczbaPkt4 + liczbaPkt5;
    sumaDruzyna2 := liczbaPkt6 + liczbaPkt7 + liczbaPkt8 + liczbaPkt9 + liczbaPkt10;
	UPDATE MECZ SET iloscPkt1 = sumaDruzyna1, iloscPkt2 = sumaDruzyna2 WHERE id_meczu = nextId;
END;

CREATE OR REPLACE TRIGGER Czy5OsobWDruzynie
BEFORE INSERT
ON Zawodnik_w_druzynie
FOR EACH ROW
DECLARE ileWDruzynie INT;
BEGIN
SELECT  COUNT(*) into ileWDruzynie FROM Zawodnik_w_druzynie WHERE Druzyna_id = :NEW.Druzyna_id;
IF ileWDruzynie >= 5 THEN
        RAISE_APPLICATION_ERROR(-20505,'W druzynie jest juz 5 osob' || SYSDATE);
    END IF;
END;

SELECT * FROM Zawodnik_w_druzynie;
SELECT * FROM OsobaP;
EXECUTE DodajZawodnika ('Maciej', 'Andrzejewski', 76, 'Rozgr', 1);

