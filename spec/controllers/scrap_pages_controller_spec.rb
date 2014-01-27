require 'spec_helper'

describe ScrapPagesController do

  describe "GET 'feed'" do
    it "returns http success" do
      get 'feed'
      response.should be_success
    end
  end

  describe "GET 'scrape'" do
    it "returns http success" do
      get 'scrape'
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
