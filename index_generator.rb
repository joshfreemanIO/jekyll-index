module Jekyll

  #
  # # Index Generator
  #

  class IndexGenerator < Generator
    safe true




    def initialize
      @index_config = site.config['indexgenerator']
    end
  end
end