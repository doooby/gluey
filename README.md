# Gluey

This library suppose to be an alternative for assets processing for ruby web apps. First there was
just dislike with how restrictive Rails feels to any javascript whatsoever. After digging
deep into big and messy sprockets, I realized I'd rather make my own alternative then spend 
days trying to pack in my fancy features into sprockets.

## Installation

```ruby
gem install 'gluey'
```

## Documentation

Start up yard server and browse the documentation on local:

    bundle exec yard server 

## Usage

As this is an 'alternative', it tries to mimic the sprockets library.
For scripting, here also are headers on top of files, that specify how the parts will be compossed.
Though apparent difference is that you can add your own headers/directives very easily and you have
full control of the result. 

### Setting up

Each type of assets have to be defined as a 'material': 

```ruby
GLUEY_ENV = Gluey::Workshop.new Rails.root.to_s, path_prefix: '/gluey_assets' do
  # css material
  register_material :css, Gluey::Glues.load('script') do |m|
    m.paths << 'assets/stylesheets'
    m.items.concat %w(pages admin)
  end
end
```

For details refer to `Worshop` and `Material` classes in documentation, but important here is this:

* Workshop needs to know on what path will be assets served (default :'/assets'), that is in this case
it will be on '<server>/gluey_assets/css/pages.css'.
* Paths for materials are relative to Workshop's root, therefore css files will get looked up for at
'<root>/assets/stylesheets/pages.css'.
* There are only two items, that will be processed via gluey: 'admin.css' and 'pages.css'. Requesting
anything else would give error Gluey::FileNotFound.
* Material needs to know HOW to process the files, and that's the role of 'glues'. You have to load
each glue, that you use, because they are not loaded automatically. That `Gluey::Glues.load('script')`
will load generic script glue and return the appropriate class. Once loaded you can simply
reference them `Gluey::Glues::Script`
* Material's name gives part of path on which assets will be served. But you can specify what different 
`file_extension` files have or what different `asset_extension` should the resulting assets have.

Consider this:

```ruby
register_material :my_css, Gluey::Glues.load('sass') do |m|
  m.set asset_extension: 'css', file_extension: 'scss'
end
```

### Referencing to assets

Suppose you have gluey environment (/workshop) set up as above, this is how to get the path
on which assets will be served:

```erb
<link rel="stylesheet" type="text/css" href="<%= GLUEY_ENV.asset_url :css, 'pages' %>">
```

### Processing source files

#### Base file

What material look up is a 'base file' in given destination. Items therefore simply can be under
nested directories like 'pages/dependencies'. This code

```ruby
GLUEY_ENV.asset_url :js, 'page/dependencies'
```

will look up for base file at: (given :js material's paths is 'assets' and file_extension has 
not been assigned)

* <root>/assets/page/dependencies.js 
* <root>/assets/page/dependencies/index.js
* <root>/assets/page/dependencies.js.erb 
* <root>/assets/page/dependencies/index.js.erb
 
Now, if the base file has .erb extenesion it will gou through ERB first (binded to gluey
environment - `GLUEY_ENV`). Given glue for that material (supposedly `Gluey::Glues::JsScript`)
will build the asset. Every other file (and base file) will be picked up and stored as dependency,
therefore any change you make in any of these files will impose the building process next time
asset is referenced.

#### Directives

Example how to reference other files from within some script:

```javascript
//> append greeter.js 
$(function () {
  console.log(Greeter.english());
});
```

Every header/directive can work differently, but mostly it references a file on relative path to
file from which it was referenced. For more, each directive can be two step process - glue will
try to call it before and after of appending of the file's body. That can prove convenient in
some situation. Here are descriptions some of directives defined for `Gluey::Gluey::Script`:

* `prepend` inserts a file before the rest of the file's body
* `append` inserts a file after the rest of the file's body
* `depend_on` add a file dependency to the bundle  

And here's additions for `Gluey::Gluey::JsScript`:

* `enclose` wraps the whole body into js scope: `"(function(){\n#{@output}\n}());"`. This one
is utilized on the latter step, i.e. after all 'before-' directives have been run and the 
file's body was appended to `@output`.
* `replace` example: `//> replace GREETER_CLASS greeter.js` will look up for `"%GREETER_CLASS%"`
verbatim and replace it with content of referenced asset.

