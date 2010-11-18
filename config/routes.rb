Videogames::Application.routes.draw do
  resources :tags
  root :to=>'games#index'
  match '/tags',:to=>'tags#index'
  resources :games
  match '/games/destroy',:to=>'games#destroy'
  match '/tags/destroy',:to=>'tags#destroy'
  match '/getgameinfo',:to=>'games#getgameinfo'
  match '/getsearchresults',:to=>'games#getsearchresults'
  match '/getparenttags',:to=>'games#getparenttags'
  match '/search',:to=>'games#searchgames'
  match '/results',:to=>'games#searchresults'
  match '/searchimages',:to=>'games#searchimages'
  match '/browse',:to=>'games#browse'
  match '/loadnewgames',:to=>'games#load_new_games'
end
