
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
		# Was @query ever saved???
		puts "Query id = #{@query.id}"
		if !@query.id.nil?
			@query.delete
		end

		# Delete the ui elements
		@query_ui_widgets.each do |widget|
			widget.destroy
			# TODO: this doesn't clean up the space
		end

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

			@query_ui_widgets = []

			@query_ui_widgets << name_label = TkLabel.new(f) {text "Query Name:"}
			@name_var = TkVariable.new
			@name_var.value = query.name
			@query_ui_widgets << name_entry = TkEntry.new(f, 'textvariable' => @name_var)

			@query_ui_widgets << type_label = TkLabel.new(f) {text "Type:"}
			@type_var = TkVariable.new
			@query_ui_widgets << type_combo = Tk::Tile::Combobox.new(f, 'textvariable' => @type_var)
			type_combo.values = ['zoql', 'zoqlexport']
			type_combo.state = 'readonly'
			type_combo.set(query.type)

			@query_ui_widgets << delete_button = TkButton.new(f) {text "Delete"}
			delete_button.command { delete_query }

			@query_ui_widgets << @query_text = TkText.new(f) {height 4}
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

# Python code that puts widgets in a canvas
# class Example(tk.Frame):
#     def __init__(self, root):

#         tk.Frame.__init__(self, root)
#         self.canvas = tk.Canvas(root, borderwidth=0, background="#ffffff")
#         self.frame = tk.Frame(self.canvas, background="#ffffff")
#         self.vsb = tk.Scrollbar(root, orient="vertical", command=self.canvas.yview)
#         self.canvas.configure(yscrollcommand=self.vsb.set)

#         self.vsb.pack(side="right", fill="y")
#         self.canvas.pack(side="left", fill="both", expand=True)
#         self.canvas.create_window((4,4), window=self.frame, anchor="nw", 
#                                   tags="self.frame")

#         self.frame.bind("<Configure>", self.OnFrameConfigure)

#         self.populate()

#     def populate(self):
#         '''Put in some fake data'''
#         for row in range(100):
#             tk.Label(self.frame, text="%s" % row, width=3, borderwidth="1", 
#                      relief="solid").grid(row=row, column=0)
#             t="this is the second colum for row %s" %row
#             tk.Label(self.frame, text=t).grid(row=row, column=1)

#     def OnFrameConfigure(self, event):
#         '''Reset the scroll region to encompass the inner frame'''
#         self.canvas.configure(scrollregion=self.canvas.bbox("all"))

# if __name__ == "__main__":
#     root=tk.Tk()
#     Example(root).pack(side="top", fill="both", expand=True)
#     root.mainloop()