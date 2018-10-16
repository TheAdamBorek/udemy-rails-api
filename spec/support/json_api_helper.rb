module JsonApiHelper
  def json
    JSON.parse(response.body)
  end

  def json_data
    json['data']
  end

  def json_errors
    json['errors']
  end
end