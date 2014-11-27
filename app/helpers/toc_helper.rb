# encoding: utf-8
# View helpers for showing TOC
# Used in conjunction with Controllers that include Toshokan::BuildsToc
module TocHelper

  def render_toc toc
    years = toc[:issues].group_by{|t| t[:year]}
    content_tag :ul, years.keys.sort.reverse.map{ |year|
      content_tag :li, render_year(year, years[year], toc[:current_issue]), :class => 'toc_year'
    }.join.html_safe, :class => 'toc_issues'
  end

  def render_year year, issues, current_issue
    volumes = issues.group_by{|i| i[:vol] }
    (year.to_s +
      content_tag(:ul,
        volumes.keys.sort.reverse.map{ |vol|
          content_tag :li, render_volume(vol, volumes[vol], current_issue)
        }.join.html_safe)).html_safe
  end

  def render_volume vol, issues, current_issue
    if issues.size > 1 || issues.first[:issue] != 0
      render_volume_with_many_issues vol, issues.reject{|i| i[:issue] == 0}, current_issue
    else
      render_volume_without_issues vol, issues.first[:key], current_issue
    end
  end

  def render_volume_with_many_issues vol, issues, current_issue
    render(:partial => 'toc/volume_with_many_issues',
      :locals => { :vol => vol, :issues => issues.sort_by{ |i| [i[:issue], i[:part] || ''] }.reverse, :current_issue => current_issue })
  end

  def render_volume_without_issues vol, key, current_issue
    render_toc_entry("#{I18n.t('toshokan.catalog.toc.volume')} #{vol}", key, current_issue)
  end


  def render_toc_entry label, key, current_issue
    if current_issue && key == current_issue[:key]
      render_selected_toc_entry label
    else
      render_toc_entry_link label, key
    end
  end

  def render_toc_entry_link label, key
    link_to label, params.merge(:key => key, :ignore_search => '✓'), :class => 'toc_issue'
  end

  def render_selected_toc_entry label
    content_tag :strong, label, :class => 'toc_issue selected'
  end

  def render_issue_info issue, part
    ["#{I18n.t('toshokan.catalog.toc.issue')} #{issue}", part].compact.reject(&:empty?).join(', ')
  end

  def render_journal_info_for_issue issue
    render_journal_metadata_from_parts(issue[:year], issue[:vol], issue[:issue] > 0 && issue[:issue], issue[:part])
  end

  def link_to_toc_query body, key, title
    link_to_toc_query_if true, body, key, title
  end

  def link_to_toc_query_if condition, body, key, title
    link_to_if(condition,
      body,
      set_limit_params_and_redirect(:toc, { :value => key, :title => title}),
      { :title => I18n.t('toshokan.catalog.find_in_issue'), :data => { :toggle => 'tooltip' } })
  end

end
