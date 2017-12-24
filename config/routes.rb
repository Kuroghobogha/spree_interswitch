Spree::Core::Engine.add_routes do
  get '/interswitch', :to => "interswitch#index", :as => :interswitch_proceed
  get '/interswitch/confirm', :to => "interswitch#confirm", :as => :interswitch_confirm
  get '/interswitch/cancel', :to => "interswitch#cancel", :as => :interswitch_cancel
end