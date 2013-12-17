require 'bundler'
Bundler.require

activate :sprockets

activate :directory_indexes

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

after_configuration do
  Opal.paths.each do |p|
    sprockets.append_path p
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end
