#!/bin/bash
# list-glob.sh

svn=/usr/bin/svn
cwd=`pwd`

for i in ./*
do
    cd $i
    $svn up --set-depth infinity trunk
    $svn up --set-depth immediates branches/
    $svn up --set-depth infinity branches/1.6
    cd $cwd
done
