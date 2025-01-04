# Use Oracle's official image as the base
FROM container-registry.oracle.com/database/free:latest

# Set environment variables for Oracle DB configuration
ENV DB_SID=OraDoc \
    DB_PASSWD=pass \
    DB_DOMAIN=my.domain.com \
    DB_BUNDLE=basic

# Expose the necessary ports for Oracle Database
EXPOSE 1521