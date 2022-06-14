FROM ruby:2.7-buster

RUN mkdir /app

COPY server.rb /app
COPY Gemfile /app
COPY Gemfile.lock /app

WORKDIR /app

RUN bundle install

ENTRYPOINT ["ruby", "server.rb"]
