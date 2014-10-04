module MetaKGS
  class Archives
    def self.build_path( query = {} )
      now = Time.now.gmtime
      user = query[:user]
      year = query[:year] || now.year
      month = query[:month] || now.mon

      raise ":user is required" unless query.has_key?(:user)
      raise ":user is invalid" unless user.is_a? String and user.match(/^[a-zA-Z][a-zA-Z0-9]{0,9}$/)
      raise ":year is invalid" unless year.is_a? Integer and year >= 2000
      raise ":month is invalid" unless month.is_a? Integer and month.between?(1, 12)

      "archives/#{user}/#{year}/#{month}"
    end
  end
end

