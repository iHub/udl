class CsvImportController < ApplicationController

  def import
  	path_to_file = "#{Rails.root}/db/csv/test.csv"
  	
  	#for this to work
  	#create csv table for import based on structure of csv file
  	#ensure csv file is in utf8 encoding, 
  	#check for mapping of csv table id and model id - update csv_table_id
  	#else the funny characters will break the structure

  	#imported_csv_data 	= SmarterCSV.process(path_to_file, {:key_mapping => {:csv_table_id => :id}})  	

  	# @csvstuff = CSVmodel.new(imported_csv_data)

  	# if @csvstuff.save
  	# 	flash[:success] = "CSV file imported and successfully saved"
  	# else
  	# 	flash[:error] = "Unable to import CSV file"
  	# end
  end

end
