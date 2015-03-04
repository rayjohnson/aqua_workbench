

class JobUI
	def job_with_defaults
		# Set defaults
		job = Job.new
		# TODO: ensure name is unique?
		job.name = "New job"
		job.version = "1.1"
		job.encrypted = "none"
		job.format = "csv"
		job.save_path = "#{Dir.home}/Downloads/"

		return job
	end

	def delete_job(job, t)
		job.queries.each do |q|
			q.delete
		end
		job.delete
		t.destroy
		update_job_references(nil)
	end

	def save_job(job, t)
		job.name = @name_entry.value.strip
		job.format = @format_combo.get
		job.version = @version_entry.value
		job.encrypted = @encrypted_combo.get
		job.partner = @partner_entry.value.strip
		job.project = @project_entry.value.strip

		if job.partner == ""
			job.partner = nil
		end
		if job.project == ""
			job.project = nil
		end

		# Delete any queries marked for deletion
		@queries_to_delete.each do |q|
			q.delete
		end

		job.save

		@query_editors.each do |qe|
			qe.save_query(job)
		end

		t.destroy
		update_job_references(job)
	end

	def select_save_dir(job, t)
		bdir=Tk.chooseDirectory(:parent => t)
		job.save_path = bdir
		@folder_label.text bdir
	end

	def build_query_editors(job)
		@canvas = TkCanvas.new(@query_frame) {borderwidth 0}
		@scrollbar = @canvas.yscrollbar(TkScrollbar.new(@query_frame))

		@canvas.grid :column => 0, :sticky => 'nsew'
		@scrollbar.grid :column => 1, :row => 0, :sticky => 'ns'

		# Our query widgets will be placed on a frame within a canvas
		# That way we can scroll the frame and have many more queries
		# than would otherwise fit on the screen
		@internal_query_frame = TkFrame.new(@canvas)

		@cwin = TkcWindow.new(@canvas, 4, 4)
		@cwin.anchor = 'nw'
		@cwin.window(@internal_query_frame)

		@internal_query_frame.bind( "Configure", proc {onConfigure})
		@query_frame.bind( "Configure", proc {onWidthConfigure})

		query_editors = []

		if job.queries.length == 0
			# If we have none - create a frame and pass nil to get em started
			add_query_editor(nil)
		else
			job.queries.each do |query|
				add_query_editor(query)
			end
		end
		
		TkGrid.columnconfigure( @query_frame, 0, :weight => 1 )
		TkGrid.rowconfigure( @query_frame, 0, :weight => 1 )
		TkGrid.columnconfigure( @internal_query_frame, 0, :weight => 1 )

		return query_editors
	end

	def onWidthConfigure
		# This forces the frame inside the canvas to resize when the canvas resizes
		@cwin.width = @query_frame.winfo_width - @scrollbar.winfo_width
	end


	def onConfigure
		# If the frame inside the canvas grows or shrinks we need to adjust the scrollable area
		@canvas.scrollregion(@canvas.bbox('all'))
	end

	# Add a new query UI - query may be nil indicating a new query not yet saved
	# to the DB
	def add_query_editor(query)
		@query_editors << QueryUI.new(self, query, @internal_query_frame)
	end

	attr_accessor :query_editors
	attr_accessor :queries_to_delete

	def initialize(job, parent)

		if job.nil?
			job = job_with_defaults
		end

		t = TkToplevel.new(parent)
		t['title'] = "AQuA Job"

		name_label = TkLabel.new(t) {text "Job name:"}
		@name_entry = TkEntry.new(t) {  }
		@name_entry.insert(0, job.name)

		format_label = TkLabel.new(t) {text "Format:"}

		@format_var = TkVariable.new
		@format_combo = Tk::Tile::Combobox.new(t, 'textvariable' => @format_var)
		@format_combo.state = 'readonly'
		@format_combo.values = ["csv", "zip", "gzip"]
		@format_combo.set job.format

		version_label = TkLabel.new(t) {text "Version:"}
		@version_entry = TkEntry.new(t) {  }
		@version_entry.insert(0, job.version)
		
		encrypted_label = TkLabel.new(t) {text "Encrypted:"}

		@encrypted_var = TkVariable.new
		@encrypted_combo = Tk::Tile::Combobox.new(t, 'textvariable' => @encrypted_var)
		@encrypted_combo.state = 'readonly'
		@encrypted_combo.values = ["none", "pgp"]
		@encrypted_combo.set job.encrypted

		partner_label = TkLabel.new(t) {text "Partner:"}
		@partner_entry = TkEntry.new(t) {  }
		@partner_entry.insert(0, job.partner)
		
		project_label = TkLabel.new(t) {text "Project:"}
		@project_entry = TkEntry.new(t) {  }
		@project_entry.insert(0, job.project)

		@query_frame = TkFrame.new(t)
		@query_editors = []
		@queries_to_delete = []
		build_query_editors(job)

		folder_button = TkButton.new(t) {text 'Folder'}
		folder_button.command proc{select_save_dir(job, t)}
		@folder_label = TkLabel.new(t, :anchor => 'w')
		@folder_label.text job.save_path

		f = TkFrame.new(t)
		delete = TkButton.new(f) {
			text "Delete"
			pack('padx' => 10, 'pady' => 10, :side => 'right')
		}
		delete.command {delete_job(job, t)}

		save = TkButton.new(f) {
			text "Save & Close"
			pack('padx' => 10, 'pady' => 10, :side => 'right')
		}
		save.command {save_job(job, t)}

		cancel = TkButton.new(f) {
			text "Cancel"
			command proc{t.destroy}
			pack('padx' => 10, 'pady' => 10, :side => 'right')
		}

		addQuery = TkButton.new(f) {
			text "Add Query"
			pack('padx' => 10, 'pady' => 10, :side => 'right')
		}
		addQuery.command { add_query_editor(nil) }

		name_label.grid :column => 0, :row => 0
		@name_entry.grid :column => 1, :row => 0, :columnspan => 3, :sticky => 'ew'
		format_label.grid :column => 0, :row => 1
		@format_combo.grid :column => 1, :row => 1
		encrypted_label.grid :column => 2, :row => 1
		@encrypted_combo.grid :column => 3, :row => 1, :sticky => 'w'
		version_label.grid :column => 0, :row => 2
		@version_entry.grid :column => 1, :row => 2, :columnspan => 3, :sticky => 'ew'
		partner_label.grid :column => 0, :row => 3
		@partner_entry.grid :column => 1, :row => 3, :columnspan => 3, :sticky => 'ew'
		project_label.grid :column => 0, :row => 4
		@project_entry.grid :column => 1, :row => 4, :columnspan => 3, :sticky => 'ew'
		folder_button.grid :column => 0, :row => 5
		@folder_label.grid :column => 1, :row => 5, :columnspan => 3, :sticky => 'ew'

		@query_frame.grid :column => 0, :row => 6, :columnspan => 4, :sticky => 'nsew'

		f.grid :column => 0, :row => 7, :columnspan => 4, :sticky => 'e'

		TkGrid.columnconfigure( t, 3, :weight => 1 )
		TkGrid.rowconfigure( t, 6, :weight => 1 )

		@win = t
	end
end
