module ActiveScaffold::Actions
  module ConferenceRegistrationStatistics
    def self.included(base)
      base.before_filter :live_search_authorized?, :only => :show_search
    end

    def show_statistics
      respond_to do |type|
        type.html do
          if successful?
            render(:partial => "show_statistics", :layout => true)
          else
            return_to_main
          end
        end
        type.js { render(:partial => "show_statistics", :layout => false) }
      end
    end
  end
end
