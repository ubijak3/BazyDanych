CREATE TABLE STAT_GRADE_S26100 (
    Id integer  NOT NULL,
    Grade integer  NOT NULL,
    Budzet integer  NOT NULL,
    LiczbaPrac integer  NOT NULL,
    OstModyfikacja date  NOT NULL,
    CONSTRAINT STAT_GRADE_S26100_pk PRIMARY KEY (Id)
) ;

SET ServerOutput ON
CREATE OR REPLACE PROCEDURE WypelnijDane AS
nextId INT; nrGrupy INT;
sumaGrupy INT; liczbaPracGrupy INT;
gornaGranica INT; dolnaGranica INT;
Info VARCHAR2(200);
CURSOR aktGrupa IS SELECT grade FROM salgrade;
BEGIN
OPEN aktGrupa;
    LOOP 
        FETCH aktGrupa INTO nrGrupy;
        SELECT losal INTO dolnaGranica FROM salgrade WHERE grade = nrGrupy;
        SELECT hisal INTO gornaGranica FROM salgrade WHERE grade = nrGrupy;
        SELECT SUM(sal) INTO sumaGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
        SELECT NVL(MAX(id),0) + 1 INTO nextId FROM stat_grade_s26100;
        SELECT COUNT(1) INTO liczbaPracGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
        INSERT INTO STAT_GRADE_S26100 VALUES(nextId,nrGrupy,sumaGrupy,liczbaPracGrupy,SYSDATE);
        info := 'Do tabeli STAT_GRADE_S26100 wpisano rekord: id: ' || nextId || ' grupa zarobkowa: ' || nrGrupy || ' suma potrzebna na wyplate pensji: ' || sumaGrupy;
        DBMS_OUTPUT.PUT_LINE(info);
        EXIT WHEN aktGrupa %NOTFOUND;
        END LOOP;
    CLOSE aktGrupa;
    -- Nie obsluguje wpisywania zero jesli grupa zarobkowa jest pusta
END;

CREATE OR REPLACE TRIGGER ZmienionoDaneOPensjach
AFTER INSERT OR UPDATE
ON emp
FOR EACH ROW
DECLARE
nextId INT; nrGrupy INT; zarobki INT;
sumaGrupy INT; liczbaPracGrupy INT;
gornaGranica INT; dolnaGranica INT;
Info VARCHAR2(200);
BEGIN
    IF INSERTING THEN
        zarobki := :NEW.Sal;
        SELECT grade into nrGrupy FROM Salgrade WHERE losal < zarobki AND hisal > zarobki;
        SELECT losal INTO dolnaGranica FROM salgrade WHERE grade = nrGrupy;
        SELECT hisal INTO gornaGranica FROM salgrade WHERE grade = nrGrupy;
        SELECT SUM(sal) INTO sumaGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
        SELECT NVL(MAX(id),0) + 1 INTO nextId FROM stat_grade_s26100;
        SELECT COUNT(1) INTO liczbaPracGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
        INSERT INTO STAT_GRADE_S26100 VALUES(nextId,nrGrupy,sumaGrupy,liczbaPracGrupy,SYSDATE);
        info := 'w grupie zarobkowej ' || nrGrupy || 'pojawil sie nowy pracownik z pensja ' || zarobki
        || ' do tabeli STAT_GRADE_S26100 wpisano rekord: id: ' || nextId || ' grupa zarobkowa: ' || nrGrupy 
        || ' suma potrzebna na wyplate pensji: ' || sumaGrupy;
        DBMS_OUTPUT.PUT_LINE(info);
    END IF;
    IF UPDATING THEN
        IF :NEW.Sal <> :OLD.Sal THEN
            zarobki := :NEW.Sal;
            SELECT grade into nrGrupy FROM Salgrade WHERE losal < zarobki AND hisal > zarobki;
            SELECT losal INTO dolnaGranica FROM salgrade WHERE grade = nrGrupy;
            SELECT hisal INTO gornaGranica FROM salgrade WHERE grade = nrGrupy;
            SELECT SUM(sal) INTO sumaGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
            SELECT NVL(MAX(id),0) + 1 INTO nextId FROM stat_grade_s26100;
            SELECT COUNT(1) INTO liczbaPracGrupy FROM emp WHERE sal BETWEEN dolnaGranica AND gornagranica;
            INSERT INTO STAT_GRADE_S26100 VALUES(nextId,nrGrupy,sumaGrupy,liczbaPracGrupy,SYSDATE);
            info := 'w grupie zarobkowej ' || nrGrupy || 'wystapiły zmiany pensji z ' || :OLD.Sal || ' na ' || zarobki
        || ' do tabeli STAT_GRADE_S26100 wpisano rekord: id: ' || nextId || ' grupa zarobkowa: ' || nrGrupy 
        || ' suma potrzebna na wyplate pensji: ' || sumaGrupy;
        DBMS_OUTPUT.PUT_LINE(info);
        END IF;
    END IF;
