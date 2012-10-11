# Cookbook for a new Django Project

This cookbook is intended to be used with [Django Newproj Template](https://github.com/jbergantine/django-newproj-template).

## Requires

See the configuration instructions in the [Django Newproj Template](https://github.com/jbergantine/django-newproj-template).

## Git Hooks Created

### post-merge

A hook that runs every time a merge is made. A merge will happen every time `$ git pull` is executed (and there are changes to be brought in; it won't happen if there are no changes) in addition to the explicit `$ git merge` command. This hook will compile stylesheets, sync and migrate the database. This hook lives in `.git/hooks/post-merge` and can be disabled by either removing the file (`post-merge`) or making it non-executable. If you want to use Scout to compile SASS or use Tower or a similar application to manage Git you will want to disable or remove this hook as it relies on the presence of SASS, Compass, Susy, Django and a database among other things.

## Stylesheets Created

This project utilizes the [Compass](http://compass-style.org) [SASS](http://sass-lang.com) framework and creates a stylesheet directory following the requirements of that application. CSS files will be created in the appropriate spots the first time you run either ``compass watch static_media/stylesheets`` or ``compass compile static_media/stylesheets``. The [bash shortcut ``cw``](#compass) is set up to reduce keyboard fatigue.

### _base.sass

This is where mixins and variables are defined. This also imports compass to the project.

### screen.sass

The main stylesheet. This imports ``_base.sass``, calls a reset and begins defining the styles for elements, classes and ids.

### print.sass

A stylesheet specifically for print styling. Meant to be used in a way that styles defined here override ``screen.sass``.

* In ``myproject/static_media/stylesheets/sass/print.sass``, replace ``siteURL.com`` with the site's domain name.

### ie.sass

A stylesheet specifically for dealing with modifications necessary for Internet Explorer. Meant to be used in a way that styles defined here override screen.sass.

## JavaScript Files Created

When you run the script to create the project, the script downloads the latest version of jQuery (which is then referenced both locally and via Google's AJAX load in base.html) as well as a customized basic version of modernizr.js which includes only the shims for the HTML5 doctype.

## Bash Aliases

The following bash aliases are added to the shell. 

### Compass

<table>
    <tr>
        <th>cw</th>
        <td><pre>compass watch myproject/static_media/stylesheets</pre></td>
    </tr>
</table>

### Django

<table>
    <tr>
        <th>dj</th>
        <td>
            <pre>python manage.py</pre>
            <p>Example usage, interact with the Django shell:</p>
            <pre>dj shell</pre>
        </td>
    </tr>
</table>
<table>
    <tr>
        <th>rs</th>
        <td>
            <pre>python manage.py runserver [::]:8000</pre>
            <p>This is necessary to enable port forwarding from the virtual machine to the host. In a host the site will now be available at http://127.0.0.1:8001.</p>
        </td>
    </tr>
    <tr>
        <th>sh</th>
        <td><pre>python manage.py shell</pre></td>
    </tr>
</table>

### Python

<table>
    <tr>
        <th>py</th>
        <td>
            <pre>python</pre>
            <p>Launches a Python interactive shell.</p>
        </td>
    </tr>
    <tr>
        <th>pyclean</th>
        <td>
            <pre>find . -name "*.pyc" -delete</pre>
            <p>Removes all files ending in ".pyc".</p>
        </td>
    </tr>
</table>
