
require 'tk'
require 'tkextlib/tktable'
require 'sqlite3'
require 'sequel'

require './lib/db'
require './lib/connection'
require './lib/menus'
require './lib/result'
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

		refresh_frame = TkFrame.new(frame)
		result_label =TkLabel.new(refresh_frame) {text "Results:" }
		result_label.pack(:side => 'left')
    	refresh_button = TkButton.new(refresh_frame) { text "Refresh" }
    	refresh_button.command {check_results}
		refresh_button.pack(:side => 'right')

#TODO: make hyper link - font with underline perhaps, code for double click?
# pathName tag configure -font
#courier = TkFont.new(:family=>'Courier', :size=>10)
#table.tag_configure('s', :font=>courier, :justify=>:center)

		@results_array  = TkVariable.new_hash
		@table = Tk::TkTable.new(:cols=>6,
                        :width=>56, :height=>6,
                        :titlerows=>1,
                        :roworigin=>0, :colorigin=>0,
                        :rowtagcommand=>proc{|row|
                          row = Integer(row)
                          (row>0 && row%2 == 1)? 'OddRow': ''
                        },
                        :selectmode=>:extended,
                        :colstretchmode=>:all,
                        :state=>:disabled,
                        :bd=>1, :highlightthickness=>0,
                        :selecttype => :row)
		sx = @table.xscrollbar(TkScrollbar.new)
		sy = @table.yscrollbar(TkScrollbar.new)
		@table.tag_configure('link', :fg=>'blue')
		@table.tag_col('link', "5")
		@table.variable(@results_array)
		update_results_table

		@table.bind('Double-Button-1', proc{|w, x, y|
             table_click(w, x, y)
             }, '%W %x %y')

		connection_label.grid :column => 0, :row => 0
		@connection_combo.grid :column => 0, :row => 1
		job_label.grid :column => 1, :row => 0
		@job_combo.grid :column => 1, :row => 1
		run_button.grid :column => 2, :row => 1
		refresh_frame.grid :column => 0, :row => 2, :columnspan => 5

	    @table.grid :column => 0, :row => 3, :columnspan => 5, :sticky => 'ewns'
	    sy.grid :column => 5, :row => 3, :sticky => 'ewns'
	    sx.grid :column => 0, :row => 4, :columnspan => 5, :sticky => 'ewns'

		TkGrid.columnconfigure( frame, 4, :weight => 1 )
	end

	def table_click(w, x, y)
    	rc = w.index(TkComm._at(x,y))
    	row = rc.split(",")[0]

    	#puts "Mouseer: #{rc}"
    	#name = @results_array[row, 0]
    	#puts "Job Name: #{name}"
    	id = @results_array[row, 6]
    	puts "ID: #{id}"

    	result = Result.where(:id=>id).first
    	puts "Name #{result.name}"
    	ResultUI.new(result, $root)
	end
end


def update_results_table
	results = Result.all
	ary = @results_array

	puts "Results: #{results.length}"
	rows = results.length + 1
	cols = 5

	ary[0,0] = "Job Name"
	ary[0,1] = "Connection"
	ary[0,2] = "Start Time"
	ary[0,3] = "Partner"
	ary[0,4] = "Project"
	ary[0,5] = "Status"

	row = 1
	results.each do |result|
		ary[row,0] = result.name
		ary[row,1] = Connection.where(:id=>result.connection_id).first.name
		ary[row,2] = result.startTime
		ary[row,3] = result.partner
		ary[row,4] = result.project
		ary[row,5] = result.status
		ary[row,6] = result.id
		row = row + 1
	end
	if rows < 6
	  rows = 6
	end

	# TODO: should I sent numb of columns?
	#@table
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

$root = TkRoot.new { title "AQuA Workbench" }

$workbench = Workbench.new($root)
$menus = MenuBar.new($root)

update_job_references
update_connection_references

Tk.mainloop


