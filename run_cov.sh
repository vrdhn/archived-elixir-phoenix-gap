#!/bin/sh


mix clean
mix coveralls | sed -n '/^[-]\{3,\}$/,/^[-]\{3,\}$/p' > coverage.txt
mix coveralls
git diff coverage.txt 
