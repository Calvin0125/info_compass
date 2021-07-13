class SearchTerm < ActiveRecord::Base
  default_scope { order(term: :asc) }

  before_save :downcase_term

  belongs_to :research_topic

  validates_presence_of :term 
  validates_uniqueness_of :term, case_insensitive: true

  def downcase_term
    # 'if self.term' necessary for shoulda-matchers to work
    self.term.downcase! if self.term
  end
end
