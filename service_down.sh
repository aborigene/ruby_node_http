#!/bin/bash
NODE_PID=`ps -ef | grep node | grep -v grep | awk '{print $2}'`
RUBY_SERVER_PID=`ps -ef | grep server.rb | grep -v grep | awk '{print $2}'`
kill -9 $NODE_PID
kill -9 $RUBY_SERVER_PID
