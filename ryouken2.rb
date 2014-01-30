#!/usr/bin/ruby
require 'open-uri'
require 'nokogiri'

class Ryouken
  def initialize(seed, include_patterns: nil, exclude_patterns: nil)
    uri = URI seed
    @seed = seed
    @base = "#{uri.scheme}://#{uri.host}"
    @include_patterns = include_patterns
    @exclude_patterns = exclude_patterns
  end
  
  def get_urls
    doc = Nokogiri::HTML(open(@seed))
    doc.xpath("//a/@href").map(&:text).uniq
  end
  
  def include_urls(url_array)
    url_array.select {|url| url =~ /#{Regexp.quote(@include_patterns)}/} if @include_patterns
  end
  
  def exclude_urls(url_array)
    url_array.reject {|url| url =~ /#{Regexp.quote(@exclude_patterns)}/} if @exclude_patterns
  end
  
  def is_relative?(url)
    url =~ /^\// ? true : false
  end
end

seed = Ryouken.new("http://www.asia-gazette.com/", include_patterns: 'www.asia-gazette.com')
seed.get_urls
