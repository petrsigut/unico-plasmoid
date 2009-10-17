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
#    slots 'load(QUrl)',
#          'loadFinished(bool)',
#          :paserxml
#    slots :add_x

    def initialize parent
      super parent
    end
 
    def init
      #Qt.debug_level = Qt::DebugLevel::High
      self.has_configuration_interface = true
      self.aspect_ratio_mode = Plasma::Square
      self.background_hints = Plasma::Applet.DefaultBackground
 
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self

      configChanged

      #data = Plasma::ToolTipContent.new
      #data.mainText = "My Title"
      #data.subText = "My Title"
      #button = Plasma::PushButton.new self
      #button.text = "Hi"

        self.layout = @layout

     # resize 125, 125
    end


    
    def configChanged
      config = self.config
      configGroup = config.group('url')
      # pozor na to aby tam byl nil, ne "nil":)
      @url_to_show = configGroup.readEntry('imageUrl', 'nil')
        
      extension = @url_to_show.split('.').last

       # puts @url_to_show
        puts extension

        case extension
        when "xml"
          show_xml
        when "html"
          show_html
        else
          show_html
        end
    end

    def reset_layout
      puts "ZACINAM SMYCKU"
      while ((@child = @layout.itemAt(0)) != nil)

        @layout.removeItem(@child)
        puts @child
        @child.dispose
      end
      puts "KONCIm SMYCKU"

    end


    def show_xml
      reset_layout

      # Web search for "madonna"
      #url = 'http://localhost:3000/pcfilmtydne'
      #url = 'http://api.search.yahoo.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=madonna&results=2'
        

      # get the XML data as a string
      xml_data = Net::HTTP.get_response(URI.parse(@url_to_show)).body

      # extract event information
      doc = REXML::Document.new(xml_data)
      doc.elements.each("document/*") do |element|
        case element.name
        when "label"
          @label = Plasma::Label.new self
          @label.text = element.text
          @layout.add_item @label
          puts "X"
          puts @label
        when "image"
          @image = Plasma::WebView.new()
          @image.setUrl(KDE::Url.new(element.text))
          @layout.add_item @image
          puts "X"
          puts @image
        when "video" # potrebujeme KDE 4.3!
          @video = Plasma::VideoWidget.new()
          @video.setUrl(KDE::Url.new(element.text))
          @layout.add_item @video
          puts "X"
          puts @video
        end
      end
      #  self.layout = @layout
    end

    def show_html

      reset_layout

      @web = Plasma::WebView.new()
      @web.setUrl(KDE::Url.new(@url_to_show))
      @layout.add_item @web
      puts "X"
      puts @web
#      self.layout = @layout
       
    end

  end
end
