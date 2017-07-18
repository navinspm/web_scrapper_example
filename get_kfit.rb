require 'mechanize'
require 'csv'

class Scraper
	def initialize
     @base_url = 'https://access.kfit.com/'
     @city = 'kuala-lumpur'
     @mechanize = Mechanize.new
	end

  #Partners page is paginated, so we need to get total number of pages
	def get_total_pages
		url = "#{@base_url}partners?city=#{@city}"
		page = @mechanize.get(url)
		total_pages = page.search('.pagination li:last a')[0]['href'].split('=')[2].to_i
	end

  # Get partner urls
	def get_partners_url(total_pages)
		partner_urls =[]
		1.upto(total_pages) do |current_page|
			url = "#{@base_url}partners?city=#{@city}&page=#{current_page.to_s}"
			page = @mechanize.get(url)
			page.search('.card-details h3 a').each do |a|
				partner_urls << a["href"]
			end
		end
		partner_urls
	end

  # Fetching details from partners URLs
	def scrape_details(partner_urls)
		csv_data = []
		csv_data <<  ["City","Partner Name","Address","Latitude","Longitude","Avarage Rating","Phone Number"]

		partner_urls.each do |url|
			p 'Started scraping '+ url
			scrap_page = @mechanize.get(url)
			partner_name = scrap_page.at('.studio-info .studio-name h2').text.strip
			address = scrap_page.at('.list-unstyled.studio-details li p').text.strip
			lat_lng = scrap_page.search('.studio-sidebar script')[0].children.to_s.split("LatLng")[1].split("'")
	    latitude =  lat_lng[1].strip
	    longitude =  lat_lng[3].strip
      #For some partners raring is not available
	    if rating = scrap_page.search(".rating")
	   		 average_rating = rating[0].text.strip if rating[0]
	   	else
         average_rating = 0
	   	end
	    phone = get_partner_phone_no(scrap_page)
			csv_data << [@city.capitalize, partner_name, address,latitude,longitude,average_rating,phone]
		end
    return csv_data
	end

  # Export to CSV file
	def export_csv(csv_data)
		File.write("kfit_partners.csv", csv_data.map(&:to_csv).join)
	end

  # Getting contact number if available
	def get_partner_phone_no(page)
		begin
			schdule_btn = page.search("td.reserve-col .btn-transaction")
			if !schdule_btn.empty?
	        schdule = schdule_btn[0]["href"]
				  schdule_page = @mechanize.get(@base_url+schdule)
	        phone = schdule_page.search(".list-unstyled.activity-slot-details")[0].search("li:last").text.split("+")[1]
			else
				phone = ""
			end
		rescue Exception => e
        phone = ""
		end
		return phone
	end
end

scrape = Scraper.new
p 'Getting total number of pages from pagination'
total_pages = scrape.get_total_pages
p '-------------------------------------------'
p "Total Pages - #{total_pages}"
p '-------------------------------------------'
p 'Get Partners URL'
partner_urls = scrape.get_partners_url(total_pages)
p '-------------------------------------------'
p 'Scrape  Details'
 csv_data = scrape.scrape_details(partner_urls)
p '-------------------------------------------'
p 'Export to CSV'
export_csv = scrape.export_csv(csv_data)
p '-------------------------------------------'
p "Done! Yeah!!"

