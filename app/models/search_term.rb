class SearchTerm < ActiveRecord::Base
  default_scope { order(term: :asc) }

  before_save :downcase_term

  belongs_to :topic

  validates_presence_of :term 
  validates_uniqueness_of :term, case_insensitive: true
  validate on: :create do
    if topic && topic.search_terms.length >= 10
      errors.add(:base, message: "You can't have more than 10 search terms per topic.")     
    end
  end

  def downcase_term
    # 'if self.term' necessary for shoulda-matchers to work
    self.term.downcase! if self.term
  end
end
