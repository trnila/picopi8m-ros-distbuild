#!/bin/sh

catkin_ws_path=/root/catkin_ws/

if [ -f "$catkin_ws_path/devel/setup.sh" ]; then
	. "$catkin_ws_path/devel/setup.sh" 
fi

if [ -f "$catkin_ws_path/src/tools/setup.bash" ]; then
	. "$catkin_ws_path/src/tools/setup.bash" 
fi

unset catkin_ws_path

