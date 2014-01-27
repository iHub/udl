class FbScrapController < ApplicationController
	

	def index
		access_token = 'CAAI9jQBuPWwBAIPwAa5hZAfOrB4IJ7xxNjohAgytglX24UAAf2wXq7vmNnj3e40sJyNDjbQVLoD8dW1rfx1qHEXaeZApM1rg4EW85hUN9vZAkFvCbC0RQJUxfKKU8K5EcG9klfZCZBziNRQmaNZCBK5el5gFvFg4xMD1YJ2g8oK2vPZBkFIZA7wOLwpsZAKIZBhpQgsv3rQ23lhgZDZD'

		@graph = Koala::Facebook::API.new(access_token)
		
		@ktnfeed = @graph.get_connections("ktnkenya", "feed")
		@profile = @graph.get_object("ktnkenya")
	end

	def feed

	end

	def scrape
		
	end

end
