# Ruby On Rails Chatroom Event Api

## How to install the application, including dependencies, etc.

### Dependencies
 - git
 - rbenv
 - Ruby 2.1.2
 - Ruby on Rails 4.0.0

### Setup the environment (Mac)

```
rbenv install 2.1.2
rbenv global 2.1.2
rbenv rehash
gem update --system
printf 'gem: --no-document' >> ~/.gemrc
gem install bundler
gem install rails -v 4.0
```

### Checkout the project and install deps

```
git clone git@github.com:kldavis4/DemoChatEventApi.git
cd DemoChatEventApi
bundle install
```

## How to initialize the data store
```
rake db:create
rake db:schema:load
rake db:schema:load RAILS_ENV=test
```
## How to start the application
```
rails server
```

Access API endpoint at http://localhost:3000/events

## How to run the test suite
```
bundle exec rspec spec
```