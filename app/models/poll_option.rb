class PollOption < ActiveRecord::Base
  include FormattedDateHelper

  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  def color
    AppConfig.colors.dig(poll.poll_type, self.priority)
  end

  def display_name(zone: nil)
    if poll.dates_as_options
      formatted_datetime(name, zone || poll.time_zone)
    else
      name.humanize
    end
  end
end
