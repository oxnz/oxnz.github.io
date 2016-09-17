---
layout: moxile
title: Moxile
excerpt: Moxile, the best crossplatform markdown editor
order: 2
---

<link rel="stylesheet" href="/assets/moxile/css/octicons.css">
<link rel="stylesheet" href="/assets/moxile/css/moxile.css">
<link rel="stylesheet" href="/assets/moxile/css/style.css">
<style type="text/css">
img.site-logo {
	width: 70px;
	height: 70px;
}

header {
  display: none;
}

main > .jumbotron {
  padding-top: 0;
}

main > .jumbotron > .container {
  margin: 0;
  padding: 0;
  width: 100%;
}

.page-content {
	padding: 0;
}

.site-footer {
	padding: 0;
	border-top: none;
}

.site-footer h2 {
	text-align: left;
	margin: 15px 0px;
}

kbd {
  font-size: 75%;
}
</style>

<section id="hero-spot" class="hero-spot">
    <a href="/"><img src="/assets/moxile/img/moxile-128.png" alt="Moxile" class="logo"></a>

    <h1>A full featured markdown editor.</h1>
    <h2>Moxile is designed for productivity. With Moxile, you can write aritcle or blog post more effective</h2>

    <a href="/moxile/support" class="help-link">Moxile Support</a>

    <div id="slideshow">
      <img src="/assets/moxile/slide/screenshot-1.png" width="893" class="slide active" alt="moxile01">
      <img src="/assets/moxile/slide/screenshot-02.png" width="893" class="slide" alt="moxile02">
      <img src="/assets/moxile/slide/screenshot-03.png" width="893" class="slide" alt="moxile03">
      <img src="/assets/moxile/slide/screenshot-04.png" width="893" class="slide" alt="moxile04">
      <img src="/assets/moxile/slide/screenshot-05.png" width="893" class="slide" alt="moxile05">
  </div>
</section>

