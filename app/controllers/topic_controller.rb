class TopicController < ApplicationController
  
  before_filter :setup_context

  def show
    respond_to do |format|
      format.html
      format.parthtml { render :template => 'topic/show.html.erb', :layout => false }
    end
  end

  private
  
  def setup_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
    @topic = @site.topics.find( :first, :conditions => { 'name' => params[:topic_name] } )
  end

end
