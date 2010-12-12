Videogames::Application.routes.draw do
  resources :tags,:games
  root :to=>'games#index'
  match '/tags',:to=>'tags#index'

  match '/games/getsearchresults/:q/:site',:to=>'games#getsearchresults'
  match '/getcommontags/:game1/:game2',:to=>'games#getcommontags'
  match '/results',:to=>'games#recommend_search'
  match '/searchimages',:to=>'games#searchimages'
  match '/browse',:to=>'games#browse'
  match '/loadnewgames/:id/:offset',:to=>'games#load_new_games'
  match '/mass_delete',:to=>'games#mass_delete',:via=>:post
  match '/dissociate/:game/:tag',:to=>'tags#dissociate'
  match '/associate',:to=>'tags#associate',:via=>:post
  match ':controller/:action/:id'
  match ':controller/:action'
end
