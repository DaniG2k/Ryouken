require 'uri'
require 'open-uri'
require 'nokogiri'

# 猟犬 a url hound
class Ryouken
  
  def initialize(url)
    @url = url
    @uri = URI(url)
    @base_url = @uri.scheme + '://' + @uri.host
  end
  
  def crawl
    children = process_page(@url)
  end
  
  def process_page(url)
    page = Nokogiri::HTML(open(@url))
    get_links(@url, page)
  end
  
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
  
  def make_absolute(url, new_url)
    return @base_url + new_url
  end
end

hound = Ryouken.new('http://www.asia-gazette.com')
puts hound.crawl