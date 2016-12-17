require 'slim'

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy '/this-page-has-no-template.html', '/template-file.html', locals: {
#  which_fake_page: 'Rendering a fake page with a local variable' }


# haml
set :haml, { ugly: true }

# markdown
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :with_toc_data => false, :tables => true, :autolink => true, :gh_blockcode => true
activate :syntax

# livereload
configure :development do
  activate :livereload
end

# autoprefixer
activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 9']
end

activate :asset_hash

# directory indexes
activate :directory_indexes

# google analytics
activate :google_analytics do |ga|
  ga.tracking_id = 'UA-xxxxxxxx-x'
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :minify_html, :remove_quotes => false, :remove_intertag_spaces => true

  activate :relative_assets
  set :relative_links, true
end
