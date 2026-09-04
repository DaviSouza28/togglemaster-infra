FROM postgres:16-alpine

RUN apk add --no-cache \
    aws-cli \
    jq

COPY db-init/entrypoint.sh /usr/local/bin/entrypoint.sh

COPY auth-service/db/init.sql /sql/auth/init.sql
COPY flag-service/db/init.sql /sql/flag/init.sql
COPY targeting-service/db/init.sql /sql/targeting/init.sql

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]