Toshokan::Application.routes.draw do

  scope "(:locale)", :locale => /en|da/ do
    Blacklight.add_routes(self)

    match '/login',                   :to => 'users/sessions#new',       :as => 'new_user_session'
    match '/auth/:provider/callback', :to => 'users/sessions#create',    :as => 'create_user_session'
    match '/logout',                  :to => 'users/sessions#destroy',   :as => 'destroy_user_session'
    match '/mylibrary/profile',       :to => 'users/sessions#edit',      :as => 'edit_user_registration'
    match '/user/switch',             :to => 'users/sessions#switch',    :as => 'switch_user'
    match '/user/session'                 => 'users/sessions#update',    :as => 'user_session',         :via => :put
    match '/cover_images/:id',        :to => 'cover_images#show',        :as => 'cover_images'
    match '/auth',                    :to => 'auth_provider#index',      :as => 'select_auth_provider', :via => :get
    match '/auth',                    :to => 'auth_provider#create',     :as => 'set_auth_provider',    :via => :post
    match '/advanced',                :to => 'catalog#advanced',         :as => 'advanced'
    match '/come_back_later',         :to => 'come_back_later#index',    :as => 'come_back_later'

    # Show form for order creation
    match '/orders/',                 :to => 'orders#new',               :as => 'new_order',            :via => :get

    # Create a new order
    match '/orders/',                 :to => 'orders#create',            :as => 'create_order',         :via => :post

    # Update an order
    match '/orders/',                 :to => 'orders#update',            :as => 'update_order',         :via => :put

    # View order
    
    # For DIBS callback upon cancel
    match '/orders/:uuid/cancel',       :to => 'orders#cancel',            :as => 'order_cancel'

    # For DIBS callback upon successful authorization
    match '/orders/:uuid/receipt',      :to => 'orders#receipt',          :as => 'order_receipt'

    # For DocDel callback about delivery status
    match '/orders/:uuid/delivery',     :to => 'orders#delivery',          :as => 'order_delivery'

    # For order status
    match '/orders/:uuid/status',       :to => 'orders#status',            :as => 'order_status',       :via => :get

    # Payment page for testing - it just redirects to its callback parameter
    match '/test_payment',              :to => 'payment#credit_card',      :as => 'payment',            :via => :post

    # Temp fix since BL 4.1 removed the POST route to feedback (but BL's code still seems to rely on it).
    match '/feedback',                :to => 'feedback#show',            :as => 'feedback',             :via => :post

    # DTIC librarian assistance (create redmine issues)
    match '/cant_find/assistance/:genre',      :to => 'cant_find#assistance',     :as => 'dtic_assistance',    :via => :post

    # Can't find forms
    match '/cant_find/:genre',          :to => 'cant_find#index',          :as => 'cant_find',          :via => :get

    resources :documents, :only => [] do
      resources :tags, :except => [:edit, :update]
    end
    resources :tags, :only => [:edit, :update, :destroy]
    match 'tags'                          => 'tags#manage',              :as => 'manage_tags'

    resources :users, :only => [:index, :update, :destroy]

    get '/alerts/find/', :to => "alerts#find"
    resources :alerts, :except => [:edit, :update]

    match '/pages/searchbox', :to => 'pages#searchbox', :as => 'searchbox'
    match '/pages/search_homepage', :to => 'pages#searchbox_styled', :as => 'searchbox_styled'

    put '/search_history/save/:id', :to => 'search_history#save', :as => 'save_search'
    put '/search_history/alert/:id', :to => 'search_history#alert', :as => 'save_search_alert'
    delete '/search_history/forget/:id', :to => 'search_history#forget', :as => 'forget_search'
    delete '/search_history/forget_alert/:id', :to => 'search_history#forget_alert', :as => 'forget_search_alert'
    delete '/search_history/:id', :to => 'search_history#destroy', :as => 'delete_search_history'
  end

  match '/:locale' => 'catalog#index'
  root :to => "catalog#index"

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
