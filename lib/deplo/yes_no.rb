module Deplo

  def self.yes_no( condition = nil , message: nil , yes: nil , no: nil )
    if message.present?
      puts message
    end
    puts "OK? [Yn]"
    yn = ::STDIN.gets.chomp
    condition ||= false

    case yn.downcase
    when "y"
      condition = true
      if yes.present?
        yes.call
      end
    when "n"
      if no.present?
        no.call
      end
    else
      return __method__( condition , yes: yes , no: no )
    end
    return condition
  end

end
