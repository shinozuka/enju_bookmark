class BookmarkStat < ActiveRecord::Base
  attr_accessible :start_date, :end_date, :note
  include CalculateStat
  default_scope :order => 'id DESC'
  scope :not_calculated, where(:state => 'pending')
  has_many :bookmark_stat_has_manifestations
  has_many :manifestations, :through => :bookmark_stat_has_manifestations

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  paginates_per 10

  def calculate_count
    self.started_at = Time.zone.now
    Manifestation.find_each do |manifestation|
      daily_count = Bookmark.manifestations_count(start_date, end_date, manifestation)
      #manifestation.update_attributes({:daily_bookmarks_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        sql = ['UPDATE bookmark_stat_has_manifestations SET bookmarks_count = ? WHERE bookmark_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end

  def self.get_bookmark_stats_tsv(bookmark_stat, stats)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # term
    data << '"' + I18n.t('activerecord.attributes.bookmark_stat.start_date') + "\"\n"
    data << '"' + bookmark_stat.start_date.to_s + "\"\n"
    data << '"' + I18n.t('activerecord.attributes.bookmark_stat.end_date') + "\"\n"
    data << '"' + bookmark_stat.end_date.to_s + "\"\n"
    # state
    data << '"' + I18n.t('activerecord.attributes.bookmark_stat.state') + "\"\n"
    data << '"' + bookmark_stat.state.to_s + "\"\n"
    # note
    data << '"' + I18n.t('activerecord.attributes.bookmark_stat.note') + "\"\n"
    data << '"' + bookmark_stat.note + "\"\n"
    data << "\n"

    # title column
    columns = [
      [:manifestation, 'activerecord.models.manifestation'],
      [:bookmarks_count, 'activerecord.attributes.bookmark_stat_has_manifestation.bookmarks_count']
    ]
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    stats.each do |stat|
      row = []
      columns.each do |column|
        case column[0]
        when :manifestation
          manifestation = ""
          manifestation = stat.manifestation.original_title if stat.manifestation
          row << manifestation
        when :bookmarks_count
          row << stat.bookmarks_count
        end
      end
      data << '"' + row.join("\"\t\"") + "\"\n"
    end
    return data
  end
end

# == Schema Information
#
# Table name: bookmark_stats
#
#  id           :integer          not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  started_at   :datetime
#  completed_at :datetime
#  note         :text
#  state        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

