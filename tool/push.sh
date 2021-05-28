rm -rf .git
git init
git add .
git commit -m 'first commit'
git branch -M hexo
git remote add origin https://github.com/mhxw/mhxw.github.io.git
git push -u -f origin hexo