require 'yaml'
module Jekyll

  #
  # # Index Generator
  #
  # ```yaml
  # indexgenerator:
  #   - name: Author
  #     post_attribute: author_name
  #     directory: blog/author
  #     layout: blog-author-index
  # ```

  class IndexGenerator < Generator
    safe true
    priority :low

    def generate site
      return unless site.config['indexgenerator']

      master_index, indexes = build_index site
      puts master_index
      master_index.each do |name, hash|
        hash[:items].each do |index_name,index_items|
          site.pages << IndexPage.new(site, hash[:config], indexes, index_name, index_items)
        end
      end
      File.open('/tmp/jekyll-index.yml', 'w') {|f| f.write master_index.to_yaml}
    end

    def build_index site
      built_index = Hash.new
      indexes = Array.new

      site.config['indexgenerator'].each do |index|
        micro_index = {:config => index, :items => {} }
        site.posts.each do |post|

          data = post.data[index['post_attribute']]
          data = Array.new([data]) if data.kind_of?(String)

          data.each do |index_name|
            micro_index[:items][index_name] ||= Array.new
            micro_index[:items][index_name] << post
            indexes << index_name
          end
        end
        built_index[micro_index[:config]['name']] = micro_index
      end

      return built_index, indexes
    end

    def self.get_index name
      master_index = YAML::load_file('/tmp/jekyll-index.yml')
      master_index[name]
    end
  end

  class IndexPage < Page
    def initialize site, index_config, indexes, index_name, index_items

      dir = File.join(index_config['directory'], index_name).downcase.gsub(/[^a-zA-Z0-9\/]/,'-')

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
end
