require 'httparty'
require 'nokogiri'
require 'colorize'

checkmark = "\u2713"
ballot_box = "\u2612"

def progress_bar
    puts "\n"
    0.step(50, 2) do |x|
         printf("\rChecking for WordPress: [%-10s]", "=" * (x/5))
         sleep(0.1)
    end
    puts "\n"
end

puts "

888       888                    8888888888b.                                   88888888888             888                  
888   o   888                    888888   Y88b                                      888                 888                  
888  d8b  888                    888888    888                                      888                 888                  
888 d888b 888 .d88b. 888d888 .d88888888   d88P888d888 .d88b. .d8888b .d8888b        888  .d88b. .d8888b 888888 .d88b. 888d888
888d88888b888d88\"\"88b888P\"  d88\" 8888888888P\" 888P\"  d8P  Y8b88K     88K            888 d8P  Y8b88K     888   d8P  Y8b888P\"  
88888P Y88888888  888888    888  888888       888    88888888\"Y8888b.\"Y8888b.       888 88888888\"Y8888b.888   88888888888    
8888P   Y8888Y88..88P888    Y88b 888888       888    Y8b.         X88     X88       888 Y8b.         X88Y88b. Y8b.    888    
888P     Y888 \"Y88P\" 888     \"Y88888888       888     \"Y8888  88888P' 88888P'       888  \"Y8888  88888P' \"Y888 \"Y8888 888  

".red

puts "Enter the full URI that you'd like to test.".green

# Main URI
uri = gets.chomp

puts " Igniting the flux capacitor! Here we GO! \n".white.on_green

# Progress bar
progress_bar

# Main URI testing
response = HTTParty.get(uri)
html = Nokogiri::HTML(response.body)
html_metas = html.xpath("//meta").to_s.include?('wp-content')
html_images = html.xpath("//img").to_s.include?('wp-content')
html_links = html.xpath("//link").to_s.include?('wp-content')
puts "\n"

puts html_metas ? "#{checkmark} Meta content defines WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in meta content.".red
puts html_images ? "#{checkmark} Images define WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in images.".red
puts html_links ? "#{checkmark} Links define WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in links.".red
puts "\n"

if html_metas || html_images || html_links == true
    puts "Looks like WordPress, to be sure... \nI'm going to dig into the sitemap.xml file and see what I can't find.".green
else
    puts "Doesn't look like WordPress, to be sure... \nI'm going to dig into the sitemap.xml file and see what I can't find.".red
end

# Progress bar
progress_bar

# Sitemap testing
sitemap_uri = uri + "/sitemap.xml"
sitemap_html = HTTParty.get(sitemap_uri)
parsed_sitemap = Nokogiri::HTML(sitemap_html.body)
sitemap_links = parsed_sitemap.xpath("//loc").to_s
sitemap_links_array = sitemap_links.gsub(%r{<loc>|</\loc>}, "\n").split
sitemap_output = sitemap_links_array.each do |sitemap_link|
    puts "Testing #{sitemap_link}"
    sitemap_response = HTTParty.get(sitemap_link)    
    parsed_sitemap_uri = Nokogiri::HTML(sitemap_response.body)
    sitemap_html_metas = parsed_sitemap_uri.xpath("//meta").to_s.include?('wp-content')
    sitemap_html_images = parsed_sitemap_uri.xpath("//img").to_s.include?('wp-content')
    sitemap_html_links = parsed_sitemap_uri.xpath("//link").to_s.include?('wp-content')
    status_code = sitemap_response.code
    if status_code <= 299
        puts "> #{status_code} (RESPONSE): A successful response!".green
    elsif status_code <= 399
        puts "> #{status_code} (RESPONSE): Looks like a redirect".yellow
    elsif status_code <= 499
        puts "> #{status_code} (RESPONSE): Hmmm, seems we have a client error!".yellow
    else
        puts "> #{status_code} (RESPONSE): Ohh no! A server error!? Maybe rate limiting?".red
    end

    puts sitemap_html_metas ? "#{checkmark} Meta content defines WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in meta content.".red
    puts sitemap_html_images ? "#{checkmark} Images define WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in images.".red
    puts sitemap_html_links ? "#{checkmark} Links define WordPress directory.".green : "#{ballot_box} I don't see the wp-content directory in links.".red
end