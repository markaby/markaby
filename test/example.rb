$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'builder'
require 'markaby'


module Helpers
  def self.link_to(person)
    %{<a href="/person/#{person.id}">#{capitalize(person.name)}</a>}
  end
  def self.capitalize(text)
    text.sub(/([a-z])/) { $1.upcase }
  end
  def self.p(text)
    "<p>#{text}</p>"
  end
end

class Person < Struct.new(:id, :name)
  def self.all
    @@people ||= []
  end
  def self.<<(name)
    all << new(name)
  end
  def initialize(name)
    super(self.class.all.size + 1, name)
  end
end

Person << 'tim'
Person << 'sophie'

template = <<-EOT

  link :rel => 'stylesheet'
  
  ul do
    people.each do |person|
      li link_to(person)
    end
  end
  
  hr
  
  div self.p("foo")

EOT

puts Markaby::Template.new(template).render({'people' => Person.all}, Helpers)
