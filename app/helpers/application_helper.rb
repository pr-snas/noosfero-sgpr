# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Directories to be rejected of the directories list when needed.
  # TODO I think the better way is create a Dir class method that returns a list of files of a given path
  REJECTED_DIRS = %w[
    .
    ..
    .svn
  ]

  ICONS_DIR_PATH = "#{RAILS_ROOT}/public/icons"
  THEME_DIR_PATH = "#{RAILS_ROOT}/public/themes"
    

  # Generate a select option to choose one of the available themes.
  # The available themes are those in 'public/themes'
  def select_theme(object, chosen_theme = nil)
    return '' if object.nil?
    available_themes = Dir.new("#{THEME_DIR_PATH}").to_a - REJECTED_DIRS
    theme_options = options_for_select(available_themes.map{|theme| [theme, theme] }, chosen_theme)
    select_tag('theme_name', theme_options ) +
    change_theme('theme_name', object)
  end

  # Generate a observer to reload a page when a theme is selected
  def change_theme(observed_field, object)
    observe_field( observed_field,
      :url => {:action => 'set_default_theme'},
      :with =>"'theme_name=' + escape(value) + '&object_id=' + escape(#{object.id})",
      :complete => "document.location.reload();"
    )
  end


  # Generate a select option to choose one of the available icons themes.
  # The available icons themes are those in 'public/icons'
  def select_icons_theme(object, chosen_icons_theme = nil)
    return '' if object.nil?
    available_icons_themes = Dir.new("#{ICONS_DIR_PATH}").to_a - REJECTED_DIRS
    icons_theme_options = options_for_select(available_icons_themes.map{|icons_theme| [icons_theme, icons_theme] }, chosen_icons_theme)
    select_tag('icons_theme_name', icons_theme_options ) +
    change_icons_theme('icons_theme_name', object)
  end

  # Generate a observer to reload a page when a icons theme is selected
  def change_icons_theme(observed_field, object)
    observe_field( observed_field,
      :url => {:action => 'set_default_icons_theme'},
      :with =>"'icons_theme_name=' + escape(value) + '&object_id=' + escape(#{object.id})",
      :complete => "document.location.reload();"
    )
  end

  #Display a given icon passed as argument
  #The icon path should be '/icons/{icons_theme}/{icon_image}'
  def display_icon(icon , icons_theme = "default", options = {})
    image_tag("/icons/#{icons_theme}/#{icon}", options)
  end

  # Load all the css files of a existing theme with the theme_name passed as argument.
  #
  # The files loaded are in the path:
  #
  # 'public/themes/#{theme_name}/*'
  # If a invalid theme it's passed the 'default' theme is applied
  def stylesheet_link_tag_theme(theme_name)
    if !File.exists? "#{THEME_DIR_PATH}/#{theme_name}"
      flash[:notice] = _("The theme %s it's not a valid theme") % theme_name
      theme_name = 'default'
    end

    d = Dir.new("#{THEME_DIR_PATH}/#{theme_name}/").to_a - REJECTED_DIRS 
    d.map do |filename| 
      stylesheet_link_tag("/themes/#{theme_name}/#{filename}")
    end
  end


end
