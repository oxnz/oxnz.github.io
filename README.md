# [Tech Stack](https://oxnz.github.io)

[![Build Status](https://travis-ci.org/oxnz/oxnz.github.io.svg?branch=master)](https://travis-ci.org/oxnz/oxnz.github.io)

## Introduction

website: https://oxnz.github.io/

## Infrastructure

```
_config.yml  # configuration
_includes/   # include files
_layouts/    # layout templates
_posts/      # articles
_sass/       # css files
_site/       # generated html files
_drafts/     # drafts
assets/      # static files
css/         # css files
LICENSE      # license file
```

## Contribute

1. fork
2. make changes

  ```shell
  git clone https://github.com/username/oxnz.github.io
  cd oxnz.github.io
  vi _posts/2016-11-20-hibernate.md
  git add _posts/2016-11-20-hibernate.md
  git commit -m 'add hibernate article'
  git push
  ```
  
3. open pull requests (compare across forks)
4. done

### Update fork

```shell
git remote add upstream https://github.com/oxnz/oxnz.github.io.git
git fetch upstream
git merge upstream/master
```

## License

See LICENSE file under the same directory.
