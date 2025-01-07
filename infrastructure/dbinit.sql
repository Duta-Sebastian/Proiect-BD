DROP TABLE IF EXISTS Credentiale_Cititor;
DROP TABLE IF EXISTS Carte_Cititor_Recenzie;
DROP TABLE IF EXISTS Cititor;
DROP TABLE IF EXISTS Recenzie;
DROP TABLE IF EXISTS Carte;
DROP TABLE IF EXISTS Editura;
DROP TABLE IF EXISTS Autor;
DROP TABLE IF EXISTS Categorie;
DROP TRIGGER IF EXISTS before_insert_update_editura;
DROP TRIGGER IF EXISTS before_insert_update_recenzie;
DROP VIEW IF EXISTS BestRatedAuthor;
DROP VIEW IF EXISTS user_credentials_view;

CREATE TABLE IF NOT EXISTS Cititor (
    CNP varchar2(13),
    prenume varchar2(20),
    nume varchar2(40),
    email varchar2(50),
    numar_telefon varchar2(10),
    activ CHAR(1) DEFAULT 'Y',
    restante NUMBER DEFAULT 0,
    CONSTRAINT PK_Cititor PRIMARY KEY(CNP),
    CONSTRAINT CHK_Cititor_Prenume_Exista CHECK (prenume IS NOT NULL),
    CONSTRAINT CHK_Cititor_Nume_Exista CHECK (nume IS NOT NULL),
    CONSTRAINT CHK_Cititor_Email_Exista CHECK (email IS NOT NULL),
    CONSTRAINT UNK_Cititor_Email_Unic UNIQUE (email),
    CONSTRAINT CHK_Cititor_Activ CHECK (activ IN ('Y','N')),
    CONSTRAINT CHK_Cititor_Restante_Pozitive CHECK (restante >= 0),
    CONSTRAINT CHK_Cititor_Numar_Telefon_Valid CHECK (
        LENGTH(numar_telefon) = 10 AND
        SUBSTR(numar_telefon, 1, 1) = '0' AND
        REGEXP_LIKE(numar_telefon, '^[0-9]{10}$')),
    CONSTRAINT CHK_Cititor_CNP CHECK (
        LENGTH(CNP) = 13 AND
        REGEXP_LIKE(cnp, '^[1-9]\d{12}$') AND
        SUBSTR(CNP, 1, 1) IN ( '1', '2', '5', '6', '7', '8') AND
        SUBSTR(CNP, 4, 2) BETWEEN '01' AND '12' AND
        SUBSTR(CNP, 6, 2) BETWEEN '01' AND '31' AND
            TO_DATE(
        CASE
            WHEN SUBSTR(CNP, 1, 1) IN ('1', '2') THEN '19' || SUBSTR(CNP, 2, 2) || SUBSTR(CNP, 4, 2) || SUBSTR(CNP, 6, 2)
            WHEN SUBSTR(CNP, 1, 1) IN ('5', '6') THEN '20' || SUBSTR(CNP, 2, 2) || SUBSTR(CNP, 4, 2) || SUBSTR(CNP, 6, 2)
            ELSE NULL
        END, 'YYYYMMDD'
        ) IS NOT NULL AND
        SUBSTR(cnp, 13, 1) = CASE
            WHEN MOD(
                TO_NUMBER(SUBSTR(cnp, 1, 1)) * 2 +
                TO_NUMBER(SUBSTR(cnp, 2, 1)) * 7 +
                TO_NUMBER(SUBSTR(cnp, 3, 1)) * 9 +
                TO_NUMBER(SUBSTR(cnp, 4, 1)) * 1 +
                TO_NUMBER(SUBSTR(cnp, 5, 1)) * 4 +
                TO_NUMBER(SUBSTR(cnp, 6, 1)) * 6 +
                TO_NUMBER(SUBSTR(cnp, 7, 1)) * 3 +
                TO_NUMBER(SUBSTR(cnp, 8, 1)) * 5 +
                TO_NUMBER(SUBSTR(cnp, 9, 1)) * 8 +
                TO_NUMBER(SUBSTR(cnp, 10, 1)) * 2 +
                TO_NUMBER(SUBSTR(cnp, 11, 1)) * 7 +
                TO_NUMBER(SUBSTR(cnp, 12, 1)) * 9,
                11
            ) = 10 THEN '1'
            ELSE TO_CHAR(
                MOD(
                    TO_NUMBER(SUBSTR(cnp, 1, 1)) * 2 +
                    TO_NUMBER(SUBSTR(cnp, 2, 1)) * 7 +
                    TO_NUMBER(SUBSTR(cnp, 3, 1)) * 9 +
                    TO_NUMBER(SUBSTR(cnp, 4, 1)) * 1 +
                    TO_NUMBER(SUBSTR(cnp, 5, 1)) * 4 +
                    TO_NUMBER(SUBSTR(cnp, 6, 1)) * 6 +
                    TO_NUMBER(SUBSTR(cnp, 7, 1)) * 3 +
                    TO_NUMBER(SUBSTR(cnp, 8, 1)) * 5 +
                    TO_NUMBER(SUBSTR(cnp, 9, 1)) * 8 +
                    TO_NUMBER(SUBSTR(cnp, 10, 1)) * 2 +
                    TO_NUMBER(SUBSTR(cnp, 11, 1)) * 7 +
                    TO_NUMBER(SUBSTR(cnp, 12, 1)) * 9,
                    11
                )
            )
        END
    ));

