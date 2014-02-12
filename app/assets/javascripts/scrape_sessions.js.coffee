$ ->
  $("#batch-retro-scrape-form").validate ->
    debug: true

  $("#multiple-select").click ->
    $(".page-checkbox").prop("checked", $(this).is(':checked') )
  
  console.log "we're in session"