require 'spec_helper'

describe "/themes/colors" do
  before(:each) do
    assigns[:colors] = %w(  #888888 #DDDDDD #555555 #A8A8A8 #CCCCCC #999999 #222222 #FFFFFF )
  end

  it "renders a css file" do
    render 'themes/colors.css.erb'
    response.should =~  /background-color: #999999;/
  end
end
