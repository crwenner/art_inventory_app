FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y build-essential libpng-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile Gemfile.lock* ./
RUN gem install bundler && bundle install || true

COPY . /app

RUN bundle install --jobs 4 || true

EXPOSE 4567
CMD ["ruby", "app.rb"]
