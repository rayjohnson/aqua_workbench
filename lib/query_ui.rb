
class QueryUI
	def save_query(job)
		@query.name = @name_var.value
		@query.type = @type_var.value
		@query.query = @query_text.get("1.0", 'end').strip

		if @new_query
			job.add_query(@query)
		end
		@query.save
	end

	def delete_query
		# Defer the actual delete until save - so it still exists if we cancel
		if !@query.id.nil?
			@job_ui.queries_to_delete << @query
		end

		# Delete the query frame
		@my_frame.grid_forget
		@my_frame.destroy

		# Remove reference to this object from job_ui
		@job_ui.query_editors = @job_ui.query_editors - [self]
	end

	def initialize(job_ui, query, query_frame)
			if query.nil?
				query = Query.new
				query.name = "New query"
				query.type = "zoqlexport"
				query.apiVersion = "64.0"
				@new_query = true
			end
			@query = query
			@job_ui = job_ui

			# All widgets for the query fit into this frame
			# we add the frame to the grid without specifying row
			f = TkFrame.new(query_frame)
			f.grid :column => 0, :sticky => 'ew'
			@my_frame = f

			name_label = TkLabel.new(f) {text "Query Name:"}
			@name_var = TkVariable.new
			@name_var.value = query.name
			name_entry = TkEntry.new(f, 'textvariable' => @name_var)
			# TODO: need to make a max of 32 chares

			type_label = TkLabel.new(f) {text "Type:"}
			@type_var = TkVariable.new
			type_combo = Tk::Tile::Combobox.new(f, 'textvariable' => @type_var)
			type_combo.values = ['zoql', 'zoqlexport']
			type_combo.state = 'readonly'
			type_combo.set(query.type)

			delete_button = TkButton.new(f) {text "Delete"}
			delete_button.command { delete_query }

			@query_text = TkText.new(f) {height 4}
			@query_text.insert(1.0, query.query)
			@query_text.wrap = 'word'

			name_label.grid :column => 0, :row => 0
			name_entry.grid :column => 1, :row => 0, :sticky => 'ew'
			type_label.grid :column => 2, :row => 0
			type_combo.grid :column => 3, :row => 0
			delete_button.grid :column => 4, :row => 0
			@query_text.grid :column => 0, :row => 1, :columnspan => 5, :sticky => 'ew'

			TkGrid.columnconfigure( f, 1, :weight => 1 )
	end
end
