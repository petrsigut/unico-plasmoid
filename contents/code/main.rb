# GPLv3
require 'plasma_applet'
#require 'Qt4'
require 'korundum4'
require "qtwebkit"

# pro stahnuti a parsovani xmlka
require 'net/http'
require 'rexml/document'

require 'logger'

#
require 'tempfile'

module RubyWidget
  # PlasmaScripting::Applet - for GHNS
  class Main < PlasmaScripting::Applet
# The both slots used by our applet.
#    slots 'load(QUrl)',
#          'loadFinished(bool)',
#          :paserxml
    slots :check_new_data

    def initialize parent
      super parent
    end
 
    def init
      #Qt.debug_level = Qt::DebugLevel::High
      self.has_configuration_interface = true
      self.aspect_ratio_mode = Plasma::IgnoreAspectRatio
      self.background_hints = Plasma::Applet.DefaultBackground
 
      @layout = Qt::GraphicsLinearLayout.new Qt::Vertical, self

      @tmp_data = ""
      configChanged
      reload_content

      #data = Plasma::ToolTipContent.new
      #data.mainText = "My Title"
      #data.subText = "My Title"
      #button = Plasma::PushButton.new self
      #button.text = "Hi"

        self.layout = @layout

     # resize 125, 125
    end
    
    #http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails
    def validate(url)
      errors = false # tady by se chtelo asi naucit pracovat s podminkama    
      begin
        uri = URI.parse(url)
        if uri.class != URI::HTTP
          puts 'XXXOnly HTTP protocol addresses can be used'
          errors = true
        end
        rescue URI::InvalidURIError
          puts 'XXXThe format of the url is not valid.'
          errors = true
        end
      return errors
    end
  
    def validate_download(url)
      errors = false
      uri = URI.parse(url)
      begin
        case Net::HTTP.get_response(uri)
          when Net::HTTPSuccess then errors = false
          else errors = true
        end
      rescue
        errors = true
        puts "rescue jak cyp"
      end
      return errors
    end

    def reload_content
      timer = Qt::Timer.new(parent)
      connect(timer, SIGNAL('timeout()'), self, SLOT(:check_new_data))
      timer.start(@interval * 1000 * 60) # in minutes
      puts "setting timer"
    end

    def decide_what_to_show(errors=false)
     unless errors
        extension = @url_to_show.split('.').last.split('?').first

        case extension
        when "xml"
          show_xml
        when "html"
          show_html
        else
          show_html
        end
      else
        show_configure_me
      end

    end

    
    def configChanged
      # http://techbase.kde.org/Development/Tutorials/Using_KConfig_XT
      config = self.config
      configGroup = config.group('url')
      # pozor na to aby tam byl nil, ne "nil":)
      @url_to_show = configGroup.readEntry('contentUrl', 'nil')
      @interval = configGroup.readEntry('interval', 1)


      # test if the url could be downloaded
      errors = validate(@url_to_show)
      errors = validate_download(@url_to_show)

      check_new_data
      decide_what_to_show(errors)
      
    end

    def show_configure_me
      reset_layout
      @label = Plasma::Label.new self
      @label.text = "URL is strange, please reconfigure"
      @layout.add_item @label
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

    # should call validate_download first!
    def check_new_data
      # http://www.devdaily.com/blog/post/ruby/ruby-how-write-to-a-temporary-file
      #
      # we just cache the text - that means url to image, not the image itself
      
      # 
      errors = validate_download(@url_to_show)
      
      unless errors
        # get the data as a string
        new_data = Net::HTTP.get_response(URI.parse(@url_to_show)).body
        puts "Checking new data"+Time.now.to_s

        #puts "TENHLE SOUBOR"
        #puts @tmp_file.path
        #tmp_data = IO.read(@tmp_file.path)

        # data we downloaded are newer
        if new_data != @tmp_data
          # write new data to cache tmp file
          #open(@tmp_file.path, File::TRUNC) {}
          #@tmp_file << new_data
          #@tmp_file.flush
          #puts "novy obsah do tmpfilu"
          @tmp_data = new_data
          puts "cache is different, rendering new data"
          
          @data_to_show = new_data
          decide_what_to_show
        else
          puts "no really new data"
        end

        
        # we should delete tmp file after exiting plasmoid? Better than exiting
        # - deleting from workspace, so we will have some content after restart
        # and no connection

        # http://labs.trolltech.com/blogs/2008/08/04/network-cache/
        # would be better to use QT cache
      end



    end

    def show_xml
      reset_layout
      puts "Showing XML"

      # extract event information
      doc = REXML::Document.new(@data_to_show)
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

      puts "Showing HTML"
      
      @web = Plasma::WebView.new()
      @web.setHtml(@data_to_show)
      @layout.add_item @web
      puts "X"
      puts @web
#      self.layout = @layout
       
    end

  end
end