END;

SELECT * FROM PROJ;
SELECT * FROM PROJ_EMP;
SELECT * FROM EMP;
GO
ALTER PROCEDURE proc1 @stan VARCHAR(9), @proj VARCHAR(14)
AS
BEGIN
DECLARE @empnoP INT, @liczbaZatrNaStan INT, @nextProjno INT, @budzet INT, @projId INT;
IF NOT EXISTS (SELECT 'X' FROM emp WHERE job = @stan) BEGIN
		RAISERROR('W tabeli EMP nie ma pracownika na danym stanowisku',17,1);
	END
ELSE BEGIN
IF NOT EXISTS (SELECT 'X' FROM PROJ WHERE PNAME = @proj) BEGIN
	SELECT @budzet = 10*SUM(sal) FROM emp;
	INSERT INTO PROJ
	VALUES (@proj, @budzet, GETDATE(),GETDATE()+12)
	PRINT 'Dodano nowy projekt o nazwie: ' + @proj;
	END
DECLARE kurs CURSOR FOR SELECT EMPNO FROM emp WHERE job=@stan;
OPEN kurs
SELECT @projId = projno FROM PROJ WHERE PNAME = @proj;
FETCH NEXT FROM kurs INTO @empnoP
--IF NOT EXISTS (SELECT 'X' FROM PROJ_EMP WHERE EMPNO = @empnoP AND PROJNO =@projId) BEGIN
--	INSERT INTO PROJ_EMP VALUES (@projId, @empnoP)
--	PRINT 'Do projektu' + @proj + ' dodano pracownika o nr: ' + CONVERT(VARCHAR,@empnoP);
--	SELECT @liczbaZatrNaStan = COUNT(*) FROM emp e
--		INNER JOIN PROJ_EMP pe ON pe.EMPNO = e.EMPNO
--		WHERE e.JOB = @stan;
--	PRINT 'Liczba osob zatrudnionych aktualnie na stanowisku ' + @stan + ' wynosi ' + CONVERT(VARCHAR,@liczbaZatrNaStan);
--	END
WHILE @@FETCH_STATUS = 0 BEGIN
	IF NOT EXISTS (SELECT 'X' FROM PROJ_EMP WHERE EMPNO = @empnoP AND PROJNO =@projId) BEGIN
		INSERT INTO PROJ_EMP
		VALUES (@projId, @empnoP)
		PRINT 'Do projektu' + @proj + ' dodano pracownika o nr: ' + CONVERT(VARCHAR,@empnoP);
		SELECT @liczbaZatrNaStan = COUNT(*) FROM emp e
		INNER JOIN PROJ_EMP pe ON pe.EMPNO = e.EMPNO
		WHERE e.JOB = @stan;
		PRINT 'Liczba osob zatrudnionych aktualnie na stanowisku ' + @stan + ' wynosi ' + CONVERT(VARCHAR,@liczbaZatrNaStan);
		END
	FETCH NEXT FROM kurs INTO @empnoP
	END
	CLOSE kurs
	DEALLOCATE kurs
