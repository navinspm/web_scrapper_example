require 'mechanize'
require 'csv'

class Scraper
	def initialize
     @base_url = 'https://access.kfit.com/'
     @city = 'kuala-lumpur'
     @mechanize = Mechanize.new
	end

  #partners page is paginated, so we need to get total number of pages
	def get_total_pages
		url = "#{@base_url}partners?city=#{@city}"
		page = @mechanize.get(url)
		total_pages = page.search('.pagination li:last a')[0]['href'].split('=')[2].to_i
	end

  # Get partner urls
	def get_partners_url(total_pages)
		partner_urls =[]
		1.upto(total_pages) do |current_page|
			url = "#{@base_url}/partners?city=#{@city}&page=#{current_page.to_s}"
			page = @mechanize.get(url)
			page.search('.card-details h3 a').each do |a|
				partner_urls << a["href"]
			end
		end
		partner_urls
	end
end

scrape = Scraper.new
p 'Getting total number of pages from pagination'
total_pages = scrape.get_total_pages
p '-------------------------------------------'
p "Total Pages - #{total_pages}"
p '-------------------------------------------'
p 'Get Partners URL'
p partner_urls = scrape.get_partners_url(total_pages)