#### Addons and Handlebars

For `JsScript` glue there are even addons, that can add some useful other common features. Role
of addons is simply to add some directives and are applied straight to the class. You simply
`require` particular file or use this while defining material:

```ruby
Gluey::Glues.load('js_script', 'handlebars') # returns Gluey::Glues::JsScript with handlebars support
```

That adds possibility to reference handlebars templates that will get precompiled and insert as
a object into js code: 

```javascript
//> replace_with_handlebars TEMPALTES templates
var templates = "%TEMPLATES%";
```

Given that '/templates' is a folder relative to the base file and it contains 'menu.hb' file and 
'header.hb' in 'body' subdirectory, this will be the result:

```javascript
var templates = {
"menu": ['...'],
"body/header": ['..']
};
```

#### Images and other non-script assets

There is the `Gluey::Glues::Copy` glues that doesnẗ process the files in any way, but utilizes
the gluey process for other purposes. (Of course you can always hard reference your graphics
assets in html)

### Development and production

On developement, use `Gluey::Workshop`, that watches for changes in assets and enables you to
reference to built results. Attaching `Gluey::RackMountable` to your routes will utilize
serving requested assets to client.
(or simply use `#find_asset_file` to get path to the built asset, so you can
serve it to client.)

#### Rails:

```ruby
Rails.application.routes.prepend do
  mount Gluey::RackMountable.new(GLUEY_ENV, Rails.logger) => GLUEY_ENV.path_prefix
end
```

#### Sinatra:
```ruby
GLUEY_APP = Gluey::RackMountable.new GLUEY_ENV, logger
get "/gluey_assets*" do |asset|
  GLUEY_APP.dup.call env.merge!('PATH_INFO' => asset)
end
```

But for production you need to use `Gluey::Warehouse`, this environment doesn't create assets
but serves only the role of finding the reference to them. Therefore:

```ruby
GLUEY_ENV = if Rails.env.development?
           Gluey::Workshop.new Nesselsburg.root, &define_materials_proc
         else
           Gluey::Warehouse.new Nesselsburg.root, mark_versions: true
         end
```

The `mark_versions` option serve the purpose of cache-busting for browsers, because assets get a stamp
to tell the version. Warehouse needs to have it's index file built to know how to reeference to
assets (look for `warehouse.write_listing GLUEY_ENV` in example how to generate assets for
production)

#### Generating assets for production

You have to build your own way, how to generate assets fro production, because it hugely depends on
how you serve them. Either you can you the same `Gluey::RackMountable` app as for development, or
use nginx. In both cases you need to put your assets into public directory. But then, you may
wanth to upload your assets to somewhere else, like AWS S3...
The library has some helpers in `Gluey::Tools` that will help you anyway to put the process together.
Here is example how to generate assets into public dir using rake task:

```ruby
desc 'creates assets into public dir'
task make: :environment do
  require 'gluey/tools/local_make'
  raise 'Only for development environment!' unless GLUEY_ENV.is_a? Gluey::Workshop

  GLUEY_ENV.mark_versions = true
  warehouse = Gluey::Warehouse.new GLUEY_ENV.root, path_prefix: GLUEY_ENV.path_prefix

  # For the production build I wanth treat those assets differently
  Gluey::Glues::Sass.engine_opts = {style: :compressed}
  Gluey::Glues.load 'js_script', 'uglifier'

  # makes a special index file for warehouse (!important!) 
  warehouse.write_listing GLUEY_ENV
  created = Gluey::Tools.make_into_assets_dir GLUEY_ENV, warehouse
  
  # this is purely to enjoy of my layzines (use with caution!)
  #unless created.empty?
  #  puts 'adding new files into git ...'
  #  created.each{|file| %x(git add #{file})}
  #end
end
```

One could build some process to clear out old versions of assets, but that is hugely dependent.
Look for my attempts into 'lib/gluey/tools/local_make.rb' if you're interested.

## Contributing

(Any comments or support are welcome!) - the future is open

1. Fork it ( https://github.com/[my-github-username]/gluey/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