INSERT INTO Cititor(CNP, prenume, nume, email, numar_telefon) VALUES
    ('5040923297263', 'Andrei-Sebastian', 'Duta', 'sebiduta2004@gmail.com', '0737674463'),
    ('1760908207248', 'Iulian', 'Hasdeu', 'iulian.hasdeu@gmail.com', '0721295325'),
    ('6040412041027', 'Adriana', 'Popa', 'adriana.popa@gmail.com', '0743192483'),
    ('1891221042546', 'Mihai', 'Ionescu', 'mihai.ionescu@gmail.com', '0745123456'),
    ('2790511415898', 'Ana', 'Vasilescu', 'ana.vasilescu@gmail.com', '0745236789'),
    ('1650708297305', 'Ion', 'Popescu', 'ion.popescu@gmail.com', '0745345678'),
    ('6010112286475', 'Elena', 'Stoica', 'elena.stoica@gmail.com', '0745456789'),
    ('1951101227469', 'George', 'Georgescu', 'george.georgescu@gmail.com', '0745567890'),
    ('2980307065351', 'Maria', 'Nistor', 'maria.nistor@gmail.com', '0745678901'),
    ('5000229469481', 'Victor', 'Dumitru', 'victor.dumitru@gmail.com', '0745789012');

CREATE TABLE IF NOT EXISTS Credentiale_cititor (
    id_credentiale NUMBER GENERATED BY DEFAULT AS IDENTITY,
    CNP VARCHAR2(13),
    metoda_autentificare VARCHAR2(20) default 'username_parola',
    status CHAR(1) DEFAULT 'A',
    nume_utilizator VARCHAR2(30),
    hash_parola VARCHAR2(40),
    token_autentificare VARCHAR2(255),
    numar_telefon_auth VARCHAR2(10),
    CONSTRAINT PK_Credentiale_Cititor PRIMARY KEY (id_credentiale),
    CONSTRAINT FK_Credentiale_Cititor_Cititor FOREIGN KEY (CNP) REFERENCES Cititor(CNP) ON DELETE CASCADE,
    CONSTRAINT CHK_Credentiale_Cititor_Numar_Telefon_Valid CHECK (
        LENGTH(numar_telefon_auth) = 10 AND
        SUBSTR(numar_telefon_auth, 1, 1) = '0' AND
        REGEXP_LIKE(numar_telefon_auth, '^[0-9]{10}$')),
    CONSTRAINT CHK_Credentiale_Cititor_Metoda_Auth_Valida CHECK (
        metoda_autentificare in ('username_parola', '2FA', 'token') AND
        metoda_autentificare IS NOT NULL),
    CONSTRAINT CHK_Credentiale_Cititor_Autentificare_Valida CHECK (
        metoda_autentificare = 'username_parola' AND nume_utilizator IS NOT NULL AND hash_parola IS NOT NULL OR
        metoda_autentificare = '2FA' AND nume_utilizator IS NOT NULL AND hash_parola IS NOT NULL AND numar_telefon_auth IS NOT NULL OR
        metoda_autentificare = 'token' AND token_autentificare IS NOT NULL),
    CONSTRAINT UNK_Credentiale_Cititor_Nume_Utilizator_Unic UNIQUE(nume_utilizator),
    CONSTRAINT UNK_Credentiale_Cititor_Token_Unic UNIQUE(token_autentificare));

