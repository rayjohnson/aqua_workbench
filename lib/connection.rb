# Code for manage connection settings

class ConnectionUI
	def initialize(connection, parent)
		# TODO: support an edit mode

		t = TkToplevel.new(parent)
		t['title'] = "Create AQuA Connection"

		if connection.nil?
			connection = Connection.new
		end

		name_label = TkLabel.new(t) {text "Connection name:"}
		@name_entry = TkEntry.new(t) {}
		@name_entry.insert(0, connection.name)

		user_label = TkLabel.new(t) {text "Zuora User Name:"}
		@user_entry = TkEntry.new(t) {}
		@user_entry.insert(0, connection.username)

		pw_label = TkLabel.new(t) {text "Zuora Password:"}
		@pw_entry = TkEntry.new(t) {}
		@pw_entry.insert(0, connection.password)

		@connection_environment = TkVariable.new
		@connection_environment.value = 'sandbox'
		env_label = TkLabel.new(t) {text "Environment:"}
		env_f = TkFrame.new(t)
		env_sandbox = TkRadioButton.new(env_f) { text 'Sandbox'; value 'sandbox'; pack(:side => 'top', :anchor => 'w') }
		env_sandbox.variable = @connection_environment
		env_prod = TkRadioButton.new(env_f) { text 'Production'; value 'prod'; pack(:side => 'top', :anchor => 'w') }
		env_prod.variable = @connection_environment

		save = TkButton.new(t) { text "Save" }
		save.command {save_connection(connection, t)}

		cancel = TkButton.new(t) {
			text "Cancel"
			command proc{t.destroy}
		}

		delete = TkButton.new(t) { text "Delete" }
		delete.command {delete_connection(connection, t)}


		name_label.grid :column => 0, :row => 0
		@name_entry.grid :column => 1, :row => 0, :sticky => 'ew', :columnspan => 2
		user_label.grid :column => 0, :row => 1
		@user_entry.grid :column => 1, :row => 1, :sticky => 'ew', :columnspan => 2
		pw_label.grid :column => 0, :row => 2
		@pw_entry.grid :column => 1, :row => 2, :sticky => 'ew', :columnspan => 2

		env_label.grid :column => 0, :row => 3
		env_f.grid :column => 1, :row => 3, :sticky => 'w'

		save.grid :column => 0, :row => 4
		cancel.grid :column => 1, :row => 4
		delete.grid :column => 2, :row => 4

		TkGrid.columnconfigure( t, 1, :weight => 1 )
	end

	def delete_connection(connection, toplevel)
		connection.delete
		update_connection_references
		toplevel.destroy
	end

	def save_connection(connection, toplevel)
		# TODO: some validation - like if name already exists (or make it ident?)

		connection.name = @name_entry.get
		connection.username = @user_entry.get
		connection.password = @pw_entry.get
		connection.environment = @connection_environment.value
		connection.save

		update_connection_references
		toplevel.destroy
	end
end

