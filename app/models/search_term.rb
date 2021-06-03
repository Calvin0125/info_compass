class SearchTerm < ActiveRecord::Base
  default_scope { order(term: :asc) }

  belongs_to :research_topic

  validates_presence_of :term
end
