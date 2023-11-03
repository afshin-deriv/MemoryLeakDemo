FROM --platform=linux/amd64 regentmarkets/debian-perl:bullseye-5.26.2

WORKDIR /app
COPY cpanfile .

RUN cpanm -n --installdeps .

COPY test.pl .

ENTRYPOINT [ "perl", "/app/test.pl"]
