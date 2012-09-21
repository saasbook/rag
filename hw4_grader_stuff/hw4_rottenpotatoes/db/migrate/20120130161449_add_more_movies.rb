class AddMoreMovies < ActiveRecord::Migration
  MORE_MOVIES = [
    {:title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992'},
    {:title => 'The Terminator', :rating => 'R', :release_date => '26-Oct-1984'},
    {:title => 'When Harry Met Sally', :rating => 'R', :release_date => '21-Jul-1989'},
    {:title => 'The Help', :rating => 'PG-13', :release_date => '10-Aug-2011'},
    {:title => 'Chocolat', :rating => 'PG-13', :release_date => '5-Jan-2001'},
    {:title => 'Amelie', :rating => 'R', :release_date => '25-Apr-2001'},
    {:title => '2001: A Space Odyssey', :rating => 'G', :release_date => '6-Apr-1968'},
    {:title => 'The Incredibles', :rating => 'PG', :release_date => '5-Nov-2004'},
    {:title => 'Raiders of the Lost Ark', :rating => 'PG', :release_date => '12-Jun-1981'},
    {:title => 'Chicken Run', :rating => 'G', :release_date => '21-Jun-2000'},
  ]
  def up
    MORE_MOVIES.each do |movie|
      Movie.create!(movie)
    end
  end

  def down
    MORE_MOVIES.each do |movie|
      Movie.find_by_title_and_rating(movie[:title], movie[:rating]).destroy
    end
  end
end
