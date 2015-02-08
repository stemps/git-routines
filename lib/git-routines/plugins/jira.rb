requires_gem 'jira'

setup do
  @jira_username     = config('jira.username', 'Your JIRA username', :local)
  @jira_password     = config('jira.password', 'Your JIRA Password', :local)
  @jira_url          = config('jira.url', 'Base URL if your JIRA instance', :local)
  @jira_context_path = config('jira.context-path', 'JIRA context path (leave empty if unsure)', :local) || ""
  @project_id        = config('jira.project-id', 'JIRA project key', :local)
  @start_transition  = "Start Progress"
  @finish_transition = config('jira.finish-transition', 'When finished, execute transition (e.g. "Resolve Issue")', :local)
  @jira_api          = JIRA::Client.new(username: @jira_username, 
                                        password: @jira_password, 
                                        site: @jira_url, 
                                        context_path: @jira_context_path,
                                        auth_type: :basic) 
end

before_start do
  jira_select_issue
  @branch  = "#{@issue.issuetype.name.downcase}/#{@issue.key}-#{@issue.summary}"
  @title   = @issue.summary
  @summary = jira_generate_summary
end

after_start do
  jira_transition_start_progress @issue
end

before_finish do
  @issue_id = branch.upcase.match(/.*\/(#{@project_id}-\d+)-.*/)[1]
  @issue    = @jira_api.Issue.find(@issue_id)
  @title    = @issue.summary
  @summary  = jira_generate_summary
end

after_finish do
  # new_state = @issue.story_type == 'chore' ? 'accepted' : 'finished'
  # update_story @issue.id, current_state: new_state
end


def jira_generate_summary
  <<-MARKDOWN.gsub(/^    /, '').gsub(/\n+/, "\n\n")
    # #{@issue.summary}
    #{@issue.description}
    <#{jira_issue_url(@issue)}>
  MARKDOWN
end

def jira_issues
  @issues ||= @jira_api.Issue.jql(jira_issue_filter)
end

def jira_issue_filter
  "project = '#{@project_id}' and assignee = currentUser() and sprint in openSprints() and statusCategory = 'To Do'"
end

def jira_select_issue
  existing_issues = jira_issues.map do |i|
    i.issuetype.name.upcase.ljust(9) + i.summary 
  end
  choice = select_one_of('Select story', existing_issues)

  if choice >= 0 and choice < jira_issues.length
    @issue = jira_issues[choice]
  else
    abort "No valid issue selected."
  end
end

def jira_transition_start_progress(issue)
  jira_transition(issue, @start_transition)
end

def jira_transition_fininsh_progress(issue)
  jira_transition(issue, @finish_transition)
end

def jira_transition(issue, transition_name)
  transition = jira_find_transition(transition_name)
  abort "Cannot find transistion #{transition_name} for #{issue.key}" unless transition
  @jira_api.post("#{issue.self}/transitions", { transition: transistion.id }.to_json )
end

def jira_find_transition(transition_name)
  transistions = @jira_api.Transition.all(issue: issue)
  transistions.find { |t| t.name == transition_name }
end

def jira_issue_url(issue)
  "#{@jira_url}/browse/#{issue.key}"
end
