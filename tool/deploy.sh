hexo generate
cd public
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/mhxw/mhxw.github.io.git
git push -u -f origin main
cd ..
rm -rf public