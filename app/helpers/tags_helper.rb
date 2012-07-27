module TagsHelper
  def tag_control(document)
    render(:partial => 'tags/tag_control', :locals => {:document=> document})
  end
end
