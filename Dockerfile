FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .
RUN chown -R nobody .

ARG SHA
ENV SHA=${SHA}

EXPOSE 5637
USER nobody
CMD [ "./up.sh" ]
