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
          'loadFinished(bool)'
#    slots :add_x

    def initialize parent
      super parent
    end
 
    def init
      self.has_configuration_interface = false
      self.aspect_ratio_mode = Plasma::Square
      self.background_hints = Plasma::Applet.DefaultBackground
 
      layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self

      # try to load config
      
      data = Plasma::ToolTipContent.new
      data.mainText = "My Title"
      data.subText = "My Title"

      button = Plasma::PushButton.new self
      button.text = "Hi"

      image = Plasma::IconWidget.new self
#      image.setIcon(KDE::Url.new("http://www.sigut.net/fotky/obr1500.jpg"))

      @label = Plasma::Label.new self
      @label.text = "Hello world!"
      Plasma::ToolTipManager::self().setContent(@label, data)



# web = Qt::WebView.new()
# web.load(Qt::Url.new("http://www.google.com"))

#       @page = Plasma::WebView.new()
#@page.setUrl(KDE::Url.new("http://dot.kde.org/"))
#       url = KDE::Url.new 'http://localhost/~phax/sigut//'
#       web = Plasma::WebView.new
#       web.url = url

#       @page.page = Qt::WebPage.new(@page)
#       @page.page.linkDelegationPolicy = Qt::WebPage::DelegateAllLinks
#       @page.page.settings.setAttribute(
#        Qt::WebSettings::LinksIncludedInFocusChain, true)

      # Connect signals the webbrowser provides with own functions.
#      connect(@page, SIGNAL('loadFinished(bool)'),
#              self, SLOT('loadFinished(bool)'))
#      connect(@page.page, SIGNAL('linkClicked(QUrl)'),
#              self, SLOT('load(QUrl)'))

#   @page.load(Qt::Url.new("http://www.google.com"))



#      @page.setUrl("fddsfadf") 
#       puts Plasma.instance_methods
#puts "\n\button.methods : "+ button.methods.sort.join("\n").to_s+"\n\n" 
#puts "\n\b@page.methods : "+ @page.methods.sort.join("\n").to_s+"\n\n" 
#  mousePressEvent
      
#--------------------------------------------------
#       @labels = parsexml
#       @labels.each do |label_text|
#          @label = Plasma::Label.new self
#          @label.text = label_text
#          layout.add_item @label
#       end
# 
#-------------------------------------------------- 
      #@label.text = titles[2]
      parsexml

#      neco = KIO::storedGet(KDE::Url.new("http://www.sigut.net/fotky/obr1500.jpg"), KIO::Reload, KIO::HideProgressInfo)

#       image = Plasma::IconWidget.new self
#       image.setIcon(KDE::Url.new("http://www.sigut.net/fotky/obr1500.jpg"))

       KIO::NetAccess::download((KDE::Url.new("http://www.google.ca/index.html")), tmpx)

#      obr = Net::HTTP.get_response(URI.parse('http://www.sigut.net/fotky/obr1500.jpg')).body
 #     image.setIcon(obr)
      

#      $LOG = Logger.new('log_file.log', 'monthly')
#      debug(titles)

      
      #@label.text = @titles[@i]
  
      
      layout.add_item @label

      layout.add_item button
      
      #layout.add_item web

      self.layout = layout
 
      resize 125, 125
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
      doc.elements.each("Document/*") do |element|
        case element.name
        when "label"
          @label = Plasma::Label.new self
          @label.text = element.text
          layout.add_item @label
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
