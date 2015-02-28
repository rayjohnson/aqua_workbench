
class ResultUI
  def initialize(result, root)
    f = TkToplevel.new(root)
    f['title'] = "Results"
    @toplevel = f

      name_label = TkLabel.new(f) {text "Job Name:"}
      name_value = TkLabel.new(f) {text result.name}

      start_label = TkLabel.new(f) {text "Start Time:"}
      start_value = TkLabel.new(f) {text result.startTime}

      api_label = TkLabel.new(f) {text "Api Version:"}
      api_value = TkLabel.new(f) {text result.version}

      format_label = TkLabel.new(f) {text "Format:"}
      format_value = TkLabel.new(f) {text result.format}

      partner_label = TkLabel.new(f) {text "Partner:"}
      partner_value = TkLabel.new(f) {text result.partner}

      project_label = TkLabel.new(f) {text "Project:"}
      project_value = TkLabel.new(f) {text result.project}

      status_label = TkLabel.new(f) {text "Status:"}
      status_value = TkLabel.new(f) {text result.status}
      # TODO: encrypted?, result_id?

      @batch_array  = TkVariable.new_hash
      table = Tk::TkTable.new(f)
      table.configure(:cols=>5,
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

      a = @batch_array
      a[0,0] = "Name"
      a[0,1] = "Batch Type"
      a[0,2] = "Rows"
      a[0,3] = "Status"
      a[0,4] = "Download"

      row = 1
      result.batches.each do |batch|
        # Name provide link to query?, message?, full?, etc
        a[row,0] = batch.name
        a[row,1] = batch.batchType
        a[row,2] = batch.recordCount
        a[row,3] = batch.status
        a[row,4] = "Download"
        a[row,5] = batch.id
        row = row + 1
      end
      table.variable(@batch_array)
      table.rows = row

      table.bind('Double-Button-1', proc{|w, x, y|
             table_click(w, x, y)
             }, '%W %x %y')

      name_label.grid :column => 0, :row => 0, :sticky => 'e'
      name_value.grid :column => 1, :row => 0, :sticky => 'w'
      start_label.grid :column => 3, :row => 0, :sticky => 'e'
      start_value.grid :column => 4, :row => 0, :sticky => 'w'

      api_label.grid :column => 0, :row => 1, :sticky => 'e'
      api_value.grid :column => 1, :row => 1, :sticky => 'w'
      format_label.grid :column => 3, :row => 1, :sticky => 'e'
      format_value.grid :column => 4, :row => 1, :sticky => 'w'

      partner_label.grid :column => 0, :row => 2, :sticky => 'e'
      partner_value.grid :column => 1, :row => 2, :sticky => 'w'
      project_label.grid :column => 3, :row => 2, :sticky => 'e'
      project_value.grid :column => 4, :row => 2, :sticky => 'w'

      status_label.grid :column => 3, :row => 3, :sticky => 'e'
      status_value.grid :column => 4, :row => 3, :sticky => 'w'

      table.grid :column => 0, :row => 4, :columnspan => 5, :sticky => 'ewns'
  end


  def table_click(w, x, y)
      rc = w.index(TkComm._at(x,y))
      row = rc.split(",")[0]

      id = @batch_array[row, 5]
      puts "ID: #{id}"
      batch = Batch.where(:id => id).first

      download_query_results(batch)
      return
      # Go do the rest stuff
      # TODO: got get file
      # choose location or Downloads file, or what?
ftypes = [
["Text files", '*txt'],
["Midi files", '*mid'],
["Backup files", '*~'],
["All files", '*']
]

      fname = Tk.getSaveFile('filetypes' => ftypes,'parent'=> @toplevel,
'initialdir' => "Downloads",
'initialfile' => "some file name",
'defaultextension' => ".csv"
)
  end
  
end
