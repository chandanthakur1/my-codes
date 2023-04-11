module Transactions    
    class DeleteEachTransactionJob < ApplicationJob
        queue_as ENV['LOANS_WORKER_QUEUE']


        def perform(params)
            return unless Rails.env.staging?
            params = JSON.parse(params).symbolize_keys
            transactions_ids = params[:transaction_ids]

            transactions_ids.each do |transaction_id|
                Transaction.find(transaction_id).destroy
            end
        rescue => exception
            Rails.logger.error "DeleteEachTransactionJob delete job error => #{exception}"
        end
    end
end