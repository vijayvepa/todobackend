#brew install homebrew/versions/mysql56
brew install mysql@5.6
echo 'export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"' >> ~/.bash_profile
brew services start mysql@5.6
/usr/local/opt/mysql@5.6/bin/mysql.server start