<section id="tutorial" class="tutorial">
  <h1>Create, Edit and Save your markdown files. As well as QuickLook support.</h1>
  <h2>Moxile is available for multipe platforms.<br>Such as OS X, Windows as well as Linux</h2>

  <ul class="tabs">
    <li><a href="#user-site" class="selected">Get Moxile</a></li>
    <li><a href="#project-site">Report Issue</a></li>
  </ul>

  <!-- ### Start of tutorials -->
  <ul id="user-site" class="tutorial-list wrapper active">
    <li id="create-repo-step" class="image-right">
      <h4>Create a new file</h4>
      <p>Press <kbd>Command + N</kbd> or choose <kbd>New</kbd> menu item under <kbd>File</kbd> menu to create a new file.</p>

      <p class="details">Open up the Moxile app would create a new file by default. Any text file would open with Moxile to renderered as markdown</p>

    </li>

    <li id="xcreate-repo-step" class="">
      <h4>Full GFM extensions support</h4>
      <p></p>
      <img src="/assets/moxile/slide/screenshot-05.png" alt="GitHub for Windows screenshot" class="full-size" width="813">
    </li>

    <li id="xcreate-repo-step" class="">
      <h4>External editor support</h4>
      <p>With Moxile, you could write with your favorite editor, such as vim/emacs or sublime. All you need is turn on view mode under the preview menu</p>
      <img src="/assets/moxile/slide/screenshot-04.png" alt="GitHub for Windows screenshot" class="full-size" width="813">
    </li>

    <li id="xcreate-repo-step" class="">
      <h4>Beautiful math</h4>
      <p>with Moxile, high-quality math is available</p>
      <img src="/assets/moxile/slide/gfm-support.png" alt="GitHub for Windows screenshot" class="full-size" width="813">
    </li>

    <li class="question">
      <h4>What desktop environment are you using?</h4>
      <ul class="tabs">
        <li><a id="option-newuser-w" href="#new-user-step-1" class="selected">Moxile for Mac</a></li>
        <li><a id="option-ghfm" href="#setup-in-desktop">Moxile for Windows</a></li>
        <li><a id="option-terminal" href="#terminal-step-1">Moxile for Linux</a></li>
        <li><a id="option-ghfw" href="#setup-in-desktop">Others</a></li>
      </ul>
    </li>

    <li id="new-user-step-1" class="option-newuser-w animate-in hidden">
      <h4>Get Moxile for Windows</h4>
      <p>GitHub for Windows is a great way to use git and GitHub on Windows.</p>

      <a class="windows-download" href="https://github-windows.s3.amazonaws.com/GitHubSetup.exe"><span class="icon"></span>Download GitHub for Windows</a>

      <img src="/assets/moxile/img/dashboard2x.png" alt="GitHub for Windows screenshot" class="full-size" width="1054">
    </li>

    <li class="option-newuser-m animate-in hidden">
      <h4>Get Moxile for Mac</h4>
      <p>Moxile for Mac is a great way to edit and view markdown file on Mac.</p>

      <p><a href="https://itunes.apple.com/cn/app/moxile/id989166472"><img src="/assets/moxile/img/appstore.svg"></a></p>

      <img src="/assets/moxile/img/screenshot-01.png" alt="GitHub for Mac screenshot" class="full-size" width="1078">
    </li>

    <li id="terminal-step-1" class="option-terminal">
      <h4>Clone the repository</h4>
      <p>Go to the folder where you want to store your project, and clone the new repository:</p>

      <div class="terminal">
        <div class="header"></div>
        <div class="shell">
          <p><span class="path">~</span><span class="prompt">$</span>git clone https://github.com/<em>username</em>/<em>username</em>.github.io</p>
        </div>
      </div>
    </li>

    <li id="setup-in-desktop" class="option-ghfm option-ghfw image-right animate-in hidden">
      <h4>Clone the repository</h4>
      <p>Click the green "Set up in Desktop" button. When the GitHub desktop app opens, save the project.</p>

      <p class="details">If the app doesn't open, launch it and clone the repository from the app.</p>
    </li>

    <li id="setup-in-desktop" class="option-newuser-w option-newuser-m image-right animate-in hidden">
      <h4>QuickLook in Finder</h4>
      <p>After the installation, The QuickLook feature is ready for use.
      you could choose any file in Finder and press <kbd>Space</kbd> to launch the QuickLook to preivew the markdown files without open Moxile</p>

      <p class="details">QuickLook will lanuch all features suck as Task List and Fenced blocks by default.</p>
    </li>

    <li class="option-terminal">
      <h4>Hello World</h4>
      <p>Enter the project folder and add an index.html file:</p>

      <div class="terminal">
        <div class="header"></div>
        <div class="shell">
          <p><span class="path">~</span><span class="prompt">$</span>cd <em>username</em>.github.io</p>
          <p><span class="path">~</span><span class="prompt">$</span>echo "Hello World" &gt; index.html</p>
        </div>
      </div>
    </li>

    <li class="option-terminal">
      <h4>Push it</h4>
      <p>Add, commit, and push your changes:</p>

      <div class="terminal">
        <div class="header"></div>
        <div class="shell">
          <p><span class="path">~</span><span class="prompt">$</span>git add --all</p>
          <p><span class="path">~</span><span class="prompt">$</span>git commit -m "Initial commit"</p>
          <p><span class="path">~</span><span class="prompt">$</span>git push -u origin master</p>
        </div>
      </div>
    </li>

    <li class="option-all">
      <h4>…and you're done!</h4>
      <p>Start writting with Moxile or goto <a href="/support">http://errpro.com/support</a> for support information and extra theme download</p>
      <div class="hero-octicon">
        <span class="mega-octicon octicon-check"></span>
      </div>
    </li>
  </ul>
  <!-- End of user site tutorial -->

  <!-- Project Site tutorial -->
  <ul id="project-site" class="tutorial-list wrapper">
    <li class="question">
      <h4>Generate a site, or start from scratch?</h4>
      <p>For Project sites, you have the option to generate a site with 
one of the amazing pre-built themes, or to create a site from scratch.
      </p><ul class="tabs">
        <li><a id="option-generate" href="#generate-step-1" class="selected">Generate a site</a></li>
        <li><a id="option-vanilla" href="#vanilla-step-1">Start from scratch</a></li>
      </ul>
    </li>

    <li id="generate-step-1" class="option-generate">
      <h4>Repository Settings</h4>
      <p>Head over to <a href="https://github.com/">GitHub.com</a> and create a new repository, or go to an existing one. On the right hand side, <strong>click on Settings</strong>.</p>
      <p class="details">For <strong>Project pages</strong>, the <code>gh-pages</code>
 branch is used to publish your site. That means that you can work with 
