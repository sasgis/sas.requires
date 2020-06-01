@echo off

set hidden=!git

git version

for /f "usebackq tokens=1-5 delims=," %%a in ("sync.csv") do (
    
    echo.
    echo %%a %%b %%c %%d %%e
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
    ) else (
        git remote remove upstream
    )
    
    git remote add upstream %%d
    git remote --verbose show
        
    git fetch --all --verbose
    git clean -d -x --force
    git reset --hard upstream/%%e    
    git push origin %%c --force 
    
    cd ..
)

echo.

call update
