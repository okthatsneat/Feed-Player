require 'spec_helper'

describe "feeds/show" do
  before(:each) do
    @feed = assign(:feed, stub_model(Feed,
      :url => "Url",
      :title => "Title",
      :feed_url => "Feed Url",
      :etag => "Etag"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Url/)
    rendered.should match(/Title/)
    rendered.should match(/Feed Url/)
    rendered.should match(/Etag/)
  end
end
