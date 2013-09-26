#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'yaml'

positions = { "QB" => 0, "RB" => 2, "WR" => 4, "TE" => 6, "D/ST" => 16, "K" => 17  }

credentials = YAML.load_file('credentials.yml')
username = credentials["username"]
password = credentials["password"]

uri = URI('https://r.espn.go.com/espn/memberservices/pc/login')

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

req = Net::HTTP::Post.new(uri.request_uri)
req.set_form_data({'SUBMIT' => '1', 'username' => username, 'password' => password})

res = http.request(req)

cookies = res.response['set-cookie']

leagueid = 756713
week = 3

# top scorers
# url = "http://games.espn.go.com/ffl/leaders?seasonTotals=true&seasonId=2013&leagueId=#{leagueid}&slotCategoryId="
# by week
url = "http://games.espn.go.com/ffl/leaders?leagueId=#{leagueid}&seasonId=2013&scoringPeriodId=#{week}&slotCategoryId="

# on rosters
# this will also take a scoringPeriodId=#{week}
# url = "http://games.espn.go.com/ffl/freeagency?leagueId=#{leagueid}&seasonId=2013&avail=4&slotCategoryId="

positions.each do |pos,num|
  uri = URI("#{url}#{num}")
  http = Net::HTTP.new(uri.host,uri.port)
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Cookie'] = cookies 
  res = http.request(req)
  doc = Nokogiri::HTML(res.body)
  doc.xpath("//tr[starts-with(@class,'pncPlayerRow playerTableBgRow')]").each do |r|
    name = r.xpath("./td[@class='playertablePlayerName']/a/text()")
    teamid = r.xpath("(./td)[3]/a/text()")
    # get score for on rosters version 
    # score = r.xpath("./td[@class='playertableStat appliedPoints sortedCell']").inner_text
    # get score for leaders version
    score = r.xpath("./td[@class='playertableStat appliedPoints appliedPointsProGameFinal']").inner_text
    puts "#{name},#{pos},#{teamid},#{score}"
  end
end
