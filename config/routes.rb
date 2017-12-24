Spree::Core::Engine.add_routes do
  post '/interswitch', :to => "interswitch#index", :as => :interswitch_proceed
  post '/interswitch/confirm', :to => "interswitch#confirm", :as => :interswitch_confirm
  post '/interswitch/cancel', :to => "interswitch#cancel", :as => :interswitch_cancel
end