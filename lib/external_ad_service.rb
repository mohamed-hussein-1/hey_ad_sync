class ExternalAdService

  class ApiException < StandardError; end

  URL = 'https://mockbin.org/bin/fcb30500-7b98-476f-810d-463a0b8fc3df'

  # service to call external api and returns the result in form
  # of hash indexed by the reference id
  # this has drawback that same reference id will override
  def call
    response = call_ads_api
    ads = response["ads"]
    ads_hash = index_ads_remote(ads)
    {success: true, data: ads_hash}
  end

  private

  def call_ads_api
    conn = Faraday.new(url: URL) do |faraday|
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
    begin
      response = conn.get
    rescue StandardError => e
      STDERR.puts e.backtrace
      raise ApiException.new
    end
    if response.status != 200
      STDERR.puts response.inspect
      raise ApiException.new("Api Failed")
    end
    response.body
  end

  def index_ads_remote(ads)
    ads.inject({}) do |memo, curr|
      memo[curr["reference"].to_i] = curr if is_number? curr["reference"]
      memo
    end
  end

  # method to make sure that string is a valid id
  # is_number?("x12x") returns false
  # is_number?("12") returns true
  def is_number?(string)
    true if Integer(string) && Integer(string) >= 0 rescue false
  end

end
