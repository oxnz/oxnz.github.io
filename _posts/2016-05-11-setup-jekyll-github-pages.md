---
layout: post
title: Setup Jekyll for Github Pages
date: 2016-05-11 15:47:48 +0800
categories:
- Linux
tags:
- jekyll
---

## Install and run jekyll

Bash command history(some non-relative command are ommited):

{% highlight bash %}
[will@rhel.vmg ~/Workspace]$ history
496  git clone https://github.com/oxnz/oxnz.github.io
497  ruby --version # verify ruby installation
499  sudo gem install bundler
500  cd oxnz.github.io/
503  vi Gemfile # see below for content
504  bundle install
523  vi _config.yml # update config
526  bundle exec jekyll serve --watch --host 0.0.0.0 # bind to all IPs
{% endhighlight %}

<!--more-->

Gemfile content:

{% highlight ruby %}
source 'https://rubygems.org'
gem 'github-pages', group: :jekyll_plugins
{% endhighlight %}

## Migrate posts

First, export an xml file from wordpress use the Export submenu in Tools.

Keep the default to export all and save the xml file locally.   You can then use jekyll import to retrieve all your posts. First you first need to install jekyll-import as it is not part of jekyll main gem:   

{% highlight bash %}
gem install jekyll-import
{% endhighlight %}

You can then use jekyll import. There are several options here. Here is the command that worked best for me:


{% highlight bash %}
ruby -rubygems -e 'require "jekyll-import";
JekyllImport::Importers::WordpressDotCom.run({
	"source" => "wordpress.xml",
	"no_fetch_images" => false,
	"assets_folder" => "assets"
})'
{% endhighlight %}


## Edit posts

You’ll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve --watch`, which launches a web server and auto-regenerates your site when a file is updated.

To add new posts, simply add a file in the `_posts` directory that follows the convention `YYYY-MM-DD-name-of-post.ext` and includes the necessary front matter. Take a look at the source for this post to get an idea about how it works.

Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll’s dedicated Help repository][jekyll-help].

[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help
