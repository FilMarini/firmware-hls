core_file = cfg/include_cores.tcl
core_dir = cgn
core_append = /impl/ip/component.xml
core_path = ../../../src/firmware-hls/firmware

CORE_DIRS_WF= $(wildcard $(core_dir)/*/*)
CORE_DIRS = $(filter-out $(wildcard $(core_dir)/*/vivado_hls.app), $(CORE_DIRS_WF))
CORE_FILES = $(addsuffix $(core_append), $(CORE_DIRS))



$(core_file):
	@echo -e "source ../../../src/firmware-hls/firmware/cfg/ip_tools.tcl" >> $(core_file);
	@$(foreach core,$(CORE_FILES),echo -e "tool_add_core -level 0 $(core_path)/$(core)" >> $(core_file);)	