INSERT INTO Credentiale_Cititor (CNP, metoda_autentificare, status, nume_utilizator, hash_parola, token_autentificare, numar_telefon_auth) VALUES
    ('5040923297263', 'username_parola', 'I', 'duta-sebastian', 'parolaSigura123', NULL, NULL),
    ('5040923297263', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.Sb-YaFbsHlYWvUS0R9oMmVo6_9LxNYtZVeJom0_5T8g', NULL),
    ('5040923297263', '2FA', 'A', 'duta-sebastian1', 'parolaSigura123', NULL, '0737674463'),
    ('1760908207248', 'username_parola', 'A', 'iulicaiulianica', 'hashashdedeu', NULL, NULL),
    ('6040412041027', 'username_parola', 'I', 'popa-adriana', 'hashadriana123', NULL, NULL),
    ('6040412041027', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.dGyFcYWvZuy8Iq7qphlLZPZ1GgAq2aYXadfj_LHvq8Y', NULL),
    ('6040412041027', '2FA', 'A', 'popa-adriana1', 'hashadriana123', NULL, '0743192483'),
    ('1891221042546', 'username_parola', 'I', 'ionescu-mihai', 'mihai_hash123', NULL, NULL),
    ('1891221042546', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.lFg9d8DPGDbz3RfiWgdg22h9OD8JvHdqieFwLhB8q5A', NULL),
    ('1891221042546', '2FA', 'A', 'ionescu-mihai1', 'mihai_hash123', NULL, '0745123456'),
    ('2790511415898', 'username_parola', 'I', 'vasilescu-ana', 'anafans123', NULL, NULL),
    ('2790511415898', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wXyZZg0cReVvnZOG8F6Kf8YtG3f6dc5pZGQn08X9cl8', NULL),
    ('2790511415898', '2FA', 'A', 'vasilescu-ana1', 'anafans123', NULL, '0745236789'),
    ('1650708297305', 'username_parola', 'I', 'popescu-ion', 'ionpopescu123', NULL, NULL),
    ('1650708297305', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.bOsh66QHGv24U7s_b2gg3zCwa21lHdL63eTLbgaBpR0', NULL),
    ('6010112286475', 'username_parola', 'I', 'stoica-elena', 'elena123', NULL, NULL),
    ('6010112286475', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.W3bDd89jJd4f7yH0PbEAYGi8_d-ybd5zH2v0pqF22Kc', NULL),
    ('6010112286475', '2FA', 'A', 'stoica-elena1', 'elena123', NULL, '0745456789'),
    ('1951101227469', 'username_parola', 'I', 'georgescu-george', 'georgehash123', NULL, NULL),
    ('1951101227469', 'token', 'I', NULL, NULL, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.1zvNf-rVylDT52X7rTKF2vfX-19dGJ59pZZoHpISZfg', NULL),
    ('2980307065351', 'username_parola', 'I', 'nistor-maria', 'p213124fdasda', NULL, '0745678901'),
    ('5000229469481', 'username_parola', 'I', 'dumitru-victor', 'parolaparola1234', NULL, '0745789012');

CREATE TABLE IF NOT EXISTS EDITURA (
    CUI VARCHAR2(10),
    nume VARCHAR2(50),
    oras VARCHAR2(50),
    numar_telefon VARCHAR2(10),
    website VARCHAR2(50),
    data_infiintare DATE,
    reprezentant_legal VARCHAR2(50),
    CONSTRAINT PK_Editura PRIMARY KEY (CUI),
    CONSTRAINT CHK_Editura_Telefon_Valid CHECK (
        LENGTH(numar_telefon) = 10 AND
        SUBSTR(numar_telefon, 1, 1) = '0' AND
        REGEXP_LIKE(numar_telefon, '^[0-9]{10}$')),
    CONSTRAINT CHK_Editura_CUI_Numar CHECK (REGEXP_LIKE(CUI, '^\d+$')),
    CONSTRAINT CHK_Editura_Nume_Exista CHECK (nume IS NOT NULL),
    CONSTRAINT UNK_Editura_Nume_Unic UNIQUE (nume));

CREATE OR REPLACE TRIGGER before_insert_update_editura
BEFORE INSERT OR UPDATE ON Editura
FOR EACH ROW
DECLARE
    v_data DATE;
BEGIN
    v_data := :NEW.data_infiintare;
    IF v_data > CURRENT_DATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data de inregistrare nu poate fi in viitor!');
    END IF;

    :NEW.data_infiintare := v_data;
END;
/

INSERT INTO EDITURA (CUI, nume, oras, numar_telefon, website, data_infiintare, reprezentant_legal) VALUES
    ('363367', 'Humanitas', 'Bucure?ti', '0214088350', 'www.humanitas.ro', TO_DATE('14/03/1994', 'DD/MM/YYYY'), NULL),
    ('6494981', 'Paralela 45', 'Pite?ti', '0248214533', 'www.paralela45.ro', TO_DATE('07/12/1994', 'DD/MM/YYYY'), NULL),
    ('7726230', 'Editura Universitara', 'Bucure?ti', NULL, 'www.editurauniversitara.ro', TO_DATE('06/03/2002', 'DD/MM/YYYY'), NULL);

CREATE TABLE IF NOT EXISTS Categorie (
    id_categorie NUMBER GENERATED BY DEFAULT AS IDENTITY,
    audienta VARCHAR2(6),
    nume VARCHAR2(50),
    gen VARCHAR2(50),
    CONSTRAINT PK_Categorie PRIMARY KEY (id_categorie),
    CONSTRAINT UNK_Categorie_Nume_Unic UNIQUE (nume),
    CONSTRAINT CHK_Categorie_Nume_Exista CHECK (nume IS NOT NULL),
    CONSTRAINT CHK_Categorie_Gen_Exista CHECK (gen IS NOT NULL),
    CONSTRAINT CHK_Audienta_Corecta CHECK (
        audienta IS NOT NULL AND
        audienta in ('<3','3-6','+7','10-16','+18')));

INSERT INTO Categorie (audienta, nume, gen) VALUES
    ('+18', 'Poezie Liric?', 'Romantism'),
    ('+18', 'Romanul unei epoci', 'Romantism'),
    ('+18', 'Absurditi?i Existentiale', 'Existentialism'),
    ('+18', 'Realismul Magic �n Lumea Modern?', 'Realism magic'),
    ('+18', 'Tragedii ?i Comedii Clasice', 'Renastere'),
    ('10-16', 'Distopie ?i Utopie', 'Distopie'),
    ('+18', 'Realismul Rus', 'Realism'),
    ('+7', 'Fic?iune Magic? Modern?', 'Fictiune moderna'),
    ('10-16', 'Epopeea Greceasc?', 'Epoca clasica'),
    ('10-16', 'Romantism Englez', 'Romantism');

CREATE TABLE IF NOT EXISTS Autor (
    id_autor NUMBER GENERATED BY DEFAULT AS IDENTITY,
    nume VARCHAR2(50),
    nationalitate VARCHAR2(50),
    curent_literar VARCHAR2(50),
    interes_literar VARCHAR2(50),
    CONSTRAINT PK_Autor PRIMARY KEY (id_autor),
    CONSTRAINT UNK_Autor_Nume_Unic UNIQUE (nume));

INSERT INTO Autor(nume, nationalitate, curent_literar, interes_literar) VALUES
    ('Mihai Eminescu', 'Romana', 'Romantism', 'Poezie'),
    ('Victor Hugo', 'Franceza', 'Romantism', 'Roman'),
    ('Franz Kafka', 'Austriaca', 'Existentialism', 'Proza scurta'),
    ('Gabriel Garcia Marquez', 'Columbiana', 'Realism magic', 'Roman'),
    ('William Shakespeare', 'Engleza', 'Renastere', 'Teatru'),
    ('George Orwell', 'Engleza', 'Distopie', 'Eseu'),
    ('Fyodor Dostoievski', 'Rusa', 'Realism', 'Roman'),
    ('J.K. Rowling', 'Engleza', 'Fictiune moderna', 'Fantasy'),
    ('Homer', 'Greceasca', 'Epoca clasica', 'Epopee'),
    ('Jane Austen', 'Engleza', 'Romantism', 'Roman');

CREATE TABLE IF NOT EXISTS Carte (
    ISBN VARCHAR2(13),
    id_autor NUMBER CONSTRAINT CHK_Carte_Autor_NN NOT NULL,
    id_categorie NUMBER CONSTRAINT CHK_Carte_Categorie_NN NOT NULL,
    CUI_editura VARCHAR2(10) CONSTRAINT CHK_Carte_Editura_NN NOT NULL,
    tip_coperta VARCHAR2(10),
    numar_pagini NUMBER,
    titlu VARCHAR2(50),
    limba VARCHAR2(50),
    CONSTRAINT PK_Carte PRIMARY KEY (ISBN),
    CONSTRAINT FK_Carte_Autor FOREIGN KEY (id_autor) REFERENCES Autor (id_autor) ON DELETE CASCADE,
    CONSTRAINT FK_Carte_Categorie FOREIGN KEY (id_categorie) REFERENCES Categorie (id_categorie) ON DELETE CASCADE,
    CONSTRAINT FK_Carte_Editura FOREIGN KEY (CUI_editura) REFERENCES Editura (CUI) ON DELETE CASCADE,
    CONSTRAINT CHK_Carte_Tip_Coperta_Valid CHECK (tip_coperta in ('Hardcover', 'Paperback')),
    CONSTRAINT CHK_Carte_Numar_Pagini_Valid CHECK (numar_pagini > 0));

INSERT INTO Carte (ISBN, id_autor, id_categorie, CUI_editura, tip_coperta, numar_pagini, titlu, limba) VALUES
    ('9789731234567', 1, 1, 363367, 'Hardcover', 200, 'Luceaf?rul', 'Rom�n?'),
    ('9789732234567', 2, 2, 6494981, 'Paperback', 350, 'Mizerabilii', 'Francez?'),
    ('9789733234567', 3, 3, 6494981, 'Paperback', 150, 'Metamorfoza', 'German?'),
    ('9789734234567', 4, 4, 7726230, 'Hardcover', 400, 'Un veac de singur?tate', 'Spaniol?'),
    ('9789735234567', 5, 5, 363367, 'Hardcover', 150, 'Hamlet', 'Englez?'),
    ('9789736234567', 6, 6, 363367, 'Paperback', 300, '1984', 'Englez?'),
    ('9789737234567', 7, 7, 7726230, 'Hardcover', 700, 'Fra?ii Karamazov', 'Rus?'),
    ('9789738234567', 8, 8, 6494981, 'Paperback', 500, 'Harry Potter ?i Piatra Filozofal?', 'Englez?'),
    ('9789739234567', 9, 9, 6494981, 'Hardcover', 800, 'Iliada', 'Greceasc?'),
    ('9789740234567', 10, 10, 7726230, 'Hardcover', 300, 'M�ndrie ?i Prejudecat?', 'Englez?'),
    ('9789741234567', 1, 1, 7726230, 'Paperback', 220, 'Scrisori', 'Rom�n?'),
    ('9789742234567', 2, 2, 6494981, 'Hardcover', 400, 'Coco?atul de la Notre-Dame', 'Francez?'),
    ('9789743234567', 5, 5, 6494981, 'Paperback', 250, 'Romeo ?i Julieta', 'Englez?'),
    ('9789744234567', 7, 7, 363367, 'Hardcover', 900, 'Crim? ?i pedeaps?', 'Rus?'),
    ('9789745234567', 8, 8, 7726230, 'Paperback', 550, 'Harry Potter ?i Camera Secretelor', 'Englez?');


CREATE TABLE IF NOT EXISTS Recenzie (
    id_recenzie NUMBER GENERATED BY DEFAULT AS IDENTITY,
    nota NUMBER(2),
    titlu VARCHAR2(250),
    ultima_modificare DATE DEFAULT SYSDATE,
    vizibil VARCHAR2(1) DEFAULT 'Y',
    motiv varchar2(50) DEFAULT NULL,
    numar_voturi NUMBER(4),
    CONSTRAINT PK_Recenzie PRIMARY KEY (id_recenzie),
    CONSTRAINT CHK_Recenzie_Nota_Valida CHECK (nota between 1 and 10),
    CONSTRAINT CHK_Recenzie_Vizibilitate_Valida CHECK (vizibil in ('Y','N')));

INSERT INTO Recenzie (nota, titlu, vizibil, motiv, numar_voturi) VALUES
    (10, 'Capodoper? literar?!', 'Y', NULL, 123),
    (9, 'Foarte captivant, dar u?or previzibil.', 'Y', NULL, 89),
    (7, 'Bun?, dar cu multe descrieri plictisitoare.', 'Y', NULL, 45),
    (5, 'Mediocr?, nu m-a impresionat.', 'Y', NULL, 22),
    (3, 'Am fost dezam?git de final ?i de autor.', 'N', 'Con?inut ofensiv', -15),
    (8, 'Recomand iubitorilor de thrillere!', 'Y', NULL, 67),
    (6, 'C�teva idei interesante, dar stilul autorului nu mi-a pl?cut.', 'Y', NULL, 30),
    (1, 'Nu o recomand. Foarte slab?.', 'N', 'Con?inut ofensator', 5),
    (9, 'O lectur? memorabil?, personajele sunt bine conturate.', 'Y', NULL, 95),
    (4, 'O carte decent?, dar nu o voi reciti.', 'Y', NULL, 15);


CREATE OR REPLACE TRIGGER before_insert_update_recenzie
BEFORE INSERT OR UPDATE ON Recenzie
FOR EACH ROW
DECLARE
    v_data DATE;
BEGIN
    v_data := :NEW.ultima_modificare;
    IF v_data > CURRENT_DATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data modificarii nu poate fi in viitor!');
    END IF;

    IF UPDATING THEN
        IF v_data < :OLD.ultima_modificare THEN
            RAISE_APPLICATION_ERROR(-20002, 'Data modificarii trebuie sa fie mai mare decat data anterioara!');
        END IF;
    END IF;

    :NEW.ultima_modificare := v_data;
END;
/

CREATE TABLE IF NOT EXISTS Carte_Cititor_Recenzie (
    id_imprumut NUMBER GENERATED BY DEFAULT AS IDENTITY,
    id_recenzie NUMBER,
    ISBN VARCHAR2(13),
    CNP_Cititor VARCHAR2(13),
    CONSTRAINT PK_Carte_Cititor_Recenzie PRIMARY KEY (id_imprumut),
    CONSTRAINT FK_Carte_Cititor_Recenzie_Carte FOREIGN KEY (ISBN) REFERENCES Carte(ISBN),
    CONSTRAINT FK_Carte_Cititor_Recenzie_Cititor FOREIGN KEY (CNP_Cititor) REFERENCES Cititor(CNP),
    CONSTRAINT FK_Carte_Cititor_Recenzie_Recenzie FOREIGN KEY (id_recenzie) REFERENCES Recenzie(id_recenzie));

INSERT INTO Carte_Cititor_Recenzie (id_recenzie, ISBN, CNP_Cititor) VALUES
    (1, '9789731234567', '5040923297263'),
    (2, '9789732234567', '1760908207248'),
    (3, '9789733234567', '6040412041027'),
    (4, '9789734234567', '1891221042546'),
    (5, '9789735234567', '2790511415898'),
    (6, '9789736234567', '1650708297305'),
    (7, '9789737234567', '6010112286475'),
    (8, '9789738234567', '1951101227469'),
    (9, '9789739234567', '2980307065351'),
    (10, '9789740234567', '5000229469481'),
    (1, '9789741234567', '5040923297263'),
    (2, '9789742234567', '1760908207248'),
    (3, '9789743234567', '6040412041027'),
    (4, '9789744234567', '1891221042546'),
    (5, '9789745234567', '2790511415898'),
    (6, '9789734234567', '1650708297305'),
    (7, '9789735234567', '6010112286475'),
    (8, '9789731234567', '1951101227469'),
    (9, '9789738234567', '2980307065351'),
    (10, '9789742234567', '5000229469481'),
    (1, '9789741234567', '5000229469481'),
    (1, '9789741234567', '1951101227469');

SELECT C.Nume || ' ' || C.Prenume as "Nume Cititor", R.Nota, R.Titlu, CA.Titlu
FROM CITITOR C JOIN Carte_Cititor_Recenzie CCR on C.CNP = CCR.CNP_Cititor
JOIN RECENZIE R on CCR.id_recenzie = R.id_recenzie JOIN CARTE CA on CCR.ISBN = CA.ISBN
WHERE R.nota > 5 and R.vizibil = 'Y';

SELECT Titlu
FROM Carte
WHERE ISBN IN (
    SELECT C.ISBN
    FROM Carte C
    JOIN Carte_Cititor_Recenzie CCR ON CCR.ISBN = C.ISBN
    JOIN Recenzie R ON CCR.id_recenzie = R.id_recenzie
    GROUP BY C.ISBN
    HAVING AVG(R.NOTA) > 8
);


CREATE VIEW BestRatedAuthor AS
SELECT A.NUME
FROM AUTOR A
JOIN CARTE C ON A.ID_AUTOR = C.ID_AUTOR
WHERE C.ISBN = (
    SELECT *
    FROM (
        SELECT C.ISBN
        FROM CARTE C
        JOIN CARTE_CITITOR_RECENZIE CCR ON C.ISBN = CCR.ISBN
        JOIN RECENZIE R ON CCR.ID_RECENZIE = R.ID_RECENZIE
        GROUP BY C.ISBN
        ORDER BY AVG(R.NOTA) DESC
    )
    WHERE ROWNUM = 1
);

CREATE VIEW user_credentials_view AS
SELECT
    CNP,
    C.prenume,
    C.nume,
    CC.id_credentiale,
    CC.metoda_autentificare,
    CC.status,
    CC.nume_utilizator,
    CC.hash_parola
FROM
    Cititor C
JOIN
    Credentiale_cititor CC using (CNP)
WHERE CC.metoda_autentificare = 'username_parola';

COMMIT;
