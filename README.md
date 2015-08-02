# Gluey

This is my custom alternative for processing assets in ruby web apps. Firt, there was just dislike in sprockets
(and their integration into rails), but then i realized it's not that big a deal to write my own caching and processing system.
This has unlimited abilities, because it's very easy to write custom directives (that headers in assets that you know from
sprockets). For example, you can precompile handlebars a nd insert them into page's js file as an object (it cannot be easier).
You can append, prepend, insert (...) other files, merge them into one asset, that you wanth to hit on
particular http path. There is no docs nor test for now, and probably never will be, but the code should not be hard
to read, so if you're interested, just digg into the code itself.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gluey'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gluey

## Usage

 look at my nesselsburg2 integration (a repository just next door)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gluey/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
