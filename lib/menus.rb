
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
    @jobs_menu.delete(1, 'end')

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
    #apple = TkSysMenu_Apple.new(menubar)
    #menubar.add :cascade, :menu => apple
    #help = TkSysMenu_Help.new(menubar)
    #menubar.add :cascade, :menu => help
    # TODO: About menu, Help, App->Quit

    @connections_menu = TkMenu.new(menubar)
    @connections_menu.add :command, :label => 'New Connection...', :command => proc{ConnectionUI.new(nil, win)}

    menubar.add :cascade, :menu => @connections_menu, :label => 'Connections'

    @jobs_menu = TkMenu.new(menubar)
    @jobs_menu.add :command, :label => 'New Job...', :command => proc{JobUI.new(nil, win)}

    menubar.add :cascade, :menu => @jobs_menu, :label => 'Jobs'
  end
end

