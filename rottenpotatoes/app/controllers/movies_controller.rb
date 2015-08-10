class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    sort = params[:sort] || session[:sort]
    case sort
      when 'title'
        ordering,@title_header = {:order => :title}, 'hilite'
      when 'release_date'
        ordering,@date_header = {:order => :release_date}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}

    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end

    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)

    begin
      r = @selected_ratings.keys
      o = ordering && ordering[:order]
      case ENV['version']
        when '1'
          r = %w( PG R )
        when '2'
          r = %w( G PG-13 )
        when '3'
          r = %w( )
        when '4'
          r = %w( G PG PG-13 R )
        when '11'
          o = :release_date
        when '12'
          o = :title
      end
      @selected_ratings = {}
      ordering = o
      r.each {|rating| @selected_ratings[rating.to_s] = "1"}
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)

    case ENV['version']
      when '10'
        @movies.to_a.reverse!
    end
  end

  def shuffle(array)
    if array.nil? || array.length < 1
      return array
    end
    new_array = array.shuffle
    while (new_array == array)
      new_array = array.shuffle
    end
    return new_array
  end

  def swap(array, index1, index2)
    if array.nil? || array.length < 1
      return
    end
    temp = array[index1]
    array[index1] = array[index2]
    array[index2] = temp
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
