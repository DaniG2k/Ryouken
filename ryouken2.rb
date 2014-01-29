#!/usr/bin/ruby
require 'open-uri'
require 'nokogiri'

class Ryouken
  def initialize(seed)
    uri = URI(seed)
    @seed = seed
    @base_url = "#{uri.scheme}://#{uri.host}" 
  end
  
  def get_links
    doc = Nokogiri::HTML(open(@seed))
    urls = doc.css('a').map { |href| href.attribute('href').text }.uniq
    urls.each do |url|
      puts url.make_absolute
    end
  end
  
  def make_absolute
    self.is_relative? ? "#{@base_url}#{self}" : self
  end
  
  def is_relative?
    (self =~ /^\//).nil? ? false : true 
  end
end

page = "http://www.asia-gazette.com"

a = Ryouken.new(page)
puts a.get_links
