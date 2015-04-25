module Deployer

  def self.yes_no( condition = nil , message: nil , yes: nil , no: nil )
    if message.present?
      puts message
    end
    puts "OK? [Yn]"
    yn = ::STDIN.gets.chomp
    condition ||= false

    if yn.downcase == "y"
      condition = true
      if yes.present?
        yes.call
      end
    elsif yn.downcase == "n"
      if no.present?
        no.call
      end
    else
      yes_no( condition , yes: yes , no: no )
    end
    return condition
  end

end