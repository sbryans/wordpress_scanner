# WordPress Scanner

Written in Ruby, this terminal based application performs a GET request to the URI of choice. HTML is parsed, three tags are targeted (meta, link, img) - then scanned for the string value "wp-content". This same operation is then performed on each link in the sitemap.xml file, which is typically associated with SEO smart websites. Enjoy!!!

## How to install:

1. Navigate to the application's working directory
```ruby 
bundle install 
```

## How to operate:

1. Navigate to the application's working directory
```ruby
ruby app.rb
```
2. Enter the full target URI

> Use freely & responsibly.

.
