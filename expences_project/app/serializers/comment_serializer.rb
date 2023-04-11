class CommentSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :content, :expenditure_id
end
