require 'open-uri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)

    html = open(index_url)
    doc = Nokogiri::HTML(html)
    students = []

    doc.css(".student-card > a").each do |card|      
      student = {
        :name => card.css("div.card-text-container h4.student-name").children.text,
        :location => card.css("div.card-text-container p.student-location").children.text,
        :profile_url => card.attribute("href").value
      }
      students << student
    end
    students
  end

  def self.scrape_profile_page(profile_url)
    html = open(profile_url)
    doc = Nokogiri::HTML(html)
    profile = {}

    doc.css("div.vitals-container div.social-icon-container a").each do |account|
      if account
        new_account = account.attribute("href").value 
        key = new_account.match(/https?:\/\/(www\.)?([a-z]+)\./i) 
        if key
          if key[2] == "twitter" || key[2] == "github" || key[2] == "linkedin"
            profile[key[2].to_sym] = new_account
          else 
            profile[:blog] = new_account 
          end
        end

      end
    end

    profile[:profile_quote] = doc.css("div.vitals-container div.vitals-text-container div.profile-quote").text.strip
    profile[:bio] = doc.css("div.details-container div.bio-block.details-block div.bio-content.content-holder p").text.strip
    profile
  end

end

