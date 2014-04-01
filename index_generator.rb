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

      site.config['indexgenerator'].each do |item|
        puts item['index']
      end

    end
  end

  class IndexPage < Page
    def initialize site, base, dir, name
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(name)
      self.read_yaml(File.join(base, dir), name)
    end
  end
end
