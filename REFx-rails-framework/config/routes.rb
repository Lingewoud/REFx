ActionController::Routing::Routes.draw do |map|


  map.resources :jobs, :collection => { :destroyall => :delete }, :member => { :runagain => :get}
  map.resources :refx_admin, :collection => { :flushlog => :flushlog }
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => "welcome"  



end
