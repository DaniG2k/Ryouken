#!/usr/bin/ruby
require 'open-uri'
require 'nokogiri'

class Ryouken
  def initialize(seed)
    @seed = URL.new(seed)
  end
  
  def get_links
    doc = Nokogiri::HTML(open(@seed))
    #doc.xpath("//a/@href").map(&:text).uniq
    urls = doc.css('a').map { |href| href.attribute('href').text }.uniq
    urls.each { |url| puts url.absolute(base: @seed) }
  end
end

class URL
  def initialize(url)
    @url = url
  end
  
  def to_s
    @url.to_s
  end
  
  def +(rhs)
    URL.new(to_s + rhs.to_s)
  end
  
  def ==(rhs)
    @url == rhs.to_s
  end
  
  def absolute(base: nil)
    is_relative? ? base + self : self
  end
  
  def is_relative?
    @url =~ /^\// ? true : false 
  end
end

page = "http://www.asia-gazette.com"

a = Ryouken.new(page)
puts a.get_links
