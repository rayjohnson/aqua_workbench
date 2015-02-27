
class ResultUI
  def initialize(result, f)
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

      # TODO: Add table
      table = TkLabel.new(f) {text "TODO: SHow batch table"}
      result.batches.each do |batch|
        puts "Name #{batch.name}"
        # Name provide link to query?, message?, full?, etc
        puts "Type #{batch.batchType}"
        puts "Rows #{batch.recordCount}"
        puts "Status #{batch.status}"
        puts "Download: #{batch.fileId}"
      end

      name_label.grid :column => 0, :row => 0
      name_value.grid :column => 1, :row => 0
      start_label.grid :column => 3, :row => 0
      start_value.grid :column => 4, :row => 0

      api_label.grid :column => 0, :row => 1
      api_value.grid :column => 1, :row => 1
      format_label.grid :column => 3, :row => 1
      format_value.grid :column => 4, :row => 1

      partner_label.grid :column => 0, :row => 2
      partner_value.grid :column => 1, :row => 2
      project_label.grid :column => 3, :row => 2
      project_value.grid :column => 4, :row => 2

      status_label.grid :column => 3, :row => 3
      status_value.grid :column => 4, :row => 3

      table.grid :column => 1, :row => 4, :columnspan => 4
  end
end
