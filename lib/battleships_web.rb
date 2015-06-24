require 'sinatra/base'
require 'battleships'

class BattleshipsWeb < Sinatra::Base
  set :views, proc { File.join(root, '..', 'views') }

  get '/' do # how much do we want to do on the landing page?
    $game = Game.new(Player,Board)
    erb :index
  end

  get '/new_game' do # perhaps "register" - what do we want to do with names? Should we take names from two-players, too, if using sessions?
    @player = params[:name]
    erb :new_game
  end

  get '/setup_game' do # pack away into a helper, and maybe do earlier (when 1 player game is requested?)
    $game.player_2.place_ship(Ship.battleship, :A1, :vertically)
    $game.player_2.place_ship(Ship.aircraft_carrier, :C1, :vertically)
    $game.player_2.place_ship(Ship.cruiser, :E1, :vertically)
    $game.player_2.place_ship(Ship.destroyer, :G1, :vertically)
    $game.player_2.place_ship(Ship.submarine, :I1, :vertically)
    redirect '/play_game'
  end

  get '/play_game' do # perhaps /1_player_game - all gameplay is on this site?
    @board = $game.opponent_board_view $game.player_1
    erb :play_game
  end

  post '/play_game' do # or just /1_player
    @coord = params[:coord]
    if @coord && @coord != ""
      begin
        @status = $game.player_1.shoot @coord.to_sym
      rescue
        @status = 'You have already hit that coordinate or it is not on the board!'
      end
    end
    redirect '/victory' if $game.has_winner?
    @board = $game.opponent_board_view $game.player_1
    erb :play_game
  end

  get '/victory' do # possible to combine with 2-player victory page? (use sessions to pull up name / player number?)
    erb :victory
  end

  get '/new_game_21' do # /place_ships - in theory this should be the same page for all ship placement, apart from appelation (saved in session?) and where we will want to save the POST output (i.e. whose board we place the ships on)
    erb :new_game_21
  end

  post '/new_game_21' do # combine with other POST placement pages - if player == player_2, or == player_1, or if it's a single player game...?
    $game.player_1.place_ship(Ship.battleship, params[:sub_coords], params[:sub_dir])
    redirect '/new_game_22'
  end

  get '/new_game_22' do # combine with above? abstract into a helper?
    erb :new_game_22
  end

  post '/new_game_22' do # combine with above?
    $game.player_2.place_ship(Ship.battleship, params[:sub_coords], params[:sub_dir])
    redirect '/play_game_21'
  end

  get '/play_game_21' do # perhaps "/2_player" this is where all the 2_player gameplay is
    @message = 'Player 1, choose coordinate to fire!'
    @board = $game.opponent_board_view $game.player_1
    erb :play_game_21
  end

  post '/play_game_21' do
    @result = $game.player_1.shoot(params[:hit_coord].to_sym)
    @board = $game.opponent_board_view $game.player_1
    redirect '/victory2' if $game.has_winner?
    if @result == :hit || @result == :sunk
      @message = 'Well done! That was a hit!'
    else
      @message = 'Sorry, that was a miss!'
    end
    erb :play_game_21
  end

  get '/play_game_22' do
    @message = 'Player 2, choose coordinate to fire!'
    @board = $game.opponent_board_view $game.player_2
    erb :play_game_22
  end

  post '/play_game_22' do
    @result = $game.player_2.shoot(params[:hit_coord].to_sym)
    @board = $game.opponent_board_view $game.player_2
    redirect '/victory2' if $game.has_winner?
    if @result == :hit || @result == :sunk
      @message = 'Well done! That was a hit!'
    else
      @message = 'Sorry, that was a miss!'
    end
    erb :play_game_22
  end

  get '/victory2' do
    @winner = 'Player 1' if $game.player_1.winner?
    @winner = 'Player 2' if $game.player_2.winner?
    erb :victory2
  end

  run! if app_file == $0
end
