require 'pp'
module Jekyll

  #
  # # Index Generator
  #
  # ```yaml
  # indexgenerator:
  # - item: tags
  #   directory: blog/category
  #   layout: blog-category-index

  # - item: categories
  #   directory: blog/tag
  #   layout: blog-tag-index

  # - item: authors
  #   directory: blog/author
  #   layout: blog-author-index
  # ```

  class IndexGenerator < Generator
    safe true
    priority :low

    def generate site
      return unless site.config['indexgenerator']

      master_index = build_index site
      master_index.each do |index|
        index[:items].each do |index_name,index_items|
          site.pages << IndexPage.new(site, index[:config], index_name, index_items)
        end
      end
    end

    def build_index site
      built_index = Array.new

      site.config['indexgenerator'].each do |index|
        micro_index = {:config => index, :items => {} }
        site.posts.each do |post|

          data = post.data[index['post_attribute']]
          data = Array.new([data]) if data.kind_of?(String)

          data.each do |index_name|
            micro_index[:items][index_name] ||= Array.new
            micro_index[:items][index_name] << post
          end
        end
        built_index << micro_index
      end

      return built_index
    end
  end

  class IndexPage < Page
    def initialize site, index_config, index_name, index_items

      dir = File.join(index_config['directory'], index_name).downcase.gsub(/[^a-zA-Z0-9\/]/,'-')

      @site = site
      @base = site.source
      @dir  = dir
      @name = 'index.html'

      puts dir

      self.process(name)
      self.read_yaml File.join(@base, '_layouts'), index_config['layout'] + '.html'

      self.data['post_attribtute'] = index_config['post_attribtute']
      self.data['index_name'] = index_config['name']
      self.data['index_items'] = index_items
    end
  end
end
