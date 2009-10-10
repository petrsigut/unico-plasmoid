# <Copyright and license information goes here.>
require 'plasma_applet'
#require 'Qt4'
require 'korundum4'
require "qtwebkit"

# pro stahnuti a parsovani xmlka
require 'net/http'
require 'rexml/document'

require 'logger'

module RubyWidget
  # PlasmaScripting::Applet - for GHNS
  class Main < PlasmaScripting::Applet
# The both slots used by our applet.
    slots 'load(QUrl)',
          'loadFinished(bool)',
          :paserxml
#    slots :add_x

    def initialize parent
      super parent
    end
 
    def init
      self.has_configuration_interface = true
      self.aspect_ratio_mode = Plasma::Square
      self.background_hints = Plasma::Applet.DefaultBackground
 
      layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self

      # try to load config
      
      data = Plasma::ToolTipContent.new
      data.mainText = "My Title"
      data.subText = "My Title"

      button = Plasma::PushButton.new self
      button.text = "Hi"

      #@label.text = titles[2]
      parsexml

      read_config
      puts @mensa

 
      
      layout.add_item @label

      layout.add_item button
      
      #layout.add_item web

      self.layout = layout
 
      resize 125, 125
    end

    def read_config
      config = self.config
      configGroup = config.group('Happa')
      @mensa = configGroup.readEntry('Mensa','true')
      puts @mensa
    end

    def configChanged
      puts "xxx"
      readxml
    end


    def parsexml
      # Web search for "madonna"
      url = 'http://localhost:3000/pcfilmtydne'
      #url = 'http://api.search.yahoo.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=madonna&results=2'

      # get the XML data as a string
      xml_data = Net::HTTP.get_response(URI.parse(url)).body

      # extract event information
      doc = REXML::Document.new(xml_data)
      labels = []
      links = []
      doc.elements.each("document/*") do |element|
        case element.name
        when "label"
          @label = Plasma::Label.new self
          @label.text = element.text
          layout.add_item @label
        when "image"
          @image = Plasma::WebView.new()
          @image.setUrl(KDE::Url.new(element.text))
          layout.add_item @image
        when "video" # potrebujeme KDE 4.3!
          @video = Plasma::VideoWidget.new()
          @video.setUrl(KDE::Url.new(element.text))
          layout.add_item @video
        end
      end
      #@delka =titles.length
#      doc.elements.each('ResultSet/Result/item') do |ele|
#         links << ele.text
#      end

      # print all events
#--------------------------------------------------
#       titles.each_with_index do |title, idx|
#          print "#{title} => #{links[idx]}\n"
#       end
#-------------------------------------------------- 
      labels

    end

  end
end
