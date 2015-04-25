module Deployer

  def self.display_file_info_to_check( filename_to_check , *contents )
    puts "-" * 64
    puts ""
    puts filename_to_check
    puts ""
    if contents.present?
      contents.each do | str |
        puts " " * 4 + str
      end
      puts ""
    end
  end

end