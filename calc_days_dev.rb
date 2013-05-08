#!/usr/bin/env ruby
$VERBOSE = nil
require 'time'
require 'rubygems'
require 'ruby-debug'
require 'active_support'
require 'highline/import'
require 'rally_rest_api'
require 'date'
@filename = "stories_accepted.csv"

def get_password(prompt="Digite a Senha")
   ask(prompt) {|q| q.echo = '*'}
end

def get_login(prompt="Digite seu login")
   ask(prompt)
end
login = get_login()
password = get_password()
if(login.nil?)
  login = 'abcde@abcde.com.br'
end
puts login
# Nome do arquivo em argumento ruby parse4.rb nome.csv
if ARGV[0] != nil
  @filename = ARGV[0]
end


# Login com o Rally
rally = RallyRestAPI.new(:base_url => "https://rally1.rallydev.com/slm",
  :username => login,
  :password => password)

# Criando Cabeçalho
@output_file = File.new(@filename, "w")
@output_file << "   Story Name   " + "," + "  Owner  " + "," + "description" + "," + "   Revision Date\n"

# Query das Tasks
def check_revision(hierarchical_requirement, rev)
@data_formatada = ""
@data_formatada2 =""
#if (rev.description.include? "[Ready to development] to [Developing]" or rev.description.include? "[Accepting] to [Ready to Release]" )
  if (rev.description.include? "[Ready to development] to [Developing]")
	@data_formatada = Time.parse(rev.creation_date)    
        puts @data_formatada.strftime("%d-%m-%Y %H:%M")
  if (rev.description.include? "to [Ready to Release]" or "to [Released]")
 	@data_formatada2 = Time.parse(rev.creation_date)
        puts @data_formatada2.strftime("%d-%m-%Y %H:%M")
# Adicionando campos ao csv
    @output_file << hierarchical_requirement.name << "," <<
      hierarchical_requirement.owner << "," <<
      hierarchical_requirement.formatted_i_d << ","  <<
      rev.creation_date << "\n"
  end
  end
end

# Parse story revision history
def parse_story(hierarchical_requirement)
  hierarchical_requirement.revision_history.revisions.each {|rev| check_revision(hierarchical_requirement,  rev)}
end

# Find all Stories
query_result = rally.find(:hierarchical_requirement) { equal :formatted_i_d, "US16284" }
query_result.each {|hierarchical_requirement| parse_story(hierarchical_requirement)}
print "   Output file: " + @filename
