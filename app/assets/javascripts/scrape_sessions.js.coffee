$ ->
  console.log "what about here?"

  $("#batch-retro-scrape-form").validate ->
    debug: true

  $("#multiple-select").click ->
    $(".page-checkbox").prop("checked", $(this).is(':checked') )

  $(".page-checkbox").click ->  
    if $(this).is(':checked') is false
      $("#multiple-select").prop("checked", false )

  console.log "we're in session"