# Custom aliases
# Adds all files that aren't labeled 'Untracked' and then shows the status
alias gitadd='git ls-files --modified | xargs git add; git status'

# Pushes the branch to an upstream branch with the same name. Sets tracking to that branch
alias gitpush='__git_push_set_remote'

# I'm a windows user at home
alias cls='clear'

# Get top 5 git contributers to a file
alias gittopusers='__show_git_top_5_committers'

# Set up tests against dockerized postgres
alias ijsetuptests='POSTGRES_FORCE_PORT=5432 docker/psql-tmpfs/run'

# Alias to be run on main repo that resets to an updated stable master then checks out the new branch
alias stablebranch='__branch_off_updated_stable_master'

# Opens up a main repo branch's commits on stash in a web browser
alias stashbranch='__open_branch_in_stash'

# Moves current changes to a testing branch
alias testbranch='git stash; git branch -D jam-testing; git push origin -d jam-testing; git checkout -b jam-testing; git stash pop'

# Deletes a branch both locally and remotely
alias deletebranch='__git_delete_branch'

# Redfin standard local bazel build
alias bazelbuild='bazel build -- ... -//corvair/... -//scripts/distros/... -//redfin.stingrayStatic/... -//redfin.npm/... -//:lerna_bootstrap'

# Compare BUILD diles
alias compbuildfiles='basebranch=$(git rev-parse --abbrev-ref HEAD); git checkout master; bazel build //redfin.core.enums; tools/audit/compare-bazel save before; git checkout $basebranch; bazel build //redfin.core.enums; tools/audit/compare-bazel cmp before > diff-all.txt; echo "Done. Check diff-all.txt for results"'

# Shows current epoch time in seconds
alias epoch='date +%s'

# Converts an epoch to a date time
alias convert_epoch='__convert_epoch'

# Pipe in a git diff and it will add filenames and line numbers
alias diff-lines='__diff_lines'

# Destroys then remakes the directory
alias refresh='__refresh_dir'

alias ll='ls -lhG'
alias lsh='ls -ld .?*'
alias sourceme='source $HOME/.bash_profile'
alias backprofile='cp $HOME/.bash_profile $HOME/.bash_profile_backup'

###############################################
#       Functions used by the aliases         #
###############################################

__show_git_top_5_committers ()
{
    if [ -z "$1" ]; then
	echo "No file specified"
    else
	git log $1 | grep '^Author' | cut -d: -f2 | cut -d' ' -f2,3 | sort | uniq -c | sort -rn | head -5
    fi
}

__branch_off_updated_stable_master ()
{
    git checkout stable-master
    git pull
    if [ -z "$1" ]; then
	echo "No branch specified to use. Just staying on update stable-master"
    else
	git checkout -b $1
    fi
}

__git_push_set_remote ()
{
    gitBranch=$(git rev-parse --abbrev-ref HEAD)
    git push -u origin $gitBranch
}

__git_delete_branch ()
{
    if [ -z "$1" ]; then
	echo "No branch specified for delete"
    else
	git branch -D "$1"
	git push -d origin "$1"
    fi
}

__open_branch_in_stash()
{
    gitBranch=$(git rev-parse --abbrev-ref HEAD)
    gitRepo=$(basename $(git config --local --get remote.$(git config --get branch.master.remote).url) .git)
    open "https://stash.redfin.com/projects/RED/repos/$gitRepo/commits?until=refs%2Fheads%2F$gitBranch"
}

__convert_epoch()
{
    if [ -z "$1" ]; then
	echo "Please pass in an epoch time"
    else
	date -r "$1" '+%m/%d/%Y:%H:%M:%S' 
    fi
}

__diff_lines()
{
    local path=
    local line=
    while read; do
        esc=$'\033'
        if [[ $REPLY =~ ---\ (a/)?.* ]]; then
            continue
        elif [[ $REPLY =~ \+\+\+\ (b/)?([^[:blank:]$esc]+).* ]]; then
            path=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ @@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.* ]]; then
            line=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ ^($esc\[[0-9;]+m)*([\ +-]) ]]; then
            echo "$path:$line:$REPLY"
            if [[ ${BASH_REMATCH[2]} != - ]]; then
                ((line++))
            fi
        fi
    done
}

__refresh_dir()
{
    rm -rf "$1"
    mkdir -p "$1"
}