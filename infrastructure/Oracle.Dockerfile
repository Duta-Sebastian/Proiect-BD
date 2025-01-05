FROM container-registry.oracle.com/database/free:latest

EXPOSE 1521

COPY ./infrastructure/setup.sql .

COPY ./infrastructure/dbinit.sql .

COPY ./infrastructure/init_db.sh .

RUN lsnrctl start && ./init_db.sh
