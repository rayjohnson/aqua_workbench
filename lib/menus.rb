
class MenuBar
  def construct_connections_menu(connection_hash)
    win = @main_win
    @connections_menu.delete(1, 'end')

    if connection_hash.length > 0
      @connections_menu.add :separator
    end
    connection_hash.each do |name, con|
      @connections_menu.add :command, :label => name, :command => proc{ConnectionUI.new(con, win)}
    end
  end

  def construct_jobs_menu(job_hash)
    win = @main_win
    @jobs_menu.delete(2, 'end')

    if job_hash.length > 0
      @jobs_menu.add :separator
    end
    job_hash.each do |name, job|
      @jobs_menu.add :command, :label => name, :command => proc{JobUI.new(job_hash[name], win)}
    end
  end

  def initialize(win)
    @main_win = win

    menubar = TkMenu.new(win)
    win['menu'] = menubar

    # TODO: special menus
    # DEBUG - this doesn't replace the ruby menu like I was hoping it would...
    apple = TkSysMenu_Apple.new(menubar)
    apple.add :command, :label => "About...", :command => proc{aboutDialog}
    menubar.add :cascade, :menu => apple, :label => "AQuA workbench"
    #help = TkSysMenu_Help.new(menubar)
    #menubar.add :cascade, :menu => help
    # TODO: About menu, Help, App->Quit

    @connections_menu = TkMenu.new(menubar)
    @connections_menu.add :command, :label => 'New Connection...', :command => proc{ConnectionUI.new(nil, win)}

    menubar.add :cascade, :menu => @connections_menu, :label => 'Connections'

    @jobs_menu = TkMenu.new(menubar)
    @jobs_menu.add :command, :label => 'New Job...', :command => proc{JobUI.new(nil, win)}
    @jobs_menu.add :command, :label => 'Export...', :command => proc{export_jobs}

    menubar.add :cascade, :menu => @jobs_menu, :label => 'Jobs'
  end

  def aboutDialog
    puts "About me!"
  end

  def export_jobs
    jobs = Job.all
    jobs.each do |job|
      puts "#{job.queries.first.name}"
    end
    #json = jobs.to_yaml(:Indent => 4, :UseHeader => true, :UseVersion => true)
    json = jobs.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})
    puts "hello"
    puts "JSON: #{json}"
    data = JSON.parse(json)
    puts "world"
    yml = YAML::dump(data)
    puts "what?"
    #request = job.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})

    puts "#{yml}"
    puts "ok"
ftypes = [
["Text files", '*txt'],
["Midi files", '*mid'],
["Backup files", '*~'],
["All files", '*']
]

      fname = Tk.getSaveFile('filetypes' => ftypes,'parent'=> $root,
        'initialdir' => "#{Dir.home}/Downloads",
        'initialfile' => "job_export",
        'defaultextension' => ".yaml"
      )

      puts "file name: #{fname}"

  end
end

