class RedmineIssueRepository
  def initialize(initial_issues = nil)
    @issues = initial_issues || []
  end
  attr_reader :issues

  def add_issues(issues_to_add)
    @issues.concat(issues_to_add)
  end

  def all_issue_ids
    @issues.collect do |issue|
      issue["issue"]["id"]
    end
  end

  def journal_entries(issue_id)
    issue = @issues.select { |issue| issue["issue"]["id"] == issue_id }.first

    return issue["issue"]["journals"].collect do |journal_entry|
      journal_entry["details"].collect do |d|
        d.merge("created_on" => journal_entry["created_on"])
         .merge("issue_id" => issue["issue"]["id"])
         .merge("journal_entry_id" => journal_entry["id"])
      end
    end.flatten
  end

  def journal_notes(issue_id)
    issue = @issues.select { |issue| issue["issue"]["id"] == issue_id }.first

    return issue["issue"]["journals"].collect do |journal_entry|
      ["id", "notes", "created_on"].inject({}) { |previous_value,key| previous_value.merge({key => journal_entry[key]}) }.merge("issue_id" => issue["issue"]["id"])
    end
  end

  def latest_issue_update_time
    @issues.collect { |issue| DateTime.parse(issue["issue"]["updated_on"]) }.sort.last || DateTime.new
  end
end
