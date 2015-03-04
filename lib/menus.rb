
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
    @jobs_menu.delete(4, 'end')

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
    @jobs_menu.add :command, :label => 'Import...', :command => proc{import_jobs}
    @jobs_menu.add :command, :label => 'Export...', :command => proc{export_jobs}
    @jobs_menu.add :command, :label => 'Clear all jobs', :command => proc{clear_jobs}

    menubar.add :cascade, :menu => @jobs_menu, :label => 'Jobs'
  end

  def aboutDialog
    puts "About me!"
  end

  def clear_jobs
    Job.all.each do |job|
      job.queries.each do |query|
        query.delete
      end
      job.delete
    end
    update_job_references
  end

  def import_jobs
    ftypes = [["Yaml files", '*.yml']]
    file_path = Tk.getOpenFile('filetypes' => ftypes)
    if file_path.empty?
      return
    end
    data = YAML.load_file(file_path)
    data['jobs'].each do |job_data|
      q_arr = job_data['queries']
      job = Job.new(job_data.tap {|hs| hs.delete('queries')})
      job.save
      q_arr.each do |query_data|
        query = Query.new(query_data)
        job.add_query(query)
        query.save
      end
    end
    update_job_references
  end

  def export_jobs
    fname = Tk.getSaveFile('initialdir' => "#{Dir.home}/Downloads",
      'initialfile' => "job_export",
      'defaultextension' => ".yml"
    )
    if fname.empty?
      return
    end

    jobs = Job.all
    
    data=[]
    jobs.each do |job|
      json = job.to_json(:except=>:id, :include=>{:queries=>{:except=>[:id, :job_id]}})
      data << JSON.parse(json)
    end

    yml = YAML::dump({"jobs" => data})
    #request = job.to_json(:except=>[:id, :name], :include=>{:queries=>{:except=>[:id, :job_id]}})



      #fname = Tk.getSaveFile('filetypes' => ftypes,'parent'=> $root,


    puts "file name: #{fname}"
    File.write(fname, yml)
  end
end

