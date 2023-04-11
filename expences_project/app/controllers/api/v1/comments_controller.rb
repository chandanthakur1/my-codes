module Api 
    module V1
        class CommentsController < ApplicationController
            include JsonWebToken

            def create
                user = current_active_user
                data = comment_params
                data[:name] = user[:name]
                cmt = Comment.new(data)
                unless cmt.save!
                    render json: {message: cmt.errors.messages}, status: 201
                end
                render json: cmt
            end
            private

            def comment_params
                params.require(:comment).permit(:content, :expenditure_id)
            end

        end
    end
end