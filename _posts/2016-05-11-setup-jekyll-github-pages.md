---
layout: post
title: Setup Jekyll for Github Pages
date: 2016-05-11 15:47:48 +0800
categories: [jekyll, sysadm, ruby]
tags: [jekyll]
---

![jekyll-github](/assets/jekyll-github.png)

## Introduction

Jekyll is a simple static site generator that convert from Markdown source file to HTML pages. The result site is fast, portable and easy for servers like nginx to serve many users concurrently.

Github Pages use jekyll to build site for user and repo pages. And the pages are hosted on github as a normal Git repository. So there is no differences between edit a source file and edit a post. The post is published when you push it to the upstream.

This article introduces how to setup jekyll and the post-install steps like tweaks and adjustments.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Install and run jekyll

Even though Github can automatically build site from the repo conent. It is more convenient to setup a local jekyll server for debugging and testing purpose.

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
526  bundle exec jekyll serve --watch --incremental --detach --host 0.0.0.0 # bind to all IPs
{% endhighlight %}

Gemfile content:

{% highlight ruby %}
source 'https://rubygems.org'
gem 'github-pages', group: :jekyll_plugins
{% endhighlight %}

Ubuntu install ruby2.0. jekyll failed to start, need to specify some gem version manually, edit `vi /var/lib/gems/2.0.0/gems/jekyll-3.1.3/bin/jekyll`:

{% highlight ruby %}
gem 'jekyll', '=3.1.3'
gem 'jekyll-watch', '=1.4.0'
gem 'rb-fsevent', '=0.9.7'
require 'jekyll'
require 'mercenary'

# Jekyll::PluginManager.require_from_bundler
{% endhighlight %}

### Configure

0. Site Configure(`_config.yml`)

   ```yml
   gems: [jekyll-paginate, jekyll-sitemap, jekyll-gist, jekyll-seo-tag, jekyll-redirect-from]

   # source .
   # destination _site
   # exclude [dir, file, ...]
   # include: ['.htaccess']

   # Conversion
   timezone: Asia/Shanghai
   excerpt_separator: <!--more-->

   # Pagination
   paginate: 10

   # Sass
   sass:
     style: compressed

   # View
   permalink: /:year/:month/:day/:title/
   ```

	**Notes**

	If you would like to exclude specific pages/posts from the sitemap set the sitemap flag to false in the front matter for the page/post.

	   ```yml
	   sitemap: false
	   ```
0. Frontmatter

   ```yml
   layout: post
   title: About
   date: 2015-12-25 13:08:00 +0800
   permalink: '/about'
   published: false
   category: sysadm
   categories: [net, dev]
   tags: [socket]
   ```

## Depolyment

### Travis CI

Create an `.travis.yml` in the root directory with the following contents:

{% highlight yml %}
language: ruby
rvm:
  - 2.2
script: "bundle exec jekyll build"
{% endhighlight %}

Then the Travis CI would automatically build after each `git push`.

## Adjust Styles

add `_sass/_custom.scss`, edit `css/main.scss` to contains it:

{% highlight highlight scss %}
// Import partials from `sass_dir` (defaults to `_sass`)
@import
	"base",
	"layout",
	"syntax-highlighting",
	"custom"
;
{% endhighlight %}

### Adjust Font Family

![avenir-next](/assets/avenir-next.png)

Use 'Avenir Next' on OS X, proxima-nova on other platforms which does not have 'Avenir Next' installed by default.

## Add Google Analytics

Include the code before `body`.

## Add Disqus Support

Register an Disqus account and paste the embeded code.

## Migrate posts

First, export an xml file from wordpress use the Export submenu in Tools.

Keep the default to export all and save the xml file locally.   You can then use jekyll import to retrieve all your posts. First you first need to install jekyll-import as it is not part of jekyll main gem:   

{% highlight bash %}
gem install jekyll-import
{% endhighlight %}

You can then use jekyll import. There are several options here. Here is the command that worked best for me:

{% highlight shell %}
ruby -rubygems -e 'require "jekyll-import";
JekyllImport::Importers::WordpressDotCom.run({
	"source" => "wordpress.xml",
	"no_fetch_images" => false,
	"assets_folder" => "assets"
})'
{% endhighlight %}

After this, some there may be some drafts in the `_drafts` directory with encoded file names, so we need to rename them:

{% highlight python %}
import os
import urllib

for subdir, dirs, files in os.walk('./_drafts'):
    for f in files:
		src = './_drafts/{}'.format(f)
		dst = './_drafts/{}'.format(urllib.unquote(f))
        print('{} -> {}'.format(src, dst)
        os.rename(src, dst)
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

### Kramdown’s Indentation Syntax

#### Code Blocks Within Lists

With Github-flavored Markdown, when you insert a code block within a list, you can indent the code block **4** spaces.

But with Kramdown, you must line up the indent of the code block with the first non-space character after the list item marker (e.g., `1.`). Usually this will mean indenting the code block **3** spaces instead of **4**.

Thomas Leitner, the developer leading Kramdown, [explains it as follows](https://github.com/tomjohnson1492/kramdowntest/issues/1#issue-135448518):

>
The gist is that the indentation for the list contents is determined by the column number of the first non-space character after the list item marker.

If you have 4 spaces instead of 3, Kramdown will set off the code with `code` tags instead of `pre` tags. This will make a huge difference, since `code` tags render inline whereas `pre` renders as a div block.

## Check posts

With more posts was added, there may be some malformed posts.

The following code snippets find out which post has not include an layout instruction, in this case, the post would be rendered use the default layout, which may not what you want.

{% highlight shell %}
for f in ./_posts/*; do
    if ! grep 'layout: post' "$f" > /dev/null 2>&1; then
        echo "$f"
    fi
done
{% endhighlight %}

[jekyll]:      http://jekyllrb.com
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-help]: https://github.com/jekyll/jekyll-help

## References

* [http://jekyllrb.com/docs](http://jekyllrb.com/docs)
* [shopify liquid docs](http://docs.shopify.com/themes/liquid-basics)
* [Liquid for Designers](https://github.com/shopify/liquid/wiki/Liquid-for-Designers)
* [Jekyll Cheatsheet](http://ricostacruz.com/cheatsheets/jekyll.html)
* [kdramdown syntax](http://kramdown.gettalong.org/syntax.html)
