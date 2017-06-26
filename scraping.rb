require 'nokogiri'
require 'open-uri'
require 'csv'

years = ["2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017"]

years.each do |year|

	doc = Nokogiri::HTML(open("https://www.bundestag.de/parlament/praesidium/parteienfinanzierung/fundstellen50000/" + year))

	table =  doc.xpath("//*[contains(@class, 'table-responsive')]")

	donations = Array.new

	table.xpath("//tr").each do |row|
		# rows with a month as a text are subheaders
		if (row.to_s.index("Januar") || row.to_s.index("Februar") || row.to_s.index("März") || row.to_s.index("April") || row.to_s.index("Mai") || row.to_s.index("Juni") || row.to_s.index("Juli") || row.to_s.index("August") || row.to_s.index("September") || row.to_s.index("Oktober") || row.to_s.index("November") || row.to_s.index("Dezember"))
			next
		else
			donation = Hash.new
			party = row.xpath("(./td)[1]").text()
			amount = row.xpath("(./td)[2]").text()
			donor = row.xpath("(./td)[3]").text()
			date = row.xpath("(./td)[4]").text()
			donation["party"] = party
			donation["amount"] = amount
			donation["donor"] = donor
			donation["date"] = date
			donations.push donation
		end
	end

	# we have to shift?!
	donations.shift

	CSV.open("./donations_" + year + ".csv", "w") do |csv|
		csv << ["party", "amount", "donor", "date"]
		donations.each do |donation|
			csv << [donation["party"], donation["amount"], donation["donor"], donation["date"]]
		end
	end

end