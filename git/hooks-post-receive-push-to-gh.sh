#!/usr/bin/env bash
"/var/lib/git/gogs/gogs" hook --config='/var/lib/git/gogs/conf/app.ini' post-receive

GIT_DIR="$(pwd)"
TMP_GIT_DIR="/tmp/${GIT_DIR##*/}"

if [[ ! -d "${TMP_GIT_DIR}" ]]; then
    git clone "${GIT_DIR}" "${TMP_GIT_DIR}"
    cd "${TMP_GIT_DIR}" || exit
else
    cd "${TMP_GIT_DIR}" || exit
    unset GIT_DIR
    git fetch --all
    git reset --hard origin/master
    git pull
fi

for site in *.*/; do
    deploy_dir="/var/www/${site}"
    if [[ ! -d "$deploy_dir" ]]; then
        mkdir -p "$deploy_dir"
        chgrp -R "$deploy_dir"
        chmod g+s "$deploy_dir"
    fi
    pushd "${site}" || exit $?
    ruby -S bundle install --deployment
    ruby -S bundle exec jekyll build --destination "$deploy_dir"
    popd || exit $?
done

exit 0

git push --mirror git@github.com:cryobry/www.git

