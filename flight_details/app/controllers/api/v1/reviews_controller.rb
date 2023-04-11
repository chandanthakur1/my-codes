module Api
    module V1
        class ReviewsController < ApplicationController
            protect_from_forgery with: :null_session

            def index 
                reviews = Review.all 
                render json: ReviewSerializer.new(reviews).serialized_json
            end

            def create 
                review = Review.new(review_param)

                if review.save 
                    render json: review
                else
                    render json: {error: review.errors.messages}
                end
            end

            def destroy 
                review = Review.find(params[:id])

                if review.destroy 
                    head :no_content
                else
                    render json: {error: review.errors.messages}
                end
            end

            def search
                review = Review.where(airline_id: params[:airline_id])

                render json: ReviewSerializer.new(review).serialized_json
            end


            private 
                def review_param 
                    params.require(:review).permit(:title, :description, :score, :airline_id)
                end
        end
    end
end