# == Schema Information
# Schema version: 20091030224557
#
# Table name: content_pages
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  body       :text          
#  special    :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
# End Schema

class ContentPage < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :categories

  class << self
    def find_or_create_by_name(name)
      cp = find_by_name(name)
      cp || ContentPage.create( :name => name, :body => "<p>TO DO: edit this page</p>" )
    end

    def get_side_menu
      find(:first, :conditions => { :special => 'Side Menu'}) ||
        create( :special => 'Side Menu', :name => 'Side Menu', 
          :body => "<h3>Menu</h3>\n[[ListCategories WithHome]]" )
    end

    def get_top_menu
      find(:first, :conditions => { :special => 'Top Menu'}) ||
        create( :special => 'Top Menu', :name => 'Top Menu', :body => "[[ListCategories]]" )
    end

    def get_front_page
      find(:first, :conditions => { :special => 'Front Page'}) ||
        create( :special => 'Front Page', :name => 'Welcome to the Site', :body => "<p>To do: edit this page</p>" )
    end


    # functions:
    #   ListCategories    // lists all categories
    #   ListPagesInCategory Some Kind of Category    // list all pages in the category called "Some Kind of Category"
    #   LinkPage Page Name  // links directly to the page specified
    #   LinkCategory Some Kind of Category    // links to the category index page
    def function(function_string)
      function_name, param = function_string.split(' ', 2)
      case function_name.downcase
      when "listcategories"
        categories = Category.find(:all)
        out = "<ul>\n"

        if param and param.downcase == "withhome"
          out += "<li><a href=\"/\">Home</a></li>\n"
        end

        if categories.empty?
          out += "<li><em>No categories were found</em></li>\n"
        else
          out += categories.map { |cat|
            "<li><a href=\"/categories/#{cat.id}\">#{cat.name}</a></li>"
          }.join("\n")
        end

        out += "</ul>\n"
        out
      when "listpagesincategory"
        category = Category.find_by_name param
        out = "<ul>\n"

        if category
          pages = category.content_pages
          if pages.empty?
              out += "<li><em>No pages were found in the category: #{param}</em></li>\n"
          else
            out += pages.map { |page|
              "<li><a href=\"/content_pages/#{page.id}\">#{page.name}</a></li>"
            }.join("\n")
          end

          out += "</ul>\n"
          out
        else
          ""
        end
      when "linkpage"
        page = ContentPage.find_by_name param

        if page
          "<a href=\"/content_pages/#{page.id}\">#{page.name}</a>"
        else
          "<em>No page found named: #{param}</em>"
        end
      when "linkcategory"
        category = Category.find_by_name param

        if category
          "<a href=\"/categories/#{category.id}\">#{category.name}</a>"
        else
          "<em>No category found named: #{param}</em>"
        end
      else
        "<em>Unknown function: #{function_name}</em>"
      end
    end
  end

  def body_for_display
    body.gsub( /(\[\[([^\]]*)\]\])/ ) { |s| ContentPage.function($2) }
  end
end