GitHub Pages in the same repository as the project that it's for, 
without affecting the project itself.</p>

      <img src="/assets/moxile/img/settings2x.png" alt="Settings for a repository" width="489">
    </li>

    <li class="option-generate">
      <h4>Automatic Generator</h4>
      <p>Scroll down to the <strong>GitHub Pages</strong> module. Press the <strong>Automatic Page Generator</strong> button.</p>
      <img src="/assets/moxile/img/automatic2x.png" alt="Automatic Generator button on GitHub.com, Settings" width="520">
    </li>

    <li class="option-generate">
      <h4>Add content</h4>
      <p>Use the editor to add content to your site. If you already have a <code>README.md</code> in your project, you can import that on the right hand side.</p>
      <p>When you're done, click <strong>Continue to Layouts</strong>.</p>

      <img class="full-size" src="/assets/moxile/img/add-content2x.png" alt="Add content to your GitHub Pages site" width="681">
    </li>

    <li class="option-generate">
      <h4>Pick a theme</h4>
      <p>Choose between the themes in the carouselle at the top. When you're done, <strong>click the Publish button</strong> on the right hand side.</p>

      <img src="/assets/moxile/img/choose-layout2x.png" class="full-size" alt="Choose layout" width="610">
    </li>

    <!-- Start of vanilla sub tutorial -->
    <li id="vanilla-step-1" class="option-vanilla animate-in hidden">
      <h4>Create a gh-pages branch</h4>
      <p>Head over to <a href="https://github.com/">GitHub.com</a> and 
create a new repository, or go to an existing one. In the repository 
overview, click the branch drop-down on the left-hand side. Type in <code>gh-pages</code> and press enter.</p>

      <p class="details">For <strong>Project pages</strong>, the <code>gh-pages</code>
 branch is used to publish your site. That means that you can work with 
GitHub Pages in the same repository as the project that it's for.</p>
      <img src="/assets/moxile/img/create-branch2x.png" alt="Create a branch named gh-pages" width="525">
    </li>

    <li class="option-vanilla animate-in hidden">
      <h4>Optional: Make gh-pages the default branch</h4>
      <p>If you created a new branch for GitHub Pages, enter the 
repository settings on the right hand side. In the top module, change 
the default branch to the newly created <code>gh-pages</code> branch.</p>

      <img src="/assets/moxile/img/default-branch2x.png" alt="Change the default branch to gh-pages" width="851">
    </li>

    <li class="option-vanilla animate-in hidden">
      <h4>Create an index file</h4>
      <p>Go back to the repository overview, and use the plus icon next to the repository name to create a new file.</p>

      <img src="/assets/moxile/img/create-file2x.png" alt="Create a file in your repository" width="610">
    </li>

    <li class="option-vanilla animate-in hidden">
      <h4>Hello World</h4>
      <p>Name the file <code>index.html</code> and type in <code>Hello World</code> for the content.</p>

      <img src="/assets/moxile/img/hello-world2x.png" alt="Hello World on GitHub.com" width="518">
    </li>

    <li class="option-vanilla animate-in hidden">
      <h4>Commit the file</h4>
      <p>Scroll to the bottom of the page, write a commit message, and commit the new file.</p>

      <img src="/assets/moxile/img/commit-web2x.png" alt="Commit the file" width="627">
    </li>

    <li class="option-all">
      <h4>…and you're done!</h4>
      <p>Fire up a browser and go to <strong>http://<em>username</em>.github.io/<em>repository</em></strong>.</p>
      <div class="hero-octicon">
        <span class="mega-octicon octicon-check"></span>
      </div>
    </li>
  </ul>

</section>
<!-- End of tutorial section -->

<section id="next-steps">
  <h1>Now that you’re up and running, here are a few things you should know.</h1>

  <ul class="next-steps wrapper">
    <li class="jekyll">
      <a class="hero-octicon" href="/support">
        <span class="mega-octicon octicon-markdown"></span>
      </a>
      <h4><a href="/support">Writting with Moxile</a></h4>
      <p>Using Moxile, you can blog using beautiful Markdown syntax, and a lot of extensions, including Github Flavored Markdown Syntax. <a href="http://daringfireball.net/projects/markdown/syntax">Learn the standard markdown syntax</a>.</p>
    </li>
    <li class="custom-urls">
      <a class="hero-octicon" href="/support">
        <span class="mega-octicon octicon-paintcan"></span>
      </a>
      <h4><a href="/support">Custom Themes and Stylesheets</a></h4>
      <p>Want to use your own custom themes and stylesheets for Moxile? Just create a new theme in the preferences pane.</p>
    </li>
    <li class="guides">
      <a class="hero-octicon" href="/support">
        <span class="mega-octicon octicon-book"></span>
      </a>
      <h4><a href="/support">Shortcuts Cheatsheet</a></h4>
      <p>Moxile comes with a collection thoughtful shortcuts to improve your effectiency and experience <a href="/support">learn more about Moxile shortcuts</a>.</p>
    </li>
  </ul>
</section>

<script>window.slides = {"moxile-overview":"moxile01","moxile-edit":"moxile02","moxile03":"moxile03","moxile-viewer":"moxile04", "moxile-split":"moxile05"}</script>
