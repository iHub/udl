# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
  # $("body").html "this works"   #first test
  # $("#slider").hide() 		  #second test

  # say = (something) ->   		  #third test
  #   alert something
  
  # console.log "again"
  # say "something else"
  # everything above this line works
  ###############################################
  $(".date-field").datepicker
  	dateFormat: 'yy-mm-dd'