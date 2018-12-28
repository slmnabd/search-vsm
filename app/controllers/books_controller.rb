class BooksController < ApplicationController
  
  def index
    @book = Book.all
  end

  def new
    @book = Book.new
  end

  def show
    @book = Book.find(params[:id])
  end

  def create
    @book = Book.new(resource_params)
    if @book.save
      redirect_to books_path
    else
      render 'new'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    @book.update(resource_params)
    redirect_to books_path(@book)
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path(@book)
  end
  


  private
  def resource_params
    params.require(:book).permit(:title, :author, :category, :synopsis)
  end

end