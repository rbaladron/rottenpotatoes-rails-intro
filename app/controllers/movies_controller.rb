class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
     #id = params [:id]           # retrieve movie ID from URI route 
     #@movie = Movie.find(id)     # look up movie by unique ID
     # whill render app/views/movies/show.html.haml by default
     @movie = Movie.find(params[:id])
  end

  def index
    if(!params.has_key?(:sort) && !params.has_key?(:ratings))
      if(session.has_key?(:sort) || session.has_key?(:ratings))
        redirect_to movies_path(:sort=>session[:sort], :ratings=>session[:ratings])
      end
    end
    @sort = params.has_key?(:sort) ? (session[:sort] = params[:sort]) : session[:sort]
    @all_ratings = Movie.all_ratings.keys
    @ratings = params[:ratings]
    if(@ratings != nil)
      ratings = @ratings.keys
      session[:ratings] = @ratings
    else
      if(!params.has_key?(:commit) && !params.has_key?(:sort))
        ratings = Movie.all_ratings.keys
        session[:ratings] = Movie.all_ratings
      else
        ratings = session[:ratings].keys
      end
    end
    #@movies = Movie.order(@sort).find_all_by_rating(ratings) ==> no funciona en Rails 5
    @movies = Movie.order(@sort).where(rating: ratings)
    @mark  = ratings

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def find_class(header)
    params[:sort] == header ? 'hilite' : nil
  end
  helper_method :find_class
  
  private
    def movie_params #:title, :rating, :description, :release_date
      params.require(:movie).permit(:title, :rating, :description, :release_date )
    end
    
    def check
      if params[:ratings]
        params[:ratings].keys
      else
        @all_ratings
      end
    end

end
