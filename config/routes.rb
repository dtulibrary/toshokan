Toshokan::Application.routes.draw do
  root :to => "catalog#index"

  Blacklight.add_routes(self)

  match '/login',                   :to => 'users/sessions#new',       :as => 'new_user_session'
  match '/auth/:provider/callback', :to => 'users/sessions#create',    :as => 'create_user_session'
  match '/logout',                  :to => 'users/sessions#destroy',   :as => 'destroy_user_session'
  match '/mylibrary/profile',       :to => 'users/sessions#edit',      :as => 'edit_user_registration'
  match '/user/switch',             :to => 'users/sessions#switch',    :as => 'switch_user'
  match '/user/session'                 => 'users/sessions#update',    :as => 'user_session', :via => :put
  match '/cover_images/:id',        :to => 'cover_images#show',        :as => 'cover_images'
  match '/auth',                    :to => 'auth_provider#index',      :as => 'select_auth_provider', :via => :get
  match '/auth',                    :to => 'auth_provider#create',     :as => 'set_auth_provider',    :via => :post

  resources :documents, :only => [] do
    resources :tags, :except => [:edit, :update]
  end
  resources :tags, :only => [:edit, :update, :destroy]
  match 'tags'                          => 'tags#manage',              :as => 'manage_tags'

  resources :users, :only => [:index, :update, :destroy]
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
