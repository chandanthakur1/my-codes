# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < ApplicationController


      # GET /transactions
      def index
        
        if params[:search].present?
          search_text = /#{params[:search].gsub(/[.\[\]@#!%&*~]/, '')}/i
          transactions = transactions.where(deal_name: search_text).or(client_name: search_text).or(sponsor_name: search_text)
        end
      end
    end
  end
end
