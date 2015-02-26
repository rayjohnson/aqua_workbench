

class JobUI
	def job_with_defaults
		# Set defaults
		job = Job.new
		# TODO: ensure name is unique?
		job.name = "New job"
		job.version = "1.1"
		job.encrypted = "none"

		return job
	end


	def save_job(job, t)
		job.name = @name_entry.value
		job.format = @format_entry.value
		job.version = @version_entry.value
		job.encrypted = @encrypted_entry.value
		job.partner = @partner_entry.value
		job.project = @project_entry.value

		job.save
		t.destroy
		update_job_list
	end

	def initialize(job, parent)

		if job.nil?
			job = job_with_defaults
		end

		t = TkToplevel.new(parent)
		t['title'] = "AQuA Job"

		name_label = TkLabel.new(t) {text "Job name:"}
		@name_entry = TkEntry.new(t) {  }
		@name_entry.insert(0, job.name)

		# Todo: combo?
		format_label = TkLabel.new(t) {text "Format:"}
		@format_entry = TkEntry.new(t) {  }
		@format_entry.insert(0, job.format)

		version_label = TkLabel.new(t) {text "Version:"}
		@version_entry = TkEntry.new(t) {  }
		@version_entry.insert(0, job.version)
		
		encrypted_label = TkLabel.new(t) {text "Encrypted:"}
		@encrypted_entry = TkEntry.new(t) {  }
		@encrypted_entry.insert(0, job.encrypted)
		
		partner_label = TkLabel.new(t) {text "Partner:"}
		@partner_entry = TkEntry.new(t) {  }
		@partner_entry.insert(0, job.partner)
		
		project_label = TkLabel.new(t) {text "Project:"}
		@project_entry = TkEntry.new(t) {  }
		@project_entry.insert(0, job.project)

		f = TkFrame.new(t)
		run = TkButton.new(f) {
			text "Save & Run"
			pack('padx' => 10, 'pady' => 10, :side => 'right')
		}
		run.command {save_job(job, t)}

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

		name_label.grid :column => 0, :row => 0
		@name_entry.grid :column => 1, :row => 0, :sticky => 'ew'
		format_label.grid :column => 0, :row => 1
		@format_entry.grid :column => 1, :row => 1, :sticky => 'ew'
		version_label.grid :column => 0, :row => 2
		@version_entry.grid :column => 1, :row => 2, :sticky => 'ew'
		encrypted_label.grid :column => 0, :row => 3
		@encrypted_entry.grid :column => 1, :row => 3, :sticky => 'ew'
		partner_label.grid :column => 0, :row => 4
		@partner_entry.grid :column => 1, :row => 4, :sticky => 'ew'
		project_label.grid :column => 0, :row => 5
		@project_entry.grid :column => 1, :row => 5, :sticky => 'ew'

		f.grid :column => 0, :row => 6, :columnspan => 2, :sticky => 'e'

		TkGrid.columnconfigure( t, 1, :weight => 1 )

		@win = t
	end


end