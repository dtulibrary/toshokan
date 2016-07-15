FROM ruby:2.1
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  libxslt1-dev \
  libxml2-dev \
  libqt4-dev \
  libqtwebkit-dev \
  xvfb


# for nokogiri
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp

