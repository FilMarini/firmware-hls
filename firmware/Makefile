core_file = cfg/include_cores.tcl
core_dir = cgn
core_append = /impl/ip/component.xml
core_path = ../../../src/firmware-hls/firmware
hls_script_path = ../IntegrationTests/ReducedConfig/IRtoTB/script

all: $(core_file) hls_add_files

$(core_dir):
	@mkdir cgn
	cd $(hls_script_path); vivado_hls -f compileHLSforEMP.tcl;

$(core_file): $(core_dir)
	@$(eval CORE_DIRS_WF= $(wildcard $(core_dir)/*/*))
	@$(eval CORE_DIRS = $(filter-out $(wildcard $(core_dir)/*/vivado_hls.app), $(CORE_DIRS_WF)))
	@$(eval CORE_FILES = $(addsuffix $(core_append), $(CORE_DIRS)))
	@echo -e "source ../../../src/firmware-hls/firmware/cfg/ip_tools.tcl" >> $(core_file);
	@$(foreach core,$(CORE_FILES),echo -e "tool_add_core -level 0 $(core_path)/$(core)" >> $(core_file);)	

hdl_add_files: $(core_file)
	cd hdl; ln -s ../$(hls_script_path)/../hdl/*.vhd .

.PHONY: hls_add_files
