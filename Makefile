SRV = night-script.service
ENV = /etc/default/night_script
SERVICE_DIR = /etc/systemd/system

install:
	sed -e "s|@SCRIPT_PATH@|$(PWD)/night_script.sh|" \
		$(SRV) | sudo tee $(SERVICE_DIR)/$(SRV)
	sudo cp night_script.env $(ENV)
	sudo systemctl daemon-reload	
	sudo systemctl enable $(SRV)

uninstall:
	sudo systemctl disable $(SRV)
	sudo rm -f $(SERVICE_DIR)/$(SRV) $(ENV)


.PHONY: install uninstall
