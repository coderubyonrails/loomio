class EmailActionsController < AuthenticateByUnsubscribeTokenController

  def unfollow_discussion
    set_discussion_volume volume: :quiet, flash_notice: :"notifications.email_actions.not_following_thread"
   end

  def follow_discussion
    set_discussion_volume volume: :loud, flash_notice: :"notifications.email_actions.following_thread"
  end

  def mark_discussion_as_read
    DiscussionReader.for(discussion: discussion, user: user).viewed!(event.created_at)
    respond_with_pixel
  rescue ActiveRecord::RecordNotFound
    respond_with_pixel
  end

  def mark_summary_email_as_read
    time_start  = Time.at(params[:time_start].to_i).utc
    time_finish = Time.at(params[:time_finish].to_i).utc

    Queries::VisibleDiscussions.new(user: user).
                                    unread.
                                    last_activity_after(time_start).each do |discussion|
      DiscussionReader.for(user: user, discussion: discussion).viewed!(time_finish)
    end

    respond_to do |format|
      format.html {
        flash[:notice] = I18n.t "email.missed_yesterday.marked_as_read_success"
        redirect_to root_path
      }
      format.gif { respond_with_pixel }
    end
  end

  private

  def respond_with_pixel
    send_file Rails.root.join('app','assets','images', 'empty.gif'), type: 'image/gif', disposition: 'inline'
  end

  def set_discussion_volume(volume:, flash_notice:)
    DiscussionReader.for(discussion: discussion, user: user).set_volume! volume
    redirect_to root_path, notice: t(flash_notice, thread_title: discussion.title)
  end

  def discussion
    @discussion ||= Discussion.find params[:discussion_id]
  end

  def event
    @event ||= Event.find params[:event_id]
  end
end
