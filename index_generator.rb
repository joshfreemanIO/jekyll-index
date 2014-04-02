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
      build_index

      # site.config['indexgenerator'].each do |item|
      #   build_index site, item['index']
      # end
      puts @index
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
    # def build_index index_config

    #   @index = index_config
    #   puts @index
    #   @index.each do |index_item|
    #     site.posts.each do |post|
    #       index_item['items'][post[index_item['index']]] = post
    #     end
    #   end
    # end
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
