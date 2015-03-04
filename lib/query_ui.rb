
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
		# TODO: this deletes from DB - so you can't cancel deletes you make.
		# Ideally this should lose the UI but not delete from the DB until cancel is hit
		puts "Query id = #{@query.id}"
		if !@query.id.nil?
			@query.delete
		end

		# Delete the query frame
		@my_frame.grid_forget
		@my_frame.destroy

		# Remove reference to this object from job_ui
		@job_ui.query_editors = @job_ui.query_editors - [self]
	end

	def initialize(job_ui, query, f)
			if query.nil?
				query = Query.new
				query.name = "New query"
				query.type = "zoqlexport"
				query.apiVersion = "64.0"
				@new_query = true
			end
			@query = query
			@job_ui = job_ui

			@my_frame = f


			name_label = TkLabel.new(f) {text "Query Name:"}
			@name_var = TkVariable.new
			@name_var.value = query.name
			name_entry = TkEntry.new(f, 'textvariable' => @name_var)

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
