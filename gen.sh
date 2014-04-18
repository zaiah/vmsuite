# vminstall
buildopts \
	--from "first-run" \
	--from "rebuild" \
	--from "@install,uninstall,@config"

# vmbuilder (is somewhat ok)

# vmimg
buildopts \
	--from "@location,@download" \
	--from "@alias,list" 

# vmmgr
buildopts \
	--from "list,@start,@stop,@restart,foreground,background,snapshot"

# vmnet
buildopts \
	--from "@list,netgroup,ip,nic,nictype,@in,add,remove,update,show"

# vmwatch
# ...
