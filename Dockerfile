FROM ruby:3.2.2-alpine3.19

RUN addgroup -S deco
RUN adduser -g docker -G deco -h /home/deco deco -D

RUN apk add --update make g++ bash zsh git openssh postgresql-dev nodejs yarn sudo nano python3 libstdc++ libx11 libxrender libxext libssl3 ca-certificates fontconfig freetype ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-freefont
RUN apk add --update libssl3 shared-mime-info

ENV APP_PATH "/home/deco/consumer-api"

USER root

RUN mkdir -p $APP_PATH

RUN chown deco -R $APP_PATH

USER deco

# Working gems separately
WORKDIR $APP_PATH

COPY Gemfile* $APP_PATH/

COPY --chown=deco:deco entrypoint $APP_PATH/
COPY --chown=deco:deco bin $APP_PATH/bin

COPY --chown=deco:deco config.ru $APP_PATH
COPY --chown=deco:deco config $APP_PATH/config
COPY --chown=deco:deco db $APP_PATH/db
COPY --chown=deco:deco lib $APP_PATH/lib
COPY --chown=deco:deco public $APP_PATH/public
COPY --chown=deco:deco Rakefile $APP_PATH/Rakefile
# COPY --chown=deco:deco spec/ $APP_PATH/spec/
# COPY --chown=deco:deco .rspec $APP_PATH/.rspec

RUN bundle install

RUN bundle binstubs --all

COPY --chown=deco:deco app $APP_PATH/app

EXPOSE 3000

ENTRYPOINT [ "/home/deco/consumer-api/entrypoint" ]
