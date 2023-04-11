

MarketPlaceApi::Application.routes.draw do
  
  namespace :api, defaults: { format: :json }, path: '/' do
    

      resources :dms_documents do
        collection do
          get :documents
          get :download
          post :update_doc
          post :upload_metadata
          put :add_tag
          put :delete_tag
          post :upload_with_metadata
          delete :delete_doc
        end
      end


  
  end
end