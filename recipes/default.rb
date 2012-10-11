# Setup VirtualenvWrapper
python_pip "virtualenvwrapper" do
  action :install
  not_if "test -e /usr/local/bin/virtualenvwrapper.sh"
end

bash "configure virtualenvwrapper" do
  user "vagrant"
  code <<-EOH
    echo "export WORKON_HOME=/home/vagrant/.virtualenvs" >> /home/vagrant/.profile
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.profile
    echo "workon djangoproj" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep /home/vagrant/.virtualenvs"
end

# Create the Virtual Environment
python_virtualenv "/home/vagrant/.virtualenvs/djangoproj" do
  interpreter "python2.7"
  owner "vagrant"
  action :create
  not_if "test -d /home/vagrant/.virtualenvs/djangoproj"
end

# Create Bash Aliases
bash "create aliases" do
  user "vagrant"
  code <<-EOH
    echo "alias cw='compass watch myproject/static_media/stylesheets'" >> /home/vagrant/.profile
    echo "alias sh='python manage.py shell'" >> /home/vagrant/.profile
    echo "alias rs='python manage.py runserver [::]:8000'" >> /home/vagrant/.profile
    echo "alias dj='python manage.py'" >> /home/vagrant/.profile
    echo "alias py='python'" >> /home/vagrant/.profile
    echo "alias pyclean='find . -name \"*.pyc\" -delete'" >> /home/vagrant/.profile
    echo "alias ga='git add'" >> /home/vagrant/.profile
    echo "alias gb='git branch'" >> /home/vagrant/.profile
    echo "alias gco='git checkout'" >> /home/vagrant/.profile
    echo "alias gl='git pull'" >> /home/vagrant/.profile
    echo "alias gp='git push'" >> /home/vagrant/.profile
    echo "alias gst='git status'" >> /home/vagrant/.profile
    echo "alias gss='git status -s'" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep compass"
end

# Set Database permissions
bash "database permissions" do
  code <<-EOH
    echo "local all all md5" >> /etc/postgresql/9.1/main/pg_hba.conf
  EOH
  not_if "cat /etc/postgresql/9.1/main/pg_hba.conf | grep 'local all all md5'"
end

# Configure Git
bash "configure git" do
  code <<-EOH
    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.interactive auto
    git config --global color.status auto
    git config --global merge.summary true
    git config --global alias.st status
    git config --global alias.ci commit
    git config --global alias.co checkout
    git config --global alias.br branch
  EOH
  not_if "git config --get color.diff"
end

# Create Symlinks for PIL
bash "create symlinks" do
  code <<-EOH
    sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
  EOH
  not_if "ls /usr/lib | grep libz.so"
end

# Create the Database
bash "create database" do
  code <<-EOH
    echo "CREATE USER django_login WITH SUPERUSER PASSWORD 'secret';" | sudo -u postgres psql
    sudo -u postgres createdb -O django_login -E UTF8 --lc-ctype=en_US.utf8 --lc-collate=en_US.utf8 -T template0 django_db
  EOH
  not_if "sudo -u postgres psql -l | grep django_db"
end

# Install Compass / Susy
gems = Array.new

gems |= %w/
  compass
  susy
/

gems.each do |gem|
  gem_package gem do
    action :install
  end
end

# Install Python packages and start the Django project
bash "install packages and start project" do
  user "vagrant"
  code <<-EOH
    virtualenv /home/vagrant/.virtualenvs/djangoproj
    source /home/vagrant/.virtualenvs/djangoproj/bin/activate
    pip install -r https://raw.github.com/jbergantine/django-newproj-template/master/stable-req.txt
    cd /vagrant
    django-admin.py startproject --template=https://github.com/jbergantine/django-newproj-template/zipball/master --extension=py,rst myproject
    cd /vagrant/myproject
    chmod u+x manage.py
    echo "export DJANGO_SETTINGS_MODULE=myproject.settings.dev" >> $VIRTUAL_ENV/bin/postactivate
    echo "unset DJANGO_SETTINGS_MODULE" >> $VIRTUAL_ENV/bin/postdeactivate
    echo "cd /vagrant/myproject" >> /home/vagrant/.profile
  EOH
  not_if "test -d /home/vagrant/.virtualenvs/djangoproj/lib/python2.7/site-packages/django"
end

# Init Git Project and install post-merge hook
bash "congiure git" do
  user "vagrant"
  code <<-EOH
    cd /vagrant
    git init
    cd /vagrant/.git/hooks
    wget https://raw.github.com/gist/3870080/c5a55674901db6b901cf3f6a4a11b28b0dde2738/gistfile1.sh -O post-merge
    chmod u+x post-merge
  EOH
  not_if "ls /vagrant/.git/hooks | grep post-merge"
end

# Configure Static Media
bash "configure static media" do
  user "vagrant"
  code <<-EOH
    cd /vagrant/myproject/myproject
    mkdir -p media static static_media static_media/javascripts/libs
    cd static_media
    compass create stylesheets --syntax sass -r susy -u susy
    cd stylesheets/sass
    rm _base.sass screen.sass
    git clone https://github.com/jbergantine/compass-gesso/ .
    touch /vagrant/myproject/myproject/static_media/stylesheets/sass/ie.sass
    cd /vagrant/myproject/myproject/static_media/javascripts/libs
    wget http://code.jquery.com/jquery-1.8.1.min.js
    wget https://raw.github.com/gist/3868451/a313411f080ab542a703b805e4d1494bcbf23a0b/gistfile1.js -O modernizr.js
  EOH
  not_if "ls /vagrant/myproject/myproject | static_media"
end
