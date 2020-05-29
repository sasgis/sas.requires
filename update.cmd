@echo off

set hidden=!git
set log=.log

git version

if not exist %log%\ (
    mkdir %log%
)

for /f "usebackq tokens=1-3 delims=," %%a in ("meta.csv") do (
    
    echo.
    echo %%a %%b %%c
    echo.
    
    if not exist %%a (
        mkdir %%a
    )
    
    cd %%a
    
    if not exist .git\ (
        if exist %hidden%\ (
            rename %hidden% .git
        )
    )
    
    if not exist .git\ (
        git init
        git remote add origin %%b
    )    
        
    git fetch --all --verbose
    git clean -d -x --force    
    git reset --hard %%c
    
    git log > ..\%log%\%%a.txt
    
    attrib -s -h ".git"
    rename ".git" %hidden%    
    
    cd ..
)

echo.

pause
