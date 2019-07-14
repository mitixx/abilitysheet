FROM ruby:2.6.1-alpine3.9
LABEL maintainer '8398a7 <8398a7@gmail.com>'

ENV \
  HOME=/app \
  RAILS_ENV=production \
  SECRET_KEY_BASE=wip

WORKDIR $HOME

RUN \
  apk upgrade --no-cache && \
  apk add --update --no-cache \
  build-base \
  git \
  postgresql-dev \
  ruby-dev \
  libxml2-dev \
  libxslt-dev \
  postgresql-client \
  tzdata \
  yarn

COPY Gemfile* $HOME/
RUN bundle install -j4 --without development test deployment

COPY package.json yarn.lock $HOME/
RUN yarn install
COPY ./bin $HOME/bin
COPY \
  ./Rakefile \
  ./tsconfig.json \
  ./.browserslistrc  \
  ./babel.config.js \
  ./postcss.config.js \
  $HOME/
COPY ./app/assets $HOME/app/assets
COPY ./app/models/user.rb ./app/models/application_record.rb $HOME/app/models/
COPY ./app/models/concerns/user $HOME/app/models/concerns/user
COPY ./lib/tasks/ts_routes.rake $HOME/lib/tasks/ts_routes.rake
COPY ./app/javascript $HOME/app/javascript
COPY ./app/controllers/application_controller.rb $HOME/app/controllers/application_controller.rb
COPY ./config $HOME/config
COPY config/database.k8s.yml $HOME/config/database.yml
ENV SENTRY_JS_DSN https://f318e1509040449986ca17cd247924b9@sentry.husq.tk/26
RUN mkdir log && touch TAG && rails ts:routes assets:precompile