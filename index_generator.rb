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
      pp master_index
      master_index.each do |index|
        site.pages << IndexPage.new(site, index[:config])
      end
    end

    def build_index site
      built_index = Array.new

      site.config['indexgenerator'].each do |index|
        micro_index = {:config => index, :items => {} }
        site.posts.each do |post|

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
      self.read_yaml File.join(@base, '_layouts'), index_config['layout'] + '.html'
    end
  end
end
