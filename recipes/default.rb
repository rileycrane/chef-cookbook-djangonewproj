# Setup VirtualenvWrapper
python_pip "virtualenvwrapper" do
  action :install
  not_if "test -e /usr/local/bin/virtualenvwrapper.sh"
end

bash "configure virtualenvwrapper" do
  user "vagrant"
  code <<-EOH
    echo "export WORKON_HOME=/vagrant/.virtualenvs" >> /home/vagrant/.profile
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.profile
    echo "workon djangoproj" >> /home/vagrant/.profile
    echo "cd /vagrant/.virtualenvs/djangoproj" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep virtualenvwrapper.sh"
end

# Create the Virtual Environment
python_virtualenv "/vagrant/.virtualenvs/djangoproj" do
  interpreter "python2.7"
  owner "vagrant"
  action :create
  not_if "test -d /vagrant/.virtualenvs/djangoproj"
end

# Create Bash Aliases
bash "create aliases" do
  user "vagrant"
  code <<-EOH
    echo "alias cw='compass watch myproject/static_media/stylesheets'" >> /home/vagrant/.profile
    echo "alias py='python manage.py shell'" >> /home/vagrant/.profile
    echo "alias rs='python manage.py runserver [::]:8000'" >> /home/vagrant/.profile
    echo "alias dj='python manage.py '" >> /home/vagrant/.profile
  EOH
  not_if "cat /home/vagrant/.profile | grep compass"
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
  #user "vagrant"
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

# Load virtualenv requirements
bash "Initial loading of virtualenv requirements" do
  user "vagrant"
  code <<-EOH
    source /vagrant/.virtualenvs/djangoproj/bin/activate
    cd /vagrant/.virtualenvs/djangoproj
    pip install -r https://raw.github.com/jbergantine/django-newproj/master/default-requirements.txt
    django-admin.py startproject --template=https://github.com/jbergantine/django-newproj-template/zipball/master --extension=py,rst myproject
  EOH
  not_if "test -d /vagrant/.virtualenvs/djangoproject/lib/python2.7/site-packages/django"
end

