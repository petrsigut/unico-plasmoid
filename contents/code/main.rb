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
      
       data = Plasma::ToolTipContent.new
       data.mainText = "My Title"
       data.subText = "My Title"

      button = Plasma::PushButton.new self
      button.text = "Hi"

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
      
      #@titles = parsexml
      #titles.each do |title|
      #   @label.text = "#{title}"
      #end
      #@label.text = titles[2]

#      $LOG = Logger.new('log_file.log', 'monthly')
#      debug(titles)
#      $LOG.error @titles

      
      #@label.text = @titles[@i]
  
      
      layout.add_item @label

      layout.add_item button
      
     layout.add_item web

      self.layout = layout
 
      resize 125, 125
    end

    def parsexml
      # Web search for "madonna"
      url = 'http://localhost:3000/movies/feed.rss'
      #url = 'http://api.search.yahoo.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=madonna&results=2'

      # get the XML data as a string
      xml_data = Net::HTTP.get_response(URI.parse(url)).body

      # extract event information
      doc = REXML::Document.new(xml_data)
      titles = []
      links = []
      doc.elements.each('rss/channel/item/title') do |ele|
         titles << ele.text
      end
      @delka =titles.length
#      doc.elements.each('ResultSet/Result/item') do |ele|
#         links << ele.text
#      end

      # print all events
#--------------------------------------------------
#       titles.each_with_index do |title, idx|
#          print "#{title} => #{links[idx]}\n"
#       end
#-------------------------------------------------- 
      titles

    end

  end
end
