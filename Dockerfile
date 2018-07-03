FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs


WORKDIR /myapp
COPY ./demo .

RUN bundle install

RUN rake --tasks
RUN rake app:update:bin

EXPOSE 8080
CMD bundle exec rails s -p 8080 -b '0.0.0.0'
