
require 'tk'
require 'sqlite3'
require 'sequel'

require './lib/db'
require './lib/connection'
require './lib/job'

class EnvironmentFrame
	def create(root)
		frame = TkFrame.new(root) {
			pack(:side => 'top')
		}
		TkLabel.new(frame) {
			text "Select Environment:"
			pack('padx' => 10, 'pady' => 10, :side => 'left')
		}

		$config_selection = TkVariable.new
		$config_combo = Tk::Tile::Combobox.new(frame) { 
			textvariable $config_selection 
			pack('padx' => 10, 'pady' => 10, :side => 'left')
		}
		update_config_menu
	end
end

def update_config_menu
	aqua_configs = Connection.all
	config_names = Array.new
	aqua_configs.each { |c| 
		config_names.push c.config_name
	}
	$config_combo.values = config_names
end



def create_menus(win)
	menubar = TkMenu.new(win)
	win['menu'] = menubar

	file = TkMenu.new(menubar)
	menubar.add :cascade, :menu => file, :label => 'Configure'

	file.add :command, :label => 'New Connection...', :command => proc{newAquaConfig(win)}
	file.add :command, :label => 'New Job...', :command => proc{JobUI.new(nil, win)}
end


root = TkRoot.new { title "AQuA Workbench" }
create_menus(root)

envf = EnvironmentFrame.new
envf.create(root)

TkLabel.new(root) do
   text 'Query:'
   pack { padx 15 ; pady 15; side 'top' }
end

$joblist = TkVariable.new

def update_job_list
	jobs = Job.all
	tcl_str = ""
	$job_name_arr = []
	jobs.each do |job|
		tcl_str << "{#{job.name}} "
		$job_name_arr << job.name
	end
	$joblist.value = tcl_str
end

update_job_list
$job_listbox = TkListbox.new(root) do
	listvariable $joblist
	pack { padx 15 ; pady 15; side 'top' }
end
$job_listbox.bind 'Double-1', proc{
    idx = $job_listbox.curselection
    if idx.length==1
        idx = idx[0]    
        #$job_listbox.see idx
        puts $job_name_arr[idx]
        job = Job.where(:name => $job_name_arr[idx]).first
        puts "Obj: #{job.name}"
        JobUI.new(job, root)
    end
}

Tk.mainloop


