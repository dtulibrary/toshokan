Toshokan::Application.routes.draw do

  scope "(:locale)", :locale => /en|da/ do

    # Catalog and related
    Blacklight.add_routes(self)
    get   '/journal',                           :to => 'catalog#journal',               :as => 'catalog_journal'
    get   '/cover_images/:id',                  :to => 'cover_images#show',             :as => 'cover_images'
    get   '/advanced',                          :to => 'catalog#advanced',              :as => 'advanced'


    # Authentication
    get   '/login',                             :to => 'users/sessions#new',            :as => 'new_user_session'
    get   '/auth/:provider/callback',           :to => 'users/sessions#create',         :as => 'create_user_session'
    get   '/auth/:provider/setup',              :to => 'users/sessions#setup',          :as => 'setup_user_session'
    get   '/logout',                            :to => 'users/sessions#destroy',        :as => 'destroy_user_session'
    get   '/user/switch',                       :to => 'users/sessions#switch',         :as => 'switch_user'
    put   '/user/session',                      :to => 'users/sessions#update',         :as => 'user_session'


    # Orders
    resources :orders, :only => [:new, :create, :update]
    get  '/orders/:uuid/status',                :to => 'orders#status',                 :as => 'order_status'
    get  '/orders/:uuid/reorder',               :to => 'orders#reorder',                :as => 'order_reorder'
    post '/orders/:uuid/cancel',                :to => 'orders#cancel',                 :as => 'order_cancel'   # DIBS callback
    post '/orders/:uuid/receipt',               :to => 'orders#receipt',                :as => 'order_receipt'  # DIBS callback
    get  '/orders/:uuid/receipt',               :to => 'orders#receipt',                :as => 'order_receipt'
    get  '/orders/:uuid/delivery',              :to => 'orders#delivery',               :as => 'order_delivery' # DocDel callback
    post '/test_payment',                       :to => 'payment#credit_card',           :as => 'payment'


    # Assistance (Can't Find) forms
    resources :assistance_requests,             :only => [:index, :new, :create, :show]
    get   '/cant_find/:genre',                  :to => redirect('/assistance_requests/new?genre=%{genre}')
    get   '/resolve',                           :to => 'resolver#index',                :as => 'resolve'


    # Tags and Bookmarks
    resources :documents, :only => [] do
      resources :tags,                          :except => [:edit, :update]
    end
    resources :tags,                            :only => [:edit, :update, :destroy]
    get   'tags',                               :to => 'tags#manage',                   :as => 'manage_tags'


    # Alerts
    get   '/alerts/find/',                      :to => "alerts#find"
    resources :alerts,                          :except => [:edit, :update]


    # Search history
    put    '/search_history/save/:id',          :to => 'search_history#save',           :as => 'save_search'
    put    '/search_history/alert/:id',         :to => 'search_history#alert',          :as => 'save_search_alert'
    delete '/search_history/forget/:id',        :to => 'search_history#forget',         :as => 'forget_search'
    delete '/search_history/forget_alert/:id',  :to => 'search_history#forget_alert',   :as => 'forget_search_alert'
    delete '/search_history/:id',               :to => 'search_history#destroy',        :as => 'delete_search_history'
    get    '/search_history/saved',             :to => 'search_history#saved',          :as => 'saved_searches'
    get    '/search_history/alerted',           :to => 'search_history#alerted',        :as => 'alerted_searches'


    # User management
    resources :users,                           :only => [:index, :update, :destroy]


    # Semi-static pages
    get   '/pages/searchbox',                   :to => 'pages#searchbox',               :as => 'searchbox'
    get   '/pages/search_homepage',             :to => 'pages#searchbox_styled',        :as => 'searchbox_styled'
    get   '/about',                             :to => 'pages#about'


    # Temporary fix since BL 4.1 removed the POST route to feedback (but BL's code still seems to rely on it).
    post  '/feedback',                          :to => 'feedback#show',                 :as => 'feedback'

    get   '/',                                  :to => 'catalog#index'
  end
  root :to => "catalog#index"
end
