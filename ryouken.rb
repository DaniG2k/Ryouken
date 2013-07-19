require 'uri'
require 'open-uri'
require 'nokogiri'

# 猟犬 a url hound
class Ryouken
  
  def initialize(seed)
    uri = URI(seed)
    @seed = seed
    @host = uri.scheme + '://' + uri.host
    @visited = Array.new
  end
  
  def crawl(url=@seed)
    children_all = process_page(url)
    children = rm_secondary_urls!(children_all, @host)
    children -= @visited
    while !children.empty?
      next_url = children.shift
      unless @visited.include?(next_url)
        puts 'Visiting ' + next_url
        @visited.push(next_url)
        self.crawl(next_url)
      end
    end
  end
  
  # Use Nokogiri to fetch all links on a page
  def process_page(url)
    page = Nokogiri::HTML(open(url))
    get_links(url, page)
  end
  
  # Return an array of links containing scheme+host+path
  def get_links(url, page)
    links = []
    page.css('a').map do |link|
      new_url = link['href']
      unless new_url == nil
        if relative?(new_url)
          new_url = make_absolute(url, new_url)
        end
        links.push(new_url)
      end
    end
    return links
  end
  
  def relative?(url)
    if((url =~ /^\/.+/) != nil)
      return true
    else
      return false
    end
  end
  
  def make_absolute(url, path)
    @host + path
  end
  
  def rm_secondary_urls!(url_list, host)
    primary_urls = []
    url_list.each {|url| primary_urls.push(url) if url.start_with?(host) }
    primary_urls
  end
end

hound = Ryouken.new('http://www.asia-gazette.com')
hound.crawl