require 'open-uri'
require 'nokogiri'
require 'set'

class Crawler
  class PageProcessor
    attr_reader :url, :dom
    def initialize(url)
      @url = url
      @dom = open(@url) { |fh| Nokogiri::HTML(fh) }
    end
    
    # Get all hrefs and return in @dom and return them as a set.
    def urls
      @dom.xpath("//a/@href").map { |node| rewrite_url(node.text) }.to_set
    end
    
    # In the event a url is relative (ex. '/') rewrite it to a full path
    def rewrite_url(path)
      is_relative?(url) ? @url + path : path
    end
    
    def is_relative?(url)
      url =~ /^\// ? true : false
    end
  end
  
  attr_reader :start_url, :include_patterns, :exclude_patterns, :visited, :work
  def initialize(start_url, include: nil, exclude: nil)
    @start_uri        = URI(start_url)
    @include_patterns = include && /#{Regexp.quote(include)}/
    @exclude_patterns = exclude && /#{Regexp.quote(exclude)}/
    @visited          = Set.new
    @work             = [@start_url]
  end
  
  def run
    until @work.empty?
      current_url = @work.shift
      @visited << current_url
      page = PageProcessor.new(current_url)
      yield(page)
      append_urls(page.urls)
    end
  end
  
  def append_urls(urls)
    remaining = urls - @visited - @work.to_set
    remaining.select! { |url| url.to_s =~ @include_patterns } if @include_patterns
    remaining.reject! { |url| url.to_s =~ @exclude_patterns } if @exclude_patterns
    remaining.select! { |url| ['http', 'https'].include?(url.scheme) }
    @work.concat(remaining.to_a)
  end
end


#my_crawler = Crawler.new('https://www.asia-gazette.com', include_patterns: 'asia-gazette')
my_crawler = Crawler.new 'http://www.nytimes.com/pages/world/asia/', include: 'ref=asia'
my_crawler.run { |page| puts "Visiting #{page.url}" }
