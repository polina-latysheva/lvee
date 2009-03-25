# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  protected
  # Displays all flashes if any
  def flashes_if_any
    html = ''
    [:notice, :error].each do |key|
      message = flash[key]
      html << content_tag(:p, message, :class => key) if(message)
    end
    flash.discard
    html
  end

  # FIXME
  def format_date(time)
    time ? localize(time, :format => :long) : t("date.none")
  end

  def link_to_languages
    html = Language.published.map do |lang|
      #img = image_tag("/images/flags/"+lang.name+".png", :alt => lang.description)
      to_params = params_to_lang(lang.name)
      content_tag(:li, link_to_unless_current( lang.name.upcase, to_params), :class=> (lang.name == I18n.locale ? 'active' : ''))
    end
    html.join(' ')
  end

  def article_output(category, name)
    a = Article.load_by_name_or_create(category, name)
    render :partial => "/articles/inline", :locals=> {:article => a}
  end

  def editor?
    current_user && current_user.editor?
  end

  def admin?
    current_user && current_user.admin?
  end

  def article_link(title, category, name)
    link_to(title, :category => category, :name => name, :controller => "/articles", :action => 'show')
  end

  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

  def params_to_lang(lang)
    {:controller => controller.controller_name, :lang => lang, :id => params[:id],
        :user_id => params[:user_id], :conference_id => params[:conference_id],
        :category => params[:category], :name => params[:name], :action => controller.action_name}
  end

end
