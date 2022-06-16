class BooksController < ApplicationController
   impressionist :action => [:show,:index]

  def show
    @book = Book.find(params[:id])
    @books = Book.all
    @book_new = Book.new
    @user = @book.user
    @book_comment = BookComment.new
    impressionist(@book,nil,unique:[:session_hash.to_s])
  end

  def index
    @book_new = Book.new
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorited_users).sort{|a,b| b.favorited_users.where(created_at: from...to).size <=> a.favorited_users.where(created_at: from...to).size}
    @rank_books = Book.order(impressions_count: "DESC")
    @book = Book.find(params[:id])
    impressionist(@book,nil,unique:[:session_hash.to_s])
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    @books = Book.all
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
      render :edit
    else
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title,:body)
  end
end
