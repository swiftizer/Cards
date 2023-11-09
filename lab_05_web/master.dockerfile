FROM sickcodes/docker-osx

COPY ./PPOcards.app ./PPOcards.app

# RUN touch config.properties
# RUN echo "DB_USE = pg" >> config.properties
# RUN echo "PG_DB_USERNAME = te_manager" >> config.properties
# RUN echo "PG_DB_PASSWORD = te_manager" >> config.properties
# RUN echo "PG_DB_URL = jdbc:postgresql://postgresql_master:5432/business_test" >> config.properties
# RUN echo "LOG_PATH = web_log/web_log.log" >> config.properties

# RUN mkdir web_log

EXPOSE 8078

CMD ["open", "PPOcards.app"]