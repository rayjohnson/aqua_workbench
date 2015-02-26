# Code for manage connection settings

def newAquaConfig(parent)
	# TODO: support an edit mode

	t = TkToplevel.new(parent)
	t['title'] = "Create AQuA Config"

	name_label = TkLabel.new(t) {text "Connection name:"}
	name_entry = TkEntry.new(t) {}

	user_label = TkLabel.new(t) {text "Zuora User Name:"}
	user_entry = TkEntry.new(t) {}
	pw_label = TkLabel.new(t) {text "Zuora Password:"}
	pw_entry = TkEntry.new(t) {}

	$connection_environment = TkVariable.new
	$connection_environment.value = 'sandbox'
	env_label = TkLabel.new(t) {text "Environment:"}
	env_f = TkFrame.new(t)
	env_sandbox = TkRadioButton.new(env_f) {
		text 'Sandbox'; variable $connection_environment; value 'sandbox'; pack(:side => 'top', :anchor => 'w')
	}
	env_sandbox = TkRadioButton.new(env_f) {
		text 'Production'; variable $connection_environment; value 'prod'; pack(:side => 'top', :anchor => 'w')
	}

	save = TkButton.new(t) {
		text "Save"
		command proc{save_connection(t, name_entry, user_entry, pw_entry)}
	} 
	cancel = TkButton.new(t) {
		text "Cancel"
		command proc{t.destroy}
	} 

	name_label.grid :column => 0, :row => 0
	name_entry.grid :column => 1, :row => 0, :sticky => 'ew'
	user_label.grid :column => 0, :row => 1
	user_entry.grid :column => 1, :row => 1, :sticky => 'ew'
	pw_label.grid :column => 0, :row => 2
	pw_entry.grid :column => 1, :row => 2, :sticky => 'ew'

	env_label.grid :column => 0, :row => 3
	env_f.grid :column => 1, :row => 3, :sticky => 'w'

	save.grid :column => 0, :row => 4
	cancel.grid :column => 1, :row => 4

	TkGrid.columnconfigure( t, 1, :weight => 1 )

end

def save_connection(toplevel, name_entry, user_entry, pw_entry)
	# TODO: some validation - like if name already exists (or make it ident?)

	aqua_config = Connection.new({
		:name => name_entry.get,
		:username => user_entry.get,
		:password => pw_entry.get,
		:environment => $connection_environment.value
		})
	aqua_config.save

	update_config_menu
	toplevel.destroy
end


