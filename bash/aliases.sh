# Custom aliases
# Adds all files that aren't labeled 'Untracked' and then shows the status
alias gitadd='git ls-files --modified | xargs git add; git status'

# Pushes the branch to an upstream branch with the same name. Sets tracking to that branch
alias gitpush='__git_push_set_remote'

# Force pushes the branch to an upstream branch with the same name. Sets tracking to that branch     
alias gitpushf='__git_force_push_set_remote'

# Git status takes a while in large repos. This is a quick alias for uno status
alias gitst='git status -uno'

# I'm a windows user at home
alias cls='clear'

# Get top 5 git contributers to a file
alias gittopusers='__show_git_top_5_committers'

# Set up tests against dockerized postgres
alias ijsetuptests='POSTGRES_FORCE_PORT=5432 docker/psql-tmpfs/run'

# Deletes all local branches which have merged with master
alias clean-branches='git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d'

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

# Mimics the ll command on linux
alias ll='ls -lhGA'

# Shows hidden files. TODO: This doesn't work if you pass a directory after it
alias lsh='ls -ld .?*'

# Show the file permissions in octal format as well. TODO: This doesn't work if you pass a directory
alias lso="ls -alG | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"

# Source the bash profile
alias sourceme='source $HOME/.bash_profile'

# Backup the bash profile
alias backprofile='cp $HOME/.bash_profile $HOME/.bash_profile_backup'

# Adds the tree command to mac
alias tree="find ${1:-.} -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

# Makes a directory then cd's to it
alias mkcdir='__mkcdir'

# These aliases require git-number to function and are designed to make git easier
alias gn='git number --column'
alias ga='git number add'
alias gan='__git_number_add_show'

###############################################                                                                                                                                                                                                                              
#       Redfin specific aliases               #
############################################### 

# Unzip the snzipped tar directory to a refreshed /tmp/deleteme
alias sztar='__sztar'

# ssh to the panda machine given a url
alias pandassh='__panda_ssh'


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
    git pull origin stable-master
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

__git_force_push_set_remote ()
{
    gitBranch=$(git rev-parse --abbrev-ref HEAD)
    git push -u origin $gitBranch --force
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
    gitRepo=$(basename `git rev-parse --show-toplevel`)

    # Determining the project is a little annoying
    local project=RED
    case $gitRepo in
	"puppet") project=OPS ;;
	"redtronimus") project=TRON ;;
	"timber") project=AF ;;
    esac
    if [[ "$(pwd)" == *"code/bouncer"* ]]; then
	project=BOUNCER
    elif [[ "$(pwd)" == *"code/cop"* ]]; then
	project=COP
    fi
    
    open "https://stash.redfin.com/projects/$project/repos/$gitRepo/commits?until=refs%2Fheads%2F$gitBranch"
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

__sztar()
{
    refresh /tmp/deleteme
    snzip -dc < "$1" | tar -x -C /tmp/deleteme
}

__mkcdir ()
{
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

__panda_ssh()
{
    nofront=${1/https:\/\/ip-/}
    noback=${nofront/.redfintest.com/}
    host=${noback//-/.}
    ssh root@$host
}

__git_number_add_show()
{
    git number add "$1"
    git number --column
}
