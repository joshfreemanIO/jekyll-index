module Jekyll

  ###
  # # Index Generator
  #
  # Jekyll Plugin to build indexes from Posts
  #
  # ## Installation and Configuration
  #
  # To use in a Jekyll application, copy this file into _plugins
  # and add the following configuration to your _config.yml
  #
  # ```yaml
  # indexgenerator:
  #   - name: Author
  #     name_plural: Authors
  #     post_attribute: author_name
  #     directory: blog/author
  #     layout: blog-author-index
  #   - name: Tag
  #     name_plural: Tags
  #     post_attribute: tags
  #     directory: blog/tag
  #     layout: blog-tag-index
  # ```
  #
  # name/name_plural: how you want to referenced the index in a template
  # post_attribute: the variable you want to index in a post's front-matter
  # directory: the output directory during a Jekyll build
  # layout: the layout to use for displaying individual index results
  #
  # ## Accessing Built Indexes
  #
  # You can access your indexes two ways: globally and through templates.
  #
  # To access a single index, use your layout with the following variables:
  #
  # - page.index_name (the name attribute in your _config.yml)
  # - page.indexes (a list of all index names--all authors or tags, for example)
  # - page.name (the indivual index name--a particular author or tag, for example)
  # - page.items (the posts associated to a particular index)
  #
  # To access all indexes globally, use  {{ indexes }}. Liquid handles hashes a bit
  # differently than ruby, see below;
  #
  # ```html
  # {% for index in indexes %}
  #     <h1>{{index[1].config.name_plural}}</h1>
  #     <ul>
  #         {% for item in index[1].items %}
  #         <li>{{item[0]}}</li>
  #         {% endfor %}
  #     </ul>
  # {% endfor %}
  # ```
  #
  # Everything in the config hash are the index-specific settings from _config.yml.
  # Everything in the items hash are the generated indexes.

  class IndexGenerator < Generator
    safe true
    priority :low

    def generate site
      return unless site.config['indexgenerator']

      master_index, indexes = build_index site
      master_index.each do |name, hash|
        hash['items'].each do |index_name,index_items|
          site.pages << IndexPage.new(site, hash['config'], indexes, index_name, index_items)
        end
      end
    end

    def build_index site
      built_index = Hash.new
      indexes = Array.new

      site.config['indexgenerator'].each do |index|
        micro_index = {'config' => index, 'items' => {} }
        site.posts.each do |post|

          data = post.data[index['post_attribute']]
          data = Array.new([data]) if data.kind_of?(String)

          next if data.nil?

          data.each do |index_name|
            micro_index['items'][index_name] ||= Array.new
            micro_index['items'][index_name].unshift(post)
            indexes << index_name
            puts "Generating #{index['name']} Index: adding \'#{post.title}\' to \'#{index_name}\' index";
          end
        end
        built_index[micro_index['config']['name']] = micro_index
        site.indexes micro_index['config']['name'], micro_index
      end

      return built_index, indexes
    end
  end

  ###
  # # Index Page
  #
  # Page generator for the Index Generator Plugin
  #
  # Each page is index specific. This class extends Jekyll::Page, and
  # the best way to learn the inner workings is to read the original
  # documentation.
  #
  # The intialization method parameters differ from the original class.
  # This does not present a problem so long as the correct class properties are
  # set and class methods are called, similarly to the parent class.
  #
  # All self.data assignments allow the template to access those parameters
  # through {{ page.param }}

  class IndexPage < Page
    def initialize site, index_config, indexes, index_name, index_items

      dir = File.join(index_config['directory'], index_name).downcase.gsub(/[^a-zA-Z0-9\/]/,'_')

      @site = site
      @base = site.source
      @dir  = dir
      @name = 'index.html'

      self.process(name)
      self.read_yaml File.join(@base, '_layouts'), index_config['layout'] + '.html'

      self.data['post_attribtute'] = index_config['post_attribtute']
      self.data['index_name'] = index_config['name']
      self.data['indexes'] = indexes
      self.data['name'] = index_name
      self.data['items'] = index_items
    end
  end

  ###
  # # Site
  #
  # This modifies the original Jekyll::Site to create global access
  # for custom index variables.
  #
  # Standard global variables access:
  # {{ site }}, {{ page }}, etc.
  #
  # Additional global variable access:
  # {{ indexes }}
  #
  # The global indexes variable contains ALL generated indexes specified
  # in the _config.yml under the indexgenerator section.
  #
  class Site
    attr_accessor :custom_payload

    def indexes index_name, index_items
      custom_payload.merge!({"#{index_name}"=>index_items})
    end

    def custom_payload
      @custom_payload ||= {}
    end

    alias old_site_payload site_payload
    def site_payload
      old_site_payload.merge!({'indexes'=>custom_payload})
    end
  end
end
