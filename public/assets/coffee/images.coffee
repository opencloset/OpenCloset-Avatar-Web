$ ->
  $('.thumbnail').on 'click', 'span.star', (e) ->
    e.preventDefault()

    rating = $(@).data('rating')
    url = $(@).closest('a').attr('href')
    $.ajax url,
      type: 'PUT'
      data: { rating: rating }
      success: (data, textStatus, jqXHR) ->
        location.reload()
      error: (jqXHR, textStatus, errorThrown) ->
      complete: (jqXHR, textStatus) ->


