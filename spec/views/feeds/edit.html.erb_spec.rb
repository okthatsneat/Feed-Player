require 'spec_helper'

describe "feeds/edit" do
  before(:each) do
    @feed = assign(:feed, stub_model(Feed,
      :url => "MyString",
      :title => "MyString",
      :feed_url => "MyString",
      :etag => "MyString"
    ))
  end

  it "renders the edit feed form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => feeds_path(@feed), :method => "post" do
      assert_select "input#feed_url", :name => "feed[url]"
      assert_select "input#feed_title", :name => "feed[title]"
      assert_select "input#feed_feed_url", :name => "feed[feed_url]"
      assert_select "input#feed_etag", :name => "feed[etag]"
    end
  end
end
