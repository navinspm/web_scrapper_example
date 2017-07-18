require 'mechanize'
require 'csv'

class Scraper
	def initialize
     @base_url = 'https://access.kfit.com/'
     @city = 'kuala-lumpur'
     @mechanize = Mechanize.new
	end

	def get_total_pages
		url = "#{@base_url}partners?city=#{@city}"
		page = @mechanize.get(url)
		total_pages = page.search('.pagination li:last a')[0]['href'].split('=')[2]
	end
end

scrape = Scraper.new
p 'Getting total number of pages from pagination'
total_pages = scrape.get_total_pages
p '-------------------------------------------'
p "Total Pages - #{total_pages}"
