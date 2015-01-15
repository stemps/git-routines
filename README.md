# Git-Start

`git start`—a Git workflow helper that:

* Shows all your PivotalTracker stories
* Creates feature/bug/chore branches (e.g. feature/4711-create-profile) for a chosen story
  **Bonus:** you can also create a new story in the command line
* Asks to estimate the story if needed
* Sets the story started
* _Optional:_ Outputs a summary of the story to the command line (incl. description, tasks, and link to story)

`git finish`—to call after you finished the story:

* Sets the story finished
* _Optional:_ Rebases the current branch to your *master* branch
* Pushes the branch
* _Optional:_ Opens a GitHub pull request (incl. link to the corresponding PivotalTracker story)
* Checks out *master*


## Setup

```
gem install git-start
```

Other configuration happens on the fly. All information will be requested when needed.


## Work in Progress

This is brand new but at [Homify](https://www.homify.co.uk) we’re using it for our workflows. It is mostly done, feedback is welcome, and [GitHub issues integration](https://github.com/hagenburger/git-start/issues/1) as alternative to PivotalTracker is in the planning. Other tools should be easy to integrate. Have a look into the source or ping me [on Twitter](https://twitter.com/hagenburger). If you have a better name for this, let me know ;)
