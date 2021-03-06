require 'open-uri'
require 'nokogiri'

class Ryouken
  class PageProcessor
    attr_reader :url, :dom
    
    def initialize(url)
      @url = url
      @dom = open(@url.to_s) { |fh| Nokogiri::HTML(fh) }
    end
    
    # Get all hrefs and return in @dom and return them as a set.
    def urls
      @dom.xpath("//a/@href").map { |node| uri(node.text) }.uniq
    end
    
    def uri(url)
      URI(@url + url)
    end
  end
  
  attr_reader :start_url, :include_ptn, :exclude_ptn, :visited, :work
  
  def initialize(start_url, include_ptn: nil, exclude_ptn: nil)
    @start_url    = URI(start_url)
    @visited      = Array.new
    @work         = [@start_url]
    # The && is for returning nil if no value was specified
    @include_ptn  = include_ptn && /#{Regexp.quote(include_ptn)}/
    @exclude_ptn  = exclude_ptn && /#{Regexp.quote(exclude_ptn)}/
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
    puts "URLS: #{urls}"
    remaining = urls - @visited - @work
    remaining.select! { |url| url =~ @include_ptn } if @include_ptn
    remaining.reject! { |url| url =~ @exclude_ptn } if @exclude_ptn
    @work.concat(remaining).uniq
  end
end


#my_crawler = Crawler.new('https://www.asia-gazette.com', include_patterns: 'asia-gazette')
my_crawler = Ryouken.new('http://www.nytimes.com/pages/world/asia/', include_ptn: 'ref=asia')
my_crawler.run { |page| puts "Visiting #{page.url}" }
