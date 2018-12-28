class HomeController < ApplicationController
  def index
    @book = Book.all
  end
  

end