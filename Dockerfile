# Use a community Ruby image with Sinatra
FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y build-essential libpng-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN gem install sinatra rqrcode rqrcode_png rackup puma

EXPOSE 4567

CMD ["ruby", "app.rb"]
