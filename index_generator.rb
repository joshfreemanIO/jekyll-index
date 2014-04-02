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

    def generate site
      return unless site.config['indexgenerator']
      @site = site

      master_index = build_index
      master_index.each do |index|
        index[:items].each do |index_name, indexed_item|
          puts index_name
        end
      end

      # site.config['indexgenerator'].each do |item|
      #   build_index site, item['index']
      # end
    end

    def build_index
      built_index = Array.new

      @site.config['indexgenerator'].each do |index|
        micro_index = {:index => index['index'], :items => {} }
        @site.posts.each do |post|

          data = post.data[index['index']]
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
    def initialize site, index_config
      @site = site
      @base = site.source
      @dir  = index_config['directory']
      @name = index_config['index']

      self.process(name)
      self.read_yaml(File.join(base, dir), name)
    end
  end
end
