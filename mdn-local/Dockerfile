# Build it with "https" as name
FROM tutum/lamp
MAINTAINER Moez Bouhlel <bmoez.j@gmail.com>

RUN a2ensite default-ssl && \
    a2enmod ssl

RUN echo "#!/bin/bash" > ./start && \
    echo "service apache2 start" >> ./start && \
    echo "tail -f /var/log/apache2/access.log" >> ./start && \
    chmod +x ./start

EXPOSE 80 443
CMD ["./start"]
