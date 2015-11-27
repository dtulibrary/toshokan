Toshokan::Application.routes.draw do

  mount DtuBlacklightCommon::Engine, at: '/'

  scope "(:locale)", :locale => /en|da/ do

    # Catalog and related
    Blacklight.add_routes(self)
    get   '/metadata/:id',                          :to => 'metadata#show',                         :as => 'metadata'
    get   '/journal',                               :to => 'catalog#journal',                       :as => 'catalog_journal'
    get   '/mendeley',                              :to => 'catalog#mendeley_index',                :as => 'mendeley_index'
    get   '/mendeley/:id',                          :to => 'catalog#mendeley_show',                 :as => 'mendeley_show'
    post  '/mendeley',                              :to => 'catalog#mendeley_index_save',           :as => 'mendeley_index_save'
    post  '/mendeley/:id',                          :to => 'catalog#mendeley_show_save',            :as => 'mendeley_show_save'
    get   '/cover_images/:id',                      :to => 'cover_images#show',                     :as => 'cover_images'
    get   '/progress/:name',                        :to => 'progress#show',                         :as => 'show_progress'

    # Mendeley oauth
    get   '/auth/mendeley/login',                   :to => 'mendeley/sessions#new',                 :as => 'new_mendeley_session'
    get   '/auth/mendeley/callback',                :to => 'mendeley/sessions#create',              :as => 'create_mendeley_session'
    get   '/auth/mendeley/setup',                   :to => 'mendeley/sessions#setup',               :as => 'setup_mendeley_session'

    # Authentication
    get   '/login',                                 :to => 'users/sessions#new',                    :as => 'new_user_session'
    get   '/auth/:provider/callback',               :to => 'users/sessions#create',                 :as => 'create_user_session'
    get   '/auth/:provider/setup',                  :to => 'users/sessions#setup',                  :as => 'setup_user_session'
    get   '/logout',                                :to => 'users/sessions#destroy',                :as => 'destroy_user_session'
    get   '/logout_login_as_dtu',                   :to => 'users/sessions#logout_login_as_dtu',    :as => 'logout_login_as_dtu'
    get   '/user/switch',                           :to => 'users/sessions#switch',                 :as => 'switch_user'
    put   '/user/session',                          :to => 'users/sessions#update',                 :as => 'user_session'


    # Orders
    resources :orders, :only => [:index, :new, :create, :update]
    get  '/orders/:uuid/status',                    :to => 'orders#status',                         :as => 'order_status'
    get  '/orders/:uuid/reorder',                   :to => 'orders#reorder',                        :as => 'order_reorder'
    post '/orders/:uuid/cancel',                    :to => 'orders#cancel',                         :as => 'order_cancel'   # DIBS callback
    post '/orders/:uuid/receipt',                   :to => 'orders#receipt',                        :as => 'dibs_order_receipt'  # DIBS callback
    get  '/orders/:uuid/receipt',                   :to => 'orders#receipt',                        :as => 'order_receipt'
    get  '/orders/:uuid/delivery',                  :to => 'orders#delivery',                       :as => 'order_delivery' # DocDel callback
    get  '/orders/:uuid/resend',                    :to => 'orders#resend',                         :as => 'order_resend_library_support'
    post '/test_payment',                           :to => 'payment#credit_card',                   :as => 'payment'


    # Assistance (Can't Find) forms
    resources :assistance_requests,                 :only => [:index, :new, :create, :show]
    get   '/assistance_requests/:id/resend',        :to => 'assistance_requests#resend',            :as => 'assistance_request_resend_library_support'
    get   '/cant_find/:genre',                      :to => redirect('/assistance_requests/new?genre=%{genre}')


    # OpenURL resolver
    get   '/resolve',                               :to => 'resolver#index',                :as => 'resolve'


    # Tags and Bookmarks
    resources :documents, :only => [] do
      resources :tags,                              :except => [:edit, :update]
    end
    resources :tags,                                :only => [:edit, :update, :destroy]
    get   'tags',                                   :to => 'tags#manage',                           :as => 'manage_tags'


    # Suggestions
    get   '/suggest/spelling',                      :to => "suggestions#spelling"
    get   '/suggest/completion',                    :to => "suggestions#completion"

    # Alerts
    get   '/alerts/find/',                          :to => "alerts#find"
    resources :alerts,                              :except => [:edit, :update]


    # Search history
    put    '/search_history/save/:id',              :to => 'search_history#save',                   :as => 'save_search_history'
    put    '/search_history/alert/:id',             :to => 'search_history#alert',                  :as => 'alert_search_history'
    delete '/search_history/forget/:id',            :to => 'search_history#forget',                 :as => 'forget_search_history'
    delete '/search_history/forget_alert/:id',      :to => 'search_history#forget_alert',           :as => 'forget_search_history_alert'
    delete '/search_history/:id',                   :to => 'search_history#destroy',                :as => 'delete_search_history'
    get    '/search_history/saved',                 :to => 'search_history#saved',                  :as => 'saved_search_history'
    get    '/search_history/alerted',               :to => 'search_history#alerted',                :as => 'alerted_search_history'


    # User management
    resources :users,                               :only => [:index, :update, :destroy]


    # Feedback
    resource :feedback, :only => [:new, :create]


    # Semi-static pages
    get   '/pages/searchbox',                       :to => 'pages#searchbox',                       :as => 'searchbox'
    get   '/pages/search_homepage',                 :to => 'pages#searchbox_styled',                :as => 'searchbox_styled'
    get   '/pages/authentication_required',         :to => 'pages#authentication_required',         :as => 'authentication_required'
    get   '/pages/authentication_required_catalog', :to => 'pages#authentication_required_catalog', :as => 'authentication_required_catalog'
    get   '/about',                                 :to => 'pages#about'


    get   '/',                                      :to => 'catalog#index'
  end
  root :to => "catalog#index"
end