END
END
GO

EXEC proc1 'SALESMAN', 'PROJECT2';
EXEC proc1 'CLERK', 'PROJECT6';
EXEC proc1 'CLER', 'PROJECT7';

GO
ALTER TRIGGER wyzw1
ON PROJ
FOR INSERT, UPDATE
AS
BEGIN
DECLARE @ileInserted INT, @ileDeleted INT, @wartBudzetu INT, @projId INT;
SELECT @ileDeleted = COUNT(*) FROM deleted;
SELECT @ileInserted = COUNT(*) FROM inserted;
IF @ileDeleted = 0 AND @ileInserted > 0 BEGIN --insert
	SELECT @projId = projno FROM inserted;
	SELECT @wartBudzetu = budget FROM proj WHERE PROJNO = @projId;
	IF @wartBudzetu < 1000 BEGIN
		PRINT 'insert trigger'
		ROLLBACK
		END
	END
IF @ileDeleted > 0 AND @ileInserted > 0 BEGIN --update
	SELECT @projId = projno FROM inserted;
	SELECT @wartBudzetu = budget FROM proj WHERE PROJNO = @projId;
	IF @wartBudzetu < 0 BEGIN
		PRINT 'update trigger'
		ROLLBACK
		END
	END
END
GO

INSERT INTO PROJ
VALUES ('projektx', 990, GETDATE(),GETDATE()+5);

UPDATE PROJ SET BUDGET=-150 WHERE PNAME = 'PROJECT6';

GO

CREATE TRIGGER wyzw2
ON PROJ
FOR INSERT, UPDATE
AS
BEGIN
DECLARE @ileInserted INT, @ileDeleted INT, @wartBudzetu INT, @projId INT, @budzetInserted INT;
SELECT @ileDeleted = COUNT(*) FROM deleted;
SELECT @ileInserted = COUNT(*) FROM inserted;
DECLARE kursor2 CURSOR FOR SELECT budget FROM INSERTED
OPEN kursor2
FETCH NEXT FROM kursonr2 INTO @budzetInserted;
WHILE @@FETCH_STATUS = 0 BEGIN
	IF @ileDeleted = 0 AND @ileInserted > 0 BEGIN --insert
		SELECT @projId = projno FROM inserted;
		SELECT @wartBudzetu = budget FROM proj WHERE PROJNO = @projId;
		IF @wartBudzetu < 1000 BEGIN
			PRINT 'insert trigger'
			ROLLBACK
			END
		END
	IF @ileDeleted > 0 AND @ileInserted > 0 BEGIN --update
		SELECT @projId = projno FROM inserted;
		SELECT @wartBudzetu = budget FROM proj WHERE PROJNO = @projId;
		IF @wartBudzetu < 0 BEGIN
			PRINT 'update trigger'
			ROLLBACK
			END
		END
	END
END

--7
create or replace TRIGGER zad7
AFTER UPDATE OF sal
ON emp
FOR EACH ROW
DECLARE nextLp int;
BEGIN
    if (:OLD.Sal > :NEW.Sal) THEN
        RAISE_APPLICATION_ERROR(-20505,'Nie wolno zmniejszac pensji' || SYSDATE);
    END IF;
    if :OLD.Sal *1.1 <= :NEW.Sal THEN
        SELECT (MAX(Lp)+1)INTO nextLp FROM T_Podwyzka;
        INSERT INTO T_Podwyzka VALUES(nextLp, :NEW.Empno,:NEW.Ename,:NEW.Job,:NEW.Mgr,:NEW.Deptno,:OLD.Sal,:NEW.Sal,Sysdate);
    END IF;
END;

