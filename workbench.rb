
require 'tk'
require 'tkextlib/tktable'
require 'sqlite3'
require 'sequel'

require './lib/db'
require './lib/connection'
require './lib/menus'
require './lib/job'
require './lib/zuora_aqua'
require './lib/query_runner'

class Workbench
	def run_job
		# TODO: button should be disabled if nothing to run
		# TODO: ensure names are unique
		if @connection_var.value.empty? || @job_var.value.empty?
			return
		end

		connection = Connection.where(:name => @connection_var.value).first
		job = Job.where(:name => @job_var.value).first

		run_query(connection, job)
	end

  	attr_reader :connection_combo
  	attr_reader :job_combo
    attr_accessor :connection_var
    attr_accessor :job_var

	def initialize(frame)

		connection_label =TkLabel.new(frame) {text "Select Connection:"}

		@connection_var = TkVariable.new
		@connection_combo = Tk::Tile::Combobox.new(frame, 'textvariable' => @connection_var)
		@connection_combo.values = ['zoql', 'zoqlexport'] # TODO - get list of jobs
		@connection_combo.state = 'readonly'

		job_label =TkLabel.new(frame) {text "Select Job:"}

		@job_var = TkVariable.new
		@job_combo = Tk::Tile::Combobox.new(frame, 'textvariable' => @job_var)
		@job_combo.values = ['zoql', 'zoqlexport'] # TODO - get list of jobs
		@job_combo.state = 'readonly'
		#job_combo.set(query.type)

		run_button = TkButton.new(frame) { text "Run" }
		run_button.command {run_job}

		result_label =TkLabel.new(frame) {text "Results:"}
		results_table = nil  # TODO: TkTable

    refresh_button = TkButton.new(frame) { text "Refresh" }
    refresh_button.command {check_results}


results = Result.all

ary  = TkVariable.new_hash
puts "Results: #{results.length}"
rows = results.length + 1
cols = 5

ary[0,0] = "Start Time"
ary[0,1] = "Partner"
ary[0,2] = "Project"
ary[0,3] = "Status"
ary[0,4] = "FileId"

row = 1
results.each do |result|
	ary[row,0] = result.startTime
	ary[row,1] = result.partner
	ary[row,2] = result.project
	ary[row,3] = result.status
	#ary[row,4] = result.fileId
	row = row + 1
end
if rows < 6
  rows = 6
end

#TODO: make hyper link - font with underline perhaps, code for double click?
# remove focus ring
table = Tk::TkTable.new(:rows=>rows, :cols=>cols, :variable=>ary,
                        :width=>6, :height=>6,
                        :titlerows=>1,
                        :roworigin=>0, :colorigin=>0,
                        :rowtagcommand=>proc{|row|
                          row = Integer(row)
                          (row>0 && row%2 == 1)? 'OddRow': ''
                        },
                        :selectmode=>:extended,
                        :colstretchmode=>:all,
                        :state=>:disabled,
                        :selecttype => :row)
 sx = table.xscrollbar(TkScrollbar.new)
 sy = table.yscrollbar(TkScrollbar.new)



		connection_label.grid :column => 0, :row => 0
		@connection_combo.grid :column => 0, :row => 1
		job_label.grid :column => 1, :row => 0
		@job_combo.grid :column => 1, :row => 1
		run_button.grid :column => 2, :row => 1
		result_label.grid :column => 0, :row => 2
    refresh_button.grid :column => 4, :row => 2

    table.grid :column => 0, :row => 3, :columnspan => 5, :sticky => 'ewns'
    sy.grid :column => 5, :row => 3, :sticky => 'ewns'
    sx.grid :column => 0, :row => 4, :columnspan => 4, :sticky => 'ewns'

		TkGrid.columnconfigure( frame, 4, :weight => 1 )
	end
end


def update_connection_references(selected = nil)
	connections = Connection.all
	connection_arr = Array.new
	connection_hash = {}
	connections.each { |c| 
		connection_arr.push c.name
		connection_hash[c.name] = c
	}

	# Update Workbench
	# TODO: the selected value may be empty or worse wrong
	$workbench.connection_combo.values = connection_arr
  if ! selected.nil?
    $workbench.connection_var = selected.name
  end

	# Update menus
	$menus.construct_connections_menu(connection_hash)
end

def update_job_references(selected = nil)
	jobs = Job.all
	jobs_arr = Array.new
	job_hash = {}
	jobs.each { |j| 
		jobs_arr.push j.name
		job_hash[j.name] = j
	}

	# Update Workbench
	$workbench.job_combo.values = jobs_arr
  if ! selected.nil?
    # TODO: debug - this did not select this
    $workbench.job_var = selected.name
  end

	# Update menus
	$menus.construct_jobs_menu(job_hash)
end

root = TkRoot.new { title "AQuA Workbench" }

$workbench = Workbench.new(root)
$menus = MenuBar.new(root)

update_job_references
update_connection_references

Tk.mainloop


