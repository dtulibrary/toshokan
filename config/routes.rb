Toshokan::Application.routes.draw do

  scope "(:locale)", :locale => /en|da/ do
    Blacklight.add_routes(self)

    get   '/journal',                 :to => 'catalog#journal',          :as => 'catalog_journal'

    match '/login',                   :to => 'users/sessions#new',       :as => 'new_user_session'
    match '/auth/:provider/callback', :to => 'users/sessions#create',    :as => 'create_user_session'
    match '/auth/:provider/setup',    :to => 'users/sessions#setup',     :as => 'setup_user_session'
    match '/logout',                  :to => 'users/sessions#destroy',   :as => 'destroy_user_session'
    match '/mylibrary/profile',       :to => 'users/sessions#edit',      :as => 'edit_user_registration'
    match '/user/switch',             :to => 'users/sessions#switch',    :as => 'switch_user'
    match '/user/session'                 => 'users/sessions#update',    :as => 'user_session',         :via => :put
    match '/cover_images/:id',        :to => 'cover_images#show',        :as => 'cover_images'
    match '/advanced',                :to => 'catalog#advanced',         :as => 'advanced'

    # Order creation
    resources :orders, :only => [:new, :create, :update]

    # DIBS callbacks - receipt doubles as DIBS callback and DIBS receipt
    post '/orders/:uuid/cancel',   :to => 'orders#cancel',   :as => 'order_cancel'
    post '/orders/:uuid/receipt',  :to => 'orders#receipt',  :as => 'order_receipt'
    get  '/orders/:uuid/receipt',  :to => 'orders#receipt',  :as => 'order_receipt'

    # DocDel callback
    get  '/orders/:uuid/delivery', :to => 'orders#delivery', :as => 'order_delivery'

    # Status and reordering
    get  '/orders/:uuid/status',   :to => 'orders#status',   :as => 'order_status'
    get  '/orders/:uuid/reorder',  :to => 'orders#reorder',  :as => 'order_reorder'
    
    # Payment page for testing - it just redirects to its callback parameter
    post '/test_payment',              :to => 'payment#credit_card',      :as => 'payment'

    # Temp fix since BL 4.1 removed the POST route to feedback (but BL's code still seems to rely on it).
    post '/feedback',                  :to => 'feedback#show',            :as => 'feedback'

    # Resolver (populates can't find forms on zero hits)
    get '/resolve',                   :to => 'resolver#index',           :as => 'resolve'

    resources :assistance_requests, :only => [:index, :new, :create, :show]

    # Redirect old can't find links to assistance request links
    get   '/cant_find/:genre',          :to => redirect('/assistance_requests/new?genre=%{genre}')

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
    get '/search_history/saved', :to => 'search_history#saved', :as => 'saved_searches'
    get '/search_history/alerted', :to => 'search_history#alerted', :as => 'alerted_searches'
  end

  match '/:locale' => 'catalog#index'
  root :to => "catalog#index"
end