ALTER PROCEDURE DodajPrac
@nazwisko Varchar(14),
@dname Varchar(20)
AS
DECLARE @Info Varchar(128), @NR Int, @min Int, @deptno Int, @nowaPensja Int
BEGIN
SELECT @deptno = DEPT.DEPTNO FROM s26100.DEPT WHERE DEPT.DNAME = @dname;
IF NOT EXISTS (SELECT 1 FROM s26100.DEPT WHERE dept.deptno = @deptno )
	SET @Info = 'Dział o numerze ' + CONVERT(VARCHAR,@deptno)  + ' nie istnieje'
	ELSE
	BEGIN
	SELECT @NR = ISNULL(MAX(EMPNO),0) FROM s26100.EMP;
	SELECT @min = MIN(SAL) FROM s26100.EMP, s26100.DEPT WHERE EMP.DEPTNO=DEPT.DEPTNO AND DEPT.DEPTNO=@deptno;
	IF EXISTS( SELECT 1 FROM s26100.EMP WHERE emp.EMPNO = @nazwisko) BEGIN
		SET @Info = 'Pracownik o zadanym nazwisku juz istnieje'
		SELECT @nowaPensja = MIN(SAL) FROM s26100.EMP, s26100.DEPT WHERE EMP.DEPTNO=DEPT.DEPTNO AND DEPT.DEPTNO=@deptno;
	INSERT INTO s26100.EMP
	VALUES (@NR+1,@nazwisko,null,null,GETDATE(),@min,null,@deptno);
	SET @Info = 'Dopisano pracownika ' + @nazwisko;
	END;
	Print @Info;
END;

CREATE TRIGGER lacznaSumaWynagrodzen
ON emp
FOR INSERT, UPDATE, DELETE
AS
DECLARE @suma INT
SELECT @suma = SUM(sal) FROM emp
UPDATE budzet SET wartosc = @suma;
go

SELECT * FROM EMp;
SELECT * FROM budzet;

INSERT INTO EMP (EMPNO, SAL) VALUES (1111,1000);

go
CREATE TRIGGER nieModyfikujNazwDzialow
ON dept
FOR UPDATE
AS
ROLLBACK;

go
CREATE TRIGGER nieUsunPrac6
ON EMP
FOR INSERT, UPDATE, DELETE
AS
DECLARE @ileInsert INT, @ileDelete INT, @sal INT, @nazwisko VARCHAR, @InsertedNazwisko VARCHAR, @DeletedNazwisko VARCHAR
SELECT @ileInsert = COUNT(*) FROM INSERTED
SELECT @ileDelete = COUNT(*) FROM DELETED
IF @ileInsert = 0 AND @ileDelete > 0 BEGIN --DELETE
	SELECT @sal = sal FROM INSERTED
	IF @sal > 0 BEGIN
		ROLLBACK
	END
END
IF @ileInsert > 0 AND @ileDelete > 0 BEGIN --UPDATE
	SELECT @InsertedNazwisko = ename FROM INSERTED
	SELECT @DeletedNazwisko = ename FROM DELETED
	IF @insertedNazwisko != @DeletedNazwisko BEGIN
		ROLLBACK
	END
END
IF @ileInsert > 1 AND @ileDelete = 0 BEGIN --INSERT
	SELECT @nazwisko = ename FROM INSERTED
	IF @nazwisko IN (SELECT ename FROM EMP) BEGIN
		ROLLBACK
	END
END
go
ALTER TRIGGER wyzw7
ON EMP
FOR UPDATE, DELETE
AS
DECLARE @ileInsert INT, @ileDelete INT, @oldSal INT, @newSal INT, @empno INT
SELECT @ileInsert = COUNT(*) FROM INSERTED
SELECT @ileDelete = COUNT(*) FROM DELETED
IF @ileInsert > 0 AND @ileDelete > 0 BEGIN --UPDATE
	SELECT @empno = empno FROM INSERTED
	SELECT @newSal = sal FROM INSERTED
	SELECT @oldSal = sal FROM DELETED
	IF @newSal < @oldSal BEGIN
		ROLLBACK
	END
END
IF @ileInsert = 0 AND @ileDelete > 0 BEGIN --DELETE
	ROLLBACK
END
go
